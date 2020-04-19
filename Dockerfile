ARG STEP_1_IMAGE=golang:1.14.1-alpine3.11
ARG STEP_2_IMAGE=alpine:3.11

FROM ${STEP_1_IMAGE} AS STEP_1

ARG TERRAFORM_VERSION=0.12.20

ENV BUILD_PACKAGES \
    bash \
    curl \
    tar \
    openssh-client \
    sshpass \
    git

RUN set -x \
 && apk update \
 && apk upgrade \
 && apk add --no-cache ${BUILD_PACKAGES}

# Terraform
ENV TF_DEV=true
ENV TF_RELEASE=true

WORKDIR $GOPATH/src/github.com/hashicorp/terraform
RUN git clone https://github.com/hashicorp/terraform.git ./ \
 && git checkout v${TERRAFORM_VERSION} \
 && /bin/bash scripts/build.sh

FROM ${STEP_2_IMAGE} AS STEP_2

LABEL Name="bryan-nice/docker-terrraform-azure" \
      Version="1.0.0"

# Copy from Step 1
COPY --from=STEP_1 /go/bin/terraform /usr/bin/terraform

ENV BASE_PACKAGES \
    gettext \
    git \
    bash \
    curl \
    make \
    ncurses \
    tar \
    openssh-client \
    sshpass \
    py-pip \
    python3

RUN apk --update add --virtual build-dependencies \
    gcc \
    musl-dev \
    libffi-dev \
    openssl-dev \
    python3-dev

RUN set -x \
 && apk update && apk upgrade \
 && apk add --no-cache ${BASE_PACKAGES} \
 && python3 -m pip install --upgrade pip \
 && python3 -m pip install \
        azure-cli \
 && apk del build-dependencies \
 && rm -rf /var/cache/apk/* \
 && rm /usr/bin/python \
 && ln -s /usr/bin/python3 /usr/bin/python

# Create Terraform User
RUN addgroup -S terraform && adduser -S terraform -G terraform

USER terraform

WORKDIR /home/terraform
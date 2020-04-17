ARG BASE_IMAGE=golang:1.14.1-alpine3.11

FROM ${BASE_IMAGE} AS BUILD

ENV REFRESHED_AT=2019-11-13

LABEL Name="bryan-nice/docker-terrraform-azure" \
      Version="1.0.0"

ARG TERRAFORM_VERSION=0.12.20

ENV BUILD_PACKAGES \
    wget \
    build-base \
    tar \
    git \
    ncurses \
    make \
    graphviz \
    tree \
    gettext \
    bash \
    openssh-client \
    sshpass \
    libffi-dev \
    openssl-dev \
    py-pip \
    python3 \
    python3-dev

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

# Install azure cli
RUN pip3 install \
        azure-cli

# Create Terraform User
RUN addgroup -S terraform && adduser -S terraform -G terraform

USER terraform

WORKDIR /home/terraform
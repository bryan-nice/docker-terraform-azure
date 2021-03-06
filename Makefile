# -----------------------------------------------------------------------------
# Docker Terraform Azure
# -----------------------------------------------------------------------------

# -----------------------------------------------------------------------------
# Internal Variables
# -----------------------------------------------------------------------------

BOLD :=$(shell tput bold)
RED :=$(shell tput setaf 1)
GREEN :=$(shell tput setaf 2)
YELLOW :=$(shell tput setaf 3)
RESET :=$(shell tput sgr0)

# -----------------------------------------------------------------------------
# Git Variables
# -----------------------------------------------------------------------------

GIT_BRANCH := $(shell git rev-parse --abbrev-ref HEAD)
GIT_REPOSITORY_NAME := $(shell git config --get remote.origin.url | rev | cut -d"." -f2 | cut -d"/" -f1 | rev )
GIT_ACCOUNT_NAME := $(shell git config --get remote.origin.url | rev | cut -d"." -f2 | cut -d"/" -f2 | cut -d":" -f1 | rev)
GIT_SHA := $(shell git log --pretty=format:'%H' -n 1)
GIT_TAG ?= $(shell git describe --always --tags | awk -F "-" '{print $$1}')
GIT_TAG_END ?= HEAD
GIT_VERSION := $(shell git describe --always --tags --long --dirty | sed -e 's/\-0//' -e 's/\-g.......//')
GIT_VERSION_LONG := $(shell git describe --always --tags --long --dirty)

# -----------------------------------------------------------------------------
# Docker Variables
# -----------------------------------------------------------------------------

STEP_1_IMAGE ?= golang:1.15.8-alpine3.13
STEP_2_IMAGE ?= alpine:3.13
DOCKER_IMAGE_PACKAGE := $(GIT_REPOSITORY_NAME)-package:$(GIT_VERSION)
DOCKER_IMAGE_TAG ?= $(GIT_REPOSITORY_NAME):$(GIT_VERSION)
DOCKER_IMAGE_NAME := $(GIT_REPOSITORY_NAME)

# -----------------------------------------------------------------------------
# Terraform Varibles
# -----------------------------------------------------------------------------

TERRAFORM_VERSION ?= 0.14.6

# -----------------------------------------------------------------------------
# FUNCTIONS
# -----------------------------------------------------------------------------



# -----------------------------------------------------------------------------
# Docker-based builds
# -----------------------------------------------------------------------------

.PHONY: docker-build
docker-build: docker-rmi-for-build
	@echo "$(BOLD)$(YELLOW)Building docker image.$(RESET)"
	@docker build \
		--build-arg STEP_1_IMAGE=$(STEP_1_IMAGE) \
		--build-arg STEP_2_IMAGE=$(STEP_2_IMAGE) \
		--build-arg TERRAFORM_VERSION=$(TERRAFORM_VERSION) \
		--tag $(DOCKER_IMAGE_NAME) \
		--tag $(DOCKER_IMAGE_NAME):$(GIT_VERSION) \
		.
	@echo "$(BOLD)$(GREEN)Completed building docker image.$(RESET)"

.PHONY: docker-build-development-cache
docker-build-development-cache: docker-rmi-for-build-development-cache
	@echo "$(BOLD)$(YELLOW)Building docker image.$(RESET)"
	@docker build \
		--build-arg STEP_1_IMAGE=$(STEP_1_IMAGE) \
		--build-arg STEP_2_IMAGE=$(STEP_2_IMAGE) \
		--build-arg TERRAFORM_VERSION=$(TERRAFORM_VERSION) \
		--tag $(DOCKER_IMAGE_TAG) \
		.
	@echo "$(BOLD)$(GREEN)Completed building docker image.$(RESET)"

# -----------------------------------------------------------------------------
# Clean up targets
# -----------------------------------------------------------------------------

.PHONY: docker-rmi-for-build
docker-rmi-for-build:
	-docker rmi --force \
		$(DOCKER_IMAGE_NAME):$(GIT_VERSION) \
		$(DOCKER_IMAGE_NAME)

.PHONY: docker-rmi-for-build-development-cache
docker-rmi-for-build-development-cache:
	-docker rmi --force $(DOCKER_IMAGE_TAG)

.PHONY: docker-rmi-for-package
docker-rmi-for-packagae:
	-docker rmi --force $(DOCKER_IMAGE_PACKAGE)


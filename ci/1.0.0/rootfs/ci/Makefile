# NPM_TOKEN must be set
# AWS_ACCOUNT_ID or PRIVATE_REGISTRY must be set
# SLACK_DEV_WEBHOOK_URL can be set optionally for deployment
# notifications
SHELL = /bin/bash

ifndef AWS_ACCESS_KEY_ID
$(error "AWS_ACCOUNT_ID is not set")
endif
ifndef AWS_SECRET_ACCESS_KEY
$(error "AWS_SECRET_ACCESS_KEY is not set")
endif
ifndef SLACK_DEV_WEBHOOK_URL
$(warning "(warning) SLACK_DEV_WEBHOOK_URL variable is not set")
endif
ifndef NPM_TOKEN
$(warning "(warning) NPM_TOKEN variable is not set")
endif

ENVIRONMENT ?= staging
AWS_ACCOUNT_ID ?= 362178051443
REPO_PATH ?= /ci/repo

KOPS_STATE_STORE ?= 's3://binded-kops-$(ENVIRONMENT)'
CLUSTER_NAME ?= '$(ENVIRONMENT).b1nded.com'

PROJECT_REPONAME ?= $(shell ./scripts/git-repo-name $(REPO_PATH))
IMAGE_PREFIX ?=
MUTABLE_VERSION ?= $(ENVIRONMENT)
VERSION ?= git-$(shell cd $(REPO_PATH) && git rev-parse --short HEAD)
PRIVATE_REGISTRY ?= ${AWS_ACCOUNT_ID}.dkr.ecr.us-west-1.amazonaws.com

# TODO: build and use repo/Dockerfile.build if it exists?
BUILDER_IMAGE ?= binded/node-build:7.10.0
# TODO: build and use repo/Dockerfile if it exists?
RUNTIME_IMAGE ?= binded/node:7.10.0

SHORT_NAME:= ${PROJECT_REPONAME}
IMAGE := ${PRIVATE_REGISTRY}/${IMAGE_PREFIX}${SHORT_NAME}:${VERSION}
MUTABLE_IMAGE := ${PRIVATE_REGISTRY}/${IMAGE_PREFIX}${SHORT_NAME}:${MUTABLE_VERSION}

DOCKERFILE_RUNTIME := ${REPO_PATH}/Dockerfile
DOCKERFILE_BUILD := ${REPO_PATH}/Dockerfile.build

ifdef DEPLOY_MUTABLE
DEPLOY_IMAGE := $(MUTABLE_IMAGE)
else
DEPLOY_IMAGE := $(IMAGE)
endif

info:
	@echo "Build tag:       ${VERSION}"
	@echo "Immutable image: ${IMAGE}"
	@echo "Mutable image:   ${MUTABLE_IMAGE}"
	@echo "Short name:      ${SHORT_NAME}"

build: docker-build
push: docker-push
release: docker-push-mutable

.PHONY: run
run:
	docker run -d -p 5000:5000 $(IMAGE)

.PHONY: run-interactive
run-interactive:
	docker run -it $(IMAGE) bash

.PHONY: run-test
# TODO: detect test command instead of hard coding "make test"?
run-test:
	cd $(REPO_PATH) && make test

.PHONY: test
test: docker-build run-test

$(DOCKERFILE_BUILD):
	@echo "FROM $(BUILDER_IMAGE)" > $(DOCKERFILE_BUILD)
	@echo "COPY . /app" >> $(DOCKERFILE_BUILD)
	@echo "RUN make build" >> $(DOCKERFILE_BUILD)

$(DOCKERFILE_RUNTIME):
	@echo "FROM $(RUNTIME_IMAGE)" > $(DOCKERFILE_RUNTIME)
	@echo "COPY . /app" >> $(DOCKERFILE_RUNTIME)

.PHONY: docker-build
docker-build: $(DOCKERFILE_BUILD) $(DOCKERFILE_RUNTIME)
	# TODO: pass all env variables to build-arg?
	cat $(DOCKERFILE_BUILD)
	docker build \
		--rm \
		-t build-img \
		-f $(DOCKERFILE_BUILD) \
		--build-arg NPM_TOKEN \
		$(REPO_PATH)
	docker create --name build-cont build-img
	# TODO: remove container ? clean up? more specific build image/container names to avoid conflicts
	docker cp build-cont:/out /ci/out
	docker build \
		--rm \
		-t $(IMAGE) \
		/ci/out
	docker tag $(IMAGE) $(SHORT_NAME):test

.PHONY: docker-push
docker-push:
	docker push $(IMAGE)

.PHONY: docker-push-mutable
docker-push-mutable:
	docker tag $(IMAGE) $(MUTABLE_IMAGE)
	docker push $(MUTABLE_IMAGE)

.PHONY: auth
auth:
	kops export --name $(CLUSTER_NAME) --state $(KOPS_STATE_STORE) kubecfg
	@make registry-login

.PHONY: registry-login
registry-login:
	$(shell aws ecr get-login --region us-west-1)

.PHONY: deploy-registry-secret
deploy-registry-secret:
	curl https://raw.githubusercontent.com/binded/scripts/master/update-k8s-registry-secret.sh | bash

# switch kubectl context based on environment
.PHONY: deploy-context
kubectl-context:
	kubectl config use-context $(CLUSTER_NAME)

.PHONY: deploy
deploy: deploy-registry-secret kubectl-context
	helm init
	helm dependency update ./deploy
	@helm upgrade -i \
		-f "${REPO_PATH}/deploy/${ENVIRONMENT}.yaml" \
		--set "image=${DEPLOY_IMAGE}" \
		# TODO: generate all --set commands based on env variables
		# --set "$(shell ./deploy/getenv "instagram.clientSecret")"
		"$(SHORT_NAME)" "${REPO_PATH}/deploy"
	curl https://raw.githubusercontent.com/binded/scripts/master/deploy-notification.sh \
		| bash -s "${DEPLOY_IMAGE}" "${ENVIRONMENT}"

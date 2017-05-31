# NPM_TOKEN must be set
# AWS_ACCOUNT_ID or PRIVATE_REGISTRY must be set
# SLACK_DEV_WEBHOOK_URL can be set optionally for deployment
# notifications
SHELL = /bin/bash

ifndef AWS_ACCESS_KEY_ID
$(error "AWS_ACCESS_KEY_ID is not set")
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

AWS_ACCOUNT_ID ?= 362178051443
REPO_PATH ?= /ci/repo
ENVIRONMENT ?= $(shell ./scripts/guess-environment $(REPO_PATH))

KOPS_STATE_STORE ?= 's3://binded-kops-$(ENVIRONMENT)'
CLUSTER_NAME ?= '$(ENVIRONMENT).b1nded.com'

PROJECT_REPONAME ?= $(shell ./scripts/git-repo-name $(REPO_PATH))
IMAGE_PREFIX ?=
MUTABLE_VERSION ?= $(ENVIRONMENT)
VERSION ?= git-$(shell cd $(REPO_PATH) && git rev-parse --short HEAD)
PRIVATE_REGISTRY ?= ${AWS_ACCOUNT_ID}.dkr.ecr.us-west-1.amazonaws.com
DEPLOY_PATH ?= ${REPO_PATH}/deploy

# default to Node.js
BUILD_TYPE ?= node
SHORT_NAME:= ${PROJECT_REPONAME}
IMAGE := ${PRIVATE_REGISTRY}/${IMAGE_PREFIX}${SHORT_NAME}:${VERSION}
MUTABLE_IMAGE := ${PRIVATE_REGISTRY}/${IMAGE_PREFIX}${SHORT_NAME}:${MUTABLE_VERSION}
BUILD_IMAGE := ${SHORT_NAME}:build

DOCKERFILE_RUNTIME := ${REPO_PATH}/Dockerfile
DOCKERFILE_BUILD := ${REPO_PATH}/Dockerfile.build

ifdef DEPLOY_MUTABLE
DEPLOY_IMAGE := $(MUTABLE_IMAGE)
else
DEPLOY_IMAGE := $(IMAGE)
endif

all:
	make build
	make run-test
	make push
	make deploy

info:
	@echo "Environment:     ${ENVIRONMENT}"
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
	docker run --entrypoint /bin/bash -it $(IMAGE)

.PHONY: run-test
# TODO: detect test command instead of hard coding "make test"?
run-test:
	docker run \
		--rm \
		--privileged \
		-v /var/run/docker.sock:/var/run/docker.sock \
		$(BUILD_IMAGE) \
		test

.PHONY: test
test: docker-build run-test

$(DOCKERFILE_BUILD):
	cp /ci/dockerfiles/${BUILD_TYPE}/Dockerfile.build $(DOCKERFILE_BUILD)
	@[[ ! -z "${BASE_IMAGE_BUILDER}" ]] \
		&& sed -i'' 's=^FROM .*=FROM $(BASE_IMAGE_BUILDER)=' $(DOCKERFILE_BUILD) \
		|| true

$(DOCKERFILE_RUNTIME):
	cp /ci/dockerfiles/${BUILD_TYPE}/Dockerfile $(DOCKERFILE_RUNTIME)
	@[[ ! -z "${BASE_IMAGE_RUNTIME}" ]] \
		&& sed -i'' 's=^FROM .*=FROM $(BASE_IMAGE_RUNTIME)=' $(DOCKERFILE_RUNTIME) \
		|| true

.PHONY: docker-build
docker-build: $(DOCKERFILE_BUILD) $(DOCKERFILE_RUNTIME)
	# TODO: pass all env variables to build-arg?
	mkdir -p $(REPO_PATH)/.cache
	docker build \
		--rm \
		-t $(BUILD_IMAGE) \
		-f $(DOCKERFILE_BUILD) \
		--build-arg NPM_TOKEN="${NPM_TOKEN}" \
		$(REPO_PATH)
	make docker-build-runtime

docker-build-runtime:
	docker create --name extract $(BUILD_IMAGE)
	docker cp extract:/out /ci/out 2> /dev/null || \
		docker cp extract:/app /ci/out
	docker rm -f extract
	docker build \
		--rm \
		-t $(IMAGE) \
		/ci/out

.PHONY: docker-push
docker-push: auth
	docker push $(IMAGE)

.PHONY: docker-push-mutable
docker-push-mutable:
	docker tag $(IMAGE) $(MUTABLE_IMAGE)
	docker push $(MUTABLE_IMAGE)

.PHONY: auth
auth:
	@kops export --name $(CLUSTER_NAME) --state $(KOPS_STATE_STORE) kubecfg
	make registry-login

.PHONY: registry-login
registry-login:
	@$(shell aws ecr get-login --region us-west-1)

.PHONY: deploy-registry-secret
deploy-registry-secret:
	curl https://raw.githubusercontent.com/binded/scripts/master/update-k8s-registry-secret.sh | bash

# switch kubectl context based on environment
.PHONY: deploy-context
kubectl-context: auth
	kubectl config use-context $(CLUSTER_NAME)

.PHONY: deploy
deploy: kubectl-context
	helm init
	helm dependency update "${DEPLOY_PATH}"
	# TODO: generate all --set commands based on env variables
	# --set "$(shell ./deploy/getenv "instagram.clientSecret")"
	helm upgrade -i \
		-f "${DEPLOY_PATH}/${ENVIRONMENT}.yaml" \
		--set "image=${DEPLOY_IMAGE}" \
		"${SHORT_NAME}" "${DEPLOY_PATH}"
	curl https://raw.githubusercontent.com/binded/scripts/master/deploy-notification.sh \
		| bash -s "${DEPLOY_IMAGE}" "${ENVIRONMENT}" || true

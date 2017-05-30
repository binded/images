# NPM_TOKEN must be set
# AWS_ACCOUNT_ID or PRIVATE_REGISTRY must be set
# SLACK_DEV_WEBHOOK_URL can be set optionally for deployment
# notifications
SHELL = /bin/bash

ENVIRONMENT ?= staging
AWS_ACCOUNT_ID ?= 362178051443

KOPS_STATE_STORE ?= 's3://binded-kops-$(ENVIRONMENT)'
CLUSTER_NAME ?= '$(ENVIRONMENT).b1nded.com'

CIRCLE_PROJECT_REPONAME ?= $(shell basename "${PWD}")
IMAGE_PREFIX ?=
MUTABLE_VERSION ?= $(ENVIRONMENT)
VERSION ?= git-$(shell git rev-parse --short HEAD)
PRIVATE_REGISTRY ?= ${AWS_ACCOUNT_ID}.dkr.ecr.us-west-1.amazonaws.com
DOCKER_BUILD_RM ?= true

SHORT_NAME:= ${CIRCLE_PROJECT_REPONAME}
IMAGE := ${PRIVATE_REGISTRY}/${IMAGE_PREFIX}${SHORT_NAME}:${VERSION}
MUTABLE_IMAGE := ${PRIVATE_REGISTRY}/${IMAGE_PREFIX}${SHORT_NAME}:${MUTABLE_VERSION}

info:
	@echo "Build tag:       ${VERSION}"
	@echo "Immutable image: ${IMAGE}"
	@echo "Mutable image:   ${MUTABLE_IMAGE}"

build: docker-build
push: docker-push
release: docker-push-mutable

.PHONY: run
run:
	docker run -d -p 5000:5000 ${IMAGE}

.PHONY: run-interactive
run-interactive:
	docker run -it ${IMAGE} bash

.PHONY: run-test
run-test:
	npm run docker:bootstrap
	docker-compose run test

.PHONY: test
test: docker-build run-test

.PHONY: docker-build
docker-build:
	# create empty .node_modules.tar.gz if not exists, otherwise,
	# COPY will fail in Dockerfile
	ls .node_modules.tar.gz || touch .node_modules.tar.gz
	docker build --pull \
		--rm=${DOCKER_BUILD_RM} \
		--build-arg NPM_TOKEN=${NPM_TOKEN} \
		-t ${IMAGE} .
	rm .node_modules.tar.gz
	docker tag ${IMAGE} ${SHORT_NAME}:test

.PHONY: docker-cache-node-modules
# Extracts node_modules from the image so it is cached in subsequent builds
docker-cache-node-modules:
	rm .node_modules.tar.gz || true
	docker create ${IMAGE} > .docker-id
	# -n flag required to make resulting file deterministic
	docker cp `cat .docker-id`:/app/node_modules - \
		| gzip -n > .node_modules.tar.gz.part \
		&& mv .node_modules.tar.gz.part .node_modules.tar.gz
	docker rm -v `cat .docker-id` || true
	rm .docker-id

.PHONY: docker-push
docker-push:
	docker push ${IMAGE}

.PHONY: docker-push-mutable
docker-push-mutable:
	docker tag ${IMAGE} ${MUTABLE_IMAGE}
	docker push ${MUTABLE_IMAGE}

.PHONY: auth
auth:
	kops export --name ${CLUSTER_NAME} --state ${KOPS_STATE_STORE} kubecfg
	make registry-login

.PHONY: registry-login
registry-login:
	$(shell aws ecr get-login --region us-west-1)

deploy-registry-secret:
	curl https://raw.githubusercontent.com/binded/scripts/master/update-k8s-registry-secret.sh | bash

ifdef DEPLOY_MUTABLE
DEPLOY_IMAGE := $(MUTABLE_IMAGE)
else
DEPLOY_IMAGE := $(IMAGE)
endif

# switch kubectl context based on environment
kubectl-context:
	kubectl config use-context $(CLUSTER_NAME)

.PHONY: deploy
deploy: deploy-registry-secret kubectl-context
	helm init
	helm dependency update ./deploy
	@helm upgrade -i \
		-f "./deploy/${ENVIRONMENT}.yaml" \
		--set "image=${DEPLOY_IMAGE}" \
		--set "$(shell ./deploy/getenv "instagram.clientId")" \
		--set "$(shell ./deploy/getenv "instagram.clientSecret")" \
		"${SHORT_NAME}" ./deploy
	curl https://raw.githubusercontent.com/binded/scripts/master/deploy-notification.sh \
		| bash -s "${DEPLOY_IMAGE}" "${ENVIRONMENT}"

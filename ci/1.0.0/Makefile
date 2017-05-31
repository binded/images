IMAGE := "binded-ci"

TEST_APP := $(PWD)/../../../test-app

DOCKER_RUN_BASE = docker run \
	--rm \
	--privileged \
	-v /var/run/docker.sock:/var/run/docker.sock \
	-v $(TEST_APP):/ci/repo \
	-v $(PWD)/rootfs/ci/Makefile:/ci/Makefile \
	--env ENVIRONMENT \
	--env SLACK_DEV_WEBHOOK_URL \
	--env AWS_ACCESS_KEY_ID \
	--env AWS_SECRET_ACCESS_KEY

DOCKER_RUN := $(DOCKER_RUN_BASE) $(IMAGE)

build:
	docker build -t $(IMAGE) .

test-interactive:
	$(DOCKER_RUN_BASE) --rm -it $(IMAGE) /bin/bash

test-info:
	$(DOCKER_RUN) make info

test-debug:
	$(DOCKER_RUN) make build

test-debug1:
	$(DOCKER_RUN) "ls -al repo"
	$(DOCKER_RUN) "cd repo && git remote"

test-dockerfile:
	$(DOCKER_RUN) bash -c "\
	rm /ci/repo/Dockerfile.build || true; \
	rm /ci/repo/Dockerfile || true; \
	make /ci/repo/Dockerfile.build; \
	BASE_IMAGE_RUNTIME=woooot make /ci/repo/Dockerfile; \
	grep 'FROM ' /ci/repo/Dockerfile.build; \
	grep 'FROM ' /ci/repo/Dockerfile"

test-docker:
	$(DOCKER_RUN) docker ps

test-build:
	@rm $(TEST_APP)/Dockerfile || true 2> /dev/null
	@rm $(TEST_APP)/Dockerfile.build || true 2> /dev/null
	$(DOCKER_RUN) make build

test-run:
	$(DOCKER_RUN) make run

test-npm-test:
	$(DOCKER_RUN) docker run --rm test-app:test test

test-run-test:
	$(DOCKER_RUN) make run-test

test-push:
	$(DOCKER_RUN) make push

test-deploy-staging:
	$(DOCKER_RUN) make deploy

test-deploy-prod:
	ENVIRONMENT=prod $(DOCKER_RUN) make deploy

test:
	make test-build
	make test-npm-test
	make test-push
	make test-deploy-staging

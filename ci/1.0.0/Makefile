IMAGE := "binded-ci"

DOCKER_RUN_BASE = docker run \
	--rm \
	--privileged \
	-v /var/run/docker.sock:/var/run/docker.sock \
	-v $(PWD)/../../../test-app:/ci/repo \
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
	$(DOCKER_RUN) "ls -al repo"
	$(DOCKER_RUN) "cd repo && git remote"

test-docker:
	$(DOCKER_RUN) docker ps

test-build:
	$(DOCKER_RUN) make build

test-run:
	$(DOCKER_RUN) make run

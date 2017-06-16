# vim: ft=make
FOLDER := $(shell basename $(CURDIR))
PARENT_FOLDER := $(shell basename $(dir $(CURDIR)))
DOCKER_ORG := binded

IMAGE ?= $(DOCKER_ORG)/$(PARENT_FOLDER):$(FOLDER)

all: test

build:
	docker build \
		--rm=true \
		-t ${IMAGE} .

run-interactive:
	docker run --rm -it --entrypoint /bin/bash ${IMAGE}

push:
	docker push ${IMAGE}

info:
	@echo ${IMAGE}

test: build
	docker run \
		--rm \
		--entrypoint '/bin/bash' \
		"$(IMAGE)" \
		"-c" \
		-- \
		ls -al

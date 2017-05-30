IMAGE := "binded-ci"

DOCKER_RUN := docker run \
	--rm \
	--privileged \
	-v /var/run/docker.sock:/var/run/docker.sock \
	-v $(PWD)/test-app:/ci/repo \
	"$(IMAGE)"

build:
	docker build --pull \
		--rm=true \
		-t ${IMAGE} .

test-info:
	$(DOCKER_RUN) make info

test-docker:
	$(DOCKER_RUN) docker ps

test-app-build:
	$(DOCKER_RUN) ls -al

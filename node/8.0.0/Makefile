BUILD_IMAGE := "binded/node-build:8.0.0"
RUNTIME_IMAGE := "binded/node:8.0.0"

build-runtime:
	docker build \
		--rm=true \
		-t ${RUNTIME_IMAGE} .

build-build:
	docker build \
		--rm=true \
		-f Dockerfile.build \
		-t ${BUILD_IMAGE} .

build: build-runtime build-build

run-interactive-build:
	docker run --rm -it --entrypoint /bin/bash ${BUILD_IMAGE}

push-build:
	docker push ${BUILD_IMAGE}

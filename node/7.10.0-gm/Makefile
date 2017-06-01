BUILD_IMAGE := "binded/node-build:7.10.0-gm"
RUNTIME_IMAGE := "binded/node:7.10.0-gm"

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

run-interactive-runtime:
	docker run --rm -it --entrypoint /bin/bash ${RUNTIME_IMAGE}

push-build:
	docker push ${BUILD_IMAGE}

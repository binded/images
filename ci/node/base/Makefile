include ../../Makefile.inc

test: build
	docker run \
		--rm \
		--entrypoint '/bin/bash' \
		"$(IMAGE)" \
		"-c" \
		-- \
		"source /ci/lib/load-nvm.sh; nvm info"

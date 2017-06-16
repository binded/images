include ../../Makefile.inc

test: build
	docker run \
		--rm \
		--entrypoint '/bin/bash' \
		"$(IMAGE)" \
		"-c" \
		-- \
		nvm info

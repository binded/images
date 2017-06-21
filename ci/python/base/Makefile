include ../../Makefile.inc

test: build
	docker run \
		--rm \
		--entrypoint '/bin/bash' \
		"$(IMAGE)" \
		"-c" \
		-- \
		"python --version; python3 --version; pip --version;"

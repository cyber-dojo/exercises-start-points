
SHORT_SHA := $(shell git rev-parse HEAD | head -c7)
IMAGE_NAME := cyberdojo/exercises-start-points:${SHORT_SHA}

.PHONY: image snyk-container snyk-code

image:
	${PWD}/bin/build_test_tag.sh

snyk-container: image
	snyk container test ${IMAGE_NAME} \
		--sarif \
		--sarif-file-output=snyk.container.scan.json \
        --policy-path=.snyk

snyk-code:
	snyk code test \
		--sarif \
		--sarif-file-output=snyk.code.scan.json \
        --policy-path=.snyk


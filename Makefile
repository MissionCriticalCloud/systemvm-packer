iteration=$(shell date +%-y.%-m.%-d)
channel=unstable
output_dir=packer_output
name=qstack-systemvm

docker_shell := docker run -it --privileged -v ${CURDIR}:/build -w /build --rm systemvm-packer-build /bin/bash

.PHONY: images
images: .buildcontainer
images: SHELL := ${docker_shell}
images:
	./build.sh ${channel} ${iteration}

.PHONY: test
test:
	echo "pass"

.PHONY: deploy
deploy:
	./deploy.sh ${output_dir} ${name} ${channel} ${iteration}

.buildcontainer: SHELL := /bin/bash
.buildcontainer: buildcontainer/Dockerfile
	docker build --tag="systemvm-packer-build" ${CURDIR}/buildcontainer
	touch $@

.PHONY: clean
# Run this recipe with bash
clean: SHELL := /bin/bash
clean:
	rm -rf .buildcontainer
	rm -rf ${output_dir}

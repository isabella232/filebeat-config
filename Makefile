IMAGE := discourse/filebeat-config
TAG := $(shell date -u +%Y%m%d.%H%M%S)

.PHONY: default
default: push
	@printf "${IMAGE}:${TAG} ready\n"

.PHONY: push
push: build
	docker push ${IMAGE}:${TAG}

.PHONY: build
build:
	docker build -t ${IMAGE}:${TAG} .

.PHONY: test
	docker run -it --rm -v /var/docker/shared:/var/docker/shared  -v /var/run:/var/run -v `pwd`:/shared discourse/filebeat-config ruby /shared/generate_filebeat_config.rb


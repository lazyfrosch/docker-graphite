
CONTAINER  := graphite
IMAGE_NAME := docker-graphite

DATA_DIR   := /tmp/docker-data

build:
	docker \
		build \
		--rm --tag=$(IMAGE_NAME) .
	@echo Image tag: ${IMAGE_NAME}

clean:
	docker \
		rmi \
		${IMAGE_NAME}

run:
	docker \
		run \
		--detach \
		--interactive \
		--tty \
		--publish=2003:2003 \
		--publish=7002:7002 \
		--publish=8088:8080 \
		--volume=${DATA_DIR}:/srv \
		--hostname=${CONTAINER} \
		--name=${CONTAINER} \
		$(IMAGE_NAME)

shell:
	docker \
		run \
		--rm \
		--interactive \
		--tty \
		--volume=${DATA_DIR}:/srv \
		--env USE_EXTERNAL_CARBON=true \
		--hostname=${CONTAINER} \
		--name=${CONTAINER} \
		$(IMAGE_NAME) \
		/bin/sh

exec:
	docker \
		exec \
		--interactive \
		--tty \
		${CONTAINER} \
		/bin/sh

remove:
	docker \
		rm \
		${CONTAINER}

stop:
	docker \
		kill ${CONTAINER}

history:
	docker \
		history ${IMAGE_NAME}


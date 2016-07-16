TYPE := graphite
IMAGE_NAME := ${USER}-docker-${TYPE}

build:
	docker build --rm --tag=$(IMAGE_NAME) .

run:
	docker run \
		--detach \
		--interactive \
		--tty \
		--publish=2003:2003 \
		--publish=7002:7002 \
		--publish=8088:8080 \
		--hostname=${USER}-graphite \
		--name=${USER}-${TYPE} \
		$(IMAGE_NAME)

shell:
	docker run \
		--rm \
		--interactive \
		--publish=2003:2003 \
		--publish=7002:7002 \
		--publish=8088:8080 \
		--tty \
		--hostname=${USER}-graphite \
		--name=${USER}-${TYPE} \
		$(IMAGE_NAME)

exec:
	docker exec \
		--interactive \
		--tty \
		${USER}-${TYPE} \
		/bin/sh

stop:
	docker kill \
		${USER}-${TYPE}

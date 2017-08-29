docker-graphite
=================

A Docker container for an complete graphite Stack. Usable in combination with Grafana.

# Status

[![Docker Pulls](https://img.shields.io/docker/pulls/bodsch/docker-graphite.svg?branch)][hub]
[![Image Size](https://images.microbadger.com/badges/image/bodsch/docker-graphite.svg?branch)][microbadger]
[![Build Status](https://travis-ci.org/bodsch/docker-graphite.svg?branch)][travis]

[hub]: https://hub.docker.com/r/bodsch/docker-graphite/
[microbadger]: https://microbadger.com/images/bodsch/docker-graphite
[travis]: https://travis-ci.org/bodsch/docker-graphite


# Build

Your can use the included Makefile.

To build the Container: `make build`

To remove the builded Docker Image: `make clean`

Starts the Container: `make run`

Starts the Container with Login Shell: `make shell`

Entering the Container: `make exec`

Stop (but **not kill**): `make stop`

History `make history`



# Docker Hub

You can find the Container also at  [DockerHub](https://hub.docker.com/r/bodsch/docker-graphite/)

## get

    docker pull bodsch/docker-graphite

## run

    docker run \
      --rm \
      --interactive \
      --tty \
      --publish=2003:2003 \
      --publish=7002:7002 \
      --publish=8088:8080 \
      --volume=/data/docker/graphite:/srv \
      --hostname=graphite \
      --name=graphite \
      bodsch/docker-graphite

Notes:

* Please make sure to specify a hostname, so that internal metrics of carbon are not saved with a temporary hostname

# supported Environment Vars

`DATABASE_TYPE` (default: `sqlite`)

`MYSQL_HOST`

`MYSQL_PORT`

`MYSQL_ROOT_USER` (default: `root`)

`MYSQL_ROOT_PASS`

`MEMCACHE_HOST`

`MEMCACHE_PORT` (default: `11211`)

`DATABASE_GRAPHITE_PASS` (default: `graphite`)

`USE_EXTERNAL_CARBON` (default: `false`)

## Limitations

The Database store only Dashboard and i think, **grafana** are the better Tools for this part.

Conclusion, I do not use the database feature of graphite (sorry, guys).
The `sqlite` database will only created in the `/tmp` directory and not used.

When your using a external carbon-writer (like `go-carbon`) you do not need the internal carbon.
You can disable this part with `USE_EXTERNAL_CARBON`.


# includes
 - graphite-web
 - whisper
 - carbon-cache
 - nginx


# Ports
 - 2003: the Carbon line receiver port (tcp and udp)
 - 7002: the Carbon cache query port
 - 8080: the Graphite-Web port

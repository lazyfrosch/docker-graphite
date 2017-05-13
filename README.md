docker-graphite
=================

A Docker container for an complete graphite Stack. Usable in combination with Grafana.


# Status

[![Docker Pulls](https://img.shields.io/docker/pulls/bodsch/docker-graphite.svg?branch=1705-03)][hub]
[![Image Size](https://images.microbadger.com/badges/image/bodsch/docker-graphite.svg?branch=1705-03)][microbadger]
[![Build Status](https://travis-ci.org/bodsch/docker-graphite.svg?branch=1705-03)][travis]

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
      --publish=2003:2003 \
      --publish=7002:7002 \
      --publish=8088:8080 \
      --tty \
      --hostname=graphite \
      --name=graphite \
      bodsch/docker-graphite


# supported Environment Vars

`DATABASE_TYPE` (default: sqlite)

`MYSQL_HOST`

`MYSQL_PORT`

`MYSQL_ROOT_USER` (default: root)

`MYSQL_ROOT_PASS`

`MEMCACHE_HOST`

`MEMCACHE_PORT` (defaul: 11211)

`DATABASE_GRAPHITE_PASS` (default: graphite)

`USE_EXTERNAL_CARBON` (default: false)


# includes
 - graphite-web
 - whisper
 - carbon-cache
 - nginx


# Ports
 - 2003: the Carbon line receiver port (tcp and udp)
 - 7002: the Carbon cache query port
 - 8080: the Graphite-Web port


docker-graphite
=================

A Docker container for an complete graphite Stack. Usable in combination with Grafana.

# Status

[![Build Status](https://travis-ci.org/bodsch/docker-graphite.svg?branch=master)](https://travis-ci.org/bodsch/docker-graphite)

# Build

Your can use the included Makefile.

To build the Container:
    make build

Starts the Container:
    make run

Starts the Container with Login Shell:
    make shell

Entering the Container:
    make exec

Stop (but **not kill**):
    make stop

History
    make history

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


# includes
 - graphite-web
 - whisper
 - carbon-cache
 - nginx

# Ports
 - 2003: the Carbon line receiver port
 - 7002: the Carbon cache query port
 - 8080: the Graphite-Web port


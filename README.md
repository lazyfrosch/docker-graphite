docker-graphite
=================

A Docker container for an complete graphite Stack. Usable in combination with Grafana.

# Status

[![Build Status](https://travis-ci.org/bodsch/docker-graphite.svg?branch=master)](https://travis-ci.org/bodsch/docker-graphite)

# Build

# Docker Hub

You can find the Container also at  [DockerHub](https://hub.docker.com/r/bodsch/docker-graphite/)

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



FROM alpine:3.6

MAINTAINER Bodo Schulz <bodo@boone-schulz.de>

ENV \
  TERM=xterm \
  BUILD_DATE="2017-11-28" \
  GRAPHITE_VERSION="1.1.0"

# 2003: Carbon line receiver port
# 7002: Carbon cache query port
# 8080: Graphite-Web port
EXPOSE 2003 2003/udp 7002 8080

LABEL \
  version="1711" \
  org.label-schema.build-date=${BUILD_DATE} \
  org.label-schema.name="Graphite Docker Image" \
  org.label-schema.description="Inofficial Graphite Docker Image" \
  org.label-schema.url="https://graphite.readthedocs.io/en/latest/index.html" \
  org.label-schema.vcs-url="https://github.com/bodsch/docker-graphite" \
  org.label-schema.vendor="Bodo Schulz" \
  org.label-schema.version=${GRAPHITE_VERSION} \
  org.label-schema.schema-version="1.0" \
  com.microscaling.docker.dockerfile="/Dockerfile" \
  com.microscaling.license="The Unlicense"

# ---------------------------------------------------------------------------------------

RUN \
  apk update --quiet --no-cache && \
  apk upgrade --quiet --no-cache && \
  apk add --quiet --no-cache --virtual .build-deps \
    build-base git libffi-dev py2-pip python2-dev && \
  apk add --quiet --no-cache \
    cairo mysql-client nginx supervisor python2 py2-cairo py2-parsing py-mysqldb && \
  pip install \
    --quiet --trusted-host http://d.pypi.python.org/simple --upgrade pip && \
  mkdir /src && \
  git clone https://github.com/graphite-project/whisper.git      /src/whisper      && \
  git clone https://github.com/graphite-project/carbon.git       /src/carbon       && \
  git clone https://github.com/graphite-project/graphite-web.git /src/graphite-web && \
  cd /src/graphite-web &&  pip install --quiet --requirement requirements.txt && \
  cd /src/whisper      &&  python -W ignore::UserWarning:distutils.dist setup.py install --quiet > /dev/null && \
  cd /src/carbon       &&  python -W ignore::UserWarning:distutils.dist setup.py install --quiet > /dev/null && \
  cd /src/graphite-web &&  python -W ignore::UserWarning:distutils.dist setup.py install --quiet > /dev/null && \
  mv /opt/graphite/conf/graphite.wsgi.example /opt/graphite/webapp/graphite/graphite_wsgi.py && \
  apk del --quiet .build-deps && \
  rm -rf \
    /src \
    /tmp/* \
    /root/.cache \
    /var/cache/apk/*

COPY rootfs/ /

VOLUME /srv

HEALTHCHECK \
  --interval=5s \
  --timeout=2s \
  --retries=12 \
  CMD curl --silent --fail http://localhost:8080 || exit 1

CMD [ "/init/run.sh" ]

# ---------------------------------------------------------------------------------------

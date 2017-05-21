
FROM alpine:latest

MAINTAINER Bodo Schulz <bodo@boone-schulz.de>

LABEL version="1705-03"

ENV \
  ALPINE_MIRROR="dl-cdn.alpinelinux.org" \
  ALPINE_VERSION="edge" \
  TERM=xterm \
  BUILD_DATE="2017-05-13" \
  GRAPHITE_VERSION="1.1.0" \
  APK_ADD="build-base cairo git libffi-dev mysql-client nginx supervisor pwgen python2 python2-dev py2-pip py2-cairo py2-parsing py-mysqldb" \
  APK_DEL="build-base git libffi-dev python2-dev"

# 2003: Carbon line receiver port
# 7002: Carbon cache query port
# 8080: Graphite-Web port
EXPOSE 2003 2003/udp 7002 8080

LABEL org.label-schema.build-date=${BUILD_DATE} \
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
  echo "http://${ALPINE_MIRROR}/alpine/${ALPINE_VERSION}/main"       > /etc/apk/repositories && \
  echo "http://${ALPINE_MIRROR}/alpine/${ALPINE_VERSION}/community" >> /etc/apk/repositories && \
  apk --quiet --no-cache update && \
  apk --quiet --no-cache upgrade && \
  for apk in ${APK_ADD} ; \
  do \
    apk --quiet --no-cache add ${apk} ; \
  done && \
  pip install \
    --trusted-host http://d.pypi.python.org/simple --upgrade pip && \
  mkdir /src && \
  git clone https://github.com/graphite-project/whisper.git      /src/whisper      && \
  git clone https://github.com/graphite-project/carbon.git       /src/carbon       && \
  git clone https://github.com/graphite-project/graphite-web.git /src/graphite-web && \
  cd /src/graphite-web &&  pip install -r requirements.txt && \
  cd /src/whisper      &&  python setup.py install --quiet && \
  cd /src/carbon       &&  python setup.py install --quiet && \
  cd /src/graphite-web &&  python setup.py install --quiet && \
  mv /opt/graphite/conf/graphite.wsgi.example /opt/graphite/webapp/graphite/graphite_wsgi.py && \
  for apk in ${APK_DEL} ; \
  do \
    apk del --quiet --purge ${apk} ; \
  done && \
  rm -rf \
    /src \
    /tmp/* \
    /var/cache/apk/*

COPY rootfs/ /

VOLUME /srv

CMD [ "/init/run.sh" ]

# ---------------------------------------------------------------------------------------


FROM bodsch/docker-alpine-base:1609-01

MAINTAINER Bodo Schulz <bodo@boone-schulz.de>

LABEL version="1.5.0"

# 2003: Carbon line receiver port
# 7002: Carbon cache query port
# 8080: Graphite-Web port
EXPOSE 2003 7002 8080

# ---------------------------------------------------------------------------------------

RUN \
  apk --quiet --no-cache update && \
  apk --quiet --no-cache upgrade && \
  apk --quiet --no-cache add \
    git \
    nginx \
    python \
    py2-pip \
    py-cairo \
    py-twisted \
    py-gunicorn \
    py-parsing \
    py-mysqldb \
    pwgen \
    mysql-client && \
  pip install \
    --trusted-host http://d.pypi.python.org/simple --upgrade pip && \
  pip install \
    --trusted-host http://d.pypi.python.org/simple  \
    pytz \
    python-memcached==1.57 \
    Django==1.5.12 \
    "django-tagging<0.4" && \
  mkdir /src && \
  git clone https://github.com/graphite-project/whisper.git      /src/whisper      && \
  git clone https://github.com/graphite-project/carbon.git       /src/carbon       && \
  git clone https://github.com/graphite-project/graphite-web.git /src/graphite-web && \
  cd /src/whisper      &&  python setup.py install --quiet && \
  cd /src/carbon       &&  python setup.py install --quiet && \
  cd /src/graphite-web &&  python setup.py install --quiet && \
  mv /opt/graphite/conf/graphite.wsgi.example /opt/graphite/webapp/graphite/graphite_wsgi.py && \
  apk del --purge \
    git && \
  rm -rf \
    /src \
    /tmp/* \
    /var/cache/apk/*

ADD rootfs/ /

CMD [ "/opt/startup.sh" ]

# EOF

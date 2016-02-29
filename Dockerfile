FROM     debian:jessie

MAINTAINER Bodo Schulz <bodo@boone-schulz.de>

LABEL version="0.1.3"

ENV DEBIAN_FRONTEND noninteractive
ENV TERM xterm

# 2003: Carbon line receiver port
# 7002: Carbon cache query port
EXPOSE 2003 7002

# ---------------------------------------------------------------------------------------

RUN \
  apt-get -qq update && \
  apt-get -qqy install \
    ca-certificates \
    wget \
    software-properties-common && \
  apt-get -qqy update && \
  apt-get -qqy upgrade && \
  apt-get -qqy install --no-install-recommends \
    git \
    python-django-tagging \
    python-simplejson \
    python-memcache \
    python-cairo \
    python-pysqlite2 \
    python-support \
    python-pip \
    python-dev \
    supervisor \
    build-essential \
    collectd \
    pip install Django==1.5

# Checkout the stable branches of Graphite, Carbon and Whisper and install from there
RUN \
  mkdir /src \
  git clone https://github.com/graphite-project/whisper.git /src/whisper && \
  git clone https://github.com/graphite-project/carbon.git /src/carbon && \
  git clone https://github.com/graphite-project/graphite-web.git /src/graphite-web && \
  cd /src/whisper && \
  git checkout 0.9.x && \
  python setup.py install && \
  cd /src/carbon && \
  git checkout 0.9.x && \
  python setup.py install && \
  cd /src/graphite-web && \
  git checkout 0.9.x && \
  python setup.py install


#RUN \
#  find /src -type d -name ".git" -exec rm -rf {} \;

ADD rootfs/ /

RUN \
  touch /opt/graphite/storage/graphite.db /opt/graphite/storage/index && \
  chown -R www-data /opt/graphite/storage && \
  chmod 0775 /opt/graphite/storage /opt/graphite/storage/whisper && \
  chmod 0664 /opt/graphite/storage/graphite.db && \
  cd /opt/graphite/webapp/graphite && python manage.py syncdb --noinput


VOLUME ["/var/log/supervisor"]

CMD     []

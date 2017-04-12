#!/bin/sh
#


if [ ${DEBUG} ]
then
  set -x
fi

WORK_DIR="/srv"

DATABASE_TYPE=${DATABASE_TYPE:-sqlite}

MYSQL_HOST=${MYSQL_HOST:-""}
MYSQL_PORT=${MYSQL_PORT:-"3306"}
MYSQL_ROOT_USER=${MYSQL_ROOT_USER:-"root"}
MYSQL_ROOT_PASS=${MYSQL_ROOT_PASS:-""}

MEMCACHE_HOST=${MEMCACHE_HOST:-""}
MEMCACHE_PORT=${MEMCACHE_PORT:-11211}

DATABASE_GRAPHITE_PASS=${DATABASE_GRAPHITE_PASS:-graphite}

USE_EXTERNAL_CARBON=${USE_EXTERNAL_CARBON:-false}

CONFIG_FILE="/opt/graphite/webapp/graphite/local_settings.py"

# -------------------------------------------------------------------------------------------------


prepare() {

  [ -d ${WORK_DIR}/graphite ] || mkdir -p ${WORK_DIR}/graphite

  sed -i \
    "s|%STORAGE_PATH%|${WORK_DIR}|g" \
    /opt/graphite/conf/carbon.conf

  cp -ar /opt/graphite/storage ${WORK_DIR}/graphite/

  chown -R nginx ${WORK_DIR}/graphite/storage

  if [ ! -f ${CONFIG_FILE} ]
  then
    cp ${CONFIG_FILE}-DIST ${CONFIG_FILE}
  fi

  sed -i \
    -e "s|%STORAGE_PATH%|${WORK_DIR}|g" \
    ${CONFIG_FILE}

  if [ ! -z ${MEMCACHE_HOST} ]
  then
    sed -i \
      -e 's|%MEMCACHE_HOST%|'${MEMCACHE_HOST}'|g' \
      -e 's|%MEMCACHE_PORT%|'${MEMCACHE_PORT}'|g' \
      -e 's|# MEMCACHE_HOSTS|MEMCACHE_HOSTS|g' \
      ${CONFIG_FILE}
  fi

  [ -d /var/log/graphite ] || mkdir /var/log/graphite
  chown nginx: /var/log/graphite

  # we will use another carbon service, like go-carbon
  if [ ${USE_EXTERNAL_CARBON} == true ]
  then
    rm -f /etc/supervisor.d/carbon-cache.ini
  fi

}


setup() {

  chown -R nginx ${WORK_DIR}/graphite/storage

  sleep 2s

  PYTHONPATH=/opt/graphite/webapp django-admin.py migrate --verbosity 1 --settings=graphite.settings --noinput
  PYTHONPATH=/opt/graphite/webapp django-admin.py migrate --verbosity 1 --run-syncdb --settings=graphite.settings --noinput
}


startSupervisor() {

  echo -e "\n Starting Supervisor.\n\n"

  if [ -f /etc/supervisord.conf ]
  then
    /usr/bin/supervisord -c /etc/supervisord.conf >> /dev/null
  fi
}

# -------------------------------------------------------------------------------------------------

run() {

  prepare

  . /init/database.sh

  setup

  startSupervisor
}

run

# EOF





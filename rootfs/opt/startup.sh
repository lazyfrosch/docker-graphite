#!/bin/sh
#


if [ ${DEBUG} ]
then
  set -x
fi

WORK_DIR=${WORK_DIR:-/srv}
# WORK_DIR=${WORK_DIR}/graphite

initfile=${WORK_DIR}/graphite/run.init

DATABASE_TYPE=${DATABASE_TYPE:-sqlite}

MYSQL_HOST=${MYSQL_HOST:-""}
MYSQL_PORT=${MYSQL_PORT:-"3306"}
MYSQL_ROOT_USER=${MYSQL_ROOT_USER:-"root"}
MYSQL_ROOT_PASS=${MYSQL_ROOT_PASS:-""}

MEMCACHE_HOST=${MEMCACHE_HOST:-""}
MEMCACHE_PORT=${MEMCACHE_PORT:-11211}

DATABASE_GRAPHITE_PASS=${DATABASE_GRAPHITE_PASS:-graphite}

CONFIG_FILE="/opt/graphite/webapp/graphite/local_settings.py"

# -------------------------------------------------------------------------------------------------

waitForDatabase() {

  # wait for needed database
#  while ! nc -z ${MYSQL_HOST} ${MYSQL_PORT}
#  do
#    sleep 3s
#  done

  # must start initdb and do other jobs well
  echo " [i] wait for database for there initdb and do other jobs well"

  until mysql ${mysql_opts} --execute="select 1 from mysql.user limit 1" > /dev/null
  do
    echo " . "
    sleep 3s
  done

}


prepare() {

  [ -d ${WORK_DIR}/graphite ] || mkdir -p ${WORK_DIR}/graphite

  sed -i 's|^LOCAL_DATA_DIR\ =\ /opt/|LOCAL_DATA_DIR\ =\ '${WORK_DIR}'/|g' /opt/graphite/conf/carbon.conf

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
}

configureDatabase() {

  if [ "${DATABASE_TYPE}" == "sqlite" ]
  then

    if [ -d ${WORK_DIR}/graphite/storage ]
    then
      touch ${WORK_DIR}/graphite/storage/graphite.db
      touch ${WORK_DIR}/graphite/storage/index

      chmod 0664 ${WORK_DIR}/graphite/storage/graphite.db
    fi

    sed -i \
      -e "s|%DBA_FILE%|${WORK_DIR}/graphite/storage/graphite.db|" \
      -e 's|%DBA_ENGINE%|sqlite3|g' \
      -e "s|%DBA_USER%||g" \
      -e "s|%DBA_PASS%||g" \
      -e "s|%DBA_HOST%||g" \
      -e "s|%DBA_PORT%||g" \
      ${CONFIG_FILE}

  elif [ "${DATABASE_TYPE}" == "mysql" ]
  then

      sed -i \
        -e "s/%DBA_FILE%/graphite/" \
        -e "s/%DBA_ENGINE%/mysql/" \
        -e "s/%DBA_USER%/graphite/" \
        -e "s/%DBA_PASS%/${DATABASE_GRAPHITE_PASS}/" \
        -e "s/%DBA_HOST%/${MYSQL_HOST}/" \
        -e "s/%DBA_PORT%/${MYSQL_PORT}/" \
        ${CONFIG_FILE}

    mysql_opts="--host=${MYSQL_HOST} --user=${MYSQL_ROOT_USER} --password=${MYSQL_ROOT_PASS} --port=${MYSQL_PORT}"

    if [ -z ${MYSQL_HOST} ]
    then
      echo " [E] - i found no MYSQL_HOST Parameter for type: '${DATABASE_TYPE}'"
    else

      # wait for needed database
      while ! nc -z ${MYSQL_HOST} ${MYSQL_PORT}
      do
        sleep 3s
      done

      # must start initdb and do other jobs well
      sleep 10s

      waitForDatabase

      (
        echo "--- create user 'graphite'@'%' IDENTIFIED BY '${DATABASE_GRAPHITE_PASS}';"
        echo "CREATE DATABASE IF NOT EXISTS graphite;"
        echo "GRANT SELECT, INSERT, UPDATE, DELETE, DROP, CREATE, CREATE VIEW, ALTER, INDEX, EXECUTE ON graphite.* TO 'graphite'@'%' IDENTIFIED BY '${DATABASE_GRAPHITE_PASS}';"
        echo "FLUSH PRIVILEGES;"
      ) | mysql ${mysql_opts}

    fi
  else
    echo " [E] unsupported Databasetype '${DATABASE_TYPE}'"
    exit 1
  fi

  chown -R nginx ${WORK_DIR}/graphite/storage

  sleep 2s

  cd /opt/graphite/webapp/graphite && python manage.py syncdb --noinput

  touch ${initfile}
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
  configureDatabase

  echo -e "\n"
  echo " ==================================================================="
  echo " Graphite DatabaseUser 'graphite' password set to '${DATABASE_GRAPHITE_PASS}'"
  echo " ==================================================================="
  echo ""

  startSupervisor

}

run

# EOF

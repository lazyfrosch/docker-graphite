#!/bin/bash

. config.rc

if [ $(docker ps -a | grep ${CONTAINER_NAME} | awk '{print $NF}' | wc -l) -gt 0 ]
then
  docker kill ${CONTAINER_NAME} 2> /dev/null
  docker rm   ${CONTAINER_NAME} 2> /dev/null
fi

DATABASE_IP=$(docker inspect --format '{{ .NetworkSettings.IPAddress }}' ${USER}-mysql)

if [ -z ${DATABASE_IP} ] 
then
  echo "No Database Container '${USER}-mysql' running!"
  echo "use sqlite3 for storage"
  DATABASE_TYPE="sqlite"
else
  DATABASE_TYPE="mysql"
  DOCKER_DBA_ROOT_PASS=${DOCKER_DBA_ROOT_PASS:-foo.bar.Z}
  DOCKER_DATA_DIR=${DOCKER_DATA_DIR:-${DATA_DIR}}
fi

# ---------------------------------------------------------------------------------------

docker run \
  --interactive \
  --tty \
  --detach \
  --env DATABASE_GRAPHITE_TYPE=${DATABASE_TYPE} \
  --env DATABASE_GRAPHITE_HOST=${DATABASE_IP} \
  --env DATABASE_GRAPHITE_PORT=3306 \
  --env DATABASE_ROOT_USER=root \
  --env DATABASE_ROOT_PASS=${DOCKER_DBA_ROOT_PASS} \
  --publish=2003:2003 \
  --publish=7002:7002 \
  --publish=8088:8080 \
  --volume=${DOCKER_DATA_DIR}/${TYPE}:/app \
  --hostname=${USER}-${TYPE} \
  --name ${CONTAINER_NAME} \
  ${TAG_NAME}

# ---------------------------------------------------------------------------------------
# EOF




  if [ "${DATABASE_TYPE}" == "sqlite" ]
  then

    . /init/database/sqlite.sh


  elif [ "${DATABASE_TYPE}" == "mysql" ]
  then

    . /init/database/mysql.sh

  else
    echo " [E] unsupported Databasetype '${DATABASE_TYPE}'"
    exit 1
  fi



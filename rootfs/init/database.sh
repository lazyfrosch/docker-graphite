

  if [ "${DATABASE_TYPE}" == "sqlite" ]
  then

    echo " [i] use sqlite backend"
    . /init/database/sqlite.sh

  elif [ "${DATABASE_TYPE}" == "mysql" ]
  then
  
    echo " [i] use mysql backend"
    . /init/database/mysql.sh

  else
    echo " [E] unsupported Databasetype '${DATABASE_TYPE}'"
    exit 1
  fi



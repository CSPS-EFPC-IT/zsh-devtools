#!/bin/zsh

# |----------------------------------------------------------------------------
# | Store a reusabled MySQL authentication credentials to the local filesystem.
# | This allows to run MySQL commands without prompting any credentials.
# |----------------------------------------------------------------------------
function mysql:create_login()
{
  clear_console && print:info "Configuring MySQL authentication credentials..."

  # Set default values.
  DEFAULT_MYSQL_LOGIN_PATH=${CONFIG[mysql.login_path]}
  DEFAULT_DB_HOST=${CONFIG[db.host]}
  DEFAULT_DB_PORT=${CONFIG[db.port]}
  DEFAULT_DB_USER=${CONFIG[db.user]}

  # Ask for login path name.
  read MYSQL_LOGIN_PATH\?"> MySQL login path [ $DEFAULT_MYSQL_LOGIN_PATH ]: "
  if [ -z "$MYSQL_LOGIN_PATH" ]; then; MYSQL_LOGIN_PATH=$DEFAULT_MYSQL_LOGIN_PATH; fi

  # Ask for database host.
  read DB_HOST\?"> Database host [ $DEFAULT_DB_HOST ]: "
  if [ -z "$DB_HOST" ]; then; DB_HOST=$DEFAULT_DB_HOST; fi

  # Ask for database port.
  read DB_PORT\?"> Database port [ $DEFAULT_DB_PORT ]: "
  if [ -z "$DB_PORT" ]; then; DB_PORT=$DEFAULT_DB_PORT; fi

  # Ask for database username.
  read DB_USER\?"> Database username [ $DEFAULT_DB_USER ]: "
  if [ -z "$DB_USER" ]; then; DB_USER=$DEFAULT_DB_USER; fi

  # Setup authentication credentials.
  mysql_config_editor set --login-path=$MYSQL_LOGIN_PATH --host=$DB_HOST --port=$DB_PORT --user=$DB_USER --password

  echo && print:success "Credentials were successfully created for login path $(print:highlight ${MYSQL_LOGIN_PATH})."
}

# |----------------------------------------------------------------------------
# | Verify that provided MySQL login path has valid credentials.
# |----------------------------------------------------------------------------
# | @param [MYSQL_LOGIN_PATH] Name of the login path to resolve. (optional)
# |----------------------------------------------------------------------------
function mysql:test_login()
{
  # Use default MySQL login path if none was passed as argument.
  local MYSQL_LOGIN_PATH="${1:-${CONFIG[mysql.login_path]}}"
  local VALID_MYSQL_CONNECTION

  # Ping MySQL server using the login path provided.
  clear_console && print:info "Establishing connection to MySQL server..."
  VALID_MYSQL_CONNECTION=`mysqladmin --login-path=${MYSQL_LOGIN_PATH} ping 2> /dev/null`

  # If no result was returned, connection could not be established.
  if [ -z $VALID_MYSQL_CONNECTION ]; then
    print:error "Could not authenticate using login path $(print:highlight ${MYSQL_LOGIN_PATH})." && return
  fi

  print:success "MySQL authentication credentials are properly setup for login path $(print:highlight ${MYSQL_LOGIN_PATH})."
}

# |----------------------------------------------------------------------------
# | Verify that a database exists.
# |----------------------------------------------------------------------------
# | @param [DB_NAME] Name of the database to verify existence. (optional)
# |----------------------------------------------------------------------------
function db:exists()
{
  local DB_NAME=$1
  local MYSQL_LOGIN_PATH=${CONFIG[mysql.login_path]}
  local DB_EXISTS

  # If no database name is passed as argument, prompt for one.
  while [[ -z $DB_NAME ]]; do
    read DB_NAME\?"> Enter database name: "
  done

  DB_EXISTS=$(mysql --login-path=$MYSQL_LOGIN_PATH --batch --skip-column-names -e "SHOW DATABASES LIKE '"$DB_NAME"';" | grep "$DB_NAME" > /dev/null; echo "$?")
  if [ $DB_EXISTS -eq 0 ]; then
      echo true
  else
      echo false
  fi
}

# |----------------------------------------------------------------------------
# | Drop a database.
# |----------------------------------------------------------------------------
# | @param [DB_NAME] Name of the database to drop. (optional)
# |----------------------------------------------------------------------------
function db:drop()
{
  local DB_NAME=$1
  local MYSQL_LOGIN_PATH=${CONFIG[mysql.login_path]}
  local DB_DROPPED

  # When no database name is passed as argument, allow user to choose from list.
  if [ -z $DB_NAME ]; then;
    clear_console && print:info "Dropping database..."
    db:choose DB_NAME && confirm "You are about to drop the following database $(print:highlight $DB_NAME)."
    if [[ $CONFIRM = "n" ]]; then; return; fi
  fi

  DB_DROPPED=$(mysqladmin --login-path=$MYSQL_LOGIN_PATH drop $DB_NAME -f --silent >/dev/null 2>&1; echo "$?")

  if [[ $DB_DROPPED -eq 0 ]]; then
    print:success "Database $(print:highlight $DB_NAME) was dropped."
  else
    print:warning "Database $(print:highlight $DB_NAME) could not be dropped as it does not exists."
  fi
}

# |----------------------------------------------------------------------------
# | Create a database.
# |----------------------------------------------------------------------------
# | @param [DB_NAME] Name of the database to create. (optional)
# |----------------------------------------------------------------------------
function db:create()
{
  local DB_NAME=$1
  local MYSQL_LOGIN_PATH=${CONFIG[mysql.login_path]}
  local DB_CREATED

  if [ -z $DB_NAME ]; then;
    clear_console && print:info "Creating database..."
    while [[ -z $DB_NAME ]]; do
      read DB_NAME\?"> Enter database name: "
    done
  fi

  DB_CREATED=$(mysqladmin --login-path=$MYSQL_LOGIN_PATH create $DB_NAME --silent >/dev/null 2>&1; echo "$?")

  if [[ $DB_CREATED -eq 0 ]]; then
    print:success "Database $(print:highlight ${DB_NAME}) was created."
  else
    print:warning "Database $(print:highlight ${DB_NAME}) could not be created. Verify that it does not already exists."
  fi
}

# |----------------------------------------------------------------------------
# | Drop database and recreate it.
# |----------------------------------------------------------------------------
# | @param [DB_NAME] Name of the database to recreate. (optional)
# |----------------------------------------------------------------------------
function db:recreate()
{
  local DB_NAME=$1

  # When no database name is passed as argument, allow user to choose from list.
  if [ -z $DB_NAME ]; then;
    clear_console && print:info "Rereating database..."
    db:choose DB_NAME && confirm "You are about to recreate the following database $(print:highlight $DB_NAME)."
    if [[ $CONFIRM = "n" ]]; then; return; fi
  fi

  db:drop $DB_NAME
  db:create $DB_NAME
}

# |----------------------------------------------------------------------------
# | Dump a database into a dump file.
# |----------------------------------------------------------------------------
# | @param [DB_NAME] Name of the database to dump. (optional)
# | @param [DUMP_NAME] Name of dump file. (optional)
# |----------------------------------------------------------------------------
function db:dump()
{
  local DB_NAME=$1
  local DUMP_FILE=$2
  local DUMP_DIR=${CONFIG[path.mysql_dumps]}
  local DUMP_PATH
  local MYSQL_LOGIN_PATH=${CONFIG[mysql.login_path]}
  local TIMESTAMP=$(get_timestamp)

  # When no database name is passed as argument, allow user to choose from a list.
  if [ -z $DB_NAME ]; then
    clear_console && print:info "Dumping database..."
    db:choose DB_NAME
  fi

  # When no dump file name is passed as argument, ask for one.
  DEFAULT_DUMP_FILE="${DB_NAME}_${TIMESTAMP}.sql"
  if [ -z $DUMP_FILE ]; then
    read DUMP_FILE\?"> Enter dump file name [ $DEFAULT_DUMP_FILE ]: "
    if [ -z $DUMP_FILE ]; then; DUMP_FILE=$DEFAULT_DUMP_FILE; fi
  fi

  # Full absolute path to the dump file.
  DUMP_PATH="$DUMP_DIR/$DUMP_FILE"

  # Confirming information before proceeding.
  confirm "You are about to dump database $(print:highlight $DB_NAME) into $(print:highlight $DUMP_PATH)."
  if [[ $CONFIRM = "n" ]]; then; return; fi

  # Dump database.
  print:info "Creating dump file..."
  mysqldump --login-path=$MYSQL_LOGIN_PATH $DB_NAME > $DUMP_PATH
  print:success "Database dump was completed."
}

# |----------------------------------------------------------------------------
# | Copy a database to another one.
# |----------------------------------------------------------------------------
# | @param [$1] Source database name. (optional)
# | @param [$2] Destination database name. (optional)
# |----------------------------------------------------------------------------
function db:copy()
{
  local DB_SOURCE=$1
  local DB_DEST=$2
  local MYSQL_LOGIN_PATH=${CONFIG[mysql.login_path]}
  local DEFAULT_DB_DEST

  # When no source database is passed as argument, allow user to choose from a list.
  if [ -z $DB_SOURCE ]; then
    clear_console && print:info "Copying database..."
    db:choose DB_SOURCE
  fi

  # When no destination database is passed as argument, ask for one.
  DEFAULT_DB_DEST="${DB_SOURCE}_copy"
  if [ -z $DB_DEST ]; then
    read DB_DEST\?"> Enter destination database name [ $DEFAULT_DB_DEST ]: "
    if [ -z $DB_DEST ]; then; DB_DEST=$DEFAULT_DB_DEST; fi

    # Confirming information before proceeding.
    confirm "You are about to copy database $(print:highlight $DB_SOURCE) to database $(print:highlight $DB_DEST)."
    if [[ $CONFIRM = "n" ]]; then; return; fi
  fi

  # Validate that databases are not the same.
  if [[ $DB_SOURCE = $DB_DEST ]]; then; print:warning "Source database cannot be the same as destination..." && return; fi

  print:info "Copying database..."

  # Drop destination database if it already exists.
  if [[ $(db:exists $DB_DEST) = true ]]; then; db:drop $DB_DEST; fi

  # Create destination database and copy the source database over.
  db:create $DB_DEST
  mysqldump --login-path=$MYSQL_LOGIN_PATH $DB_SOURCE | mysql --login-path=$MYSQL_LOGIN_PATH $DB_DEST
  print:success "Database was copied."
}

# |----------------------------------------------------------------------------
# | List MySQL databases as a choice picker.
# |----------------------------------------------------------------------------
# | @param [$1] Variable to store choice selection in.
# |----------------------------------------------------------------------------
function db:choose()
{
  local MYSQL_LOGIN_PATH="${CONFIG[mysql.login_path]}"
  local DATABASES=(`mysql --login-path=$MYSQL_LOGIN_PATH -s -N -e "SHOW DATABASES"`)
  local DATABASES_FILTERED=()
  local INDEX=0

  if [ -z "$1" ]; then;
    print:warning "A variable must be passed as first argument to $(print:highlight db:choose) in order to store user's selection." && return
  fi

  # Print databases list.
  if [ ${#DATABASES[@]} -ne 0 ]; then
    # Filter out the default MySQL system databases.
    for i in "${DATABASES[@]}"; do
      if [[ ! $i == *"_schema" ]] && [[ ! $i == "mysql" ]] && [[ ! $i == "sys" ]]; then
        DATABASES_FILTERED+=($i)
      fi
    done

    # Prompt and validate database selection.
    print:selection "${DATABASES_FILTERED[@]}"
    while [[ -n ${INDEX//[0-9]/} ]] || [[ $INDEX == 0 ]] || [[ $INDEX == '' ]] || [[ ${DATABASES_FILTERED[($INDEX)]} == '' ]]; do
      read INDEX\?"> Choose a database from the list above (i.e. 1, 2, 3): "
    done

    # Assign user's selection value to variable passed as argument.
    eval "$1=\"${DATABASES_FILTERED[($INDEX)]}\""
  fi
}

# |----------------------------------------------------------------------------
# | List all available MySQL databases.
# |----------------------------------------------------------------------------
function db:list()
{
  local MYSQL_LOGIN_PATH="${CONFIG[mysql.login_path]}"
  local DATABASES=(`mysql --login-path=$MYSQL_LOGIN_PATH -s -N -e "SHOW DATABASES"`)

  clear_console && print:info "MySQL Databases..."
  print:list $DATABASES
}

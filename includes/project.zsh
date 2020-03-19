#!/bin/zsh

# |----------------------------------------------------------------------------
# | Open a project in vscode.
# |----------------------------------------------------------------------------
# | @param [PROJECT_NAME] Name of the project to open. (optional)
# |----------------------------------------------------------------------------
function project:open()
{
  clear_console

  local PROJECT_NAME=$1
  local PROJECT_DIR=${CONFIG[path.projects]}
  local PROJECT_PATH=""

  # If no project was passed as argument, list available choices from project directory.
  if [ -z $PROJECT_NAME ]; then;
    dir:choose PROJECT_PATH $PROJECT_DIR
    PROJECT_NAME=$(basename $PROJECT_PATH)
  else
    PROJECT_PATH="${PROJECT_DIR}/${PROJECT_NAME}"
  fi

  # Open project in vscode.
  code $PROJECT_PATH
}

# |----------------------------------------------------------------------------
# | Delete a project.
# |----------------------------------------------------------------------------
# | @param [PROJECT_NAME] Name of the project to delete. (optional)
# |----------------------------------------------------------------------------
function project:delete()
{
  clear_console && print:info "Deleting project..."

  local PROJECT_NAME=$1
  local PROJECT_DIR=${CONFIG[path.projects]}
  local PROJECT_PATH=""

  # If no project was passed as argument, list available choices from project directory.
  if [ -z $PROJECT_NAME ]; then;
    dir:choose PROJECT_PATH $PROJECT_DIR
    PROJECT_NAME=$(basename $PROJECT_PATH)
  else
    PROJECT_PATH="${PROJECT_DIR}/${PROJECT_NAME}"
  fi

  # If project directory does not exist, exit script.
  if [[ $(dir:exists $PROJECT_PATH) = false ]]; then;
    print:warning "Project directory $(print:highlight $PROJECT_PATH) could not be found." && return
  fi

  echo "You are about to delete the following project $(print:highlight $PROJECT_PATH)"
  read -q "CONFIRM?> Confirm [ y/n ]: "

  if [[ $CONFIRM = "y" ]]; then;
    echo && dir:delete $PROJECT_PATH --force
  fi

  # Drop database associated with the project.
  DB_NAME=${PROJECT_NAME//-/_}
  db:drop $DB_NAME

  print:success "Project directory $(print:highlight ${PROJECT_NAME}) was deleted."
}

# |----------------------------------------------------------------------------
# | Create a new project.
# |----------------------------------------------------------------------------
# | @param [PROJECT_NAME] Name of the project to create. (optional)
# |----------------------------------------------------------------------------
function project:create()
{
  clear_console && print:info "Creating project..."

  local PROJECT_TYPES=("laravel" "craftcms")
  local PROJECT_DIR=${CONFIG[path.projects]}
  local PROJECT_NAME=$1
  local PROJECT_PATH
  local INDEX=0

  # Print project selection list.
  print:selection $PROJECT_TYPES

  # Prompt and validate project selection.
  while [[ -n ${INDEX//[0-9]/} ]] || [[ $INDEX == 0 ]] || [[ $INDEX == '' ]] || [[ ${PROJECT_TYPES[($INDEX)]} == '' ]]; do
    read INDEX\?"> Choose a project type from the list above (i.e. 1, 2, 3): "
  done

  # Prompt project name.
  while [[ -z $PROJECT_NAME ]]; do
    read PROJECT_NAME\?"> Project name: "
  done

  # Replace spaces with dashes.
  PROJECT_NAME="${PROJECT_NAME// /-}"

  # If project directory already exists, exit script.
  PROJECT_PATH="${PROJECT_DIR}/${PROJECT_NAME}"
  if [[ $(dir:exists $PROJECT_PATH) = true ]]; then;
    print:warning "Could not create project, directory $(print:highlight $PROJECT_PATH) already exists."
    print:info "To remove the project you can run the $(print:highlight project:delete) command."
    return
  fi

  # Run appropriate function based on user's selection.
  echo && project:create_${PROJECT_TYPES[($INDEX)]} $PROJECT_NAME

  # Open project in terminal if configured to do so.
  if [[ $CONFIG[project.open_in_terminal] = true ]]; then;
    cd $PROJECT_PATH
  fi

  # Open project in browser if configured to do so.
  if [[ $CONFIG[project.open_in_browser] = true ]]; then;
    x-www-browser "http://$PROJECT_NAME.test" >/dev/null 2>&1;
  fi

  # Open project in code if configured to do so.
  if [[ $CONFIG[project.open_in_vscode] = true ]]; then;
    code $PROJECT_PATH
  fi

  print:success "Project $(print:highlight ${PROJECT_NAME}) was successfully created."
}

# |----------------------------------------------------------------------------
# | Create a new Laravel project.
# |----------------------------------------------------------------------------
function project:create_laravel()
{
  print:info "Creating Laravel Project..."

  local PROJECT_DIR=${CONFIG[path.projects]}
  local PROJECT_NAME=$1
  local PROJECT_PATH=$PROJECT_DIR"/"$PROJECT_NAME
  local DEFAULT_VERSION=${CONFIG[laravel.version]}
  local ENV_FILE="$PROJECT_PATH/.env"

  # Ask for framework version to be used.
  read VERSION\?"> Framework version [ $DEFAULT_VERSION ]: "
  if [ -z "$VERSION" ]; then; VERSION=$DEFAULT_VERSION; fi

  # Use composer install method to create Laravel project.
  composer create-project laravel/laravel="$VERSION.*" $PROJECT_PATH

  # Update .env file with values stored in config.
  print:line && print:info "Updating .env file..."

  sed -i "s/DB_HOST=127.0.0.1/DB_HOST=${CONFIG[db.host]}/g" $ENV_FILE
  sed -i "s/DB_PORT=3306/DB_PORT=${CONFIG[db.port]}/g" $ENV_FILE
  sed -i "s/DB_DATABASE=laravel/DB_DATABASE=${DB_NAME}/g" $ENV_FILE
  sed -i "s/DB_USERNAME=root/DB_USERNAME=${CONFIG[db.user]}/g" $ENV_FILE
  sed -i "s/DB_PASSWORD=/DB_PASSWORD=${CONFIG[db.password]}/g" $ENV_FILE

  # Create database using project name (replace "-" with "_").
  DB_NAME=${PROJECT_NAME//-/_}
  db:create $DB_NAME
}

# |----------------------------------------------------------------------------
# | Create a new CraftCMS project.
# |----------------------------------------------------------------------------
function project:create_craftcms()
{
  print:info "Creating CraftCMS Project..."

  local PROJECT_DIR=${CONFIG[path.projects]}
  local PROJECT_NAME=$1
  local PROJECT_PATH=$PROJECT_DIR"/"$PROJECT_NAME
  local ADMIN_EMAIL=${CONFIG[craftcms.admin_email]}
  local ADMIN_USERNAME=${CONFIG[craftcms.admin_username]}
  local ADMIN_PASSWORD=${CONFIG[craftcms.admin_password]}
  local DB_DRIVER=${CONFIG[db.driver]}
  local DB_HOST=${CONFIG[db.host]}
  local DB_PORT=${CONFIG[db.port]}
  local DB_USER=${CONFIG[db.user]}
  local DB_PASSWORD=${CONFIG[db.password]}
  local SITE_URL
  local DB_NAME

  # Use composer install method to create CraftCMS project.
  composer create-project craftcms/craft $PROJECT_PATH > /dev/null
  cd $PROJECT_PATH

  # Generate site URL using project name.
  SITE_URL="http://${PROJECT_NAME}.test"

  # Create database using project name (replace "-" with "_").
  DB_NAME=${PROJECT_NAME//-/_}
  db:create $DB_NAME

  # Run craft setup/db command.
  print:info "Configuring .env file..."
  ./craft setup/db \
    --interactive=0 \
    --driver="$DB_DRIVER" \
    --server="$DB_HOST" \
    --port="$DB_PORT" \
    --database="$DB_NAME" \
    --user="$DB_USER" \
    --password="$DB_PASSWORD"

  # Run craft install command.
  print:info "Installing CraftCMS..."
  ./craft install \
    --interactive=0 \
    --email="$ADMIN_EMAIL" \
    --username="$ADMIN_USERNAME" \
    --password="$ADMIN_PASSWORD" \
    --siteName="$SITE_NAME" \
    --siteUrl="$SITE_URL" \
    --language="en" > /dev/null
}

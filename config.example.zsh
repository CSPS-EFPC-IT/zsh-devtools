#!/bin/zsh

# Define various configs to be used within scripts and functions.
typeset -A CONFIG

CONFIG=(
  # Default driver used for databases.
  db.driver
    "mysql"

  # Default database host to use when setting up MySQL login path.
  db.host
    "localhost"

  # Default database port to use when setting up MySQL login path.
  db.port
    "3306"

  # Default database user to use when setting up MySQL login path.
  db.user
    "root"

  # Default database password associated with the db user.
  db.password
    ""

  # Default MySQL login path to be used when running db commands.
  # @note: Make sure to set it up using the [mysql:create_login] command before using any scripts.
  mysql.login_path
    "mysql_login"

  # Directory where projects are stored.
  path.projects
    "/path/to/projects"

  # Directory where you want to store mysql dump files.
  path.mysql_dumps
    "/path/to/dumps"

  # Timestamp format to use when creating dump files and such.
  format.timestamp
    "%Y.%m.%d-%H:%M:%S"

  # Open project in terminal after being created.
  project.open_in_terminal
    true

  # Open project in browser after being created.
  project.open_in_browser
    true

  # Open project in vscode after being created.
  project.open_in_vscode
    true

  # Initialize Git and commit files after being created.
  project.run_git_init
    true

  # Default version to download when creating a Laravel project.
  laravel.version
    "6.0"

  # Default admin email creating a CraftCMS project.
  craftcms.admin_email
    "admin@email.com"

  # Default admin username when creating a CraftCMS project.
  craftcms.admin_username
    "admin"

  # Default admin password when creating a CraftCMS project.
  craftcms.admin_password
    "password"
)

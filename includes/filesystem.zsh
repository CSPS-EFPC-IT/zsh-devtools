#!/bin/zsh

# |----------------------------------------------------------------------------
# | Check wether a directory exists or not.
# |----------------------------------------------------------------------------
# | @return true or false
# |----------------------------------------------------------------------------
function dir:exists()
{
  [ -d "${1}" ] && echo true || echo false
}

# |----------------------------------------------------------------------------
# | List directories as a choice picker.
# |----------------------------------------------------------------------------
# | @param [$1] Variable to store choice selection in.
# | @param [DIR] Directory to list content from.
# | @param [SELECTOR] Name selector to filter directories. (optional)
# |----------------------------------------------------------------------------
function dir:choose()
{
  local DIR=$2
  local SELECTOR=$3
  local DIRS=()
  local INDEX=0
  local COUNT=1

  if [ -z $1 ]; then;
    print:warning "A variable must be passed as first argument to $(print:highlight dir:choose) in order to store user's selection." && return
  fi

  if [[ $(dir:exists $DIR) = false ]]; then;
    print:warning "Source directory $(print:highlight $DIR) could not be found" && return
  fi

  DIRS=($(ls -d $DIR/*/ | grep "$SELECTOR" | sort -h))

  if [ ${#DIRS[@]} -ne 0 ]; then
    # Print directories list.
    echo $DIR
    print:selection ${DIRS[@]}

    # Prompt and validate directory selection.
    while [[ -n ${INDEX//[0-9]/} ]] || [[ $INDEX == 0 ]] || [[ $INDEX == '' ]] || [[ ${DIRS[($INDEX)]} == '' ]]; do
      read INDEX\?"> Choose a directory from the list above (i.e. 1, 2, 3): "
    done

    eval "$1=${DIRS[($INDEX)]}"
  fi
}

# |----------------------------------------------------------------------------
# | Remove a directory.
# |----------------------------------------------------------------------------
# | @param [DIR] Directory to remove.
# | @option [--force] If present, will not ask for a confirmation.
# |----------------------------------------------------------------------------
function dir:delete()
{
  local DIR=$1

  # Validate directory to delete.
  if [ -z $DIR ] || ! [ -d $DIR ]; then;
    print:warning "Invalid directory to delete..." && return
  fi

  # If --force option is not passed, ask for a confirmation.
  if [[ "$*" != *"--force"* ]]; then;
    confirm "You are about to delete the following directory $(print:highlight $DIR)."
    if [[ $CONFIRM = "n" ]]; then; echo && return; fi
  fi

  # Delete directory.
  rm -rf $DIR
}

# |----------------------------------------------------------------------------
# | List files as a choice picker.
# |----------------------------------------------------------------------------
# | @param [$1] Variable to store choice selection in.
# | @param [DIR] Directory to list content from.
# | @param [SELECTOR] Name selector to filter files. (optional)
# |----------------------------------------------------------------------------
function file:choose()
{
  local DIR=$2
  local SELECTOR=$3
  local FILES=()
  local INDEX=0
  local COUNT=1

  if [ -z "$1" ]; then;
    print:warning "A variable must be passed as first argument to $(print:highlight file:choose) in order to store user's selection." && return
  fi

  if [[ $(dir:exists $DIR) = false ]]; then;
    print:warning "Source directory $(print:highlight $DIR) could not be found" && return
  fi

  FILES=($(ls $DIR -p | grep "$SELECTOR" | grep -v / | sort -h))

  if [ ${#FILES[@]} -ne 0 ]; then
    # Print files list.
    echo $DIR
    print:selection ${FILES[@]}

    # Prompt and validate file selection.
    while [[ -n ${INDEX//[0-9]/} ]] || [[ $INDEX == 0 ]] || [[ $INDEX == '' ]] || [[ ${FILES[($INDEX)]} == '' ]]; do
      read INDEX\?"> Choose a file from the list above (i.e. 1, 2, 3): "
    done

    eval "$1=$DIR${FILES[($INDEX)]}"
  fi
}

# |----------------------------------------------------------------------------
# | Remove a file.
# |----------------------------------------------------------------------------
# | @param [FILE] File to remove.
# | @option [--force] If present, will not ask for a confirmation.
# |----------------------------------------------------------------------------
function file:delete()
{
  local FILE=$1

  # Validate file to delete.
  if [ -z $FILE ] || ! [ -f $FILE ]; then;
    print:warning "Invalid file to delete..." && return
  fi

  # If --force option is not passed, ask for a confirmation.
  if [[ "$*" != *"--force"* ]]; then;
    confirm "You are about to delete the following file $(print:highlight $FILE)."
    if [[ $CONFIRM = "n" ]]; then; echo && return; fi
  fi

  # Delete file.
  rm $FILE
}

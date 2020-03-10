#!/bin/zsh

# |----------------------------------------------------------------------------
# | Highlight a word or text. Used when outputting information.
# |----------------------------------------------------------------------------
# | @param [TEXT] Text to highlight.
# |----------------------------------------------------------------------------
function print:highlight()
{
  local TEXT=$1
  local OUTPUT="[ $fg_bold[cyan]$TEXT$reset_color ]"
  echo $OUTPUT
}

# |----------------------------------------------------------------------------
# | Print a separator line.
# |----------------------------------------------------------------------------
function print:line()
{
  echo "----------------------------------------------------------------------------"
}

# |----------------------------------------------------------------------------
# | Print a formatted info message.
# |----------------------------------------------------------------------------
# | @param [MESSAGE] Message to output as info.
# |----------------------------------------------------------------------------
function print:info()
{
  local MESSAGE=$1
  echo $fg_bold[cyan]"[INFO]$reset_color $MESSAGE"
}

# |----------------------------------------------------------------------------
# | Print a formatted success message.
# |----------------------------------------------------------------------------
# | @param [MESSAGE] Message to output as success.
# |----------------------------------------------------------------------------
function print:success()
{
  local MESSAGE=$1
  echo $fg_bold[green]"[SUCCESS]$reset_color $MESSAGE"
}

# |----------------------------------------------------------------------------
# | Print a formatted warning message.
# |----------------------------------------------------------------------------
# | @param [MESSAGE] Message to output as warning.
# |----------------------------------------------------------------------------
function print:warning()
{
  local MESSAGE=$1
  echo $fg_bold[yellow]"[WARNING]$reset_color $MESSAGE"
}

# |----------------------------------------------------------------------------
# | Print a formatted error message.
# |----------------------------------------------------------------------------
# | @param [MESSAGE] Message to output as error.
# |----------------------------------------------------------------------------
function print:error()
{
  local MESSAGE=$1
  echo $fg_bold[red]"[ERROR]$reset_color $MESSAGE"
}

# |----------------------------------------------------------------------------
# | Print a list of items in use for selection.
# |----------------------------------------------------------------------------
# | @param [ITEMS] Array of items to display a list of choices.
# |----------------------------------------------------------------------------
function print:selection()
{
  local ITEMS=("${@}")
  local COUNT=1

  print:line
  for i in "${ITEMS[@]}"; do;
    echo "$COUNT) $(basename $i)" && ((++COUNT))
  done
  print:line
}

# |----------------------------------------------------------------------------
# | Print a list of items in a readable format.
# |----------------------------------------------------------------------------
# | @param [ITEMS] Array of items to display a list.
# |----------------------------------------------------------------------------
function print:list()
{
  local ITEMS=("${@}")

  print:line
  for i in "${ITEMS[@]}"; do;
    echo "- $(basename $i)"
  done
  print:line
}

# |----------------------------------------------------------------------------
# | Return a formatted timestamp using the specified format in configurations.
# |----------------------------------------------------------------------------
# | @return [TIMESTAMP]
# |----------------------------------------------------------------------------
function get_timestamp()
{
  local TIMESTAMP_FORMAT=${CONFIG[format.timestamp]}
  local TIMESTAMP=$(date +$TIMESTAMP_FORMAT)
  echo $TIMESTAMP
}

# |----------------------------------------------------------------------------
# | Clear the console.
# |----------------------------------------------------------------------------
function clear_console()
{
  printf "\033c"
}

# |----------------------------------------------------------------------------
# | Prompt a confirmation and store the answer in a global $CONFIRM variable.
# |----------------------------------------------------------------------------
# | @param [MESSAGE] Confirmation message to display.
# |----------------------------------------------------------------------------
function confirm()
{
  local MESSAGE=$1
  echo $MESSAGE && read -q "CONFIRM?> Confirm [ y/n ]: " && echo
}

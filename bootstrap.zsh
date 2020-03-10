#!/bin/zsh

CURRENT_DIR="${funcsourcetrace[1]%/*}"
INCLUDE_DIR="$CURRENT_DIR/includes"

# Import all required script files.
source "$CURRENT_DIR/config.zsh"
for FILE in "$INCLUDE_DIR"/*.zsh; do
  source $FILE
done

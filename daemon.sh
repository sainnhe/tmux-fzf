#!/usr/bin/env bash

if [ -x "$(command -v pip)" ] && [ -n "$(pip list | grep PyGObject)" ]; then
    touch "$1/.temp"
    "$1/scripts/clipboard/clipster" -d &>/dev/null &
else
    rm -f "$1/.temp"
    exit
fi

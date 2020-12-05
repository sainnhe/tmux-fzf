#!/usr/bin/env bash

if [ -x "$(command -v copyq)" ]; then
    "$1/scripts/clipboard/clipster" -d &>/dev/null &
else
    exit
fi

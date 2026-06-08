#!/usr/bin/env bash

pkill -x fuzzel 2>/dev/null && exit 0

fuzzel --y-margin 20 -l 5 --minimal-lines

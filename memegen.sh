#!/bin/sh
# memegen, a posix script to generate memes from the command line
# Copyright (C) 2021 Vendicated
#
# This program is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published
# by the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See th
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program.  If not, see <https://www.gnu.org/licenses/>.

set -e

if [ -z "$3" ] && [ -z "$4" ]; then
  echo "memegen, a posix script to generate memes from the command line"
  echo "Copyright (C) 2021 Vendicated"
  echo

  echo "Usage:"
  printf "    %s <INPUT_FILE> <OUTPUT_FILE> [TOP_CAPTION] [BOTTOM_CAPTION]\n" "$0"
  echo "        - INPUT_FILE: Full or absolute path to a local file. Or alternatively an image url (will be downloaded to /tmp/memetemp using curl)"
  echo "        - OUTPUT_FILE: Full or absolute path to save file to. Will not override if file exists"
  echo "        - TOP_CAPTION: Top caption. Only one of TOP_CAPTION and BOTTOM_CAPTION is required"
  echo "        - BOTTOM_CAPTION: Bottom caption"
  exit
fi

src=$1
dest=$2
header=$3
footer=$4

if [ -e "$dest" ]; then
  printf "%s already exists, please delete it and run this command again\n" "$dest"
  exit
elif ! touch "$dest" 2>/dev/null; then
  printf "%s is not a valid path\n" "$dest"
  exit
fi

rm "$dest"

if [ ! -e "$src" ]; then
  if curl -s "$src" > /tmp/memetemp; then
    trap "rm -f /tmp/memetemp" INT TERM EXIT
    src=/tmp/memetemp
  else
    printf "%s doesn't seem to be a valid file or url\n" "$src"
    exit
  fi
fi

meta="$(file "$src")"
if [ "${meta#*image}" == "$meta" ]; then
  printf "%s doesn't seem to be a valid image\n" "$1"
  exit
fi


font=Impact

width=`identify -format %w ${src}`
caption_height=$((width/6))
strokewidth=$((width/500))

convert "$src" \
  -background none \
  -font "$font" \
  -fill white \
  -stroke black \
  -strokewidth "$strokewidth" \
  -size "${width}x${caption_height}" \
    -gravity north caption:"$header" -composite \
    -gravity south caption:"$footer" -composite \
  "$dest"

printf "Done! Saved to %s\n" "$dest"

xdg-open "$dest" &

#!/bin/bash

RE_INCLUDE='^#include[[:space:]]*"(.*)"'
RE_PRAGMA_ONCE='^#pragma once'

declare -A INCLUDED

process()
{
	local PARENT=$1
	local FOLDER=$(dirname $1)
	local IN_HEADER=true
	while read LINE; do
		if [[ $LINE =~ $RE_INCLUDE ]]; then
			local CHILD=${BASH_REMATCH[1]}
			pushd "$FOLDER" > /dev/null
			echo "$PARENT -> $CHILD" >&2
			local P=$(realpath $CHILD)
			if [[ ! ${INCLUDED[$P]} ]]; then
				process "$CHILD"
				INCLUDED[$P]=true
			else
				echo "$PARENT (-> $CHILD)" >&2
			fi
			popd > /dev/null
			IN_HEADER=false
		elif [[ $LINE =~ $RE_PRAGMA_ONCE ]]; then
			IN_HEADER=false
		elif [[ ! $IN_HEADER ]]; then
			echo $LINE
		fi
	done < $PARENT
}

process $(dirname $0)/../include/ArduinoJson.h
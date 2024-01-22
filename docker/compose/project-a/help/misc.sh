#!/bin/bash

gRelativePath=$(dirname $(realpath -s "$0"))
. $gRelativePath/log.sh

function miscMake() {
  _parentProcess=$(ps -o comm= $PPID)

  if [ "$_parentProcess" != "make" ]; then
  	log "ERROR" "[MISC: make]; please run this script using make"
    exit 1
  fi
	  log "INFO" "[MISC: make]; executabled by make"
}

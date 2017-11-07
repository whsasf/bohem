#!/bin/bash

if [ "$1" = "" ] ; then
  echo "Error: must provide class name."
  echo "Usage:"
  echo "mos_delete_class.sh <class_name>"
  exit 1
fi

host="$1"
port="$2"
cos="$3"

curl -X DELETE http://$MXOS1_HOST:$MXOS1_PORT/mxos/cos/v2/$cos

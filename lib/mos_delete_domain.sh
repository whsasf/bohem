#!/bin/bash

mos_host=$1
mos_port=$2
domain=$3

shift 3

if [ "$domain" = "" ] ; then
  echo "Error: must provide domain name."
  echo "Usage:"
  echo "cleanupMosDomain.sh <domain_name>"
  exit 1
fi

number=$(tr -dc '.' <<<"$domain" | wc -c ) 

echo $number

for n in `seq 1 $number`
do
    s=$(echo $domain | cut -f $n- -d .)
    curl -X DELETE http://$mos_host:$mos_port/mxos/domain/v2/$s   
done

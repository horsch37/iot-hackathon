#!/bin/bash
FN=/tmp/$$.txt
ls -1 /opt/demo/data/fans/49* | sort -u > $FN
while [ 1 -eq 1 ]
do
 cat $FN | while read DIR
 do
  i=0
  while [ $i -lt 6 ]
   do
    VAL=$(cat $DIR | jq --arg idx $i '.readResults[$idx | tonumber] | {id,v}' | sed 's/Fan.Fans.//g')
    echo $VAL
    curl --header "Content-Type: application/json" --request POST --data "$VAL" http://demo.hortonworks.com:3131/iot
    sleep .1
    ((i++)) 
   done
 done
done

#!/bin/bash

#Create Topics
/usr/hdp/current/kafka-broker/bin/kafka-topics.sh --zookeeper demo.hortonworks.com:2181 --topic kafka_druid_iot --create --if-not-exists --replication-factor 1 --partitions 1
/usr/hdp/current/kafka-broker/bin/kafka-topics.sh --zookeeper demo.hortonworks.com:2181 --topic kafka_druid_alert --create --if-not-exists --replication-factor 1 --partitions 1

#Fix HDFS
sudo -u hdfs hdfs dfs -mkdir /warehouse/tablespace/managed/hive/hive_iot
sudo -u hdfs hdfs dfs -chown nifi /warehouse/tablespace/managed/hive/hive_iot
sudo -u hdfs hdfs dfs -chmod 777 /warehouse/tablespace/managed/hive
sudo -u hdfs hdfs dfs -chmod 777 /warehouse/tablespace/managed
sudo -u hdfs hdfs dfs -chmod 777 /warehouse/tablespace
sudo -u hdfs hdfs dfs -chmod 777 /warehouse

#Create Tables

export HADOOP_CLIENT_OPTS="-Djline.terminal=jline.UnsupportedTerminal"
export USR=hive
export PASS=hive
HI=$(beeline --showHeader=false --headerInterval=0 --fastConnect=true --outputformat=tsv2 -n $USR -p "${PASS}" -e "show tables;" 2>/dev/null | grep -v "^tab_name" | grep '^hive_iot$' | wc -l)
if [ $HI -ne 1 ]; then
  beeline --showHeader=false --headerInterval=0 --fastConnect=true --outputformat=tsv2 -n $USR -p "${PASS}" -f hive_iot.sql
fi
KDA=$(beeline --showHeader=false --headerInterval=0 --fastConnect=true --outputformat=tsv2 -n $USR -p "${PASS}" -e "show tables;" 2>/dev/null | grep -v "^tab_name" | grep '^kafka_druid_alert$' | wc -l)
if [ $KDA -ne 1 ]; then
  beeline --showHeader=false --headerInterval=0 --fastConnect=true --outputformat=tsv2 -n $USR -p "${PASS}" -f kafka_druid_alert.sql 
fi
KDI=$(beeline --showHeader=false --headerInterval=0 --fastConnect=true --outputformat=tsv2 -n $USR -p "${PASS}" -e "show tables;" 2>/dev/null | grep -v "^tab_name" | grep '^kafka_druid_iot$' | wc -l)
if [ $KDI -ne 1 ]; then
  beeline --showHeader=false --headerInterval=0 --fastConnect=true --outputformat=tsv2 -n $USR -p "${PASS}" -f kafka_druid_iot.sql 
fi
#copy flow.xml.gz
cp flow.xml.gz /var/lib/nifi/conf
chown nifi /var/lib/nifi/conf/flow.xml.gz

#Import Zeppelin
export FNAME=/tmp/$$.cookies.txt
curl -c $FNAME -i -s --data 'userName=admin&password=admin' -X POST http://demo.hortonworks.com:9995/api/login
curl -v -i -b $FNAME -H "Content-Type: application/json" --data "@IOT.json" -X POST http://demo.hortonworks.com:9995/api/notebook/import

#Import Superset????
#https://github.com/apache/incubator-superset/issues/2560


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

#stop nifi
curl -u admin:H0rtonworks\!1 -H "X-Requested-By:ambari" -i -X PUT -d '{"RequestInfo": {"context" :"Stop NIFI"}, "Body": {"ServiceInfo": {"state": "INSTALLED"}}}' http://demo.hortonworks.com:8080/api/v1/clusters/hackathon-cluster/services/NIFI

#copy flow.xml.gz
cp flow.xml.gz /var/lib/nifi/conf
chown nifi /var/lib/nifi/conf/flow.xml.gz

#start nifi
curl -u admin:H0rtonworks\!1 -H "X-Requested-By:ambari" -i -X PUT -d '{"RequestInfo": {"context" :"Start NIFI"}, "Body": {"ServiceInfo": {"state": "STARTED"}}}' http://demo.hortonworks.com:8080/api/v1/clusters/hackathon-cluster/services/NIFI

#Import Zeppelin
export FNAME=/tmp/$$.cookies.txt
curl -c $FNAME -i -s --data 'userName=admin&password=H0rtonworks\!1' -X POST http://demo.hortonworks.com:9995/api/login
curl -v -i -b $FNAME -H "Content-Type: application/json" --data "@IOT.json" -X POST http://demo.hortonworks.com:9995/api/notebook/import
/bin/rm $FNAME

#fix superset python
/bin/rm /usr/hdp/3.0.1.0-187/superset/lib/python3.4/site-packages/superset/views/__pycache__/core.cpython-34.pyc
/bin/rm /usr/hdp/3.0.1.0-187/superset/lib/python3.4/site-packages/superset/models/__pycache__/helpers.cpython-34.pyc
cp core.py /usr/hdp/3.0.1.0-187/superset/lib/python3.4/site-packages/superset/views/core.py
cp helpers.py /usr/hdp/3.0.1.0-187/superset/lib/python3.4/site-packages/superset/models/helpers.py

#restart superset
curl -u admin:H0rtonworks\!1 -H "X-Requested-By:ambari" -i -X PUT -d '{"RequestInfo": {"context" :"Stop NIFI"}, "Body": {"ServiceInfo": {"state": "INSTALLED"}}}' http://demo.hortonworks.com:8080/api/v1/clusters/hackathon-cluster/services/SUPERSET
curl -u admin:H0rtonworks\!1 -H "X-Requested-By:ambari" -i -X PUT -d '{"RequestInfo": {"context" :"Start NIFI"}, "Body": {"ServiceInfo": {"state": "STARTED"}}}' http://demo.hortonworks.com:8080/api/v1/clusters/hackathon-cluster/services/SUPERSET

#Import Superset
#import dashboards
export FNAME=/tmp/$$.cookies.txt
curl -s -c $FNAME -u admin:H0rtonworks\!1 -XPOST -d 'username=admin&password=H0rtonworks\!1' http://demo.hortonworks.com:9088/login/
curl -b $FNAME -X POST http://demo.hortonworks.com:9088/superset/import_dashboards -F "file=@superset.json"
/bin/rm $FNAME

#import datasource
. /usr/hdp/current/superset/conf/superset-env.sh
/usr/hdp/current/superset/bin/superset import_datasources -p superset.yml


#Run data sim
#nohup ./submitdata.sh >> /var/log/submitdata.log 2>&1 &
#./startspark.sh

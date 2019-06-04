CREATE external TABLE hive_iot(`__time` string,id string, v double, agent string)
STORED AS ORC
location '/warehouse/tablespace/managed/hive/hive_iot';


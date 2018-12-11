CREATE external TABLE hive_iot(`__time` string,id string, v double)
STORED AS ORC
location '/warehouse/tablespace/managed/hive/hive_iot';


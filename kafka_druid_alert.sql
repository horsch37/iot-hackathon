set hive.druid.overlord.address.default=demo.hortonworks.com:8090;
set hive.druid.metadata.username=druid;
set hive.druid.metadata.password=druid;
set hive.druid.metadata.uri=jdbc:postgresql://demo.hortonworks.com:5433/druid;
set hive.druid.metadata.db.type=postgresql;
CREATE EXTERNAL TABLE kafka_druid_alert (`__time` timestamp, id string, minv double, maxv double, agent string)
        STORED BY 'org.apache.hadoop.hive.druid.DruidStorageHandler'
        TBLPROPERTIES (
        "kafka.bootstrap.servers" = "demo.hortonworks.com:6667",
        "kafka.topic" = "kafka_druid_alert",
        "druid.kafka.ingestion.useEarliestOffset" = "true",
        "druid.kafka.ingestion.maxRowsInMemory" = "5",
        "druid.kafka.ingestion.startDelay" = "PT1S",
        "druid.kafka.ingestion.period" = "PT1S",
        "druid.kafka.ingestion.consumer.retries" = "2");     
ALTER TABLE kafka_druid_alert SET TBLPROPERTIES('druid.kafka.ingestion' = 'START');


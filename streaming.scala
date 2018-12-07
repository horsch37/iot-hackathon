import spark.implicits._
import  _root_.kafka.serializer
import org.apache.kafka.common.serialization.StringDeserializer
import kafka.serializer.StringDecoder
import org.apache.spark.streaming.kafka010._
import org.apache.spark.storage.StorageLevel
import org.apache.spark.streaming._
import org.apache.spark.sql.types._
import org.apache.spark.SparkContext
import org.apache.spark.sql.SQLContext
import org.apache.spark.streaming.kafka010.LocationStrategies.PreferConsistent
import org.apache.spark.streaming.kafka010.ConsumerStrategies.Subscribe

sc.setLogLevel("ERROR")

val ssc = new StreamingContext(sc, Seconds(30))

val kafkaConf = Map(
    "bootstrap.servers" -> "demo.hortonworks.com:6667",
    "key.deserializer" -> classOf[StringDeserializer],
    "value.deserializer" -> classOf[StringDeserializer],
    "auto.offset.reset" -> "latest",
    "group.id" -> "kafka-streaming-example"
)

val topics = Array("kafka_druid_iot")
val stream = KafkaUtils.createDirectStream[String, String](ssc, PreferConsistent,  Subscribe[String, String](topics, kafkaConf))
val result = stream.map(record => (record.value))
result.foreachRDD( rdd =>
{
 val data = spark.read.json(rdd)
 data.registerTempTable("iot")
 val df=spark.sql("SELECT max(__time) __time, id, min(v) minv, max(v) maxv FROM iot group by id having max(v)-min(v) > 10")
 df.show()
 df.selectExpr("CAST(0 AS STRING) AS key", "to_json(struct(*)) AS value").write.format("kafka").option("kafka.bootstrap.servers", "demo.hortonworks.com:6667").option(
"topic", "kafka_druid_alert").save()
})
ssc.start()
ssc.awaitTermination()


# IoT Predictive Maintenance Demo

## Introduction
Over the last many decades, manufacturers have continuously focused on reducing unplanned downtime costs (amounting to nearly $50 billion annually according to Deloitte).

Today, the Industrial Internet of Things (IIOT), with huge new volumes of connected sensor data, provides the potential to unleash powerful new insights to optimize manufacturing performance.

This demo shows how HDP and HDF may be leveraged to provide predictive plant maintenance analytics.  It monitors and measures the vibration on two production fans on the shop floor to identify anomalies and alerts engineers via email of potential failures.

## Demo Deployment
The demo is deployable through Cloudbreak.  There are 2 options to launch it

### A) Using CB CLI

1) ssh to the vm where your CB is deployed
2) Copy and run the below command, replacing the parameters with your own

```
git clone https://github.com/horsch37/iot-hackathon
./cb configure --server 127.0.0.1 --username admin@example.com --password hortonworks
./cb recipe create from-file --file iot-hackathon/cloudbreak-automation/pre-ambari-start-script.sh --name final-pre3 --execution-type pre-ambari-start
./cb recipe create from-file --file iot-hackathon/cloudbreak-automation/post-cluster-install.sh --name final-post3 --execution-type post-cluster-install
./cb mpack create --name hdf-3-2 --url "http://public-repo-1.hortonworks.com/HDF/amazonlinux2/3.x/updates/3.2.0.0/tars/hdf_ambari_mp/hdf-ambari-mpack-3.2.0.0-520.tar.gz"  
#update the first 3 sections of iot-hackathon/cloudbreak-automation/cb_template.json
./cb cluster create --cli-input-json iot-hackathon/cloudbreak-automation/cb_template.json --name whoville
```
 
### B) Using CB UI
1) Log in to your CB UI 

2) Under Blueprints, create a new blueprint using the below url.
https://raw.githubusercontent.com/horsch37/iot-hackathon/master/cloudbreak-automation/one-node-hackathon.json

![](/images/bpscreenshot.png)


3) Under Cluster Extensions > Recipes, create a “post-cluster-install” recipe with the below url.
https://raw.githubusercontent.com/horsch37/iot-hackathon/master/cloudbreak-automation/post-cluster-install.sh

![](/images/pciscreenshot.png)

4) Under Cluster Extensions > Recipes, create a “pre-ambari-start” recipe with the below url.
https://raw.githubusercontent.com/horsch37/iot-hackathon/master/cloudbreak-automation/pre-ambari-start-script.sh


5) Create cluster using the above blueprint and recipes
	- Below are the recommended VM sizes:
		- OpenStack: m3.4xlarge
		- AWS: M4.4xlarge (16vCPU, 64GB)
		- GCS: n1-standard-16 (16vcpu, 60GB)
		- Azure: D16 (16vCPU, 64GB)


## Architecture

![](/images/architecture.png)

A simulator generates machine fan data including Fan ID, RPM, X-Axis Vibration, Y-Axis Vibration and Time.  This fan data is captured by a Nifi flow and queued into kafka.

A second Nifi flow reads from the "raw data" queue and lands the data into HDFS for further processing.

A Spark Streaming job also reads from the "raw data" queue and monitors for anomalies in the fan readings.  When it detects a value variance of greater than 10 in any 15-second sliding window it puts an alert into a Kafka "alert" queue.

A third Nifi flow picks up the alerts and sends an email notification to the engineers notifying them of the operational anomaly and potential failure.

Furthermore, analysts are able to use Supersets, Druid and Hive to query and analyze data in HDFS and the Kafka topics.



## Demo Walkthrough



1) Navigate to your Nifi UI to see the different flows.
	- The data ingestion flow is labeled in blueprint
	- The data processing flow is labeled in yellow
	- The alert processing flow is labeled in red 
	
![](/images/nifi.png)


2) Navigate to the Superset UI and explore the pre-built dashboards
	- IoT Data: min and max values over time for the variables
	- Alerts: identified anomoly alerts for which notifications have been sent
	
![](/images/superset.png)

	
3) Navigate to the Zeppelin UI for analytics
	- Modify the existing queries or write your own to explore and analyze the data
	
![](/images/zeppelin.png)

	
4) ssh to your server and run the below command to see the email notifications that have been sent to engineers alerting them of anomalies and possible failures

```
mailx
```

![](/images/mail.png)






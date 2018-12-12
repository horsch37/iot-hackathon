##Introduction
Over the last many decades, manufacturers have continuously focused on reducing unplanned downtime costs (amounting to nearly $50 billion annually according to Deloitte).

Today, the Industrial Internet of Things (IIOT), with huge new volumes of connected sensor data, provides the potential to unleash powerful new insights to optimize manufacturing performance.

This demo shows how HDP and HDF may be leveraged to provide predictive plant maintenance analytics.  It monitors and measures the vibration on two production fans on the shop floor to identify anomalies and potential failures.

##Demo Deployment
The demo is deployable through Cloudbreak.  There are 2 options to launch it

###A) Using CB CLI

placeholder

###B) Using CB UI
1) Log in to your CB UI 

2) Under Blueprints, create a new blueprint using the below url.
https://raw.githubusercontent.com/horsch37/iot-hackathon/master/cloudbreak-automation/one-node-hackathon.json


3) Under Cluster Extensions > Recipes, create a “post-cluster-install” recipe with the below url.
https://raw.githubusercontent.com/horsch37/iot-hackathon/master/cloudbreak-automation/post-cluster-install.sh

4) Under Cluster Extensions > Recipes, create a “pre-ambari-start” recipe with the below url.
https://raw.githubusercontent.com/horsch37/iot-hackathon/master/cloudbreak-automation/pre-ambari-start-script.sh


5) Create cluster using the above blueprint and recipes



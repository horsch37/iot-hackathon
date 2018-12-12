#!/bin/bash

# Globals

source /opt/demo/shared.sh

do_prep() {


# Install some packages
yum install -y git sendmail mailx
systemctl enable sendmail

}

do_setup() {

./setup.sh 


}

do_start() {

	sudo ./startspark.sh 
	sudo ./submitdata.sh 
}

#Execute functions
cd $DEMO_ROOT
do_prep
do_setup
do_start

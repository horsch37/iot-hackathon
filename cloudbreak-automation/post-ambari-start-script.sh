#!/bin/bash

# Globals

sudo . /opt/demo/shared.sh

do_prep() {


# Install some packages
sudo yum install -y git sendmail mailx
sudo systemctl enable sendmail

}

do_setup() {

sudo ./setup.sh 


}

do_start() {

	sudo ./startsubmit.sh 
	sudo ./submitdata.sh 
}

#Execute functions
sudo cd $DEMO_ROOT
do_prep
do_setup
do_start

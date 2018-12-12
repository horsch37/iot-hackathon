#!/bin/bash

# Globals

sudo source /opt/demo/shared.sh

do_prep() {


# Install some packages
sudo yum install -y git sendmail mailx
systemctl enable sendmail

}

do_setup() {

sudo ./setup.sh >> $LOGFILE


}

do_start() {

	sudo ./startsubmit.sa >> $LOGFILE
	sudo ./submitdata.sh >> $LOGFILE
}

#Execute functions
sudo cd $DEMO_ROOT
do_prep
do_setup
do_start

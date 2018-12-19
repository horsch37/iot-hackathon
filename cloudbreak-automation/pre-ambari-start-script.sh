#!/bin/bash


# Install some packages
yum -y install postgresql-server postgresql-contrib git
yum install -y git sendmail mailx
systemctl enable sendmail
service sendmail start

#Clone Repo
git clone https://github.com/horsch37/iot-hackathon /opt/demo

# Source some shared variables
source /opt/demo/shared.sh

# Setup hostname
CNT=$(grep $HOSTNAME /etc/hosts | wc -l)
if [ $CNT -eq 0 ] ; then
   sed -i '/internal/ s/$/ ambari-server.ec2.internal '"$HOSTNAME"'/' /etc/hosts
   hostnamectl set-hostname $HOSTNAME
fi

cd /opt/demo

# Install some packages

postgresql-setup initdb
systemctl start postgresql
systemctl enable postgresql

# Setup Postgres Users

sudo -u postgres createuser druid;
sudo -u postgres psql -c "alter user druid with password 'druid';"
sudo -u postgres psql -c "create database druid owner druid;"
sudo -u postgres psql -c "grant all privileges on database druid to druid";

sudo -u postgres createuser hive;
sudo -u postgres psql -c "alter user hive with password 'hive';"
sudo -u postgres psql -c "create database hive owner hive;"
sudo -u postgres psql -c "grant all privileges on database hive to hive";

sudo -u postgres createuser superset
sudo -u postgres psql -c "alter user superset with password 'superset';"
sudo -u postgres psql -c "create database superset owner superset;"
sudo -u postgres psql -c "grant all privileges on database superset to superset;"

sed -i "s/\(127.0.0.1\/32\s\+\)ident/\1trust/g" /var/lib/pgsql/data/pg_hba.conf 
sed -i "s/#listen_addresses = 'localhost'/listen_addresses = '*'/g" /var/lib/pgsql/data/postgresql.conf
echo 'host    all          all            0.0.0.0/0  trust' | sudo tee -a /var/lib/pgsql/data/pg_hba.conf
systemctl restart postgresql

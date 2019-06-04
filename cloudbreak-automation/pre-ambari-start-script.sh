#!/bin/bash


# Install some packages
curl https://bintray.com/sbt/rpm/rpm | sudo tee /etc/yum.repos.d/bintray-sbt-rpm.repo
yum -y install https://yum.postgresql.org/9.6/redhat/rhel-7-x86_64/pgdg-redhat96-9.6-3.noarch.rpm
yum -y install postgresql96-server postgresql96-contrib postgresql96 git sendmail mailx sbt

systemctl enable sendmail
service sendmail start

#Clone Repo
git clone https://github.com/horsch37/iot-hackathon /opt/demo

# Source some shared variables
source /opt/demo/shared.sh

# Setup hostname
CNT=$(grep $HOSTNAME /etc/hosts | wc -l)
DNAME=$(echo $HOSTNAME | awk "{print substr(\$0 ,index(\$0,\".\")+1,255);}")
if [ $CNT -eq 0 ] ; then
   sed -i '/internal/ s/$/ ambari-server.ec2.internal ambari-server.'"$DNAME"' '"$HOSTNAME"'/' /etc/hosts
   hostnamectl set-hostname $HOSTNAME
   domainname $DNAME
fi

cd /opt/demo

# Install some packages

/usr/pgsql-9.6/bin/postgresql96-setup initdb
systemctl enable postgresql-9.6.service
systemctl start postgresql-9.6.service

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

sudo -u postgres createuser efm
sudo -u postgres psql -c "alter user efm with password 'cloudera';"
sudo -u postgres psql -c "create database efm owner efm;"
sudo -u postgres psql -c "grant all privileges on database efm to efm;"

sudo -u postgres createuser registry
sudo -u postgres psql -c "alter user registry with password 'registry';"
sudo -u postgres psql -c "create database registry owner registry;"
sudo -u postgres psql -c "grant all privileges on database registry to registry;"

sed -i "s/\(127.0.0.1\/32\s\+\)ident/\1trust/g" /var/lib/pgsql/9.6/data/pg_hba.conf 
sed -i "s/#listen_addresses = 'localhost'/listen_addresses = '*'/g" /var/lib/pgsql/9.6/data/postgresql.conf
echo 'host    all          all            0.0.0.0/0  trust' | sudo tee -a /var/lib/pgsql/9.6/data/pg_hba.conf
systemctl restart postgresql-9.6.service

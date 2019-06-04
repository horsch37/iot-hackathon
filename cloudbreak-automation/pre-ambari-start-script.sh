#!/bin/bash


# Install some packages
curl https://bintray.com/sbt/rpm/rpm | sudo tee /etc/yum.repos.d/bintray-sbt-rpm.repo

#Install Postgres 9.6
if [[ $(cat /etc/system-release|grep -Po Amazon) == "Amazon" ]]; then
	yum install -y https://download.postgresql.org/pub/repos/yum/9.6/redhat/rhel-6-x86_64/pgdg-ami201503-96-9.6-2.noarch.rpm
	yum install -y postgresql96-server postgresql96-contrib
	service postgresql-9.6 initdb
else
	yum install -y https://download.postgresql.org/pub/repos/yum/9.6/redhat/rhel-7-x86_64/pgdg-redhat96-9.6-3.noarch.rpm
	yum install -y postgresql96-server postgresql96-contrib
	/usr/pgsql-9.6/bin/postgresql96-setup initdb
fi

#Set Postgres 9.6 listen port to 5433 to avoid collision with default Postgres instance
sed -i 's,#port = 5432,port = 5433,g' /var/lib/pgsql/9.6/data/postgresql.conf
sed -i "s/#listen_addresses = 'localhost'/listen_addresses = '*'/g" /var/lib/pgsql/9.6/data/postgresql.conf
sed -i "s/\(127.0.0.1\/32\s\+\)ident/\1trust/g" /var/lib/pgsql/9.6/data/pg_hba.conf 	
echo 'host    all          all            0.0.0.0/0  trust' | sudo tee -a /var/lib/pgsql/9.6/data/pg_hba.conf

systemctl enable postgresql-9.6.service
systemctl start postgresql-9.6.service
yum -y install git sendmail mailx sbt

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

# Setup Postgres Users

echo "CREATE DATABASE hive;" | sudo -u postgres psql -U postgres -h localhost -p 5433
echo "CREATE USER hive WITH PASSWORD 'hive';" | sudo -u postgres psql -U postgres -h localhost -p 5433
echo "GRANT ALL PRIVILEGES ON DATABASE hive TO hive;" | sudo -u postgres psql -U postgres -h localhost -p 5433

echo "CREATE DATABASE druid;" | sudo -u postgres psql -U postgres -h localhost -p 5433
echo "CREATE USER druid WITH PASSWORD 'druid';" | sudo -u postgres psql -U postgres -h localhost -p 5433
echo "GRANT ALL PRIVILEGES ON DATABASE druid TO druid;" | sudo -u postgres psql -U postgres -h localhost -p 5433

echo "CREATE DATABASE efm;" | sudo -u postgres psql -U postgres -h localhost -p 5433
echo "CREATE USER efm WITH PASSWORD 'cloudera';" | sudo -u postgres psql -U postgres -h localhost -p 5433
echo "GRANT ALL PRIVILEGES ON DATABASE efm TO efm;" | sudo -u postgres psql -U postgres -h localhost -p 5433

echo "CREATE DATABASE registry;" | sudo -u postgres psql -U postgres -h localhost -p 5433
echo "CREATE USER registry WITH PASSWORD 'registry';" | sudo -u postgres psql -U postgres -h localhost -p 5433
echo "GRANT ALL PRIVILEGES ON DATABASE registry TO registry;" | sudo -u postgres psql -U postgres -h localhost -p 5433

echo "CREATE DATABASE superset;" | sudo -u postgres psql -U postgres -h localhost -p 5433
echo "CREATE USER superset WITH PASSWORD 'superset';" | sudo -u postgres psql -U postgres -h localhost -p 5433
echo "GRANT ALL PRIVILEGES ON DATABASE superset TO superset;" | sudo -u postgres psql -U postgres -h localhost -p 5433

echo "CREATE DATABASE ranger;" | sudo -u postgres psql -U postgres -h localhost -p 5433
echo "CREATE USER ranger WITH PASSWORD 'ranger';" | sudo -u postgres psql -U postgres -h localhost -p 5433
echo "GRANT ALL PRIVILEGES ON DATABASE ranger TO ranger;" | sudo -u postgres psql -U postgres -h localhost -p 5433

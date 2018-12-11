#!/bin/bash

sudo yum -y install postgresql-server postgresql-contrib
sudo postgresql-setup initdb
sudo systemctl start postgresql
sudo systemctl enable postgresql

sudo -u postgres createuser druid;
sudo -u postgres psql -c "alter user druid with password 'druid'";
sudo -u postgres psql -c "create database druid owner druid;"
sudo -u postgres psql -c "grant all privileges on database druid to druid";

sudo -u postgres createuser hive;
sudo -u postgres psql -c "alter user hive with password 'hive'";
sudo -u postgres psql -c "create database hive owner hive;"
sudo -u postgres psql -c "grant all privileges on database hive to hive";

sed -i "s/\(127.0.0.1\/32\s\+\)ident/\1trust/g" /var/lib/pgsql/data/pg_hba.conf 
sudo sed -i "s/#listen_addresses = 'localhost'/listen_addresses = '*'/g" /var/lib/pgsql/data/postgresql.conf
echo 'host    all          all            0.0.0.0/0  trust' | sudo tee -a /var/lib/pgsql/data/pg_hba.conf
sudo systemctl restart postgresql



sudo sed -i "s/localhost4.localdomain4/localhost4.localdomain4 demo.hortonworks.com/g" /etc/hosts

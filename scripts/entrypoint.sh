#!/bin/bash
db_user=openmrs
db_password=password

mv /home/openmrs/openmrs.war /var/lib/tomcat7/webapps
service mysql start 
sh /home/openmrs/createdb.sh 
mysql -u$db_user -p$db_password openmrs -e "source /home/openmrs/DemoDB.sql" 
sh /usr/share/tomcat7/bin/startup.sh


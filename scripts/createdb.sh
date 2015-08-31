#/bin/bash
dbname=openmrs
db_root_user=root
db_root_password=passw0rd
db_user=openmrs
db_pass=password

#create database openmrs
mysql -u $db_root_user -p$db_root_password -e "CREATE DATABASE IF NOT EXISTS $dbname DEFAULT CHARACTER SET utf8 DEFAULT COLLATE utf8_general_ci;"
mysql -u $db_root_user -p$db_root_password -e "GRANT ALL PRIVILEGES ON $dbname.* TO $db_user@localhost IDENTIFIED BY '$db_pass';"
#    mysql -u $DB_ROOT_USER -p$DB_ROOT_PASS $OPENMRS_DB < $DB_LOCAL_PATH/$DB_FILE

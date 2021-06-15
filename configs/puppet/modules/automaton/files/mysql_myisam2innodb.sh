#!/bin/sh

service mysql stop
service mysqld stop
cp -r /var/lib/mysql /var/lib/mysql.fhs
service mysql start
service mysqld start
echo "SELECT concat('ALTER TABLE ',table_schema,'.',table_name,' engine=InnoDB;') FROM Information_schema.TABLES WHERE engine = 'InnoDB' AND TABLE_TYPE='BASE TABLE'" | mysql | egrep "^ALTER" > /tmp/fhs/mysql_myisam2innodb.sql
echo "SELECT concat('ALTER TABLE ',table_schema,'.',table_name,' engine=InnoDB;') FROM Information_schema.TABLES WHERE engine = 'MyISAM' AND TABLE_TYPE='BASE TABLE'" | mysql | egrep "^ALTER" >> /tmp/fhs/mysql_myisam2innodb.sql
mysql -f < /tmp/fhs/mysql_myisam2innodb.sql &> /tmp/fhs/mysql_myisam2innodb.log
/etc/cron.daily/mysql_optimize

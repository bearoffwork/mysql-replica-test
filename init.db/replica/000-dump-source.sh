#!/bin/bash

# dump replication source to /tmp/dump.sql
echo "[Entrypoint][$0] Dumping replication source."
MYSQL_PWD="$MASTER_ROOT_PASSWD" mysqldump -h mysql_master -u root --source-data=2 --single-transaction --flush-logs --databases "$MYSQL_DATABASE">/tmp/dump.sql

# source dump to replica
echo "[Entrypoint][$0] Sourcing dump."
pv /docker-entrypoint-initdb.d/dump.sql | MYSQL_PWD="$MYSQL_ROOT_PASSWORD" mysql -u root

rm /tmp/dump.sql
echo "[Entrypoint][$0] Done."

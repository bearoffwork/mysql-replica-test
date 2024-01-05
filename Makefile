
ifeq ("$(wildcard .env)","")
.env:
	@cp .env.example .env
endif

include .env

build: etc/master.cnf etc/replica.cnf init.db/replica/001-change-replica-source.sql
	@docker compose up

clean-build: clear build

etc/master.cnf:
	@export REPLICA_DB="${REPLICA_DB}";envsubst < etc/master.cnf.template > etc/master.cnf

etc/replica.cnf:
	@export REPLICA_DB="${REPLICA_DB}";envsubst < etc/replica.cnf.template > etc/replica.cnf

init.db/replica/001-change-replica-source.sql:
	@export MYSQL_USER="${REPLICA_USER}" MYSQL_PASSWORD="${REPLICA_PASSWD}"; \
		envsubst < init.db/replica/001-change-replica-source.sql.template > init.db/replica/001-change-replica-source.sql

login-master:
	@docker compose run --rm -it mysql_master sh

login-replica:
	@docker compose run --rm -it mysql_replica sh

status:
	@docker compose exec -e MYSQL_PWD=$(REPLICA_ROOT_PASSWD) mysql_replica sh -c 'mysql -u root -e "show replica status \G"'

master-status:
	@docker compose exec -e MYSQL_PWD=$(MASTER_ROOT_PASSWD) mysql_master sh -c 'mysql -u root -e "show master status \G"'

test: test-master test-replica

test-master:
	@echo "creating table and inserting data..."
	@docker compose exec -e MYSQL_PWD=$(MASTER_ROOT_PASSWD) mysql_master sh -c 'mysql -u root $(REPLICA_DB) -e "create table if not exists repl_test(str varchar(255));insert into repl_test values (\"normal string\"), (\"🎁✨🎅\")"'
	@echo "test-master done."

test-replica:
	@echo "checking table..."
	@docker compose exec -e MYSQL_PWD=$(REPLICA_ROOT_PASSWD) mysql_replica sh -c 'mysql -u root $(REPLICA_DB) -e "select * from repl_test \G"'
	@echo "test-replica done."

clear:
	@docker compose down -v --remove-orphans
	@rm -rf .data

.PHONY: build clean-build init.db/replica/001-change-replica-source.sql login-master login-replica test status master-status test-master test-replica clear

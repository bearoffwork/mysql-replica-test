# Mysql Replica test

## Usage

Clear all previous data and reboot the cluster
```shell
make clean-build
```

Open another terminal session and check replica status
```shell
make status
```

Test replication
```shell
make test
```

## Test dump

to test the replication from existing database, you can use the test dump file,
or place your own dump file in `init.db/master/` directory.
```shell
mv init.db/master/100-test-dump.sql.disabled init.db/master/100-test-dump.sql
```

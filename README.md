# Docker based images for dbsmartbackup

- Docker integration for [dbsmartbackup](https://github.com/kiorky/db_smart_backup)

## corpusops/dbsmartbackup
### Description
- This repo produces all those docker images except pg10, master, 1, 2 , 3.
    - [corpusops/dbsmartbackup](https://hub.docker.com/r/corpusops/dbsmartbackup/)
- Another [older repository](https://github.com/corpusops/setups.dbsmartbackup) produces all those docker images:
    - [corpusops/dbsmartbackup-legacy](https://hub.docker.com/r/corpusops/dbsmartbackup-legacy/)
    - but also the latest, 1, 3, 3 & pg10 tags [corpusops/dbsmartbackup](https://hub.docker.com/r/corpusops/dbsmartbackup/)

### Volumes
- a volume mapped to ``/var/db_smart_backup`` and maybe to ``/var/db_smart_backup/logs`` to store backups & logs

## Configuring the app
- For defaults, read the image [entry point](./rootfs/bin/dbs-entry.sh)
    - We try to made sensible defaults (most important, default periodicity is
      each day at 3am. We keep only 2 backups (as we assume you also do
      daily files backup of the volumes.
    - if NO_AUTO_PASSWORD is set, PGPASSWORD and PGUSER wont be set with the valmues of PGUSER or PASSWORD if set, see [rootfs/entry.sh](./rootfs/entry.sh)
    - ``BACKUP_TYPE`` env var is automatically set, but you can ofcourse override it
- [docker-compose example usage](./docker-compose.sample.yml)

## Env setup

Notable environment variables defaults to play with when ``DBS_AUTOCONF`` is set (configure via environment variables):

```sh
export DO_GLOBAL_BACKUP="${DBS_DO_GLOBAL_BACKUP-${DO_GLOBAL_BACKUP}}"
export DBNAMES=${DBS_DBNAMES-${DBNAMES:-"all"}}
export DBS_PERIODICITY="${DBS_USER:-"0 3 * * *"}"
export KEEP_LASTS=${KEEP_LASTS:-"1"}
export KEEP_DAYS${KEEP_DAYS:-"2"}
export KEEP_WEEKS=${KEEP_WEEKS:-"0"}
export KEEP_MONTHES=${KEEP_MONTHES:-"0"}
export KEEP_LOGS=${KEEP_LOGS:-"7"}
export DBS_USER="${DBS_USER:-"root"}"
export DBS_COMMAND="${DBS_COMMAND:-"/usr/local/bin/run_dbsmartbackup.sh --quiet --no-colors"}"
export DBS_CRONTAB="${DBS_CRONTAB:-"/conf/templates/crontab.frep"}"
export DBS_CONF_DEST="${DBS_CONF_DEST:-"/conf/dbs.conf"}"
export DBS_CONF="${DBS_CONF:-"/conf/templates/conf.frep"}"
export RUNAS=${RUNAS:-""}
```

### For pgsql
```sh
export HOST="${HOST:-${POSTGRES_HOST:-${PGHOST:-${POSTGRESQL_HOST-}}}}"
export PASSWORD="${PASSWORD:-${POSTGRES_PASSWORD:-${PGPASSWORD:-${POSTGRESQL_PASSWORD-}}}}"
export DBUSER="${DBUSER:-${POSTGRES_USER:-${POSTGRESQL_USER}}}"
export PORT=${PORT-5432}
```

### For mysql
```sh
export HOST="${HOST:-${MYSQL_HOST:-${MYSQLHOST-}}}"
export PORT=${PORT-3306}
export PASSWORD="${PASSWORD:-${MYSQL_PASSWORD}}"
export DBUSER="${DBUSER:-${MYSQL_USER-}}"
```

You have to set ``DBS_AUTOCONF`` to use the entry point without configuration via env. variables.

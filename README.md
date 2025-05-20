
DISCLAIMER - ABANDONED/UNMAINTAINED CODE / DO NOT USE
=======================================================
While this repository has been inactive for some time, this formal notice, issued on **December 10, 2024**, serves as the official declaration to clarify the situation. Consequently, this repository and all associated resources (including related projects, code, documentation, and distributed packages such as Docker images, PyPI packages, etc.) are now explicitly declared **unmaintained** and **abandoned**.

I would like to remind everyone that this project’s free license has always been based on the principle that the software is provided "AS-IS", without any warranty or expectation of liability or maintenance from the maintainer.
As such, it is used solely at the user's own risk, with no warranty or liability from the maintainer, including but not limited to any damages arising from its use.

Due to the enactment of the Cyber Resilience Act (EU Regulation 2024/2847), which significantly alters the regulatory framework, including penalties of up to €15M, combined with its demands for **unpaid** and **indefinite** liability, it has become untenable for me to continue maintaining all my Open Source Projects as a natural person.
The new regulations impose personal liability risks and create an unacceptable burden, regardless of my personal situation now or in the future, particularly when the work is done voluntarily and without compensation.

**No further technical support, updates (including security patches), or maintenance, of any kind, will be provided.**

These resources may remain online, but solely for public archiving, documentation, and educational purposes.

Users are strongly advised not to use these resources in any active or production-related projects, and to seek alternative solutions that comply with the new legal requirements (EU CRA).

**Using these resources outside of these contexts is strictly prohibited and is done at your own risk.**

This project has been transfered to Makina Corpus <freesoftware@makina-corpus.com> ( https://makina-corpus.com ). This project and its associated resources, including published resources related to this project (e.g., from PyPI, Docker Hub, GitHub, etc.), may be removed starting **March 15, 2025**, especially if the CRA’s risks remain disproportionate.

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
export DBS_DBNAMES=${DBS_DBNAMES-${DBNAMES:-"all"}}
export DBS_PERIODICITY="${DBS_USER:-"0 3 * * *"}"
export DBS_KEEP_LASTS=${DBS_KEEP_LASTS:-"1"}
export DBS_KEEP_DAYS=${DBS_KEEP_DAYS:-"2"}
export DBS_KEEP_WEEKS=${DBS_KEEP_WEEKS:-"0"}
export DBS_KEEP_MONTHES=${DBS_KEEP_MONTHES:-"0"}
export DBS_KEEP_LOGS=${KDBS_EEP_LOGS:-"7"}
export DBS_USER="${DBS_USER:-"root"}"
export DBS_COMMAND="${DBS_COMMAND:-"/usr/local/bin/run_dbsmartbackup.sh --quiet --no-colors"}"
export DBS_CRONTAB="${DBS_CRONTAB:-"/conf/templates/crontab.frep"}"
export DBS_CONF_DEST="${DBS_CONF_DEST:-"/conf/dbs.conf"}"
export DBS_CONF="${DBS_CONF:-"/conf/templates/conf.frep"}"
export DBS_RUNAS=${DBS_RUNAS:-""}
```

### For pgsql
```sh
export DBS_HOST="${DBS_HOST:-${POSTGRES_HOST:-${PGHOST:-${POSTGRESQL_HOST-}}}}"
export DBS_PASSWORD="${DBS_PASSWORD:-${POSTGRES_PASSWORD:-${PGPASSWORD:-${POSTGRESQL_PASSWORD-}}}}"
export DBS_DBUSER="${DBS_DBUSER:-${POSTGRES_USER:-${POSTGRESQL_USER}}}"
export DBS_PORT=${DBS_PORT-5432}
```

### For mysql
```sh
export DBS_HOST="${DBS_HOST:-${MYSQL_HOST:-${MYSQLHOST-}}}"
export DBS_PORT=${DBS_PORT-3306}
export DBS_PASSWORD="${DBS_PASSWORD:-${MYSQL_PASSWORD}}"
export DBS_DBUSER="${DBS_DBUSER:-${MYSQL_USER-}}"
```

You have to set ``DBS_AUTOCONF`` to use the entry point without configuration via env. variables.


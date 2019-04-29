#!/usr/bin/env sh
set -ex
SDEBUG=${SDEBUG-}
log() { echo "$@">&2; }
vv() { log "$@";"$@"; }
export BACKUP_TYPE=${BACKUP_TYPE-}
if [ "x${BACKUP_TYPE}" = "x" ];then
    log "no \$BACKUP_TYPE"
    exit 1
fi
export DO_GLOBAL_BACKUP="${DBS_DO_GLOBAL_BACKUP-${DO_GLOBAL_BACKUP}}"
export DBS_SUPERVISORD_CONFIGS="${DBS_SUPERVISORD_CONFIGS:-"/etc/supervisor.d/rsyslog /etc/supervisor.d/cron"}"
export SUPERVISORD_CONFIGS="${DBS_SUPERVISORD_CONFIGS}"
export DBS_PERIODICITY="${DBS_USER:-"0 3 * * *"}"
export DBS_USER="${DBS_USER:-"root"}"
export DBS_COMMAND="${DBS_COMMAND:-"/usr/local/bin/run_dbsmartbackup.sh --quiet --no-colors"}"
export DBS_AUTOCONF=${DBS_AUTOCONF-1}
export DBS_CRONTAB="${DBS_CRONTAB:-"/conf/templates/crontab.frep"}"
export DBS_CONF_DEST="${DBS_CONF_DEST:-"/conf/dbs.conf"}"
export DBS_CONF="${DBS_CONF:-"/conf/templates/conf.frep"}"
export IS_DCRON="${IS_DCRON-}"
export KEEP_LASTS=${KEEP_LASTS:-"1"}
export KEEP_DAYS${KEEP_DAYS:-"2"}
export KEEP_WEEKS=${KEEP_WEEKS:-"0"}
export KEEP_MONTHES=${KEEP_MONTHES:-"0"}
export KEEP_LOGS=${KEEP_LOGS:-"7"}
export DBNAMES="${DBS_DBNAMES-${DBS_DB_NAMES-${DBNAMES-${DB_NAMES:-"all"}}}}"
export RUNAS=${RUNAS:-""}
if ( echo $BACKUP_TYPE | egrep -iq "pgrouting|postgis|post" );then
    export PASSWORD="${PASSWORD:-${POSTGRES_PASSWORD:-${PGPASSWORD:-${POSTGRESQL_PASSWORD-}}}}"
    export HOST="${HOST:-${POSTGRES_HOST:-${PGHOST:-${POSTGRESQL_HOST-}}}}"
    export DBUSER="${DBUSER:-${POSTGRES_USER:-${POSTGRESQL_USER}}}"
    export PORT=${PORT-5432}
elif ( echo $BACKUP_TYPE | egrep -iq mysql );then
    export HOST="${HOST:-${MYSQL_HOST:-${MYSQLHOST-}}}"
    export PORT=${PORT-3306}
    export PASSWORD="${PASSWORD:-${MYSQL_PASSWORD}}"
    export DBUSER="${DBUSER:-${MYSQL_USER-}}"
    if [  "x${NO_AUTO_PORT-}" = "x" ];then
        if [ "x$PORT" != "x"  ];then export MYSQL_PORT="$PORT";fi
    fi
else
    export PORT=${PORT}
    export PASSWORD="${PASSWORD-}"
    export DBUSER="${DBUSER-}"
fi
if [ "${IS_DCRON}" = "x" ] && [ ! -e /etc/cron.d ];then
    export IS_DCRON="0"
    for i in /etc/crontabs /var/spool/crontabs;do
        if [ -e "$i" ];then
            export IS_DCRON="1"
            export CRONTABS_SPOOL="${CRONTABS_SPOOL:-$i}"
            break
        fi
    done
fi
if [ "x${IS_DCRON}" = "1" ];then
    export CRONTABS_SPOOL="${CRONTABS_SPOOL:-"/etc/crontabs"}"
    export DBS_CRONTAB_DEST="${DBS_CRONTAB_DEST:-"$CRONTABS_SPOOL/$DBS_USER"}"
else
    export CRONTABS_SPOOL="${CRONTABS_SPOOL:-"/etc/cron.d"}"
    export DBS_CRONTAB_DEST="${DBS_CRONTAB_DEST:-"$CRONTABS_SPOOL/dbs"}"
fi
if [  "x${NO_AUTO_PASSWORD-}" = "x" ];then
    if [ "x$PASSWORD" != "x"  ];then export PGPASSWORD="$PASSWORD";fi
    if [ "x$DBUSER" != "x" ];then export PGUSER="$DBUSER";fi
fi
export DBS_CONF_DESTS="${DBS_CONF_DESTS:-"$DBS_CONF_DEST"}"
if [ "x$SDEBUG" != "x" ];then set -x;fi
if [ "x$DBS_AUTOCONF" = "x1" ];then
    vv frep --overwrite $DBS_CRONTAB:$DBS_CRONTAB_DEST
    vv frep --overwrite $DBS_CONF:$DBS_CONF_DEST
fi
if [ "x$@" = "x" ];then
    set -- /bin/supervisord.sh
fi
log "Running $@"
exec ${@}
# vim:set et sts=4 ts=4 tw=80:

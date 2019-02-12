FROM corpusops/solr:7-slim
ARG NONINTERACTIVE=1
ARG DBSMARTBACKUP_VERSION=origin/master
ENV DBSMARTBACKUP_VERSION=$DBSMARTBACKUP_VERSION
USER root
RUN sh -exc 'if ! (git --version >/dev/null 2>&1 );then \
       NONINTERACTIVE=1 WANT_UPDATE=1 cops_pkgmgr_install.sh git;fi &&\
    git clone https://github.com/kiorky/db_smart_backup.git /srv/dbs \
    && cd /srv/dbs && git reset --hard $DBSMARTBACKUP_VERSION \
    && cp *sh /usr/local/bin \
    && mkdir /etc/dbsmartbackup \
    && cd / && rm -rf /srv/dbs'
ENV SUPERVISORD_CONFIGS="/etc/supervisor.d/rsyslog /etc/supervisor.d/cron"
CMD /bin/supervisord.sh
USER solr

FROM corpusops/solr:6.4-slim
ARG NONINTERACTIVE=1
ARG DBSMARTBACKUP_VERSION=origin/master
ENV DBSMARTBACKUP_VERSION=$DBSMARTBACKUP_VERSION
USER root
RUN sh -exc 'if ! (git --version >/dev/null 2>&1 );then \
      NONINTERACTIVE=1 WANTED_EXTRA_PACKAGES="xz-utils" \
      WANT_UPDATE=1 cops_pkgmgr_install.sh git;fi &&\
    git clone https://github.com/kiorky/db_smart_backup.git /srv/dbs \
    && cd /srv/dbs && git reset --hard $DBSMARTBACKUP_VERSION \
    && cp *sh /bin \
    && mkdir /etc/dbsmartbackup \
    && cd / && rm -rf /srv/dbs'
ADD rootfs/ /
ENTRYPOINT ["dbs-entry.sh"]
CMD []
ENV BACKUP_TYPE=solr
USER solr

FROM scratch AS rootfs
ADD /rootfs /rootfs
FROM corpusops/postgis:9.4-2.3 AS final
ARG NONINTERACTIVE=1
ARG DBSMARTBACKUP_VERSION=origin/master
ENV DBSMARTBACKUP_VERSION=$DBSMARTBACKUP_VERSION
RUN sh -exc ': \
    && if ! (git --version >/dev/null 2>&1 );then \
      if ( apt-get --version >/dev/null 2>&1 ) && ( apt-get update -yqq ) && ! ( apt-get install -y git );then \
        dpkg --purge --force-all perl-base && apt-get -f install -y;\
      fi;\
      NONINTERACTIVE=1 WANTED_EXTRA_PACKAGES="xz-utils ca-certificates jq curl" \
      WANT_UPDATE=1 cops_pkgmgr_install.sh git;fi &&\
    git clone https://github.com/kiorky/db_smart_backup.git /srv/dbs \
    && cd /srv/dbs && git reset --hard $DBSMARTBACKUP_VERSION \
    && cp *sh /bin \
    && mkdir /etc/dbsmartbackup \
    && cd / && rm -rf /srv/dbs'
# workaround for https://github.com/moby/moby/issues/42148
## ADD rootfs/ /
RUN --mount=type=bind,from=rootfs,target=/s bash -exc 'cp -frv /s/* /'
ENTRYPOINT ["dbs-entry.sh"]
CMD []
ENV BACKUP_TYPE=postgresql

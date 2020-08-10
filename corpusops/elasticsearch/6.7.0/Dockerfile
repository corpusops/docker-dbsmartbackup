FROM corpusops/elasticsearch:6.7.0
ARG NONINTERACTIVE=1
ARG DBSMARTBACKUP_VERSION=origin/master
ENV DBSMARTBACKUP_VERSION=$DBSMARTBACKUP_VERSION
RUN sh -exc 'pkgs="jq" &&\
    if ( apt-get --version >/dev/null 2>&1; );then\
        pkgs="$pkgs xz-utils";\
    else\
        pkgs="$pkgs xz";\
    fi\
    && NONINTERACTIVE=1 WANT_UPDATE=1 cops_pkgmgr_install.sh $pkgs'
RUN sh -exc ': \
    && if ! (git --version >/dev/null 2>&1 );then \
      if ( apt-get --version >/dev/null 2>&1 ) && ( apt-get update -yqq ) && ! ( apt-get install -y git );then \
        dpkg --purge --force-all perl-base && apt-get -f install -y;\
      fi;\
      NONINTERACTIVE=1 WANTED_EXTRA_PACKAGES="xz-utils ca-certificates" \
      WANT_UPDATE=1 cops_pkgmgr_install.sh git;fi &&\
    git clone https://github.com/kiorky/db_smart_backup.git /srv/dbs \
    && cd /srv/dbs && git reset --hard $DBSMARTBACKUP_VERSION \
    && cp *sh /bin \
    && mkdir /etc/dbsmartbackup \
    && cd / && rm -rf /srv/dbs'
ADD rootfs/ /
ENTRYPOINT ["dbs-entry.sh"]
CMD []
ENV BACKUP_TYPE=elasticsearch

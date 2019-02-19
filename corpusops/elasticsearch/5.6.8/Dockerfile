FROM corpusops/elasticsearch:5.6.8
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
RUN sh -exc 'if ! (git --version >/dev/null 2>&1 );then \
       NONINTERACTIVE=1 WANT_UPDATE=1 cops_pkgmgr_install.sh git;fi &&\
    git clone https://github.com/kiorky/db_smart_backup.git /srv/dbs \
    && cd /srv/dbs && git reset --hard $DBSMARTBACKUP_VERSION \
    && cp *sh /usr/local/bin \
    && mkdir /etc/dbsmartbackup \
    && cd / && rm -rf /srv/dbs'
ADD rootfs/ /
ENTRYPOINT ["dbs-entry.sh"]
CMD []

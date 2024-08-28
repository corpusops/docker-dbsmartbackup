FROM scratch AS rootfs
ADD /rootfs /rootfs
FROM corpusops/elasticsearch:8.3.3 AS final
#dbs special image
#dbs special image
ARG NONINTERACTIVE=1
ARG DBSMARTBACKUP_VERSION=origin/master
ENV DBSMARTBACKUP_VERSION=$DBSMARTBACKUP_VERSION
#dbs special image
USER root
RUN sh -exc 'pkgs="jq" &&\
    if ( apt-get --version >/dev/null 2>&1; );then\
        pkgs="$pkgs xz-utils sudo";\
    else\
        pkgs="$pkgs xz sudo";\
    fi\
    && NONINTERACTIVE=1 WANT_UPDATE=1 cops_pkgmgr_install.sh $pkgs'
#dbs special image
ADD ./db_smart_backup/ /srv/dbs/
RUN sh -exc ': \
    && NONINTERACTIVE=1 WANTED_EXTRA_PACKAGES="hostname xz xz-utils ca-certificates jq curl" WANT_UPDATE=1 cops_pkgmgr_install.sh git \
    && cd /srv/dbs && git reset --hard $DBSMARTBACKUP_VERSION \
    && cp *sh /bin \
    && mkdir /etc/dbsmartbackup \
    && cd / && rm -rf /srv/dbs'
# workaround for https://github.com/moby/moby/issues/42148
## ADD rootfs/ /
RUN --mount=type=bind,from=rootfs,target=/s bash -exc 'for i in /s/rootfs/*;do cp -frv $i/. /$(basename $i)/;done'
ENTRYPOINT ["dbs-entry.sh"]
CMD []
ENV BACKUP_TYPE=elasticsearch
#dbs special image
#dbs special image
USER elasticsearch:root

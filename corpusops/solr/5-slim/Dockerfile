FROM scratch AS rootfs
ADD /rootfs /rootfs
FROM corpusops/solr:5-slim AS final
#dbs special image
#dbs special image
ARG NONINTERACTIVE=1
ARG DBSMARTBACKUP_VERSION=origin/master
ENV DBSMARTBACKUP_VERSION=$DBSMARTBACKUP_VERSION
#dbs special image
USER root
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
#dbs special image
#dbs special image
#dbs special image
ENV BACKUP_TYPE=solr
USER solr

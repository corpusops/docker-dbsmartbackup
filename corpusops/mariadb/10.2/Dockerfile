ARG ANCESTOR=corpusops/mariadb:10.2
ARG RSYNC=corpusops/rsync
# now use Dockerfile.squash
#dbs special image
#dbs special image
# now use Dockerfile.squash

#dbs special image
#dbs special image
# now use squash
#dbs special image
#dbs special image
FROM corpusops/mariadb:10.2 AS final
FROM scratch AS files
ADD ./rootfs/ /rootfs/
ADD ./db_smart_backup/ /srv/dbs/
FROM $RSYNC AS squashed-rsync
FROM $ANCESTOR AS squashed-ancestor
ARG ROOTFS="/BASE_ROOTFS_TO_COPY_THAT_WONT_COLLIDE_1234567890"
ARG PATH="${ROOTFS}_rsync/bin:$PATH"
ARG NONINTERACTIVE=1
ARG DBSMARTBACKUP_VERSION=origin/master
ENV DBSMARTBACKUP_VERSION=$DBSMARTBACKUP_VERSION
SHELL ["busybox",  "sh", "-c"]
RUN --mount=type=bind,from=final,target=$ROOTFS --mount=type=bind,from=squashed-rsync,target=${ROOTFS}_rsync \
rsync -Aaz --delete ${ROOTFS}/ / --exclude=/proc --exclude=/sys --exclude=/etc/resolv.conf --exclude=/etc/hosts --exclude=$ROOTFS* --exclude=dev/shm --exclude=dev/pts --exclude=dev/mqueue
SHELL ["/bin/sh", "-c"]
RUN --mount=type=bind,rw,from=files,target=/s bash -exc '\
    : "workaround for https://github.com/moby/moby/issues/42148" \
    && for i in /s/rootfs/*;do cp -frv $i/. /$(basename $i)/;done \
    && NONINTERACTIVE=1 WANTED_EXTRA_PACKAGES="hostname xz xz-utils ca-certificates jq curl" WANT_UPDATE=1 cops_pkgmgr_install.sh git \
    && cd /s/srv/dbs && git reset --hard $DBSMARTBACKUP_VERSION \
    && cp *sh /bin \
    && mkdir /etc/dbsmartbackup'
ENTRYPOINT ["dbs-entry.sh"]
CMD []
ENV BACKUP_TYPE=mysql
#dbs special image

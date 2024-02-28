FROM corpusops/elasticsearch:6.7.2
ARG DO_UPDATE=y
ARG NONINTERACTIVE=y
ARG DEBIAN_FRONTEND=noninteractive
ARG INSTALL_DEFAULT_LOCALE="fr_FR.UTF-8"
ARG EXTRA_FILES_LIST=""
ARG COPS_SYSTEM=${_cops_SYSTEM}
ARG FOREGO_RELEASE=latest
ARG REMCO_RELEASE=latest
ARG GOSU_RELEASE=latest
ARG DOCKERIZE_RELEASE=latest
ARG CURL_SSL_OPTS=--tlsv1
ARG DOCKER_IMAGES_COMMIT=master
ARG COPS_HELPERS=/cops_helpers
ADD \
    helpers/up.sh \
    helpers/add_gosu.sh \
    helpers/system_detect.sh \
    helpers/add_frep.sh \
    helpers/add_confd.sh \
    helpers/add_dockerize.sh \
    helpers/add_forego.sh \
    helpers/add_opt_pkgs.sh \
    helpers/add_remco.sh \
    helpers/setup_locales.sh \
    helpers/cops_pkgmgr_install.sh \
    helpers/*_up.sh \
    helpers/*_clean.sh \
    rootfs/ \
    packages/*packages*.txt \
    ${EXTRA_FILES_LIST} \
    /tmp/corpusopssteroids/
RUN sh -exc 'pkgs="jq" &&\
    if ( apt-get --version >/dev/null 2>&1; );then\
        pkgs="$pkgs xz-utils";\
    else\
        pkgs="$pkgs xz";\
    fi\
    && NONINTERACTIVE=1 WANT_UPDATE=1 cops_pkgmgr_install.sh $pkgs'
RUN sh -c 'set -ex \
    && cd /tmp/corpusopssteroids \
    && : \
    && chmod +x *sh \
    && if [ ! -e $COPS_HELPERS ];then mkdir -p "$COPS_HELPERS";fi \
    && export PATH=$(pwd):$PATH \
    && _cops_SYSTEM=$(./system_detect.sh) \
    && cat ${_cops_SYSTEM}_optional_packages*.txt optional_packages*.txt > optional_packages.txt \
    && cat ${_cops_SYSTEM}_packages*.txt > packages.txt \
    && : fix logrorate global conf \
    && if [ -e /var/log ];then touch /var/log/syslog /var/log/messages;fi \
    && ./${_cops_SYSTEM}_up.sh \
    && ./add_opt_pkgs.sh \
    && ./add_frep.sh \
    && ./add_remco.sh \
    && ./add_confd.sh \
    && ./add_dockerize.sh \
    && ./add_gosu.sh \
    && ./add_forego.sh \
    && ln -sfv ${COPS_HELPERS}/supervisord-go /bin/supervisord-go \
    && DEBUG=1 ./setup_locales.sh \
    && sed -i -re "/var\\/log\\/messages \\{\\}/d" /etc/logrotate.conf\
    && sed -i -re "s/ dateext/nodateext/g" /etc/logrotate.conf\
    && if ! (grep -q /var/log/messages /etc/logrotate.conf);then\
           printf "\\n/var/log/messages {\\nmissingok\\n}\\n\\n" >>/etc/logrotate.conf;fi\
    && for i in bin/* system_detect.sh setup_locales.sh cops_pkgmgr_install.sh;do j=$(basename $i);cp -v $i /cops_helpers && ln -sfv /cops_helpers/$j /bin/$j;done\
    && ./${_cops_SYSTEM}_clean.sh \
    '
COPY --from=ochinchina/supervisord:latest \
    /usr/local/bin/supervisord ${COPS_HELPERS}/supervisord-go
ENV BACKUP_TYPE=elasticsearch
ADD helpers/system_detect.sh helpers/*_clean.sh /tmp/corpusopssteroids/
RUN sh -c 'set -ex \
    && echo fixperms >&2 \
    && ( chmod -vf g-wx,o-wx /etc/logrotate.d/* /etc/logrotate.conf || true ) \
    && echo cleanup >&2 \
    && cd /tmp/corpusopssteroids \
    && chmod +x *sh \
    && _cops_SYSTEM=$(./system_detect.sh) \
    && ./${_cops_SYSTEM}_clean.sh \
    && ./common_clean.sh \
    && cd / && rm -rf /tmp/corpusopssteroids /var/cache/apk/* /var/lib/apt/lists/*'
ADD helpers/system_detect.sh helpers/*_clean.sh /tmp/corpusopssteroids/
RUN sh -c 'set -ex \
    && echo fixperms >&2 \
    && ( chmod -vf g-wx,o-wx /etc/logrotate.d/* /etc/logrotate.conf || true ) \
    && echo cleanup >&2 \
    && cd /tmp/corpusopssteroids \
    && chmod +x *sh \
    && _cops_SYSTEM=$(./system_detect.sh) \
    && ./${_cops_SYSTEM}_clean.sh \
    && ./common_clean.sh \
    && cd / && rm -rf /tmp/corpusopssteroids /var/cache/apk/* /var/lib/apt/lists/*'
LABEL com.github.corpusops.docker-images-commit="$DOCKER_IMAGES_COMMIT"

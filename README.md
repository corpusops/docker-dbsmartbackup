# Docker based image for dbsmartbackup

## Support development
- Ethereum: ``0xa287d95530ba6dcb6cd59ee7f571c7ebd532814e``
- Bitcoin: ``3GH1S8j68gBceTeEG5r8EJovS3BdUBP2jR``
- [paypal](https://paypal.me/kiorky)


## corpusops/dbsmartbackup
### Description

This repository produces all those docker images:
- [corpusops/dbsmartbackup-legacy](https://hub.docker.com/r/corpusops/dbsmartbackup-legacy/)

### Volumes
- We use two main volumes!
    - a volume ``setup`` to share a configuration file to reconfigure files
    - a volume ``/srv/backups`` to store backups

#### Initialise setup volume
- To reconfigure any setting upon container (re)start, create/edit ``/setup/reconfigure.yml``
    - See [defaults](.ansible/roles/dbsmartbackup/defaults/main.yml)

    ```sh
    mkdir -p local/setup
    cat >local/setup/reconfigure.yml << EOF
    ---
    setting: value
    EOF
    ```

### Configuring via ansible

- See all options in [vars](.ansible/playbooks/roles/dbsmartbackup_vars/defaults/main.yml)

- ``local/setup/reconfigure.yml``

```yaml
cops_dbsmartbackup_confs:
  mydb:
    conf_path: /srv/backups/mydb.conf
    keep_lasts: 1
    type: postgresql
    keep_days: 2
    keep_logs: 7
    _periodicity: "0 3 * * *"
    free_form: |
      export HOST="172.17.0.2"
      export PORT="5432"
      export DBNAMES="db"
      export PASSWORD="xxxx"
      export DBUSER="dbuser"
      export PGUSER="$DBUSER"
      export RUNAS=""
      export PGPASSWORD="$PASSWORD"
  mymysqldb:
    conf_path: /srv/backups/mysql.conf
    keep_lasts: 1
    type: mysql
    keep_days: 2
    keep_logs: 7
    _periodicity: "0 3 * * *"
    free_form: |
      export HOST="mysql"
      export PORT="3306"
      export MYSQL_PORT="$PORT"
      export DBNAMES="yyy"
      export PASSWORD="xxx"
      export DBUSER="ocs"
      export RUNAS=""
```

example to save (locally) all pg databases
```yaml
cops_dbsmartbackup_confs:
  alldb:
    conf_path: /srv/backups/alldb.conf
    keep_lasts: 1
    type: postgresql
    keep_days: 2
    keep_logs: 7
    _periodicity: "0 3 * * *"
    free_form: |
      export HOST="localhost"
      export DBNAMES="all"
      export DBUSER="postgres"
      export PGUSER="$DBUSER"
      export RUNAS="$DBUSER"
```

### compose variant
```yaml
---
services:
  dbsmartbackup:
    restart: unless-stopped
    image: "corpusops/dbsmartbackup"
    tmpfs: [/run, /run/lock]
    volumes:
    - "/sys/fs/cgroup:/sys/fs/cgroup:ro"
    - "/srv/docker/portus/local/data/backups:/srv/backups"
    depends_on: [postgres, db]
    links: [postgres, db]
    environment:
    - |
      A_RECONFIGURE=---
      only_steps: true
      cops_dbsmartbackup_lifecycle_app_push_code: false
      cops_dbsmartbackup_s_docker_reconfigure: true
      cops_dbsmartbackup_s_first_fixperms: true
      cops_dbsmartbackup_s_setup: true
      cops_dbsmartbackup_s_manage_content: false
      cops_dbsmartbackup_confs:
        pg:
           conf_path: /srv/backups/pg.conf
           keep_lasts: 1
           type: postgresql
           keep_days: 2
           keep_logs: 7
           _periodicity: "0 3 * * *"
           free_form: |
             export HOST="postgres"
             export DBNAMES="all"
             export DBUSER="postgres"
             export PGUSER="$$DBUSER"
             export PASSWORD="xxx"
             export PGPASSWORD="$$PASSWORD"
             export RUNAS="$$(whoami)"
        mysql:
          conf_path: /srv/backups/mysql.conf
          keep_lasts: 1
          type: mysql
          keep_days: 2
          keep_logs: 7
          _periodicity: "0 3 * * *"
          free_form: |
            export HOST="db"
            export PORT="3306"
            export MYSQL_PORT="$$PORT"
            export DBNAMES="all"
            export PASSWORD="xxx"
            export DBUSER="root"
            export RUNAS="$$(whoami)"
    - |
      A_POSTCONFIGURE=---
      only_steps: true
      cops_dbsmartbackup_lifecycle_app_push_code: false
      cops_dbsmartbackup_s_manage_content: true
```


### Configuring manually

- A dbsmartbackup job need two things and relies on a cron daemon:
    - a dbsmartbackup compliant configuration file
    - a crontab that executes dbsmartbackup cron wrapper with that configuration file

- Eg ``data/mydb.conf``(``data``mounted to ``/srv/backups``)
    ```sh
  # A script can run only for one database type
  # and a specific host
  cfgpath="/etc/dbsmartbackup/postgresql_xxx.conf"
  DO_GLOBAL_BACKUP=""
  BACKUP_TYPE="postgresql"
  KEEP_LASTS="3"
  KEEP_DAYS="3"
  KEEP_WEEKS="0"
  KEEP_MONTHES="0"
  KEEP_LOGS="7"
  TOP_BACKUPDIR="/srv/backups"
  export HOST="foohost"
  export PORT="5432"
  export DBNAMES="db"
  export PASSWORD="xxx"
  export DBUSER="yyy"
  export PGUSER="$DBUSER"
  export PGPASSWORD="$PASSWORD"
  export RUNAS=""
  if [ -f "${cfgpath}.local" ];then
      . "${cfgpath}.local"
  fi
    ```

- Eg ``mycron`` (mounted to ``/etc/cron.d/mydbbackup``)
    ```crontab
    0 3 * * * root /srv/apps/dbsmartbackup/run_dbsmartbackup.sh /srv/backups/mydb.conf --quiet --no-colors
    ```

### Run this image through docker
- To pull & run this image (PRODUCTION) <br/>
  Note that The folllowing command implicitly create 2 volumes against local directories and the goal
  is to prepopulate the directories from the image content on the first run.<br/>
  Indeed, the -v option does not feed host directories, even if empty from an image content.

    ```sh
    docker pull corpusops/dbsmartbackup
    docker run \
      --name=my-dbsmartbackup-container \
      -v /sys/fs/cgroup:/sys/fs/cgroup:ro \
      -v $(pwd)/local/setup:/setup:ro \
      -v "$(pwd)/local/data:/srv/backups" \
      --security-opt seccomp=unconfined \
      -P -d -i -t corpusops/dbsmartbackup
    ```

- In development, you can add the following knob to indicate that you want to
  edit files.

    ```sh
    -e SUPEREDITORS=$(id -u)
    ```

### Build this image
- Install ``hashicorp/packer`` && ``docker``
- get the code
- run ``./bin/build.sh``

### Image provision notes
- See ``.ansible``, the image is (re)-configured using ansible.

### A note on file rights
- Docker file rights are a nightmare for developers
- We provide a very way to use, specially when you are on localhost,<br/>
  activly developping  your app to edit the files of the container,<br/>
  thanks to POSIX ACLS.
- You need two things to configure your app (normally good by dedfault):
    - ``cops_dbsmartbackup_supereditors_paths`` Tell which paths will be "opened" to the outside user(s) if default does not suit your need
    - ``cops_dbsmartbackup_supereditors`` Tell which user(s), (attention **UIDS**).<br/>
      The aforementioned command to launch container includes the ``SUPEREDITORS`` env var configured with the loggued in user
- Those settings can be overriden via ``/setup/reconfigure.yml``
- File rights are enforced upon container (re-)start
- If file rights are messed up too much, you can try this to enforce them

    ```sh
    docker exec -e SUPEREDITORS="$(id -u)" -ti <mycontainer> bash
    /srv/projects/<myproject>/fixperms.sh
    ```

## ansible
- Docker uses the [dbsmartbackup role](.ansible/roles/dbsmartbackup) underthehood which
  is generic and is not docker specific.
- You may use directly this role to provision dbsmartbackup on another host type.

### Steps to create cops docker compliant images
- We use via  bin/build.sh which launch [docker_build_chain](https://github.com/corpusops/corpusops.bootstrap/blob/master/hacking/docker_build_chain.py) ([doc](https://github.com/corpusops/corpusops.bootstrap/blob/master/doc/docker_build_chain.md#sumup-steps-to-create-corpusops-docker-compliant-images))



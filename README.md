# TBP Backup Service
Generic service to back-up/restore SQL snapshot and folders with user data.

## Backups
Backups will be placed into local folder, specified at file ```docker-compose.yml```.

### Create
```
$ docker-compose run my-project-backups /root/bin/create.sh
```

### Restore
```
$ docker-compose run my-project-backups /root/bin/restore.sh "<backup_folder>"
```

## Environment variables
| Name           | Usage                                                 | Example                          |
|----------------|-------------------------------------------------------|----------------------------------|
| MYSQL_HOST     | IP address / container name for MySQL/MariaDB service | ```my-container-mysql-server```  |
| MYSQL_USER     | MySQL/MariaDB user                                    | ```mysql-user```                 |
| MYSQL_PASSWORD | MySQL/MariaDB password                                | ```mysql-pass```                 |
| MYSQL_DATABASE | MySQL/MariaDB database name                           | ```my-database-name```           |
| TARGET_FOLDERS | List of folders to back-up, separated by spaces       | ```uploads locale user-images``` |

### docker-compose.yml example
```
version: "3.4"
services:
(...)
  my-project-backups:
    image: bitendian/tbp-backup-service:latest
    container_name: 'my-project-backups'
    labels:
      - traefik.enable=false
    volumes:
      - my-project-projects-data-volume:/mnt/repository
      - my-project-locale-volume:/mnt/locale
      - ./backups:/mnt/backups
    depends_on:
      - my-project-mysql
    links:
      - my-project-mysql
    environment:
      MYSQL_HOST: my-project-mysql
      MYSQL_DATABASE: my-database-name
      MYSQL_USER: mysql-user
      MYSQL_PASSWORD: mysql-pass
      TARGET_FOLDERS: repository locale
    networks:
      - my-project-internal
(...)
```

## Extended custom scripts
If ```/root/bin/pre-backup.sh``` exists, it will be executed **before** backup is done.

If ```/root/bin/post-restore.sh``` exists, it will be executed **after** restore is done.

### Adding custom scripts
Do this steps:
- Create a new service in your project. Call it ```backup-service```, for example.
- Add a ```Dockerfile``` into your ```backup-service``` folder.
- Extend image from ```tbp-backup-servie:latest```
- Copy your ```pre-backup.sh``` and/or ```post-restore.sh``` scripts to ```/root/bin``` image folder.
- Add into your ```docker-compose.yml``` files the build instructions necessaries to create your custom backup image.

#### Dockerfile example
```
FROM tbp-backup-service:latest AS base
COPY ./pre-backup.sh /root/bin/pre-backup.sh
COPY ./post-restore.sh /root/bin/post-restore.sh
```

#### docker-compose.yml example
```
version: "3.4"
services:
(...)
  my-project-backups:
    build:
      context: ./backup-service
    container_name: 'my-project-backups'
    labels:
      - traefik.enable=false
    volumes:
      - my-project-projects-data-volume:/mnt/repository
      - my-project-locale-volume:/mnt/locale
      - ./backups:/mnt/backups
    depends_on:
      - my-project-mysql
    links:
      - my-project-mysql
    environment:
      MYSQL_HOST: my-project-mysql
      MYSQL_DATABASE: my-database-name
      MYSQL_USER: mysql-user
      MYSQL_PASSWORD: mysql-pass
      TARGET_FOLDERS: repository locale
    networks:
      - my-project-internal
(...)
```

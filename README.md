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

### Example
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

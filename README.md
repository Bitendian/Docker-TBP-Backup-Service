# TBP Backup Service
Generic service to back-up/restore SQL snapshot and folders with user data.

## Parameters / environment variables
| Name | Usage | Example |
| ------ | ------ | ------ |
| MYSQL_HOST | IP address / container name for MySQL/MariaDB service | ```my-container-mysql-server``` |
| MYSQL_USER | MySQL/MariaDB user | ```mysql-user``` |
| MYSQL_PASSWORD | MySQL/MariaDB password | ```mysql-pass``` |
| MYSQL_DATABASE | MySQL/MariaDB database name | ```my-database-name``` |
| TARGET_FOLDERS | List of folders to back-up, separated by spaces | ```uploads locale user-images``` |


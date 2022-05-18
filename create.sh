#!/bin/bash

# Check environment variables
EXPECTED_VARS=('MYSQL_HOST' 'MYSQL_USER' 'MYSQL_PASSWORD' 'MYSQL_DATABASE');
for EXPECTED_VAR in ${EXPECTED_VARS} ; do
  if [ -z "${!EXPECTED_VAR}" ]
  then
    echo "ERROR: environment variable ${EXPECTED_VAR} must be defined";
    exit 1;
  fi
done

# Setup local variables
BACKUP_NAME=$(date +"%FT%T")
BACKUP_PATH=/mnt/backups/${BACKUP_NAME}

# Create backup
mkdir -p ${BACKUP_PATH} && \
mysqldump -h${MYSQL_HOST} -u${MYSQL_USER} -p${MYSQL_PASSWORD} ${MYSQL_DATABASE} > ${BACKUP_PATH}/snapshot.sql;

for FOLDER in ${TARGET_FOLDERS} ; do
  tar -C /mnt -j -c -f ${BACKUP_PATH}/${FOLDER}.tar.bz2 ${FOLDER};
done

# Create checksum
rm -f ${BACKUP_PATH}/checksums && cd ${BACKUP_PATH} && sha256sum ./* > ${BACKUP_PATH}/checksums && \
cd /mnt/backups && rm -f latest && ln -sf ${BACKUP_NAME} latest && \
echo "Backup created at ${BACKUP_NAME} (AKA latest)"

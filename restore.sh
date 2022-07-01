#!/bin/bash

# Check arguments
if [ $# -ne 1 ]; then
  echo "ERROR: usage $0 <backup_name>";
  exit 1;
fi

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
BACKUP_NAME=$1
BACKUP_PATH=/mnt/backups/${BACKUP_NAME}

# Check if backup folder exists
[ ! -d "${BACKUP_PATH}" ] && echo "ERROR: backup folder '${BACKUP_NAME}' not found." && exit -1

# Create new checksum
CHECKSUM_FILE=/tmp/checksum_$(date +"%FT%T")

rm -f ${CHECKSUM_FILE} && cd ${BACKUP_PATH} && declare -a files=()
for filename in *; do
  if [ $filename != 'checksums' ]
  then

    sha256sum ./$filename >> ${CHECKSUM_FILE};
    # Store filenames in files array
    if [ $filename != 'snapshot.sql' ]
    then
      files+=(${filename});
    fi

  fi
done

# Validate new checksum with backup checksum
diff ${CHECKSUM_FILE} ${BACKUP_PATH}/checksums &> /dev/null
DIFF_RESULT=$?
rm -f ${CHECKSUM_FILE}
if [ ${DIFF_RESULT} -ne 0 ]; then
  echo "ERROR: invalid checksum at '${BACKUP_NAME}'. Corrupted backup files?";
  exit -1;
fi

# Restore volumes in files array
echo "Unpacking volumes..."
for i in "${files[@]}"
do
  echo "$i"
	tar -C /mnt -j -x -f ${BACKUP_PATH}/$i
done

# Restore database
echo "Restoring database snapshot..."
mysql -h${MYSQL_HOST} -u ${MYSQL_USER} -p${MYSQL_PASSWORD} ${MYSQL_DATABASE} < ${BACKUP_PATH}/snapshot.sql;

echo "Backup restored from '${BACKUP_NAME}'"

exit 0;


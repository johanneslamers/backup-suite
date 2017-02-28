#!/usr/bin/env bash

CLIENT="XXX"
BACKUP_NAME="XXX-DB"

WEEK=`date +%V`
DATE=`date +%Y%m%d%H%M`

SAVE_DIR="/home/forge/backup"
S3_BUCKET="madebyjohannes-client-backup"

# Get MYSQL_USER and MYSQL_PASSWORD
source /home/forge/backup/.env

mysqldump -u ${MYSQL_USER} -p${MYSQL_PASSWORD} ${MYSQL_DATABASE} | gzip > ${SAVE_DIR}/${BACKUP_NAME}.sql.gz

if [ -e ${SAVE_DIR}/${BACKUP_NAME}-${DATE}.sql.gz ]; then

    # Upload to AWS
    aws s3 cp ${SAVE_DIR}/${BACKUP_NAME}-${DATE}.sql.gz s3://${S3_BUCKET}/${CLIENT}/${WEEK}/db/${BACKUP_NAME}-${DATE}.sql.gz

    # Test result of last command run
    if [ "$?" -ne "0" ]; then
        echo "Upload to AWS failed"
        exit 1
    fi

    # If success, remove backup file
    rm ${SAVE_DIR}/${BACKUP_NAME}-${DATE}.sql.gz

    # Exit with no error
    exit 0
elif [ ! -w "${TEMPDIR}" ]; then


fi

# Exit with error if we reach this point
echo "Backup file not created"
exit 1

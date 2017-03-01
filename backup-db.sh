#!/usr/bin/env bash

WEEK=`date +%V`
DATE=`date +%Y%m%d%H%M`

# Get all enviroment cridentials
source /home/forge/backup/.env

echo "Backing up database..."

mysqldump -u ${MYSQL_USER} -p${MYSQL_PASSWORD} ${MYSQL_DATABASE} | gzip > ${SAVE_DIR}/${BACKUP_NAME}-db-${DATE}.sql.gz

if [ -e ${SAVE_DIR}/${BACKUP_NAME}-${DATE}.sql.gz ]; 
then

    # Upload to AWS
    aws s3 cp ${SAVE_DIR}/${BACKUP_NAME}-db-${DATE}.sql.gz s3://${S3_BUCKET}/${CLIENT}/${WEEK}/db/${BACKUP_NAME}-db-${DATE}.sql.gz

    # Test result of last command run
    if [ "$?" -ne "0" ]; then
        echo "Upload to AWS S3 failed"
        exit 1
     else
        echo "Upload to AWS S3 successful"
        echo "Removing local backup file"
        # If success, remove backup file
        rm ${SAVE_DIR}/${BACKUP_NAME}-db-${DATE}.sql.gz
        echo "Local backup file "${BACKUP_FILE}" removed"
        echo " "
    fi

    # Exit with no error
    exit 0
fi

# Exit with error if we reach this point
echo "Backup file not created"
exit 1
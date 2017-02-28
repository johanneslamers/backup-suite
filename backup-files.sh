#!/usr/bin/env bash

# Warning: without leading '/' -> home/forge/default/public/static/
BACKUP_DIR="home/forge/default/public/static/"

WEEK=`date +%V`
DATE=`date +%Y%m%d%H%M`

echo "backing up files..."

# Backup site dir
tar czf ${SAVE_DIR}/${BACKUP_NAME}-files-${DATE}.tar -C / ${BACKUP_DIR}

if [ -e ${SAVE_DIR}/${BACKUP_NAME}-files-${DATE}.tar ]; then

    # Upload to AWS
    aws s3 cp ${SAVE_DIR}/${BACKUP_NAME}-files-${DATE}.tar s3://${S3_BUCKET}/${CLIENT}/${WEEK}/files/${BACKUP_NAME}-files-${DATE}.tar

    # Test result of last command run
    if [ "$?" -ne "0" ]; then
        echo "Upload to AWS failed"
        exit 1
    fi

    # If success, remove backup file
    rm ${SAVE_DIR}/${BACKUP_NAME}-files-${DATE}.tar

    echo "Local backup removed"
    # Exit with no error
    exit 0
fi


# Exit with error if we reach this point
echo "Backup file not created"
exit 1


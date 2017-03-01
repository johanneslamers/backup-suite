#!/usr/bin/env bash

WEEK=`date +%V` # Week number e.g 38
MONTH=`date +%B` # Month e.g January
DATE=`date +%Y-%m-%d_%Hh%Mm` # Date stamp e.g 2017-03-02_23h12m
DAY=`date +%A` # Day e.g. Monday

# Get all enviroment cridentials
source /home/forge/backup/.env

#### END CONFIGURATION ####

# make the temp directory if it doesn't exist and cd into it
mkdir -p ${SAVE_DIR}
cd ${SAVE_DIR}

## Check we can write to the backups directory
if [ -w "${SAVE_DIR}" ]
then
    # Do nothing and move along.
    echo "Found and is writable: "${SAVE_DIR}
    echo " "
else
    echo "Can't write to: "${SAVE_DIR}
    exit
fi

echo "Backup Start Time `date`"
echo "======================================================================"
echo "Backing up files..."

## Backup of all directories

for i in "${DIRECTORIES[@]}"
do
    # Make backup file variable
    BACKUP_FILE=${BACKUP_NAME}_${DATE}_${DAY}-$(echo $i | sed 's/\//-/g').tar.gz

    echo "======================================================================"
    echo "Backing up "$i" -> "${BACKUP_FILE}
    echo "----------------------------------------------------------------------"

    # Create tarball and compress it
    tar zcf ${SAVE_DIR}/${BACKUP_FILE} -C / $i 2>&1
    echo " "

    # Upload file to S3
    if [ -e ${BACKUP_FILE} ]; 
    then

        echo "======================================================================"
        echo "Uploading to S3"
        echo "----------------------------------------------------------------------"
        echo

        # Upload to AWS
        aws s3 cp ${SAVE_DIR}/${BACKUP_FILE} s3://${S3_BUCKET}/${CLIENT}/${WEEK}/files/${BACKUP_FILE} --storage-class "${S3_REDUNDANCY}"

        # Test result of last command run
        if [ "$?" -ne "0" ]; 
        then
            echo "Upload to AWS S3 failed"
            exit 1
        else
            echo "Upload to AWS S3 successful"
            echo "----------------------------------------------------------------------"
            echo "Removing local backup file"
            # If success, remove backup file
            rm ${SAVE_DIR}/${BACKUP_FILE}
            echo "Local backup file "${BACKUP_FILE}" removed"
            echo " "
        fi

        echo "Backup End Time `date`"
	    echo "======================================================================"
    fi
done

# Exit with error if we reach this point
echo "All Done! Yay!"
exit 1
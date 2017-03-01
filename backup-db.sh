#!/usr/bin/env bash

WEEK=`date +%V`
DATE=`date +%Y%m%d%H%M`

# Get all enviroment cridentials
source /home/forge/backup/.env

#### END CONFIGURATION ####

# make the temp directory if it doesn't exist and cd into it
mkdir -p ${SAVE_DIR}
cd ${SAVE_DIR}

## Check we can write to the backups directory
if [ -w "${SAVE_DIR}" ];
then
    # Do nothing and move along.
    echo "Found and is writable: "${SAVE_DIR}
    echo " "
else
    echo "Can't write to: "${SAVE_DIR}
    exit
fi

echo "Backing up database..."

# Check if MYSQL_DATABASE has value. If empty dump all databases
# http://serverfault.com/questions/7503/how-to-determine-if-a-bash-variable-is-empty
if [ -n "$MYSQL_DATABASE" ];
then

    # Temporary db dump path
    BACKUP_DB_PATH=${SAVE_DIR}/${BACKUP_NAME}-${DATE}-${MYSQL_DATABASE}.sql

    echo "Backing up single database: "${MYSQL_DATABASE}
    echo " "

    # Setup ignored tables
    IGNORED_TABLES_STRING=''
    for TABLE in "${EXCLUDED_TABLES[@]}"
    do
        IGNORED_TABLES_STRING+=" --ignore-table=${MYSQL_DATABASE}.${TABLE}"
    done

    echo "Ignored tables: "${IGNORED_TABLES_STRING}
    echo " "

    # dump database to its own sql file
    mysqldump -h${MYSQL_HOST} -P${MYSQL_PORT} -u${MYSQL_USER} -p${MYSQL_PASSWORD} ${MYSQL_DATABASE} --single-transaction --no-data > ${BACKUP_DB_PATH}
    mysqldump -h${MYSQL_HOST} -P${MYSQL_PORT} -u${MYSQL_USER} -p${MYSQL_PASSWORD} ${MYSQL_DATABASE} --no-create-info ${IGNORED_TABLES_STRING} >> ${BACKUP_DB_PATH}

    # repair and optimize database
    mysqlcheck -h${MYSQL_HOST} -P${MYSQL_PORT} -u${MYSQL_USER} -p${MYSQL_PASSWORD} ${MYSQL_DATABASE} --auto-repair --optimize --silent
    echo " "

else

    echo "Backing up all databases"
    echo " "

    # repair, optimize, and dump each database to its own sql file
    for DB in $(mysql -h$MYSQL_HOST -P$MYSQL_PORT -u$MYSQL_USER -p$MYSQL_PASSWORD -BNe 'show databases' | grep -Ev 'mysql|information_schema|performance_schema')
    do


        echo "Backing up database: "${DB}
        echo " "
        # Temporary db dump path
        BACKUP_DB_PATH=${SAVE_DIR}/${BACKUP_NAME}-${DATE}-${DB}.sql

        # Setup ignored tables
        IGNORED_TABLES_STRING=''
        for TABLE in "${EXCLUDED_TABLES[@]}"
        do
            IGNORED_TABLES_STRING+=" --ignore-table=${DB}.${TABLE}"
        done

        # dump each database to its own sql file
        mysqldump -h${MYSQL_HOST} -P${MYSQL_PORT} -u${MYSQL_USER} -p${MYSQL_PASSWORD} ${DB} --single-transaction --no-data > ${BACKUP_DB_PATH}
        mysqldump -h${MYSQL_HOST} -P${MYSQL_PORT} -u${MYSQL_USER} -p${MYSQL_PASSWORD} ${DB} --no-create-info ${IGNORED_TABLES_STRING} >> ${BACKUP_DB_PATH}

        # repair and optimize database
        mysqlcheck -h${MYSQL_HOST} -P${MYSQL_PORT} -u${MYSQL_USER} -p${MYSQL_PASSWORD} ${DB} --auto-repair --optimize --silent
        echo " "

    done

fi

# tar all the databases with --absolute-names.  don’t strip leading ‘/’s from file names
tar -czPf ${BACKUP_NAME}-${DATE}-db.tar.gz *.sql

if [ -e ${SAVE_DIR}/${BACKUP_NAME}-${DATE}-db.tar.gz ]; 
then

    # remove all .sql files
    echo "Removing .sql files"
    rm -f *.sql

    # Upload to AWS
    aws s3 cp ${SAVE_DIR}/${BACKUP_NAME}-${DATE}-db.tar.gz s3://${S3_BUCKET}/${CLIENT}/${WEEK}/db/${BACKUP_NAME}-${DATE}-db.tar.gz --storage-class "${S3_REDUNDANCY}"

    # Test result of last command run
    if [ "$?" -ne "0" ]; 
    then
        echo "Upload to AWS S3 failed"
        exit 1
    else
        echo "Upload to AWS S3 successful"
        echo "Removing local backup file"
        # If success, remove backup file
        rm ${SAVE_DIR}/${BACKUP_NAME}-${DATE}-db.tar.gz
        echo "Local backup file "${BACKUP_NAME}-${DATE}-db.tar.gz" removed"
        echo " "
    fi

    # Exit with no error
    exit 0
fi

# Exit with error if we reach this point
echo "Backup file not created"
exit 1
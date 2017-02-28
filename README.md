Laravel Forge Backup Suite
=========



## Install AWS CLI
SSH into your server. 
We'll install the AWS CLI tool using Python PIP, a Python package manager.

````
# Install Pip
sudo apt-get install -y python-pip

# Install AWS CLI tool globally
sudo pip install awscli

# Check to ensure it exists
which aws

# Configure AWS - adding the KEY, SECRET KEY, default zone and default output format
aws configure
> YOUR KEY HERE
> YOUR SECRET KEY HERE
> eu-west-2
> json
````

## Setup backup location and credentials
Then we can the backup folder and the environment file that holds our credentials.

````
mkdir ~/backup
cd ~/backup
vim .env
````
Paste your .env credentials and close vim with ``ESC`` followed by ``:wq``

## Setup backup scripts
Then we can create our backup shell scripts.
- backup-db.sh: This will export the database, compress it, and upload it to our S3 bucket.
- backup-files.sh: This will export the files, tarball's it, and upload it to our S3 bucket.

````
vim backup-db.sh
vim backup-files.sh
````
Paste your scripts and close vim with ``ESC`` followed by ``:wq``

Make the scripts executable with chmod and test it.

````
chmod +x backup-db.sh
chmod +x backup-files.sh
bash backup-db.sh
bash backup-files.sh
````

## Add crontask in Laravel Forge
Add these commands to the scheduled job. And run as forge user. 

#### Backup database
````
/usr/bin/env bash /home/forge/backup/backup-db.sh &>> /home/forge/backup/backup-db.log
````
#### Backup files
````
/usr/bin/env bash /home/forge/backup/backup-files.sh &>> /home/forge/backup/backup-files.log
````

## Tip: Cleanup S3 Backups

Within S3 locate your bucket properties and find the “Lifecycle” option. Then just create a rule and you can delete old backups any number of days after they were created. I created a rule called “Delete Old Backups” that runs on the whole bucket and permanently deletes items created 30 days ago.


Based on https://serversforhackers.com/video/backup-to-s3

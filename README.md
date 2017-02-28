Laravel Forge Backup Suite
=========



## Install AWS CLI
SSH into your server. 
We'll install the AWS CLI tool using Python PIP, a Python package manager.

````
# Install Pip
sudo apt-get install -y python-pip

# Install AWS CLI tol globally
sudo pip install awscli

# Check to ensure it exists
which aws

# Configure AWS - adding the id, key, default zone and default output format
aws configure
> YOUR KEY HERE
> YOUR SECRET KEY HERE
> eu-west-2
> json

````
## Setup backup location
Then we can the backup folder and the .env file to hold our MySQL database credentials.

````
mkdir ~/backup
cd ~/backup
vim .env
````

## Setup backup scripts
Then we can create our backup shell scripts.
- backup-db.sh: This will export the database, compress it, and upload it to our S3 bucket.
- backup-files.sh: This will export the files, tarball's it, and upload it to our S3 bucket.

````
vim backup-db.sh
vim backup-files.sh
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

## Protip:
Add Lifecycle for you S3 files in your AWS Console to automatic delete backup after x dates.

> Based on https://serversforhackers.com/video/backup-to-s3

Backup Suite to Amazon AWS S3
=========

You’ve setup your server (for example with Serverpilot or Laravel Forge on Digital Ocean), but have you thought about backups? 
This script backups important data, such as database and file dumps, securely to S3, than deletes the local backups for security reasons.

Amazon S3 can be an interestingly safe and cheap way to store your important data. Some of the most important data in the world is saved in... MySQL, and surely yours is quite important, so you need such a script.
All sensitive information is saved in a ``.env`` file. 

Backups are stored in the following directory structure separated by client and week number (10):

**Files:** ``S3://yourbucket/client/10/files/backup_name-20170301-folder.tar.gz``

**Database:** ``S3://yourbucket/client/10/db/backup_name-20170301-db.sql.gz``

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

**Tip:** Do NOT configure AWS CLI with your root AWS credentials - yes it will work, but would you store your root server password in a plaintext file? No, and your AWS credentials give the holder access to unlimited resources, your billing details, your machine images, everything.
Just  create a new user/group that only has access to S3 and use those credentials to configure s3. 

## Setup backup location and credentials
Now we create the backup folder and the environment file that holds our credentials.

````
mkdir ~/backup
cd ~/backup
vim .env
````
Don’t forget to add your credentials in the appropriate variables, as well as to modify the paths based on your server and AWS setup. 

Now paste the .env credentials and close vim with ``ESC`` followed by ``:wq``

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

## Add cronjob 
Add these commands to the scheduled job.

#### Backup database
````
/usr/bin/env bash /home/forge/backup/backup-db.sh &>> /home/forge/backup/backup-db.log
````
#### Backup files
````
/usr/bin/env bash /home/forge/backup/backup-files.sh &>> /home/forge/backup/backup-files.log
````

## Cleanup S3 Backups

Within S3 locate your bucket properties and find the “Lifecycle” option. Then just create a rule and you can delete old backups any number of days after they were created. I created a rule called “Delete Old Backups” that runs on the whole bucket and permanently deletes items created 30 days ago.


## Alternative DB backup with AUTOMYSQLBACKUP
Backup your datasbase with AUTOMYSQLBACKUP. Installation is pretty simple:

``sudo apt-get install automysqlbackup`` 

You’re done! Backups will be made daily. You’re done! Backups will be made daily.
All your databases and will be stored in ``/var/lib/automysqlbackup``. 

If you like to make manual backup just run ``sudo automysqlbackup``. 
For more information on installing automysqlbackup go to: [Install automysqlbackup on Ubuntu](https://gist.github.com/janikvonrotz/9488132)


# Source
- [Servers for hackers | Backup to S3](https://serversforhackers.com/video/backup-to-s3)
# Amazon S3 Backup Bot 
**Relax, it's backed up. Off site, on line, in case.** 🤖

## Features
* All configuration is done in the ``.env`` file, rather than in the scripts themselves
* Uploads the backups to Amason AWS S3
* After upload deletes the tarred files from the local server
* Dumps each backup folder into its own file
* Checks, repairs, and optimizes each MySQL database
* Compress files before upload
* Detailed information and comments
* S3 storage class options to cut costs
* Clear folder structure in S3


## Summary
You’ve setup your server (for example with Serverpilot or Laravel Forge on Digital Ocean), but have you thought about backups? 
This script backups important data, such as database and file dumps, uploads it securely to S3, than deletes the local backups for security reasons.

Amazon S3 can be an interestingly safe and cheap way to store your important data. Some of the most important data in the world is saved in... MySQL, and surely yours is quite important, so you need such a script.


## Folder structure in S3
Backups are stored in the following directory structure separated by client and week number (10) and type

**Files:** ``S3://yourbucket/client/10/files/backup_name_2017-03-01_10h18m_Wednesday-folder.tar.gz``

**Database:** ``S3://yourbucket/client/10/db/backup_name_2017-03-01_10h18m_Wednesday-db.tar.gz``




## Getting started

### 1. Install AWS CLI
Logon your server with SSH
We'll install the AWS CLI tool using Python PIP, a Python package manager.

````
# Install Pip
sudo apt-get install -y python-pip

# Install AWS CLI tool globally
sudo pip install awscli

# Check to ensure it exists
which aws
````

**Tip:** Do NOT configure AWS CLI with your root AWS credentials - yes it will work, but would you store your root server password in a plaintext file? No, and your AWS credentials give the holder access to unlimited resources, your billing details, your machine images, everything.
Just create a new user/group that only has access to S3 and use those credentials to configure S3. 

````
# Configure AWS - adding the KEY, SECRET KEY, default zone and default output format

aws configure
> YOUR KEY HERE
> YOUR SECRET KEY HERE
> eu-west-2
> json
````

### 2. Setup backup location and configuration
Now we create the backup folder and the environment file that holds our credentials.

````
mkdir ~/backup
cd ~/backup
````
All configuration is done in the .env file, rather than in the scripts themselves. So don’t forget to add your credentials in the appropriate variables, as well as to modify the paths based on your server and AWS setup. 
Open .env with vim and paste the .env credentials. 

````
vim .env
````
Now close vim with ``ESC`` followed by ``:wq``

### 3. Setup backup scripts
Now we can create our backup shell scripts.
- backup-db.sh: This will export the database, compress it, and upload it to our S3 bucket.
- backup-files.sh: This will export the files, tarball's it, and upload it to our S3 bucket.

````
vim backup-db.sh
vim backup-files.sh
````
Paste your scripts and close vim with ``ESC`` followed by ``:wq``

#### 4. Test your scripts
Make the scripts executable with chmod

````
chmod +x backup-db.sh
chmod +x backup-files.sh
````
And test the scripts

````
bash backup-db.sh
bash backup-files.sh
````

### 5. Add cronjob 
Add these commands to the scheduled job.

##### Backup database
````
/usr/bin/env bash /home/forge/backup/backup-db.sh &>> /home/forge/backup/backup-db.log
````
##### Backup files
````
/usr/bin/env bash /home/forge/backup/backup-files.sh &>> /home/forge/backup/backup-files.log
````

## Cleanup S3 Backups

Within S3 locate your bucket properties and find the “Lifecycle” option. Then just create a rule and you can delete old backups any number of days after they were created. I created a rule called “Delete Old Backups” that runs on the whole bucket and permanently deletes items created 30 days ago.


## Alternative DB backup with automysqlbackup
Backup your datasbase with automysqlbackup. Installation is pretty simple: ``sudo apt-get install automysqlbackup`` 
You’re done! Backups will be made daily.
All your databases will be stored in ``/var/lib/automysqlbackup``. 
If you like to make manual backup just run ``sudo automysqlbackup``. 

For more information on installing automysqlbackup go to: [Install automysqlbackup on Ubuntu](https://gist.github.com/janikvonrotz/9488132)


# Sources
- [Servers for hackers | Backup to S3](https://serversforhackers.com/video/backup-to-s3)
- [Install automysqlbackup on Ubuntu](https://gist.github.com/janikvonrotz/9488132)
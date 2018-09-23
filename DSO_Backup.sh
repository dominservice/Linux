#!/bin/bash

##################################################
###                                   ############
### Created by Mateusz Domin          ############
### contakt biuro@dso.biz.pl          ############
### WEB https://dso.biz.pl            ############
###                                   ############
### date create 11.08.2018r           ############
###                                   ############
##################################################
### FTP login credentials below ###
FTPU="user_ftp"
FTPP="pass_ftp"
FTPS="127.0.0.1"

### MySQL login credentials below ###
MySQLU="root"
MySQLP="pass"
MySQLDB="db_name"

### Local user
USER="itm"
PARH_SH="/opt/dso_backup"

### Date created backup ###
NOW=$(date +"%d_%m_%Y_%H_%M_%S")
### Days to check old backups | default +3 ###
DAYS=+3

### Directories and files ###
BACKUP_FOLDER="$PARH_SH/data"
DATA_FOLDER="/home"
FTP_DIRECTORY="/backup/"
ls -la $DATA_FOLDER
BD_FILE="$DATA_FOLDER/Backup_dso_DB_$NOW.sql"
DATA_FILE_NAME="Backup_dso_$NOW.tar.gz"
DATA_FILE="$BACKUP_FOLDER/$DATA_FILE_NAME"

### MySQL Dump
touch $BD_FILE
mysqldump --user=$MySQLU --password=$MySQLP --default-character-set=utf8 $MySQLDB > $BD_FILE ### | gzip > $BD_FILE

chown $MySQLU "$BD_FILE"

find "$DATA_FOLDER" -name Backup_dso_DB_* -mtime $DAYS -exec rm {} \;

tar -cvzf $DATA_FILE $DATA_FOLDER
cd $BACKUP_FOLDER
export GLOBIGNORE=$DATA_FILE_NAME;rm -rf *;export GLOBIGNORE=;

lftp -f "
open $FTPS
user $FTPU $FTPP
lcd $BACKUP_FOLDER
mirror --reverse --delete --verbose $BACKUP_FOLDER $FTP_DIRECTORY
bye
"

exit 0

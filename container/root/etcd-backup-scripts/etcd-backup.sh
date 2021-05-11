#!/bin/bash

DATE=$(date +%Y%m%dT%H%M%S)

echo "STARTING THE ETCD BACKUP SCRIPT"

# Attempting to call the regular backup script as our first attempt
/etcd-backup-scripts/cluster-backup.sh /assets/backup

echo "Trying to run etcd-backup-disconnected.sh"
    
if [ $? -eq 0 ]; then
   
    cd /assets
    ls -l
    echo "INFO" "Compressing etcd snapshot..."
    export XZ_OPT=-5
    
    echo "Creating backupfile"
    mkdir /etcd-backup
    cp -r /assets/etcd-backup-${DATE}.tar.xz.enc /etcd-backup/
    ls /etcd-backup
    #rm -r /backup/assets/*
  
    exit 0
fi
echo "Backup attempts failed. Please FIX !!!"
exit 1

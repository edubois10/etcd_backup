#!/bin/bash

DATE=$(date +%Y%m%dT%H%M%S)
    
read VAULT_SERVER < /etcd-backup-scripts/etcd-backup-vault-server/vault-server
read VAULT_TOKEN < /etcd-backup-scripts/etcd-backup-vault-key/etcd-backup-secret
read AZURE_STORAGE_URL < /etcd-backup-scripts/etcd-backup-azure-storage-url/azure-url

VAULT_KEY=$(curl -k -H "X-Vault-Token: $VAULT_TOKEN" -X GET $VAULT_SERVER | jq -r '.data.data.encryption')
AZURE_STORAGE_TOKEN=$(curl -k -H "X-Vault-Token: $VAULT_TOKEN" -X GET $VAULT_SERVER | jq -r '.data.data.azureKey')  

echo "STARTING THE ETCD BACKUP SCRIPT"

# Attempting to call the regular backup script as our first attempt
/etcd-backup-scripts/cluster-backup.sh /assets/backup

echo "Trying to run etcd-backup-disconnected.sh"
    
if [ $? -eq 0 ]; then
   
    cd /assets
    ls -l
    echo "INFO" "Compressing etcd snapshot..."
    export XZ_OPT=-5
    tar -cvJf "etcd-backup-${DATE}.tar.xz" "backup"

    echo "INFO" "Encrypting compressed etcd snapshot using generated symmetric key..."
    openssl enc -aes-256-cbc -salt -in "etcd-backup-${DATE}.tar.xz" -out "etcd-backup-${DATE}.tar.xz.enc" -pass "pass:${VAULT_KEY}"
    
    echo "Creating backupfile"
    mkdir /etcd-backup-az
    cp -r /assets/etcd-backup-${DATE}.tar.xz.enc /etcd-backup-az/
    ls /etcd-backup-az
    #rm -r /backup/assets/*
    echo "Coping backup file into Azure Storage Blob"
    azcopy copy "/etcd-backup-az/*" "${AZURE_STORAGE_URL}/${AZURE_STORAGE_TOKEN}" --recursive
    exit 0
fi
echo "Backup attempts failed. Please FIX !!!"
exit 1

FROM registry.access.redhat.com/ubi8/ubi:latest

#ARG ETCD_VERSION=3.3.18

USER root
COPY ./subcharts/etcd-backup/container/root /

RUN chmod 755 /etcd-backup-scripts/etcd-backup.sh

RUN chmod 755 /etcd-backup-scripts/cluster-backup.sh

RUN  mkdir /tmp/etcd 
        
RUN  cd /tmp/etcd
    
RUN  curl -O -L "https://github.com/etcd-io/etcd/releases/download/v3.3.18/etcd-v3.3.18-linux-amd64.tar.gz"

RUN  mv etcd-v3.3.18-linux-amd64.tar.gz /tmp/etcd

RUN  tar xzvf /tmp/etcd/*.tar.gz -C /tmp/etcd --strip-components=1 --no-same-owner

RUN  cp /tmp/etcd/etcdctl /usr/bin/etcdctl
        
RUN  mv /tmp/etcd/etcdctl /usr/local/bin/etcdctl

RUN  chmod 755 /usr/local/bin/etcdctl 
    
RUN  rm -rf /tmp/etcd 

RUN  yum install -y jq 

RUN  yum install -y openssl 

RUN  yum install -y python3-pip 

RUN  yum clean all 

RUN  rm -rf /var/cache/yum 

RUN  pip3 install azure-cli 
        
RUN  yum install -y wget

RUN  yum install -y xz

RUN  wget https://aka.ms/downloadazcopy-v10-linux 

RUN  tar -xvf downloadazcopy-v10-linux

RUN  cp ./azcopy_linux_amd64_*/azcopy /usr/bin/

LABEL name="openpaas/openpaas-etcd-backup" \
      summary="Openpaas image used to backup etcd storage and push it to an Azure blob" \
      description="An image which contains all the necessary tools to create a backup of etcd storage via API and to store it into an Azure blob" \
      url="None" \
      io.k8s.display-name="openpaas-etcd-backup" \
      io.k8s.description="An image which contains all the necessary tools to create a backup of etcd storage via API and to store it into an Azure blob" \
      io.openshift.expose-services="" \
      io.openshift.tags="openpaas,etcd,backup,s3" \
      version="1.0" \
      release="1" \
      architecture="x86_64"

ENTRYPOINT [ "/bin/sh", "-c" ]
CMD [ "/etcd-backup-scripts/etcd-backup.sh" ]

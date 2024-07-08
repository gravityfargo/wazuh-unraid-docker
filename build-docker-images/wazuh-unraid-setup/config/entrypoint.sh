#!/bin/bash
# Wazuh Docker Copyright (C) 2017, Wazuh Inc. (License GPLv2)

##############################################################################
# Copy configuration files
##############################################################################
echo "Copying configuration files"
rm -rf /wazuh-indexer/certs
rm -rf /wazuh-certificates
# cp /config/certs.yml /wazuh-indexer/certs.yml
cp /config/certs.yml /config.yml

# indexer
mkdir -p /wazuh-indexer/certs
mkdir -p /wazuh-indexer/wazuh-indexer-data
cp /config/wazuh.indexer.yml /wazuh-indexer/opensearch.yml
# chmod 0600 /wazuh-indexer/opensearch.yml
cp /config/internal_users.yml /wazuh-indexer/internal_users.yml
# chmod 0600 /wazuh-indexer/internal_users.yml

# manager
cp /config/wazuh_manager.conf /wazuh-manager/ossec.conf

# dashboard
mkdir -p /wazuh-dashboard/certs
cp /config/opensearch_dashboards.yml /wazuh-dashboard/opensearch_dashboards.yml
cp /config/wazuh.yml /wazuh-dashboard/wazuh.yml

chown 1000:1000 -R /wazuh-dashboard
chown 1000:1000 -R /wazuh-indexer
chown 1000:1000 -R /wazuh-manager


##############################################################################
# Downloading Cert Gen Tool
##############################################################################

echo "Downloading the tool to create the certificates"
## Variables
CERT_TOOL=wazuh-certs-tool.sh
PASSWORD_TOOL=wazuh-passwords-tool.sh
PACKAGES_URL=https://packages.wazuh.com/4.8/
PACKAGES_DEV_URL=https://packages-dev.wazuh.com/4.8/

## Check if the cert tool exists in S3 buckets
CERT_TOOL_PACKAGES=$(curl --silent -I $PACKAGES_URL$CERT_TOOL | grep -E "^HTTP" | awk '{print $2}')
CERT_TOOL_PACKAGES_DEV=$(curl --silent -I $PACKAGES_DEV_URL$CERT_TOOL | grep -E "^HTTP" | awk '{print $2}')

## If cert tool exists in some bucket, download it, if not exit 1
if [ "$CERT_TOOL_PACKAGES" = "200" ]; then
    curl -o $CERT_TOOL $PACKAGES_URL$CERT_TOOL -s
    echo "Download complete."
elif [ "$CERT_TOOL_PACKAGES_DEV" = "200" ]; then
    curl -o $CERT_TOOL $PACKAGES_DEV_URL$CERT_TOOL -s
    echo "Download complete."
else
    echo "The tool to create the certificates does not exist on the server."
    echo "ERROR: certificates were not created"
    exit 1
fi

chmod 700 /$CERT_TOOL

##############################################################################
# Creating Cluster certificates
##############################################################################

echo "Creating cluster certificates"
## Execute cert tool and parsin cert.yml to set UID permissions
source /$CERT_TOOL -A
nodes_server=$(cert_parseYaml /config.yml | grep -E "nodes[_]+server[_]+[0-9]+=" | sed -e 's/nodes__server__[0-9]=//' | sed 's/"//g')
node_names=($nodes_server)

echo "Moving created certificates to the destination directory"
cp /wazuh-certificates/* /wazuh-indexer/certs/
# cp /wazuh-indexer/certs/root-ca.pem /wazuh-indexer/certs/root-ca-manager.pem
# cp /wazuh-indexer/certs/root-ca.key /wazuh-indexer/certs/root-ca-manager.key

mv /wazuh-indexer/certs/wazuh-indexer-key.pem /wazuh-indexer/certs/wazuh.indexer.key
mv /wazuh-indexer/certs/wazuh-indexer.pem /wazuh-indexer/certs/wazuh.indexer.pem
mv /wazuh-indexer/certs/wazuh-manager.pem /wazuh-indexer/certs/filebeat.pem
mv /wazuh-indexer/certs/wazuh-manager-key.pem /wazuh-indexer/certs/filebeat.key

mv /wazuh-indexer/certs/wazuh-dashboard-key.pem /wazuh-dashboard/certs/wazuh-dashboard-key.pem
mv /wazuh-indexer/certs/wazuh-dashboard.pem /wazuh-dashboard/certs/wazuh-dashboard.pem

# chown 999:999  /wazuh-indexer/certs/root-ca-manager.pem
# chown 999:999  /wazuh-indexer/certs/root-ca-manager.key

chmod -R 500 /wazuh-indexer/certs
chmod -R 400 /wazuh-indexer/certs/*
chown 1000:1000 /wazuh-indexer/certs/*

chmod 500 /wazuh-dashboard/certs
chmod 400 /wazuh-dashboard/certs/*
chown 1000:1000 /wazuh-dashboard/certs/*

echo "Certificates created successfully"
echo "wazuh-unraid-setup: Finished!"

# for i in ${node_names[@]};
# do
#   chown 999:999 " /wazuh-indexer/certs/${i}.pem"
#   chown 999:999 " /wazuh-indexer/certs/${i}-key.pem"
# done

#!/bin/bash
# Wazuh Docker Copyright (C) 2017, Wazuh Inc. (License GPLv2)

if [ "${INSTALL_AGENT}" = "true" ]; then
    echo "Building the Agent for Unraid"
    curl -Ls https://github.com/wazuh/wazuh/archive/v4.8.0.tar.gz | tar zx
    rm /wazuh-4.8.0/etc/preloaded-vars.conf
    cp /config/preloaded-vars.conf /wazuh-4.8.0/etc/preloaded-vars.conf
    ./wazuh-4.8.0/install.sh
    chmod g+w rids/
fi

if [ "${INSTALL_SCRIPTS}" = "true" ]; then
    echo "Creating the User Scripts"
    mkdir -p /scripts/wazuh_prep
    mkdir -p /scripts/wazuh_agent_start
    mkdir -p /scripts/wazuh_agent_stop

    echo "- wazuh_prep"
    cat <<-EOF >/scripts/wazuh_prep/name
		wazuh_prep
	EOF

    cat <<-EOF >/scripts/wazuh_prep/script
		#!/bin/bash
		sysctl -w vm.max_map_count=262144
        /usr/sbin/useradd -u 999 wazuh
		/usr/sbin/groupmod -g 999 wazuh
	EOF

    echo "- wazuh_agent_start"
    cat <<-EOF >/scripts/wazuh_agent_start/name
		wazuh_agent_start
	EOF

    cat <<-EOF >/scripts/wazuh_agent_start/script
		#!/bin/bash

		${AGENT_DIRETORY}/bin/wazuh-control start
	EOF

    echo "- wazuh_agent_stop"
    cat <<-EOF >/scripts/wazuh_agent_stop/name
		wazuh_agent_stop
	EOF

    cat <<-EOF >/scripts/wazuh_agent_stop/script
		#!/bin/bash
		${AGENT_DIRETORY}/bin/wazuh-control stop
	EOF
fi

echo "Nuking previous app files..."
rm -rf /wazuh-indexer/*
rm -rf /wazuh-manager/*
rm -rf /wazuh-dashboard/*

echo "Copying configuration files"
rm -rf /wazuh-indexer/certs
rm -rf /wazuh-certificates
# cp /config/certs.yml /wazuh-indexer/certs.yml
cp /config/certs.yml /config.yml

echo "- indexer"
mkdir -p /wazuh-indexer/certs
mkdir -p /wazuh-indexer/wazuh-indexer-data
cp /config/wazuh.indexer.yml /wazuh-indexer/opensearch.yml
cp /config/internal_users.yml /wazuh-indexer/internal_users.yml
chown 1000:1000 -R /wazuh-indexer

echo "- manager"
mkdir -p /wazuh-manager/certs
mkdir -p /wazuh-manager/ossec_logs
mkdir -p /wazuh-manager/ossec_queue
cp /config/wazuh_manager.conf /wazuh-manager/ossec.conf
cp /config/preloaded-vars.conf /wazuh-manager/unraid-preloaded-vars.conf
chown 999:999 -R /wazuh-manager

echo "- dashboard"
mkdir -p /wazuh-dashboard/certs
cp /config/opensearch_dashboards.yml /wazuh-dashboard/opensearch_dashboards.yml
cp /config/wazuh.yml /wazuh-dashboard/wazuh.yml
chown 1000:1000 -R /wazuh-dashboard

echo "Downloading Cert Gen Tool"

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

echo "Creating Cluster certificates"

## Execute cert tool and parsin cert.yml to set UID permissions
source /$CERT_TOOL -A
nodes_server=$(cert_parseYaml /config.yml | grep -E "nodes[_]+server[_]+[0-9]+=" | sed -e 's/nodes__server__[0-9]=//' | sed 's/"//g')
node_names=($nodes_server)

echo "Moving created certificates to the destination directories"

echo "- indexer"
cp /wazuh-certificates/root-ca.key /wazuh-indexer/certs/root-ca.key
cp /wazuh-certificates/root-ca.pem /wazuh-indexer/certs/root-ca.pem
cp /wazuh-certificates/wazuh-indexer-key.pem /wazuh-indexer/certs/wazuh.indexer.key
cp /wazuh-certificates/wazuh-indexer.pem /wazuh-indexer/certs/wazuh.indexer.pem
cp /wazuh-certificates/admin.pem /wazuh-indexer/certs/admin.pem
cp /wazuh-certificates/admin-key.pem /wazuh-indexer/certs/admin-key.pem
chmod -R 500 /wazuh-indexer/certs
chmod -R 400 /wazuh-indexer/certs/*
chown 1000:1000 -R /wazuh-indexer/certs

echo "- dashboard"
cp /wazuh-certificates/root-ca.pem /wazuh-dashboard/certs/root-ca.pem
cp /wazuh-certificates/wazuh-dashboard.pem /wazuh-dashboard/certs/wazuh-dashboard.pem
cp /wazuh-certificates/wazuh-dashboard-key.pem /wazuh-dashboard/certs/wazuh-dashboard-key.pem
chmod -R 500 /wazuh-dashboard/certs
chmod -R 400 /wazuh-dashboard/certs/*
chown 1000:1000 -R /wazuh-dashboard/certs

echo "- manager"
cp /wazuh-certificates/root-ca.pem /wazuh-manager/certs/root-ca.pem
cp /wazuh-certificates/wazuh-manager.pem /wazuh-manager/certs/filebeat.pem
cp /wazuh-certificates/wazuh-manager-key.pem /wazuh-manager/certs/filebeat.key
chmod -R 500 /wazuh-manager/certs
chmod -R 400 /wazuh-manager/certs/*
chown 999:999 -R /wazuh-manager/certs

echo "wazuh-unraid-setup: Finished!"

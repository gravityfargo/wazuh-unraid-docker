#!/bin/bash
# Wazuh Docker Copyright (C) 2017, Wazuh Inc. (License GPLv2)
# Modifications by GitHub user gravityfargo, 2024

install_confs() {
    cp /config/wazuh_manager.conf /wazuh-manager/ossec.conf
    cp /config/preloaded-vars.conf /wazuh-manager/unraid-preloaded-vars.conf
    chown 999:999 -R /wazuh-manager
    echo "Copied manager configuration files"

    cp /config/opensearch_dashboards.yml /wazuh-dashboard/opensearch_dashboards.yml
    cp /config/wazuh.yml /wazuh-dashboard/wazuh.yml
    chown 1000:1000 -R /wazuh-dashboard
    echo "Copied dashboard configuration files"

    echo "Modifying configuration files"

    sed -i "s,name: wazuh.indexer,name: ${INDEXER_NAME},1" /config/certs.yml
    sed -i "s,ip: wazuh.indexer,ip: ${INDEXER_IP},1" /config/certs.yml
    sed -i "s,name: wazuh.manager,name: ${MANAGER_NAME},1" /config/certs.yml
    sed -i "s,ip: wazuh.manager,ip: ${MANAGER_IP},1" /config/certs.yml
    sed -i "s,name: wazuh.dashboard,name: ${DASHBOARD_NAME},1" /config/certs.yml
    sed -i "s,ip: wazuh.dashboard,ip: ${DASHBOARD_IP},1" /config/certs.yml

    echo "- wazuh.indexer.yml" # Indexer
    sed -i "s,network.host:.*,network.host: \"${INDEXER_IP}\",1" /config/wazuh.indexer.yml
    sed -i "s,node.name:.*,node.name: \"${INDEXER_NAME}\",1" /config/wazuh.indexer.yml

    echo "- wazuh.yml" # Dashboard
    sed -i "s,url:.*,url: \"https://${MANAGER_IP}\",1" /config/wazuh.yml
    sed -i "s,username:.*,username: ${API_USERNAME},g" /config/wazuh.yml
    sed -i "s,password:.*,password: \"${API_PASSWORD}\",g" /config/wazuh.yml

    echo "- opensearch_dashboards.conf" # Dashboard
    sed -i "s,server.host:.*,server.host: ${DASHBOARD_IP},1" /config/opensearch_dashboards.yml
    sed -i "s,opensearch.hosts:.*,opensearch.hosts: https://${INDEXER_IP}:9200,1" /config/opensearch_dashboards.yml

    echo "- wazuh_manager.conf" # Manager
    sed -i "s,<host>https://wazuh.indexer:9200</host>,<host>https://${INDEXER_IP}:9200</host>,1" /config/wazuh_manager.conf

    echo "- preloaded-vars.conf" # Agent
    sed -i "s,USER_AGENT_SERVER_IP=.*,USER_AGENT_SERVER_IP=\"${MANAGER_IP}\",g" /config/preloaded-vars.conf
}

install_agent() {
    echo "Downloading and installing agent tarball"
    curl -Ls https://github.com/wazuh/wazuh/archive/v4.8.0.tar.gz | tar zx
    cp /config/preloaded-vars.conf /wazuh-4.8.0/etc/preloaded-vars.conf

    if [ "${VERBOSE}" = "true" ]; then
        ./wazuh-4.8.0/install.sh
    else
        echo "Running install.sh"
        ./wazuh-4.8.0/install.sh > /dev/null 2>&1 &
        PID=$!
        while kill -0 $PID 2> /dev/null; do
            echo -n "."
            sleep 1
        done
        echo
        echo "Installation completed."
    fi
    # this is probably really insecure, but I got tired of screwing around on one task.
    find /agent -type d -exec chmod a+w {} +
}

install_certs() {
    echo "Running wazuh-certs-tool.sh"
    source /wazuh-certs-tool.sh -A > /dev/null 2>&1
    cert_parseYaml /config.yml > /dev/null 2>&1
    echo "Certificates were generated"

    cp /wazuh-certificates/root-ca.key /wazuh-indexer/certs/root-ca.key
    cp /wazuh-certificates/root-ca.pem /wazuh-indexer/certs/root-ca.pem
    cp /wazuh-certificates/wazuh-indexer-key.pem /wazuh-indexer/certs/wazuh.indexer.key
    cp /wazuh-certificates/wazuh-indexer.pem /wazuh-indexer/certs/wazuh.indexer.pem
    cp /wazuh-certificates/admin.pem /wazuh-indexer/certs/admin.pem
    cp /wazuh-certificates/admin-key.pem /wazuh-indexer/certs/admin-key.pem
    chmod -R 400 /wazuh-indexer/certs/*
    chown 1000:1000 -R /wazuh-indexer/certs
    echo "Wazuh Indexer"
    echo "- root-ca.key"
    echo "- root-ca.pem"
    echo "- wazuh.indexer.key"
    echo "- wazuh.indexer.pem"
    echo "- admin.pem"
    echo "- admin-key.pem"

    cp /wazuh-certificates/root-ca.pem /wazuh-dashboard/certs/root-ca.pem
    cp /wazuh-certificates/wazuh-dashboard.pem /wazuh-dashboard/certs/wazuh-dashboard.pem
    cp /wazuh-certificates/wazuh-dashboard-key.pem /wazuh-dashboard/certs/wazuh-dashboard-key.pem
    chmod -R 400 /wazuh-dashboard/certs/*
    chown 1000:1000 -R /wazuh-dashboard/certs
    echo "Wazuh Dashboard"
    echo "- root-ca.pem"
    echo "- wazuh-dashboard.pem"
    echo "- wazuh-dashboard-key.pem"

    cp /wazuh-certificates/root-ca.pem /wazuh-manager/certs/root-ca.pem
    cp /wazuh-certificates/wazuh-manager.pem /wazuh-manager/certs/filebeat.pem
    cp /wazuh-certificates/wazuh-manager-key.pem /wazuh-manager/certs/filebeat.key
    chmod -R 400 /wazuh-manager/certs/*
    chown 999:999 -R /wazuh-manager/certs
    echo "Wazuh Manager"
    echo "- root-ca.pem"
    echo "- filebeat.pem"
    echo "- filebeat.key"

    if [ "${PREP_GRAYLOG}" = "true" ]; then
        cp /wazuh-certificates/root-ca.pem /graylog/certs/wazuh-root-ca.pem
        chown 1100:1100 /graylog/certs/wazuh-root-ca.pem
        echo "Graylog"
        echo "- root-ca.pem"
    fi
}

install_scripts() {
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

		${AGENT_DIRECTORY}/bin/wazuh-control start
	EOF

    echo "- wazuh_agent_stop"
    cat <<-EOF >/scripts/wazuh_agent_stop/name
		wazuh_agent_stop
	EOF

    cat <<-EOF >/scripts/wazuh_agent_stop/script
		#!/bin/bash
		${AGENT_DIRECTORY}/bin/wazuh-control stop
	EOF
}

prepare_users() {
    # ./wazuh-passwords-tool.sh --generate-file wazuh-passwords.txt
    python3 /config/password_hasher.py
    source api_credentials.sh
    sed -i "s,# Password for wazuh API user,# API User,g" wazuh-passwords.txt
    sed -i "s,# Password for wazuh-wui API user,# Dashboard API User,g" wazuh-passwords.txt
    cp internal_users.yml /wazuh-indexer/internal_users.yml
    cp wazuh-passwords.txt /wazuh-indexer/wazuh-passwords.txt
    chown 1000:1000 -R /wazuh-indexer
}

main() {
    if [ "${OVERWRITE}" = "true" ]; then
        echo 
        echo "Removed existing files!"
        echo
        rm -rf /wazuh-manager/*
        rm -rf /wazuh-dashboard/*
        rm -rf /wazuh-indexer/*
        rm -rf /scripts/*
        rm -rf /agent/*
    fi

    if [ "${PREP_GRAYLOG}" = "true" ]; then
        mkdir -p /graylog/certs
        mkdir -p /graylog/journal
        chown 1100:1100 -R /graylog
    fi

    if [ "${INSTALL_CONFS}" = "true" ]; then
        echo "#################################################"
        echo "Installing configuration files"
        echo "#################################################"
        mkdir -p /wazuh-indexer/wazuh-indexer-data
        mkdir -p /wazuh-manager/ossec_logs
        mkdir -p /wazuh-manager/ossec_queue
        chmod g+w -R /wazuh-manager/ossec_queue
        prepare_users
        install_confs
    fi

    if [ "${INSTALL_AGENT}" = "true" ]; then
        echo "#################################################"
        echo "Installing the agent on Unraid"
        echo "#################################################"
        install_agent
    fi

    if [ "${INSTALL_CERTS}" = "true" ]; then
        echo "#################################################"
        echo "Installing certificates"
        echo "#################################################"
        cp /config/certs.yml /config.yml
        mkdir -p /wazuh-indexer/certs && chmod -R 500 /wazuh-indexer/certs
        mkdir -p /wazuh-manager/certs && chmod -R 500 /wazuh-manager/certs
        mkdir -p /wazuh-dashboard/certs && chmod -R 500 /wazuh-dashboard/certs
        install_certs
    fi

    if [ "${INSTALL_SCRIPTS}" = "true" ]; then
        echo "#################################################"
        echo "Installing User Scripts"
        echo "#################################################"
        install_scripts
    fi

    if [ "${DEV_MODE}" = "true" ]; then
        chown 1000:1000 -R /wazuh* # dev only
        chown 1000:1000 -R /scripts # dev only
        chown 1000:1000 -R /config # dev only
        chown 1000:1000 -R /agent # dev only
    fi
}
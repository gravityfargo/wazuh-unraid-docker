# Wazuh Docker Copyright (C) 2017, Wazuh Inc. (License GPLv2)
FROM amazonlinux:2023

ENV MANAGER_NAME="wazuh-manager" \
    MANAGER_HOSTNAME="wazuh-manager.local" \
    MANAGER_IP="10.10.10.101" \
    INDEXER_NAME="wazuh-indexer" \
    INDEXER_HOSTNAME="wazuh-indexer.local" \
    INDEXER_IP="10.10.10.100" \
    INDEXER_USERNAME="wazuh" \
    INDEXER_PASSWORD="wazuh" \
    DASHBOARD_NAME="wazuh-indexer" \
    DASHBOARD_HOSTNAME="wazuh-dashboard.local" \
    UNRAID_USER="root" \
    UNRAID_HOSTNAME="unraid.local" \
    FILEBEAT_SSL_VERIFICATION_MODE="full"

RUN yum install curl-minimal openssl gettext -y && \
    yum clean all

WORKDIR /
COPY config/entrypoint.sh /
COPY config /config
RUN chmod 700 /entrypoint.sh

RUN sed -i "s,name: wazuh.indexer,name: ${INDEXER_NAME},1" /config/certs.yml && \
    sed -i "s,ip: wazuh.indexer,ip: ${INDEXER_HOSTNAME},1" /config/certs.yml && \
    sed -i "s,name: wazuh.manager,name: ${MANAGER_NAME},1" /config/certs.yml && \
    sed -i "s,ip: wazuh.manager,ip: ${MANAGER_HOSTNAME},1" /config/certs.yml && \
    sed -i "s,name: wazuh.dashboard,name: ${DASHBOARD_NAME},1" /config/certs.yml && \
    sed -i "s,ip: wazuh.dashboard,ip: ${DASHBOARD_HOSTNAME},1" /config/certs.yml && \
    sed -i "s,network.host: \"0.0.0.0\",network.host: \"${INDEXER_IP}\",1" /config/indexer.yml && \
    sed -i "s,node.name: \"wazuh.indexer\",node.name: \"${INDEXER_NAME}\",1" /config/indexer.yml && \
    sed -i "s,url: \"https://wazuh.manager\",url: \"https://${MANAGER_HOSTNAME}\",1" /config/wazuh.yml && \
    sed -i "s,server.host: 0.0.0.0,server.host: ${MANAGER_IP},1" /config/opensearch_dashboards.yml && \
    sed -i "s,opensearch.hosts: https://wazuh.indexer:9200,opensearch.hosts: https://${INDEXER_HOSTNAME}:9200,1" /config/opensearch_dashboards.yml && \
    sed -i "s,<host>https://wazuh.indexer:9200</host>,<host>https://${INDEXER_HOSTNAME}:9200</host>,1" /config/wazuh_manager.conf && \
    sed -i "s,<host>root@unraid.local</host>,<host>${UNRAID_USER}@${UNRAID_HOSTNAME}</host>,1" /config/wazuh_manager.conf && \
    sed -i "s,<bind_addr>0.0.0.0</bind_addr>,<bind_addr>${MANAGER_IP}</bind_addr>,1" /config/wazuh_manager.conf && \
    sed -i "s,<node>wazuh.manager</node>,<node>${MANAGER_NAME}</node>,1" /config/wazuh_manager.conf

RUN sed -i "s|hosts:.*|hosts: ['$INDEXER_HOSTNAME']|g" /config/filebeat.yml && \
    sed -i "s|username:.*|username: '$INDEXER_USERNAME'|g" /config/filebeat.yml && \
    sed -i "s|password:.*|password: '$INDEXER_PASSWORD'|g" /config/filebeat.yml && \
    sed -i "s|ssl.verification_mode:.*|ssl.verification_mode: '$FILEBEAT_SSL_VERIFICATION_MODE'|g" /config/filebeat.yml

ENTRYPOINT ["/entrypoint.sh"]
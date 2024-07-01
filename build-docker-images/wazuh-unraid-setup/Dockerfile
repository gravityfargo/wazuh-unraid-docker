# Wazuh Docker Copyright (C) 2017, Wazuh Inc. (License GPLv2)
FROM amazonlinux:2023

ENV MANAGER_NAME="wazuh-manager" \
    MANAGER_HOSTNAME="wazuh-manager.local" \
    MANAGER_IP="10.10.10.101" \
    INDEXER_NAME="wazuh-indexer" \
    INDEXER_HOSTNAME="wazuh-indexer.local" \
    DASHBOARD_NAME="wazuh-indexer" \
    DASHBOARD_HOSTNAME="wazuh-dashboard.local" \
    UNRAID_USER="root" \
    UNRAID_HOSTNAME="unraid.local"

RUN yum install curl-minimal openssl gettext -y && \
    yum clean all

WORKDIR /
COPY config/entrypoint.sh /
RUN chmod 700 /entrypoint.sh

COPY config/wazuh-dashboard/opensearch_dashboards.yml /config/
COPY config/wazuh-dashboard/wazuh.yml /config/
COPY config/wazuh-indexer/internal_users.yml /config/
COPY config/wazuh-indexer/indexer.yml /config/
COPY config/wazuh-manager/wazuh_manager.conf /config/
COPY config/certs.yml /config/

RUN sed -i "s,name: wazuh.indexer,name: ${INDEXER_NAME},1" /config/certs.yml && \
    sed -i "s,ip: wazuh.indexer,ip: ${INDEXER_HOSTNAME},1" /config/certs.yml && \
    sed -i "s,name: wazuh.manager,name: ${MANAGER_NAME},1" /config/certs.yml && \
    sed -i "s,ip: wazuh.manager,ip: ${MANAGER_HOSTNAME},1" /config/certs.yml && \
    sed -i "s,name: wazuh.dashboard,name: ${DASHBOARD_NAME},1" /config/certs.yml && \
    sed -i "s,ip: wazuh.dashboard,ip: ${DASHBOARD_HOSTNAME},1" /config/certs.yml && \
    sed -i "s,url: \"https://wazuh.manager\",url: \"https://${MANAGER_HOSTNAME}\",1" /config/wazuh.yml && \
    sed -i "s,server.host: 0.0.0.0,server.host: ${MANAGER_IP},1" /config/opensearch_dashboards.yml && \
    sed -i "s,opensearch.hosts: https://wazuh.indexer:9200,opensearch.hosts: https://${INDEXER_HOSTNAME}:9200,1" /config/opensearch_dashboards.yml && \
    sed -i "s,<host>https://wazuh.indexer:9200</host>,<host>https://${INDEXER_HOSTNAME}:9200</host>,1" /config/wazuh_manager.conf && \
    sed -i "s,<host>root@unraid.local</host>,<host>${UNRAID_USER}@${UNRAID_HOSTNAME}</host>,1" /config/wazuh_manager.conf && \
    sed -i "s,<bind_addr>0.0.0.0</bind_addr>,<bind_addr>${MANAGER_IP}</bind_addr>,1" /config/wazuh_manager.conf && \
    sed -i "s,<node>wazuh.manager</node>,<node>${MANAGER_NAME}</node>,1" /config/wazuh_manager.conf

ENTRYPOINT ["/entrypoint.sh"]
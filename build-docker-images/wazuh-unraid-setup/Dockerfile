# Wazuh Docker Copyright (C) 2017, Wazuh Inc. (License GPLv2)
FROM amazonlinux:2023

ENV MANAGER_NAME="wazuh-manager" \
    MANAGER_IP="10.10.10.101" \
    INDEXER_NAME="wazuh-indexer" \
    INDEXER_IP="10.10.10.100" \
    DASHBOARD_NAME="wazuh-dashboard" \
    DASHBOARD_IP="10.10.10.102" \
    UNRAID_USER="root" \
    UNRAID_IP="10.10.10.10" \
    API_USERNAME="wazuh-wui" \
    API_PASSWORD="MyS3cr37P450r.*-"

RUN yum install curl-minimal openssl gettext -y  && \
    yum clean all

WORKDIR /
COPY config/entrypoint.sh /
RUN chmod 700 /entrypoint.sh
COPY config/* /config/

# Apparently docker doesnt like EOT when including variables.
RUN sed -i "s,name: wazuh.indexer,name: ${INDEXER_NAME},1" /config/certs.yml  && \
    sed -i "s,ip: wazuh.indexer,ip: ${INDEXER_IP},1" /config/certs.yml && \
    sed -i "s,name: wazuh.manager,name: ${MANAGER_NAME},1" /config/certs.yml && \
    sed -i "s,ip: wazuh.manager,ip: ${MANAGER_IP},1" /config/certs.yml && \
    sed -i "s,name: wazuh.dashboard,name: ${DASHBOARD_NAME},1" /config/certs.yml && \
    sed -i "s,ip: wazuh.dashboard,ip: ${DASHBOARD_IP},1" /config/certs.yml && \
    # 
    sed -i "s,network.host:.*,network.host: \"${INDEXER_IP}\",1" /config/wazuh.indexer.yml && \
    sed -i "s,node.name:.*,node.name: \"${INDEXER_NAME}\",1" /config/wazuh.indexer.yml && \
    #
    sed -i "s,url: \"https://wazuh.manager\",url: \"https://${MANAGER_IP}\",1" /config/wazuh.yml && \
    sed -i "s,username:.*,username: \"${API_USERNAME}\",g" /config/wazuh.yml && \
    sed -i "s,password:.*,password: \"${API_PASSWORD}\",g" /config/wazuh.yml && \
    #
    sed -i "s,server.host:.*,server.host: ${DASHBOARD_IP},1" /config/opensearch_dashboards.yml && \
    sed -i "s,opensearch.hosts:.*,opensearch.hosts: https://${INDEXER_IP}:9200,1" /config/opensearch_dashboards.yml && \
    #
    sed -i "s,<host>https://wazuh.indexer:9200</host>,<host>https://${INDEXER_IP}:9200</host>,1" /config/wazuh_manager.conf && \
    sed -i "s,<host>root@unraid</host>,<host>${UNRAID_USER}@${UNRAID_IP}</host>,1" /config/wazuh_manager.conf && \
    sed -i "s,<node>wazuh.manager</node>,<node>${MANAGER_IP}</node>,1" /config/wazuh_manager.conf

ENTRYPOINT ["/entrypoint.sh"]
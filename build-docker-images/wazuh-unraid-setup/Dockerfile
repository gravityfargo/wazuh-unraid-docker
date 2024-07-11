# Wazuh Docker Copyright (C) 2017, Wazuh Inc. (License GPLv2)
# Modifications by GitHub user gravityfargo, 2024
FROM andy5995/slackware-build-essential:15.0

ENV INSTALL_CERTS="true" \
    INSTALL_CONFS="true" \
    INSTALL_SCRIPTS="true" \
    INSTALL_AGENT="true" \
    PREP_GRAYLOG="true" \
    MANAGER_NAME="wazuh-manager" \
    MANAGER_IP="10.10.10.101" \
    INDEXER_NAME="wazuh-indexer" \
    INDEXER_IP="10.10.10.100" \
    DASHBOARD_NAME="wazuh-dashboard" \
    DASHBOARD_IP="10.10.10.102" \
    API_USERNAME="wazuhapi" \
    API_PASSWORD="MyS3cr37P450r.*-" \
    DASHBOARD_USERNAME="wazuhdash" \
    DASHBOARD_PASSWORD="MyS3cr37P450r.*-" \
    GRAYLOG_USERNAME="wazuhgraylog" \
    GRAYLOG_PASSWORD="MyS3cr37P450r.*-" \
    AGENT_DIRECTORY="/mnt/user/appdata/wazuh/wazuh-agent"
    
WORKDIR /

RUN wget -O OpenJDK17.tar.gz https://github.com/adoptium/temurin17-binaries/releases/download/jdk-17.0.11%2B9/OpenJDK17U-jdk_x64_linux_hotspot_17.0.11_9.tar.gz && \
    tar -xzf OpenJDK17.tar.gz && \
    rm OpenJDK17.tar.gz

RUN wget -O wazuh-passwords-tool.sh https://packages.wazuh.com/4.8/wazuh-passwords-tool.sh && \
    chmod 700 wazuh-passwords-tool.sh

RUN wget -O wazuh-certs-tool.sh https://packages.wazuh.com/4.8/wazuh-certs-tool.sh && \
    chmod 700 wazuh-certs-tool.sh

COPY config/* /config/

COPY config/entrypoint.sh /
RUN chmod 700 /entrypoint.sh

ENTRYPOINT ["/entrypoint.sh"]
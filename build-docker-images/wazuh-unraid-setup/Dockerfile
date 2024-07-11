# Wazuh Docker Copyright (C) 2017, Wazuh Inc. (License GPLv2)
# Modifications by GitHub user gravityfargo, 2024
FROM andy5995/slackware-build-essential:15.0

WORKDIR /

RUN wget -O wazuh-passwords-tool.sh https://packages.wazuh.com/4.8/wazuh-passwords-tool.sh && \
    chmod 700 wazuh-passwords-tool.sh \
    && wget -O wazuh-certs-tool.sh https://packages.wazuh.com/4.8/wazuh-certs-tool.sh && \
    chmod 700 wazuh-certs-tool.sh \
    && slapt-get -u \
    && slapt-get -y -i sudo \
    && pip install bcrypt pyyaml

ENV INSTALL_CONFS="true" \
    INSTALL_AGENT="true" \
    INSTALL_CERTS="true" \
    INSTALL_SCRIPTS="true" \
    PREP_GRAYLOG="true" \
    MANAGER_NAME="wazuh-manager" \
    MANAGER_IP="10.10.10.101" \
    INDEXER_NAME="wazuh-indexer" \
    INDEXER_IP="10.10.10.100" \
    DASHBOARD_NAME="wazuh-dashboard" \
    DASHBOARD_IP="10.10.10.102" \
    DASHBOARD_USERNAME="wazuhdash" \
    DASHBOARD_PASSWORD="MyS3cr37P450r.*-" \
    GRAYLOG_USERNAME="wazuhgraylog" \
    GRAYLOG_PASSWORD="MyS3cr37P450r.*-" \
    AGENT_DIRECTORY="/mnt/user/appdata/wazuh/wazuh-agent" \
    OVERWRITE="false" \
    DEV_MODE="false" \
    VERBOSE="false"
    
COPY config/* /config/

COPY config/entrypoint.sh /
RUN chmod 700 /entrypoint.sh

ENTRYPOINT ["/entrypoint.sh"]
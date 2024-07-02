# Wazuh Docker Copyright (C) 2017, Wazuh Inc. (License GPLv2)
FROM amazonlinux:2023

ARG WAZUH_VERSION
ARG WAZUH_TAG_REVISION

RUN yum install curl-minimal openssl xz tar findutils shadow-utils -y

COPY config/config.sh .

COPY config/config.yml /

RUN bash config.sh
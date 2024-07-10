WAZUH_IMAGE_VERSION=4.8.0
WAZUH_VERSION=$(echo $WAZUH_IMAGE_VERSION | sed -e 's/\.//g')
WAZUH_TAG_REVISION=1
WAZUH_CURRENT_VERSION=$(curl --silent https://api.github.com/repos/wazuh/wazuh/releases/latest | grep '["]tag_name["]:' | sed -E 's/.*\"([^\"]+)\".*/\1/' | cut -c 2- | sed -e 's/\.//g')
IMAGE_VERSION=${WAZUH_IMAGE_VERSION}

# Wazuh package generator
# Copyright (C) 2023, Wazuh Inc.
# Modifications by GitHub user gravityfargo, 2024
#
# This program is a free software; you can redistribute it
# and/or modify it under the terms of the GNU General Public
# License (version 2) as published by the FSF - Free Software
# Foundation.

WAZUH_IMAGE_VERSION="4.8.0"
WAZUH_TAG_REVISION="1"
WAZUH_DEV_STAGE=""
FILEBEAT_MODULE_VERSION="0.4"

# -----------------------------------------------------------------------------

trap ctrl_c INT

clean() {
    exit_code=$1

    exit ${exit_code}
}

ctrl_c() {
    clean 1
}

# -----------------------------------------------------------------------------

build() {

    WAZUH_VERSION="$(echo $WAZUH_IMAGE_VERSION | sed -e 's/\.//g')"
    FILEBEAT_TEMPLATE_BRANCH="${WAZUH_IMAGE_VERSION}"
    WAZUH_FILEBEAT_MODULE="wazuh-filebeat-${FILEBEAT_MODULE_VERSION}.tar.gz"
    WAZUH_UI_REVISION="${WAZUH_TAG_REVISION}"

    if [ "${WAZUH_DEV_STAGE}" ]; then
        FILEBEAT_TEMPLATE_BRANCH="v${FILEBEAT_TEMPLATE_BRANCH}-${WAZUH_DEV_STAGE,,}"
        if ! curl --output /dev/null --silent --head --fail "https://github.com/wazuh/wazuh/tree/${FILEBEAT_TEMPLATE_BRANCH}"; then
            echo "The indicated branch does not exist in the wazuh/wazuh repository: ${FILEBEAT_TEMPLATE_BRANCH}"
            clean 1
        fi
    else
        if curl --output /dev/null --silent --head --fail "https://github.com/wazuh/wazuh/tree/v${FILEBEAT_TEMPLATE_BRANCH}"; then
            FILEBEAT_TEMPLATE_BRANCH="v${FILEBEAT_TEMPLATE_BRANCH}"
        elif curl --output /dev/null --silent --head --fail "https://github.com/wazuh/wazuh/tree/${FILEBEAT_TEMPLATE_BRANCH}"; then
            FILEBEAT_TEMPLATE_BRANCH="${FILEBEAT_TEMPLATE_BRANCH}"
        else
            WAZUH_MASTER_VERSION="$(curl -s https://raw.githubusercontent.com/wazuh/wazuh/master/src/VERSION | sed -e 's/v//g')"
            if [ "${FILEBEAT_TEMPLATE_BRANCH}" == "${WAZUH_MASTER_VERSION}" ]; then
                FILEBEAT_TEMPLATE_BRANCH="master"
            else
                echo "The indicated branch does not exist in the wazuh/wazuh repository: ${FILEBEAT_TEMPLATE_BRANCH}"
                clean 1
            fi
        fi
    fi

    echo WAZUH_VERSION=$WAZUH_IMAGE_VERSION >.env
    echo WAZUH_IMAGE_VERSION=$WAZUH_IMAGE_VERSION >>.env
    echo WAZUH_TAG_REVISION=$WAZUH_TAG_REVISION >>.env
    echo FILEBEAT_TEMPLATE_BRANCH=$FILEBEAT_TEMPLATE_BRANCH >>.env
    echo WAZUH_FILEBEAT_MODULE=$WAZUH_FILEBEAT_MODULE >>.env
    echo WAZUH_UI_REVISION=$WAZUH_UI_REVISION >>.env

}

# -----------------------------------------------------------------------------

help() {
    echo
    echo "Usage: $0 [OPTIONS]"
    echo
    echo "  -a,   --all                    Build all the images."
    echo "  -bus, --wazuh-unraid-setup     Build the Wazuh Unraid setup image."
    echo "  -pus, --push-unraid-setup      Push the Wazuh Unraid setup image."
    echo "  -bm,  --wazuh-manager          Build the Wazuh Manager image."
    echo "  -pm,  --push-manager           Push the Wazuh Manager image."
    echo "  -bi,  --wazuh-indexer          Build the Wazuh Indexer image."
    echo "  -bd,  --wazuh-dashboard        Build the Wazuh Dashboard image."
    echo "  -h,   --help                   Show this help."
    echo
    exit $1
}

# -----------------------------------------------------------------------------

main() {
    while [ -n "${1}" ]; do
        case "${1}" in
        "-h" | "--help")
            help 0
            ;;
        "-a" | "--all")
            build || clean 1
            docker-compose -f build-docker-images/build-images.yml --env-file .env build
            return 0
            ;;
        "-bus" | "--build-unraid-setup")
            build || clean 1
            docker build -t gravityfargo/wazuh-unraid-setup:4.8.0 build-docker-images/wazuh-unraid-setup
            return 0
            ;;
        "-pus" | "--push-unraid-setup")
            docker push gravityfargo/wazuh-unraid-setup:4.8.0
            return 0
            ;;
        "-bm" | "--build-manager")
            build || clean 1
            docker-compose -f build-docker-images/build-images.yml --env-file .env build wazuh-manager
            return 0
            ;;
        "-pm" | "--push-manager")
            docker push gravityfargo/wazuh-manager:4.8.0
            return 0
            ;;
        "-bi" | "--build-indexer")
            build || clean 1
            docker-compose -f build-docker-images/build-images.yml --env-file .env build wazuh-indexer
            return 0
            ;;
        "-bd" | "--build-dashboard")
            build || clean 1
            docker-compose -f build-docker-images/build-images.yml --env-file .env build wazuh-dashboard
            return 0
            ;;
        *)
            help 1
            ;;
        esac
    done

    clean 0
}

export DOCKER_BUILDKIT=1
main "$@"

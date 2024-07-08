# Wazuh containers for Docker on Unraid

## Details

### gravityfargo/wazuh-unraid-setup

-   Executes the same code as `wazuh/wazuh-certs-generator:0.0.2`
-   Keeping track of the file name mappings was tedious so they are renamed to match their mapping inside the containers.
    -   `wazuh.indexer-key.pem` -> `wazuh.indexer.key`
    -   `wazuh-manager.pem` -> `filebeat.pem`
    -   `wazuh-manager-key.pem` -> `filebeat.key`
    -   `wazuh_manager.conf` -> `ossec.conf`
-   Creates appdata directories for the Wazuh Manager, Indexer, and Dashboard
-   Populates the appdata directories with several config files edited with variables entered
    in the Unraid Docker template. Several variables are ommited from the Wazuh Manager template
    because this container performs the same function ahead of time.

#### Keys that were consolidated
- dashboard
    - INDEXER_USERNAME
    - INDEXER_PASSWORD
    - WAZUH_API_URL
    - WAZUH_API_USERNAME
    - WAZUH_API_PASSWORD

### gravityfargo/wazuh-unraid-setup

-   All volumes from the stock template are mapped to paths in the appdata directory.

## Usage

### 1. Setup `max_map_count`

1. Install the `CA User Scripts` [plugin](https://forums.unraid.net/topic/48286-plugin-ca-user-scripts/)
2. Go to [http://unraid.local/Apps/Settings/Userscripts](http://10.10.10.10/Apps/Settings/Userscripts)
3. Add a new script named `vm.max_map_count`
4. Add the following code to the script:

```bash
#!/bin/bash
sysctl -w vm.max_map_count=262144
```

5. Save the script, and set it to run on array start.
6. Manually run the script.

### 2. Deploy wazuh-unraid-setup

TODO

### 3. Deploy Indexer/Manager/Dashboard

TODO

### 4. Unraid agentless registration

```bash
docker exec -it WazuhManager /bin/bash
/var/ossec/agentless/register_host.sh add root@unraid.local NTE0vmd5tve8tyh_eve
/var/ossec/agentless/register_host.sh list
```

## Using the Docker Compose Manager plugin

TODO

## Development

```bash
docker build -t gravityfargo/wazuh-unraid-setup:4.8.0 build-docker-images/wazuh-unraid-setup
docker-compose -f build-docker-images/build-manager.yml --env-file .env build

docker-compose -f docker-compose/wazuh-unraid-setup.yml run --rm generator
docker-compose -f docker-compose/docker-compose.yml run --rm manager

docker push gravityfargo/wazuh-unraid-setup:4.8.0
docker push gravityfargo/wazuh-manager:4.8.0
```

## ENV

### Dashboard

These variables have been removed. If you want to use them, edit `${WAZUH_DASHBOARD_PATH}/wazuh.yml` directly.

```yaml
CHECKS_PATTERN=""
CHECKS_TEMPLATE=""
CHECKS_API=""
CHECKS_SETUP=""
EXTENSIONS_PCI=""
EXTENSIONS_GDPR=""
EXTENSIONS_HIPAA=""
EXTENSIONS_NIST=""
EXTENSIONS_TSC=""
EXTENSIONS_AUDIT=""
EXTENSIONS_OSCAP=""
EXTENSIONS_CISCAT=""
EXTENSIONS_AWS=""
EXTENSIONS_GCP=""
EXTENSIONS_GITHUB=""
EXTENSIONS_OFFICE=""
EXTENSIONS_VIRUSTOTAL=""
EXTENSIONS_OSQUERY=""
EXTENSIONS_DOCKER=""
APP_TIMEOUT=""
API_SELECTOR=""
IP_SELECTOR=""
IP_IGNORE=""
WAZUH_MONITORING_ENABLED=""
WAZUH_MONITORING_FREQUENCY=""
WAZUH_MONITORING_SHARDS=""
WAZUH_MONITORING_REPLICAS=""
```

## Credits

This project builds on the offical Wazuh Docker containers of which this repo is a fork.

Ancestor projects of Wazuh's are based on:

-   "deviantony" dockerfiles which can be found at [https://github.com/deviantony/docker-elk](https://github.com/deviantony/docker-elk)
-   "xetus-oss" dockerfiles, which can be found at [https://github.com/xetus-oss/docker-ossec-server](https://github.com/xetus-oss/docker-ossec-server)

Wazuh Docker Copyright (C) 2017, Wazuh Inc. (License GPLv2)

## Official Wazuh links

-   [Wazuh website](http://wazuh.com)
-   [Wazuh full documentation](http://documentation.wazuh.com)
-   [Wazuh documentation for Docker](https://documentation.wazuh.com/current/docker/index.html)
-   [Docker Hub](https://hub.docker.com/u/wazuh)

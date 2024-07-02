# Wazuh containers for Docker on Unraid

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
### Running Locally

Build the wazuh-unraid-setup image:

```bash
docker build -t gravityfargo/wazuh-unraid-setup:0.0.1 build-docker-images/wazuh-unraid-setup --no-cache
```

To run the wazuh-unraid-setup::

```bash
docker-compose -f docker-compose/wazuh-unraid-setup.yml run --rm generator
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

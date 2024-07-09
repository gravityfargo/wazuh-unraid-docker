# Wazuh for Docker on Unraid

This repo holds 4 Unraid docker templates and two docker image builds.

The templates are for the Wazuh Manager, Indexer, and Dashboard.
The fourth template is a setup container that builds the Wazuh Agent from source,
installs it to the cache directory, creates and populates the appdata directories for
the wazuh applications with the necessary files, user scripts, and generating self signed cetificates in
the process.

If you do not want to use the setup container for final configuration, thats fine, but I would recommend
running it to create the directories structure with the necessary permissions, then moving in your own
configuration files.

I have not tested changing any of the enviornment variables. I would recommend
using the default values to get everything running then manually modify configuration files after the fact.

Ignoring everything else, you can just change IP addresses and run the containers as is.
Changing the passwords is also a good idea, but I have not tested that with these templates.

## Usage

-   A network bridge is requred. `br0` in my case.
-   3 IP addresses are required. One for the manager, one for the indexer, and one for the
    dashboard.
-   The manager template has my custom image in it. You can use the official image if you want. My
    image is built from the official image and only adds the `expect` package
    to it which is requred for agentless monitoring. I have not tested the
    agentless monitoring yet, it was just a feature I wanted to have available. The stock
    image will work just fine.
-   The startup order is: Indexer, Dashboard, Manager. The manager must be started first.

1. Install the `CA User Scripts` [plugin](https://forums.unraid.net/topic/48286-plugin-ca-user-scripts/)
2. Install the `Wazuh-Unraid-Setup` container. It can be deleted after the setup is complete.
   If you re-run it, it will recreate the certificates and overwrite the existing ones.
3. Go to the "Userscripts" settings page.
4. Set `wazuh_prep` to run "At First Array Start Only".
5. Set `wazuh_agent_start` to run "At Startup of Array".
6. Set `wazuh_agent_stop` to run "At Stopping of Array".
7. Manually run the `wazuh_prep` script.
8. Install the `Wazuh-Manager`, `Wazuh-Indexer`, and `Wazuh-Dashboard` containers. Install it, watch the logs for errors,
   and only start the next container after the previous one has started successfully.
9. Manually run the `wazuh_agent_start` script.

### Bonus: Graylog



## Docker Containers

### gravityfargo/wazuh-unraid-setup

-   built upon `wazuh/wazuh-certs-generator:0.0.1`.
-   Builds the Wazuh Agent from source inside the container and moves it to the chosen location on the array.
-   Uses [andy5995/slackware-build-essential](https://hub.docker.com/r/andy5995/slackware-build-essential/tags) as a base image.
-   Creates appdata directories for the Wazuh Manager, Indexer, and Dashboard and populates them with the necessary files.
-   Creates the user scripts `wazuh_agent_start`, `wazuh_agent_stop`, and `wazuh_prep`.

### gravityfargo/wazuh-unraid-setup

-   Stock, expect the addition of the `expect` package for agentless monitoring.

## Directory Structure that is _Created_

```bash
/mnt/user/appdata
├── wazuh-dashboard
│   ├── certs
│   │   ├── wazuh-dashboard-key.pem
│   │   └── wazuh-dashboard.pem
│   ├── opensearch_dashboards.yml
│   └── wazuh.yml
├── wazuh-indexer
│   ├── certs
│   │   ├── admin-key.pem
│   │   ├── admin.pem
│   │   ├── filebeat.key
│   │   ├── filebeat.pem
│   │   ├── root-ca.key
│   │   ├── root-ca.pem
│   │   ├── wazuh.indexer.key
│   │   └── wazuh.indexer.pem
│   ├── internal_users.yml
│   ├── opensearch.yml
│   └── wazuh-indexer-data
└── wazuh-manager
    └── ossec.conf
```

## Development

Helpful when being a script kiddie.

```bash
export DOCKER_BUILDKIT=1
docker build -t gravityfargo/wazuh-unraid-setup:4.8.0 build-docker-images/wazuh-unraid-setup
docker-compose -f build-docker-images/build-manager.yml --env-file .env build

docker-compose -f docker-compose/wazuh-unraid-setup.yml run --rm generator
docker-compose -f docker-compose/docker-compose.yml run --rm manager

docker push gravityfargo/wazuh-unraid-setup:4.8.0
docker push gravityfargo/wazuh-manager:4.8.0

/var/ossec/bin/manage_agents -l # List agents
/var/ossec/bin/manage_agents -r 001 # Remove an agent
```

## Credits

This project builds on the offical Wazuh Docker containers of which this repo is a fork.

Ancestor projects of Wazuh's are based on:

-   "deviantony" dockerfiles which can be found at [https://github.com/deviantony/docker-elk](https://github.com/deviantony/docker-elk)
-   "xetus-oss" dockerfiles, which can be found at [https://github.com/xetus-oss/docker-ossec-server](https://github.com/xetus-oss/docker-ossec-server)

Wazuh Docker Copyright (C) 2017, Wazuh Inc. (License GPLv2)

Thanks ChatGPT for making the icon for my container.

## Official Wazuh links

-   [Wazuh website](http://wazuh.com)
-   [Wazuh full documentation](http://documentation.wazuh.com)
-   [Wazuh documentation for Docker](https://documentation.wazuh.com/current/docker/index.html)
-   [Docker Hub](https://hub.docker.com/u/wazuh)

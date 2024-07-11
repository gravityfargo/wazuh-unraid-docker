# Deploy a Single-Node Unraid Wazuh Environment

This deployment is defined in the `docker-compose.yml` file.

There are commands to run the `wazuh-unraid-setup` container,
then the `wazuh-manager`, the `wazuh-indexer`, and finally the `wazuh-dashboard`.

This is not intended for production or persistant use. This is used to
test the containers locally prior to deploying them on an Unraid server.

The `config/` directory contains the same files from the 
`build-docker-images/wazuh-unraid-setup` directory. To speed up development,
a volume is mounted to the container to avoid rebuilding the container 
each time a change is made.

Run these from the root of the repository.

-   Increase max_map_count on your host (Linux). This command must be run with root permissions:

```bash
sysctl -w vm.max_map_count=262144
```

-   wazuh-unraid-setup

```bash
docker-compose -f single-node/unraid-docker-compose.yml run --rm wazuh-unraid-setup
```

-   wazuh-manager

```bash
docker-compose -f single-node/unraid-docker-compose.yml run --rm wazuh-manager
```

-   wazuh-indexer

```bash
docker-compose -f single-node/unraid-docker-compose.yml run --rm wazuh-indexer
```

-   wazuh-dashboard

```bash
docker-compose -f single-node/unraid-docker-compose.yml run --rm wazuh-dashboard
```

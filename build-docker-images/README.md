# Wazuh Docker Image Builder

The creation of the images for the Wazuh stack deployment in Docker is done with the `build-images.yml` script

To execute the process, the following must be executed in the root of the wazuh-docker repository:

```bash
build-docker-images/build-images.sh -h
```

```
Usage: build-docker-images/build-images.sh [OPTIONS]

-a,   --all                    Build all the images.
-bus, --wazuh-unraid-setup     Build the Wazuh Unraid setup image.
-pus, --push-unraid-setup      Push the Wazuh Unraid setup image.
-bm,  --wazuh-manager          Build the Wazuh Manager image.
-pm,  --push-manager           Push the Wazuh Manager image.
-bi,  --wazuh-indexer          Build the Wazuh Indexer image.
-bd,  --wazuh-dashboard        Build the Wazuh Dashboard image.
-h,   --help                   Show this help.
```

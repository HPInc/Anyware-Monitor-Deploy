# Anyware Monitor Deployment

### Script to automatically deploy Anyware Monitor

This script enables automating the installation and registration of Anyware Monitor to Anyware Manager. Please note :

1. Only windows hosts are supported with this version and the script should be run locally on windows host machine.
2. Ensure you have administrator privileges when running the script.
3. After the script is executed Anyware Monitor will be installed and the host is flagged as 'Healthy' in the Anyware Manager Admin Console.
4. Additionally, the "-ignore_cert" parameter can be added to skip certificate validation. In case of self-signed domains, the config file can be downloaded in the deployment service account tab when editing the current deployment Config file.

## Link to the Script

```
.\deploy_monitor.ps1 -config_file -monitor_hostname -manager_url
```

## Example on how to use the script

```
PS C:> .\deploy_monitor.ps1 -config_file file.json -monitor_hostname 'hostname.domain.local' -manager_url <https://cas-staging.teradici.com>
```

## Example on how to use the script with "-ignore_cert"

Additionally, the -ignore_cert parameter is added to skip certificate validation in the case of self-signed domains. The config file can be downloaded in the deployment service account tab when editing the current deployment.

HP recommends exploring a secure password storage solutions and not have passwords stored in a plaintext file. Customers can modify this script to retrieve passwords from a secure locations. When using this script without modifications, please ensure the read access permissions are restricted to the JSON config file that holds the Manager password.

© Copyright 2022 HP Development Company, L.P.

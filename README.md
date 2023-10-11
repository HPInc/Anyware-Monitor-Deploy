# Anyware Monitor Deployment

### Script to automatically deploy Anyware Monitor

This script enables automating the installation and registration of Anyware Monitor to Anyware Manager. Please note :

1. Only Windows hosts are supported with this version and the script should be run locally on a Windows host machine.
2. Ensure you have administrator privileges when running the script.
3. After the script is executed Anyware Monitor will be installed and the host is flagged as 'Healthy' in the Anyware Manager Admin Console.
4. Additionally, the "-ignore_cert" parameter can be added to skip certificate validation. In the case of self-signed domains, the config file can be downloaded in the deployment service account tab when editing the current deployment Config file.

## Link to the Script

```
.\deploy_monitor.ps1 -config_file -monitor_hostname -manager_url
```

## Example of how to use the script
### Cloning the repo
```
powershell.exe -noexit "./deploy_monitor.ps1 Invoke-Expression; deploy -config_file file.json -manager_url https://cas.teradici.com -monitor_machine_name hostname.domain.local;exit"
```
### Without Cloning the repo
```
powershell.exe -noexit ". { Set-Variable ProgressPreference SilentlyContinue; Invoke-WebRequest -useb https://raw.githubusercontent.com/HPInc/Anyware-Monitor-Deploy/main/deploy_monitor.ps1 } | Invoke-Expression; deploy -manager_url https://cas.teradici.com -config_file <service account.json> -monitor_machine_name <machine_name> -channel dev;exit"
```
## Example of how to use the script with "-ignore_cert"

Additionally, the -ignore_cert parameter is added to skip certificate validation in the case of self-signed domains. The config file can be downloaded in the deployment service account tab when editing the current deployment.

HP recommends exploring secure password storage solutions and not having passwords stored in plaintext file. Customers can modify this script to retrieve passwords from a secure location. When using this script without modifications, please ensure the read access permissions are restricted to the JSON config file that holds the Manager password.

## Updating the Anyware Monitor
```
powershell.exe -noexit ". { Set-Variable ProgressPreference SilentlyContinue; Invoke-WebRequest -useb https://dl.anyware.hp.com/EwX7bPdudUUD6bsr/anyware-manager/raw/names/anyware-monitor-ps1/versions/latest/anyware-monitor_latest.ps1 } | Invoke-Expression; install -download_token EwX7bPdudUUD6bsr -skip_registration 1;exit"
```
## Uninstalling the Anyware Monitor
```
powershell.exe -noexit "Start-Process -FilePath 'C:\Program Files\HP\Anyware Manager Monitor\Uninstall.exe' -ArgumentList '/S' -PassThru -Wait"
```

© Copyright 2022-2023 HP Development Company, L.P.

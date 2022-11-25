# Anyware Monitor Deployment

## Script to automatically deploy Anyware Monitor

This script enables automating the installation and registration of Anyware Monitor to Anyware Manager. 

Please note :

Only windows hosts are supported with this version and the script should be run locally on windows host machine.
Ensure you have administrator privileges when running the script.
After the script is executed Anyware Monitor will be installed and the host is flagged as 'Healthy' in the Anyware Manager Admin Console.
Additionally, the "-ignore_cert" parameter can be added to skip certificate validation. In case of self-signed domains, the config file can be downloaded in the deployment service account tab when editing the current deployment Config file.

## Link to the Script

```
.\deploy_monitor.ps1 -config_file -monitor_hostname -manager_url
```

## Example on how to use the script

```
PS C:> .\deploy_monitor.ps1 -config_file file.json -monitor_hostname 'hostname.domain.local' -manager_url <https://cas-staging.teradici.com>
```

## Example on how to use the script with "-ignore_cert"

```json
{ 
    "keyId":"6356ebcatyuk962b82460dd1", 
    "username":"6356ebjyt2b82460dd1", 
    "apiKey":"eyJhbGciOiJIUzUxMiIsInR5cCI6IkpXVCJ9.I6IjYzNTZlYjk0ZjZmMDk2YzkyYzQ2MGRhMSIsImp0aSI6ImI0NDA1OWNhMGEyNjcxZSIsImlhdCI6MTY2NjY0MDg0NywiZXhwIjoxNzYxMjQ4ODQ3fQ.ZcjXmo_el7ThftMuispX-Zm9mBYmCSDso3DyrMtn7EQZLJix_XFR9a3ffI-d2Vw4H8o1r7cuiKNAXBVEiV44FA", 
    "deploymentId":"6356ebab6c0ddfc771d7d412", 
    "keyName":"accountName", 
    "tenantId":"6356sdafww6f096c92c460da1" 
}
```

HP recommends exploring a secure password storage solutions and not have passwords stored in a plaintext file. Customers can modify this script to retrieve passwords from a secure locations. When using this script without modifications, please ensure the read access permissions are restricted to the JSON config file that holds the Manager password.

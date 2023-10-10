# (c) Copyright 2022 HP Development Company, L.P.
#
# This source code is licensed under the MIT license found in the
# LICENSE file in the root directory of this source tree.
# This script automatically install and register the Monitor to the AWM Manager
# This script must be run locally and it only works in Windows Hosts.
# This script must be with administrator privileges
# Once the script execution completes, the Monitor will be installed and the Host should be
# displayed as 'Healthy' in the Manager Admin UI.
#
# .\deploy_monitor.ps1 -config_file <json file> -monitor_hostname <ip or fqdn> -manager_url <AWM manager URL>
#
# e.g.:
# PS C:\> .\deploy_monitor.ps1 -config_file file.json -monitor_hostname 'hostname.domain.local' -manager_url https://cas-staging.teradici.com
#
# Additionally the -ignore_cert parameter could be added to skip certificate validation in case of self signed domains
# the config file can be downloaded in the deployment service account tab when editing the current deployment
# Config file example:
#
# {
# "keyId":"6356ebcatyuk962b82460dd1",
# "username":"6356ebjyt2b82460dd1",
# "apiKey":"any_apikey",
# "deploymentId":"6356ebab6c0ddfc771d7d412",
# "keyName":"accountName",
# "tenantId":"6356sdafww6f096c92c460da1"
# }
#
# HP recommends customers investigate their own secure password storage
# solutions and to not leave passwords stored in a plaintext file. This
# script can be modified by the customer to retrieve passwords from
# secure locations. If using this script without modifications, please
# make sure to restrict read access permissions to the JSON config file
# that holds the Manager password.


new-module -name deploy_monitor -scriptblock {

    Function Deploy {
        param(
            [Parameter(Mandatory = $true)]
            [string]$config_file,
            [Parameter(Mandatory = $true)]
            [string]$monitor_machine_name,
            [Parameter(Mandatory = $true)]
            [string]$manager_url,
            [Parameter()]
            [switch]$ignore_cert = $false,
            [Parameter()]
            [ValidateSet("stable", "beta", "dev")]
            [string]$channel = "stable"
        )

        #Requires -RunAsAdministrator

        $settings = ConvertFrom-Json (Get-Content $config_file -Raw)
        $username = $settings.username
        $apiKey = $settings.apiKey
        $deploymentId = $settings.deploymentId
        $tenantId = $settings.tenantId

        Function setSSLPolicy() {
            if ($ignore_cert) {

                "###############################################################################"
                "WARNING: Ignorning certificate validation to allow self-signed certificates."
                "###############################################################################"

                add-type @"
    using System.Net;
    using System.Security.Cryptography.X509Certificates;
    public class TrustAllMonitorCertsPolicy : ICertificatePolicy {
        public bool CheckValidationResult(
            ServicePoint srvPoint, X509Certificate certificate,
            WebRequest request, int certificateProblem) {
            return true;
        }
    }
"@
                [System.Net.ServicePointManager]::CertificatePolicy = New-Object TrustAllMonitorCertsPolicy

            }
        }

        Function MakeRequest {
            param(
                [Parameter(Mandatory = $true)] [string]$reqUrl,
                [Parameter(Mandatory = $true)] [string]$method,
                [string]$body,
                [string]$token
            )
            $headers = @{}
            $headers.Add("Accept", "*/*")
            $headers.Add("Content-Type", "application/json")
            if ($token) {
                $headers.Add("Authorization", $token)
            }
            $params = @{
                Uri     = $reqUrl
                Method  = $method
                Headers = $headers
            }
            if (!$body) {
                $params.Add("Body", $null)
            }
            else {
                $params.Add("Body", $body)
            }
            try {
                $response = Invoke-RestMethod @params
                return $response | ConvertTo-Json
            }
            catch {
                $errorMessage = $_.Exception
                Write-Host "ERROR: Failed to request $reqUrl with error $errorMessage."
                exit
            }
        }

        Function SignIn {
            Write-Host "--> Logging into HP Anyware Manager at $manager_url."
            $reqUrl = $manager_url + "/api/v1/auth/signin"
            $method = "POST"
            $body = @{
                username = $username
                password = $apiKey
                tenantId = $tenantId
            } | ConvertTo-Json

            $response = MakeRequest $reqUrl $method $body $token | ConvertFrom-Json
            $token = $response.data.token
            if (!$token) {
                Write-Host "ERROR: Failed to get token."
                exit
            }
            Write-Host "--> Authenticated."
            return $token
        }

        Function GetMachineId([string] $token) {
            Write-Host "--> Getting machine $monitor_machine_name id."
            $reqUrl = $manager_url + "/api/v1/machines?machineName=$monitor_machine_name"
            $method = "Get"

            $response = MakeRequest $reqUrl $method $body $token | ConvertFrom-Json
            $machineId = $response.data.machineId
            if (!$machineId) {
                Write-Host "ERROR: Could not find Machine ID of hostname $monitor_machine_name."
                exit
            }
            Write-Host "--> Sucessfully obtained machine id."
            return $machineId
        }

        Function EnableMonitor([string] $machineId, [string] $token) {
            Write-Host "--> Enabling monitor for machine $monitor_machine_name."
            $reqUrl = $manager_url + "/api/v1/machines/$machineId"
            $body = @{
                agentMonitored = $true
            } | ConvertTo-Json

            $method = "PUT"

            $response = MakeRequest $reqUrl $method $body $token | ConvertFrom-Json
            Write-Host "--> Monitor Enabled for machine $monitor_machine_name."
        }

        Function GetMonitorAPIToken([string] $machineId, [string] $token) {
            Write-Host "--> Getting monitor API token."
            $reqUrl = $manager_url + "/api/v1/auth/tokens/agent"
            $body = @{
                deploymentId = $deploymentId
                machineId    = $machineId
            } | ConvertTo-Json
            $method = "POST"

            $response = $response = MakeRequest $reqUrl $method $body $token | ConvertFrom-Json
            $monitorToken = $response.data.token
            if (!$monitorToken) {
                Write-Host "ERROR: Could not get monitor API token."
                exit
            }
            Write-Host "--> Token Obtained"
            return $monitorToken
        }

        Function InstallMonitor([string] $monitorToken) {
            $cloudsmithToken = "EwX7bPdudUUD6bsr"
            Write-Host "--> Starting monitor installation script."
            $channelUrls = @{
                "stable" = "https://dl.teradici.com/$cloudsmithToken/anyware-manager/raw/names/anyware-monitor-ps1/versions/latest/anyware-monitor.ps1"
                "beta"   = "https://dl.teradici.com/$cloudsmithToken/anyware-manager-beta/raw/names/anyware-monitor-ps1/versions/latest/anyware-monitor.ps1"
                "dev"    = "https://dl.teradici.com/$cloudsmithToken/anyware-manager-dev/raw/names/anyware-monitor-ps1/versions/latest/anyware-monitor.ps1"
            }

            $monitorSetupUrl = $channelUrls[$channel]

            $params = @{
                manager_uri    = $manager_url
                token          = $monitorToken
                download_token = $cloudsmithToken
                channel        = $channel
                use_download_timeout   = 0
            }
            if ($ignore_cert) {
                $params.Add("ignore_cert", 1)
            }

            .{ Invoke-WebRequest -useb $monitorSetupUrl } | Invoke-Expression; install @params
        }

        Function Pipeline {
            Write-Host "--> Starting Deploying process for monitor $monitor_machine_name."
            setSSLPolicy
            $token = SignIn
            $machineId = GetMachineId($token)
            EnableMonitor $machineId $token
            $monitorToken = GetMonitorAPIToken $machineId $token
            InstallMonitor($monitorToken)
        }

        Pipeline
    }

    export-modulemember -function "Deploy" -alias "deploy"
}
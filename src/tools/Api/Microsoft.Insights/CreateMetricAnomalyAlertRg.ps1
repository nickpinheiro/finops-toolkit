# Define variables
$tenantId = "86759412-e019-4f10-a127-be41d0dcbc72"

# Define variables
$subscriptionId = "e595abb5-209a-4cce-8515-6311102caecb"
$resourceGroupName = "Default-ActivityLogAlerts"
$alertRuleName = "DailyAnomalyByResourceGroup"
$location = "global"
$metricName = "ActualCost"
$timeGranularity = "Daily"
$alertThreshold = 80
$emailRecipients = @("nicholas_pinheiro@navyfederal.org")

# Connect to Azure
Connect-AzAccount -TenantId $tenantId -SubscriptionId $subscriptionId

# Create the scope
$scope = "/subscriptions/$subscriptionId/resourceGroups/$resourceGroupName"

# Create the request body
$body = @{
    "properties" = @{
        "displayName" = "Daily Anomaly by Resource Group"
        "description" = "Alert when daily anomaly is detected by resource group"
        "severity" = "3"
        "enabled" = $true
        "scopes" = @($scope)
        "evaluationFrequency" = "Day"
        "windowSize" = "Day"
        "criteria" = @{
            "allOf" = @(
                @{
                    "metricName" = $metricName
                    "metricNamespace" = "Microsoft.CostManagement"
                    "operator" = "GreaterThan"
                    "threshold" = $alertThreshold
                    "timeAggregation" = "Total"
                    "anomalyDetectionConfiguration" = @{
                        "granularity" = $timeGranularity
                    }
                }
            )
        }
        "actions" = @{
            "actionGroups" = @(
                @{
                    "actionGroupId" = "/subscriptions/$subscriptionId/resourceGroups/$resourceGroupName/providers/Microsoft.Insights/actionGroups/AGOwner"
                }
            )
        }
    }
    "location" = $location
}

# Get the access token
$token = (Get-AzAccessToken).Token

$uri = "https://management.azure.com/subscriptions/$subscriptionId/resourceGroups/$resourceGroupName/providers/Microsoft.Insights/alertRules/"+$alertRuleName+"?api-version=$apiVersion=2017-09-01-preview"

# Invoke the REST API to create the alert rule
Invoke-RestMethod `
    -Method Put `
    -Uri $uri `
    -Headers @{"Authorization"="Bearer $token"} `
    -ContentType "application/json; charset=utf-8" `
    -Body ($body | ConvertTo-Json -Depth 10 -Compress)

Write-Host "Daily Anomaly by Resource Group alert rule created successfully."

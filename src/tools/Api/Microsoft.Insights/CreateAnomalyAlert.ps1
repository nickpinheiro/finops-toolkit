# Define variables
$tenantId = "86759412-e019-4f10-a127-be41d0dcbc72"
$subscriptionId = "e595abb5-209a-4cce-8515-6311102caecb"
$resourceGroupName = "Default-ActivityLogAlerts"
$alertRuleName = "CostAnomalyDetectionAlert"
$location = "global"
$metricName = "UsedCapacity"
$alertThreshold = 80
$emailRecipients = @("nicholas_pinheiro@navyfederal.org")
$resourceIds = @(
    "/subscriptions/e595abb5-209a-4cce-8515-6311102caecb/resourceGroups/rg-datamining-batch-dev-002/providers/Microsoft.Storage/storageAccounts/stbatchdev002"
)
$apiVersion = "2017-09-01-preview"

# Connect to Azure
Connect-AzAccount -TenantId $tenantId -SubscriptionId $subscriptionId

# Iterate through resources
foreach ($resourceId in $resourceIds) {
    $body = @{
        "location" = $location
        "properties" = @{
            "description" = "Cost anomaly detection alert for $resourceId"
            "severity" = 3
            "enabled" = $true
            "evaluationFrequency" = "PT1H"   # Valid interval
            "windowSize" = "PT6H"           # Valid interval
            "scopes" = @($resourceId)
            "criteria" = @{
                "odata.type" = "Microsoft.Azure.Monitor.MultipleResourceMultipleMetricCriteria"
                "allOf" = @(
                    @{
                        "name" = "CostThreshold"
                        "metricName" = $metricName
                        "timeAggregation" = "Average"
                        "operator" = "GreaterThan"
                        "threshold" = $alertThreshold
                    }
                )
            }
            "actions" = @(
                @{
                    "actionGroupId" = "/subscriptions/$subscriptionId/resourceGroups/$resourceGroupName/providers/Microsoft.Insights/actionGroups/AGOwner"
                }
            )
        }
    }

    # Build the URI
    $uri = "https://management.azure.com/subscriptions/$subscriptionId/resourceGroups/$resourceGroupName/providers/Microsoft.Insights/metricAlerts/"+$alertRuleName+"?api-version=$apiVersion"

    # Invoke the REST API to create the alert rule
    $response = Invoke-RestMethod `
        -Method Put `
        -Uri $uri `
        -Headers @{ "Authorization" = "Bearer $token" } `
        -ContentType "application/json; charset=utf-8" `
        -Body ($body | ConvertTo-Json -Depth 10 -Compress)

    Write-Host "Cost Anomaly Detection Alert created successfully for $resourceId."
}

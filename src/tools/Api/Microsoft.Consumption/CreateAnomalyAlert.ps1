# Define variables
$tenantId = "86759412-e019-4f10-a127-be41d0dcbc72"
$subscriptionId = "e595abb5-209a-4cce-8515-6311102caecb"
$resourceGroupName = "rg-datamining-batch-dev-002"
$budgetName = "DailyAnomalyByResourceGroup"
$apiVersion = "2021-10-01"
$scope = "/subscriptions/$subscriptionId/resourceGroups/$resourceGroupName"

# Date variables
$startDate = (Get-Date -Day 1).ToString("yyyy-MM-dd") # First day of the current month
$endDate = (Get-Date -Day 1).AddYears(1).ToString("yyyy-MM-dd") # First day of the same month next year

# Authentication
Connect-AzAccount -TenantId $tenantId -SubscriptionId $subscriptionId
$token = (Get-AzAccessToken).Token

# Create request body
$body = @{
    "properties" = @{
        "category" = "Cost"  # Budget category
        "amount" = 1000      # Maximum budget threshold
        "timeGrain" = "Monthly"
        "timePeriod" = @{
            "startDate" = $startDate
            "endDate" = $endDate
        }
        "notifications" = @{
            "AnomalyDetection" = @{
                "enabled" = $true
                "operator" = "GreaterThan"
                "threshold" = 80  # Sensitivity for anomaly detection
                "contactEmails" = @("nicholas_pinheiro@navyfederal.org")
            }
        }
    }
}

# API URI
$uri = "https://management.azure.com$($scope)/providers/Microsoft.Consumption/budgets/"+$budgetName+"?api-version=$apiVersion"

# Send the API request
$response = Invoke-RestMethod `
    -Method Put `
    -Uri $uri `
    -Headers @{ "Authorization" = "Bearer $token" } `
    -ContentType "application/json" `
    -Body ($body | ConvertTo-Json -Depth 10)

Write-Host "Budget anomaly detection alert created successfully."

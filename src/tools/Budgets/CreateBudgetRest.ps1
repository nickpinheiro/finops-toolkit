# Authenticate and select the subscription and tenant
$tenantId = "86759412-e019-4f10-a127-be41d0dcbc72"
$subscriptionId = "e595abb5-209a-4cce-8515-6311102caecb"
$budgetName = "Azure_FinOps_Budget"
$contactEmail = "nick.pinheiro@microsoft.com"
$startDate = "2024-10-01T00:00:00Z"
$endDate = "2024-12-31T00:00:00Z"
$amount = 500

Connect-AzAccount -TenantId $tenantId -SubscriptionId $subscriptionId

$body = @{
    "properties"= @{
        "category" = "Cost"
        "amount"= $amount
        "timeGrain" = "Monthly"
        "timePeriod"= @{
            "startDate" = $startDate
            "endDate" = $endDate
        }
        "notifications" = @{
            "Forecasted_GreaterThan_80_Percent" = @{
                "enabled" = $true
                "operator" = "GreaterThan"
                "threshold" = 80
                "locale" = "en-us"
                "contactEmails" = @($contactEmail)
                "thresholdType" = "Forecasted"
            }
            "Actual_GreaterThan_90_Percent" = @{
                "enabled" = $true
                "operator" = "GreaterThan"
                "threshold" = 90
                "locale" = "en-us"
                "contactEmails" = @($contactEmail)
                "thresholdType" = "Actual"
            }
        }
    }
}
$token=(Get-AzAccessToken).token
Invoke-RestMethod `
    -Method Put `
    -Headers @{"Authorization"="Bearer $token"} `
    -ContentType "application/json; charset=utf-8" `
    -Body (ConvertTo-Json $body -Depth 10) `
    -Uri "https://management.azure.com/subscriptions/$subscriptionId/providers/Microsoft.Consumption/budgets/$budgetName/?api-version=2021-10-01"

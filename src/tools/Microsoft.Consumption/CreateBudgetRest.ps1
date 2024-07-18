###############################################################################################################################
#                                           Azure Cost Management Budget Creation Script                                       #
#                                                                                                                              #
# This script creates a budget in Azure Cost Management using the REST API.                                                    #
#                                                                                                                              #
# Features:                                                                                                                    #
# - Creates a budget for a specific subscription and tenant.                                                                   #
# - Sets a specific amount, start date, and end date for the budget.                                                           #
# - Includes two notifications:                                                                                                #
#   - Forecasted_GreaterThan_80_Percent: Notifies when the forecasted amount is greater than 80% of the budget.                #
#   - Actual_GreaterThan_90_Percent: Notifies when the actual amount is greater than 90% of the budget.                        #
# - Notifications are sent to specified contact emails.                                                                        #
#                                                                                                                              #
# Requirements:                                                                                                                #
# - Azure PowerShell module for authentication and REST API calls.                                                             #
# - Input parameters: subscription ID, tenant ID, budget name, contact emails, start date, end date, and amount.               #
###############################################################################################################################


# Authenticate and select the subscription and tenant
$tenantId = "86759412-e019-4f10-a127-be41d0dcbc72"
$subscriptionId = "e595abb5-209a-4cce-8515-6311102caecb"
$budgetName = "Azure_FinOps_Budget"
$contactEmails = @("nicholas_pinheiro@navyfederal.org", "alok_kar@navyfederal.org")
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
                "contactEmails" = $contactEmails
                "thresholdType" = "Forecasted"
            }
            "Actual_GreaterThan_90_Percent" = @{
                "enabled" = $true
                "operator" = "GreaterThan"
                "threshold" = 90
                "locale" = "en-us"
                "contactEmails" = $contactEmails
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
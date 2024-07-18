# Authenticate and select the subscription and tenant
$tenantId = "86759412-e019-4f10-a127-be41d0dcbc72"
$subscriptionId = "e595abb5-209a-4cce-8515-6311102caecb"

Connect-AzAccount -TenantId $tenantId -SubscriptionId $subscriptionId

# Variables
$resourceGroupName = "rg-budget-dev-001"
$budgetName = "Budget1"
$amount = 5000
$startDate = "2024-10-01T00:00:00Z"
$endDate = "2024-12-31T00:00:00Z"
$email = "your-email@example.com"

# Scope
$scope = "/subscriptions/$subscriptionId/resourceGroups/$resourceGroupName"

# Notifications
$notifications = @{
    ActualGreaterThan80Percent = @{
        Enabled = $true
        Operator = "GreaterThan"
        Threshold = 80
        ThresholdType = "Actual"
        ContactEmails = @($email)
        ContactRoles = @("Contributor", "Reader")
    }
}

# Create Budget
New-AzConsumptionBudget -Name $budgetName -Amount $amount -TimeGrain Monthly -StartDate $startDate -EndDate $endDate -Category Cost
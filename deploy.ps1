# Define variables
$resourceGroupName = "FinanceResources"
$location = "westus"
$logFilePath = "./logs/deployment.log"

# Paths to templates and parameter files
$vnetTemplatePath = "./templates/vnet-template.json"
$vnetParameterPath = "./parameters/vnet-parameters.json"
$vmTemplatePath = "./templates/vm-template.json"
$vmParameterPath = "./parameters/vm-parameters.json"
$storageTemplatePath = "./templates/storage-template.json"
$storageParameterPath = "./parameters/storage-parameters.json"

# Create logs directory if it doesn't exist
if (!(Test-Path -Path "./logs")) {
    New-Item -ItemType Directory -Path "./logs" | Out-Null
}

# Start logging
Start-Transcript -Path $logFilePath -Append
Write-Host "Deployment started. Logs will be saved to $logFilePath."

# Error handling for the entire script
try {
    # Create a resource group
    Write-Host "Creating Resource Group: $resourceGroupName in $location..."
    New-AzResourceGroup -Name $resourceGroupName -Location $location

    # Deploy the Virtual Network
    Write-Host "Deploying Virtual Network..."
    New-AzResourceGroupDeployment -ResourceGroupName $resourceGroupName `
        -TemplateFile $vnetTemplatePath `
        -TemplateParameterFile $vnetParameterPath

    # Deploy the Storage Account
    Write-Host "Deploying Storage Account..."
    New-AzResourceGroupDeployment -ResourceGroupName $resourceGroupName `
        -TemplateFile $storageTemplatePath `
        -TemplateParameterFile $storageParameterPath

    # Deploy the Virtual Machine
    Write-Host "Deploying Virtual Machine..."
    New-AzResourceGroupDeployment -ResourceGroupName $resourceGroupName `
        -TemplateFile $vmTemplatePath `
        -TemplateParameterFile $vmParameterPath

    # Verify deployments
    Write-Host "Deployment Completed. Verifying Resources in Resource Group: $resourceGroupName..."
    $resources = Get-AzResource -ResourceGroupName $resourceGroupName
    $resources | ForEach-Object {
        Write-Host "Resource Name: $($_.Name), Type: $($_.ResourceType)"
    }

    Write-Host "All resources deployed successfully!"
} catch {
    # Log error details
    Write-Host "Error during deployment: $($_.Exception.Message)"
    Write-Host "Check the log file for more details: $logFilePath"
} finally {
    # Stop logging
    Stop-Transcript
    Write-Host "Deployment logs saved to $logFilePath."
}

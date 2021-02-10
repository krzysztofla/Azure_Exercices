# az login

$servicePrincipalName = "HermesMainSP"

$sp = az ad sp create-for-rbac --name $servicePrincipalName | ConvertFrom-Json
$sp 

$sp = az ad sp show --id "db84353f-e7de-4071-bef1-9dd123d35c8d"
$sp

#check role assignments
az ad sp show --id $sp.appId
az ad sp list --display-name $servicePrincipalName

az role assignment list --assignee $sp.appId

$webAppName = "HermesWebAppExample"
$kvName = "HermesExampleKV"
$webAppRgName = "HermesExampleRG"
$webAppPlanName = "HermesExampleWebPlan"
$location = "westeurope"

#create resource group
az group create -n $webAppRgName -l $location

#create key vault
az keyvault create `
-n $kvName `
-g $webAppRgName `
--sku standard

#grant access for SP to KV
az keyvault set-policy --name $kvName --object-id "8d0e0282-4f4a-4a1e-8ea6-74865ac8763e" --secret-permissions GET

#create service plan
az appservice plan create `
-n $webAppPlanName `
-g $webAppRgName `
--sku FREE

#create web app
az webapp create `
-g $webAppRgName `
--plan $webAppPlanName `
-n $webAppName

#change role assignment from contributor to website contributor
$sampleWeb = az webapp show `
--name $webAppName `
-g $webAppRgName | ConvertFrom-Json
$sampleWeb.id

az role assignment create `
--role "Website Contributor" `
--assignee $sp.appId `
--scope $sampleWeb.id

#service principle vs Managed Service Identities - hot to manage the problem with geting credentials in your code for authentication to cloud services.
$sysid = az webapp identity assign `
-g $webAppRgName `
-n $webAppName `
$sysid

az webapp identity show `
-n $webAppName -g $webAppRgName

#key vault is a service for securely storing secrets. It will lock up those secrets in a vault for you and allow acces to those secrets by those granted permissions.
#this has a problem. When using service principle you need to keep somewhere in application configuration the credentials for authentication with the Key Vault. 
#this has been solved by MSI - Managed Service Identity 

#create key vault secret
az keyvault secret set `
--vault-name $kvName `
--name "connectionString" `
--value "this is the example connection string from KV"

az keyvault secret show `
--vault-name $kvName `
--name connectionString

#login as service principle
az login --service-principle --u $sp.appId --password $sp.password
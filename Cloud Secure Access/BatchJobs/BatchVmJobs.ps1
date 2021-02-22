$rgName = "batch"
$stgAccountName = "exstgaccbatch204"
$location = "westeurope"
$batchAccountName = "examplebatchaccountname"
$poolName = "myexamplepool"

az login

az group create -l $location -n $rgName

az storage account create --name $stgAccountName --resource-group $rgName --location $location

az batch account create --name $batchAccountName --resource-group $rgName --storage-account $stgAccountName --location $location 

az batch account login --name $batchAccountName --resource-group $rgName --shared-key-auth

az batch pool create --id mypool --vm-size Standard_A1_v2 --target-dedicated-nodes 2 --image canonical:ubuntuserver:16.04-LTS --node-agent-sku-id "batch.node.ubuntu 16.04"

az batch job create --id myjob --pool-id mypool

for($i=0; $i -lt 4; $i++) {
    az batch task create --task-id mytask$i --job-id myjob --command-line "/bin/bash -c 'printenv | grep AZ_BATCH; sleep 90s'"
}
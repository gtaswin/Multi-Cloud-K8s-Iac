# AZURE TERRAFORM

## Required id and key to run terraform code

### Subscription ID
- Open the Azure Portal and log in to your Azure account.
- GO to Subscription page.
- Select the subscription you want to use.
- Note down subscription ID.
### Create Service Principal to get CLient ID, tenant ID, Client Secrets
- Open the Azure portal and go to the "Azure Active Directory" page.
- Click on "App registrations" and then click on "New registration".
- Enter a name for the application and select the type of application. whether it is for single or multi tenant.
- click on "Register".
- Once the application is registered, note down the "Application (client) ID" and "Directory (tenant) ID".
- Next, create a client secret by clicking on "Certificates & secrets" and then "New client secret". Note down the secret value that is displayed.
### Create role to service principal
- GO to Subscription page.
- Select the subscription that already selected.
- On the subscription overview page, select Access control (IAM) Tab. Click press Add button -> Add custom role
- Provide name (Terraform) and switch to json tab. Then click edit button and paste below json policy.
- Press review and create. 
### Assaign role to service principal
- GO to Subscription page.
- Select the subscription that already selected.
- On the subscription overview page, select Access control (IAM) Tab. Click press Add button -> 'role assaignment'
- Select 'Terraform' role for terraform management. press 'Next'. Then Select member that you have created.
- And press next and assaign.
### Role for terraform in JSON
- With *
```
"Microsoft.Compute/*",
"Microsoft.ContainerService/*",
"Microsoft.Network/*",
"Microsoft.Resources/subscriptions/resourceGroups/*"
```
- Without *
```

{
    "properties": {
        "roleName": "Terraform",
        "description": "Policy for terraform",
        "assignableScopes": [
            "/subscriptions/a75235a7-5421-48ad-b9ab-814561e2cfd7"
        ],
        "permissions": [
            {
                "actions": [
                    "Microsoft.Network/virtualNetworks/read",
                    "Microsoft.Network/virtualNetworks/write",
                    "Microsoft.Network/virtualNetworks/delete",
                    "Microsoft.Network/virtualNetworks/subnets/read",
                    "Microsoft.Network/virtualNetworks/subnets/write",
                    "Microsoft.Network/virtualNetworks/subnets/delete",
                    "Microsoft.Network/networkInterfaces/read",
                    "Microsoft.Network/networkInterfaces/write",
                    "Microsoft.Network/networkInterfaces/delete",
                    "Microsoft.Network/networkInterfaces/ipConfigurations/read",
                    "Microsoft.Network/networkInterfaces/ipConfigurations/write",
                    "Microsoft.Network/networkInterfaces/ipConfigurations/delete",
                    "Microsoft.Network/publicIPAddresses/read",
                    "Microsoft.Network/publicIPAddresses/write",
                    "Microsoft.Network/publicIPAddresses/delete",
                    "Microsoft.Network/networkSecurityGroups/read",
                    "Microsoft.Network/networkSecurityGroups/write",
                    "Microsoft.Network/networkSecurityGroups/delete",
                    "Microsoft.Network/networkSecurityGroups/securityRules/read",
                    "Microsoft.Network/networkSecurityGroups/securityRules/write",
                    "Microsoft.Network/networkSecurityGroups/securityRules/delete",
                    "Microsoft.Resources/subscriptions/resourceGroups/read",
                    "Microsoft.Resources/subscriptions/resourceGroups/write",
                    "Microsoft.Resources/subscriptions/resourceGroups/delete",
                    "Microsoft.Resources/subscriptions/resourceGroups/tag"
                    "Microsoft.Compute/virtualMachines/read",
                    "Microsoft.Compute/virtualMachines/write",
                    "Microsoft.Compute/virtualMachines/delete",
                    "Microsoft.Compute/virtualMachines/start/action",
                    "Microsoft.Compute/virtualMachines/restart/action",
                    "Microsoft.Compute/virtualMachines/powerOff/action",
                    "Microsoft.Compute/disks/read",
                    "Microsoft.Compute/disks/write",
                    "Microsoft.Compute/disks/delete",
                    "Microsoft.Compute/snapshots/read",
                    "Microsoft.Compute/snapshots/write",
                    "Microsoft.Compute/snapshots/delete",
                    "Microsoft.ContainerService/managedClusters/read",
                    "Microsoft.ContainerService/managedClusters/write",
                    "Microsoft.ContainerService/managedClusters/delete",
                    "Microsoft.ContainerService/agentPools/read",
                    "Microsoft.ContainerService/agentPools/write",
                    "Microsoft.ContainerService/agentPools/delete",
                "notActions": [],
                "dataActions": [
                    "Microsoft.Storage/storageAccounts/blobServices/containers/blobs/delete",
                    "Microsoft.Storage/storageAccounts/blobServices/containers/blobs/read",
                    "Microsoft.Storage/storageAccounts/blobServices/containers/blobs/write",
                    "Microsoft.Storage/storageAccounts/blobServices/containers/blobs/move/action",
                    "Microsoft.Storage/storageAccounts/blobServices/containers/blobs/add/action"
                ],
                "notDataActions": []
            }
        ]
    }
}
```
Note: Replace Subscription ID

## TERRAFORM COMMANDS TO DEPLOY
- To create the cluster
- Before create pls check vaiables files to change any parameter based on requirements.
```
terraform init 
terraform plan -var subscription_id="" -var client_id="" -var client_secret="" -var tenant_id="" -var resource_group_name="any_name"
terraform apply -var subscription_id="" -var client_id="" -var client_secret="" -var tenant_id="" -var resource_group_name="any_name"
```
- To destroy the cluster
```
terraform destroy -var subscription_id="" -var client_id="" -var client_secret="" -var tenant_id="" -var resource_group_name="any_name"
```
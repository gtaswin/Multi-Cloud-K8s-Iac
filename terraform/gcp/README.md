# GCP TERRAFORM

## A GCP service account key: Create a service account key to enable Terraform to access your GCP account. When creating the key, use the following settings:
- Select the project you created in the previous step.
- Click "Create Service Account".
- Give it any name you like and click "Create".
- For the Role, Add all below roles, then click "Continue".
```
Compute Admin
Compute Network Admin
Kubernetes Engine Admin
Service Account User
```
- Skip granting additional users access, and click "Done".
- Select your service account from the list.
- Select the "Keys" tab.
- In the drop down menu, select "Create new key".
- Leave the "Key Type" as JSON.
- Click "Create" to create the key and save the key file to your system.

## TERRAFORM COMMANDS TO DEPLOY
- To create the cluster
- Before create pls check vaiables files to change any parameter based on requirements.
```
terraform init 
terraform plan -var project_id="" -var sa_key="" -var resource_group_name="any_name"
terraform apply -var project_id="" -var sa_key="" -var resource_group_name="any_name"
```
- To destroy the cluster
```
terraform destroy -var project_id="" -var sa_key="" -var resource_group_name="any_name"
```
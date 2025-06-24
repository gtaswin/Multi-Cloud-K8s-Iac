# AWS TERRAFORM

## Create the policy for Terraform
- In IAM, select policy tab. Then click on 'Create Policy'.
- Select JSON tab and paste below policy for terraform to create bot services.
- Click Next and provide name for the policy (Terraform) and create.
## Required access and secret keys to run terraform code
- Log in to the AWS Management Console with your AWS account credentials.
- Navigate to the IAM (Identity and Access Management) console.
- Click on "Users" in the left-hand menu and then click on the "Add user" button.
- Enter a name for the user, such as "Terraform" and Click on "Next: Permissions" to proceed to the next step.
- On the "Set permissions" screen, select "Attach existing policies directly" and then select the policies that you want to associate with the service account.
- Select the "Terraform" policy if you plan to use Terraform to create and manage EC2 and Eks instances etc.
- Click on "Next: Tags" to proceed to the next step.
- Click on "Create user" to create the service account.
- Once user is created. clicke the user name 'Terraform'. Press Create access key.
- Select CLI option and press Next button.  
- Now, you will see the access key ID and secret access key for the service account. These credentials will be used by Terraform to authenticate with the AWS API.


## Policy for Terraform in JSON
- With *
```
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Effect": "Allow",
            "Action": [
                "ec2:*",
                "eks:*",
                "autoscaling:*",
                "cloudwatch:*",
                "elasticloadbalancing:*"
            ],
            "Resource": [
                "*"
            ]
        }
    ]
}
```
- Without *
```
{
    "Version": "2012-10-17",
    "Statement": [
        {
        "Effect": "Allow",
        "Action": [
            "ec2:RunInstances",
            "ec2:TerminateInstances",
            "ec2:DescribeInstances",
            "ec2:DescribeSecurityGroups",
            "ec2:DescribeKeyPairs",
            "ec2:DescribeSubnets",
            "ec2:CreateNetworkInterface",
            "ec2:DeleteNetworkInterface",
            "ec2:DescribeNetworkInterfaces",
            "ec2:AttachNetworkInterface",
            "ec2:DetachNetworkInterface",
            "ec2:AllocateAddress",
            "ec2:AssociateAddress",
            "ec2:DescribeAddresses",
            "ec2:CreateNatGateway",
            "ec2:DeleteNatGateway",
            "ec2:DescribeNatGateways",
            "ec2:CreateRouteTable",
            "ec2:DeleteRouteTable",
            "ec2:DescribeRouteTables",
            "ec2:CreateRoute",
            "ec2:DeleteRoute",
            "ec2:DescribeRouteTables",
            "ec2:CreateInternetGateway",
            "ec2:DeleteInternetGateway",
            "ec2:DescribeInternetGateways"
        ],
        "Resource": "*"
        },
        {
        "Effect": "Allow",
        "Action": [
            "eks:CreateCluster",
            "eks:DeleteCluster",
            "eks:DescribeCluster",
            "eks:UpdateClusterConfig",
            "eks:UpdateClusterVersion",
            "eks:TagResource",
            "eks:UntagResource",
            "eks:ListTagsForResource",
            "eks:CreateNodegroup",
            "eks:UpdateNodegroupConfig",
            "eks:DeleteNodegroup",
            "eks:DescribeNodegroup",
            "eks:ListNodegroups",
            "eks:DescribeUpdate",
            "eks:UpdateNodegroupVersion",
            "eks:CreateFargateProfile",
            "eks:UpdateFargateProfile",
            "eks:DeleteFargateProfile",
            "eks:DescribeFargateProfile"
        ],
        "Resource": "*"
        },
        {
        "Effect": "Allow",
        "Action": [
            "autoscaling:AttachInstances",
            "autoscaling:CreateAutoScalingGroup",
            "autoscaling:CreateLaunchConfiguration",
            "autoscaling:DeleteAutoScalingGroup",
            "autoscaling:DeleteLaunchConfiguration",
            "autoscaling:DescribeAutoScalingGroups",
            "autoscaling:DescribeLaunchConfigurations",
            "autoscaling:DetachInstances",
            "autoscaling:UpdateAutoScalingGroup",
            "autoscaling:SetDesiredCapacity"
        ],
        "Resource": "*"
        },
        {
        "Effect": "Allow",
        "Action": [
            "cloudwatch:PutMetricAlarm",
            "cloudwatch:DeleteAlarms",
            "cloudwatch:DescribeAlarms",
            "cloudwatch:GetMetricData",
            "cloudwatch:GetMetricStatistics",
            "cloudwatch:ListMetrics",
            "cloudwatch:PutDashboard",
            "cloudwatch:DeleteDashboards"
        ],
        "Resource": "*"
        },
        {
        "Effect": "Allow",
        "Action": [
            "elasticloadbalancing:CreateLoadBalancer",
            "elasticloadbalancing:DeleteLoadBalancer",
            "elasticloadbalancing:DescribeLoadBalancers",
            "elasticloadbalancing:CreateTargetGroup",
            "elasticloadbalancing:DeleteTargetGroup",
            "elasticloadbalancing:DescribeTargetGroups",
            "elasticloadbalancing:CreateListener",
            "elasticloadbalancing:DeleteListener",
            "elasticloadbalancing:DescribeListeners"
        ],
        "Resource": "*"
        }

    ]
}

```

## TERRAFORM COMMANDS TO DEPLOY
- To create the cluster
- Before create pls check vaiables files to change any parameter based on requirements.
```
terraform init 
terraform plan -var client_id="" -var client_secret="" -var resource_group_name="any_name"
terraform apply -var client_id="" -var client_secret="" -var resource_group_name="any_name"
```
- To destroy the cluster
```
terraform destroy -var client_id="" -var client_secret="" -var resource_group_name="any_name"
```
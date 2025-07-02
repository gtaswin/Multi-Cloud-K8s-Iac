# Multi-Cloud Kubernetes Infrastructure with Terraform

![Terraform](https://img.shields.io/badge/Terraform-%237B42BC.svg?style=for-the-badge&logo=terraform&logoColor=white)
![Kubernetes](https://img.shields.io/badge/Kubernetes-%23326CE5.svg?style=for-the-badge&logo=kubernetes&logoColor=white)
![AWS](https://img.shields.io/badge/AWS-%23FF9900.svg?style=for-the-badge&logo=amazon-aws&logoColor=white)
![GCP](https://img.shields.io/badge/GCP-%234285F4.svg?style=for-the-badge&logo=google-cloud&logoColor=white)
![Azure](https://img.shields.io/badge/Azure-%230078D4.svg?style=for-the-badge&logo=microsoft-azure&logoColor=white)

This repository contains production-grade Terraform code for provisioning scalable Kubernetes clusters across multiple cloud providers (AWS, GCP, Azure). It is designed to be a robust, reusable boilerplate for creating both stateless and stateful application infrastructures.

## Key Features

-   **Multi-Cloud Support:** Deploy consistent Kubernetes infrastructure on AWS, GCP and Azure.
-   **Automated Scaling:** Natively supports autoscaling at both the Pod (HPA) and Node (Cluster Autoscaler) levels.
-   **Workspace Ready:** Utilizes Terraform Workspaces to easily manage multiple environments (e.g., `staging`, `production`) with the same codebase.
-   **Stateful & Stateless Design:** Provides a foundation for running any workload, from simple web apps to complex data services.

## Architecture Overview

The diagram below illustrates the high-level architecture, including the automated scaling mechanism that responds to sudden traffic increases. This applies to all Cloud providers.

![Cloud Infrastructure Architecture](./assets/architecture.svg)

### How Autoscaling Works

This infrastructure is built to handle dynamic workloads seamlessly:
1.  **Traffic Spike:** As user traffic increases, the CPU/memory load on the existing pods rises.
2.  **Pod Autoscaling (HPA):** The **Horizontal Pod Autoscaler (HPA)** detects this increased load and automatically provisions new application pods to distribute the work.
3.  **Node Autoscaling (Cluster Autoscaler):** If the new pods cannot be scheduled due to a lack of resources, the **Cluster Autoscaler** detects the pending pods and automatically provisions new VMs (nodes) to the cluster to accommodate them.

This two-tiered approach ensures both cost-efficiency during low traffic and high availability during traffic spikes.

## Prerequisites

-   Terraform CLI installed.
-   Access credentials configured for your target cloud provider (e.g., via AWS CLI, gcloud CLI, Azure CLI).
-   `kubectl` installed to interact with the cluster.

## Getting Started

1.  **Clone the Repository:**
    ```sh
    git clone [your-repository-url]
    cd [repository-directory]
    ```

2.  **Configure Your Deployment:**
    -   Follow the provider-specific instructions below to set up your credentials and environment.
    -   Navigate to the directory for your chosen cloud provider (`aws`, `azure`, or `gcp`).
    -   Review the `variables.tf` file to see available configuration options.

3.  **Deploy the Infrastructure:**
    -   Run the `terraform init` command.
    -   Run the `terraform apply` command, passing the required variables as prompted or via a `.tfvars` file.

4.  **Destroy the Infrastructure:**
    When you are finished, you can tear down all created resources:
    ```sh
    terraform destroy
    ```

## Provider-Specific Instructions

### AWS

1.  **Create an IAM Policy:** Create an IAM policy named `Terraform` with the permissions required to create and manage EC2 and EKS resources.
2.  **Create an IAM User:** Create an IAM user and attach the `Terraform` policy.
3.  **Generate Access Keys:** Generate an access key ID and secret access key for the IAM user.
4.  **Deploy:**
    ```sh
    cd terraform/aws
    terraform init
    terraform apply
    ```

### Azure

1.  **Get Subscription ID:** Note your Azure subscription ID.
2.  **Create a Service Principal:** Create an Azure Active Directory service principal to get a client ID, tenant ID, and client secret.
3.  **Create a Custom Role:** Create a custom role named `Terraform` with the necessary permissions for creating resources.
4.  **Assign Role:** Assign the `Terraform` role to the service principal you created.
5.  **Deploy:**
    ```sh
    cd terraform/azure
    terraform init
    terraform apply -var subscription_id="<your_subscription_id>" -var client_id="<your_client_id>" -var client_secret="<your_client_secret>" -var tenant_id="<your_tenant_id>"
    ```

### GCP

1.  **Create a Service Account:** Create a GCP service account with the following roles:
    *   Compute Admin
    *   Compute Network Admin
    *   Kubernetes Engine Admin
    *   Service Account User
2.  **Generate a Key:** Create a JSON key for the service account and download it.
3.  **Deploy:**
    ```sh
    cd terraform/gcp
    terraform init
    terraform apply -var project_id="<your_project_id>" -var sa_key_file="<path_to_your_sa_key.json>"
    ```

## Advanced Usage

### Managing Multiple Environments

To create and manage distinct environments like `staging` and `production` without duplicating code, use Terraform Workspaces.

```sh
# Create a new workspace for staging
terraform workspace new staging

# Select the staging workspace to work on it
terraform workspace select staging

# Now, any `terraform apply` will only affect the staging environment
terraform apply
```

## About Me

This project was created by **Aswin G T** as a portfolio piece to demonstrate expertise in DevOps, Infrastructure as Code, and multi-cloud architecture. I am passionate about building robust, scalable, and automated systems.

-   **LinkedIn:** [linkedin.com/in/gtas](https://www.linkedin.com/in/gtas)
-   **GitHub:** [github.com/gtaswin](https://github.com/gtaswin)

## License

This project is licensed under the MIT License. See the [LICENSE](LICENSE) file for the full details.
# DevOps Challenge

## Exercise
* EKS (Elastic Kubernetes Service)
  * Using node groups
* Convert the k8s yaml files to a helm chart
* Deploy helm chart to the EKS cluster
* Expose the application deployed in EKS via an ALB (Application Load Balancer)
    * We recommend using [AWS Load Balancer Controller](https://kubernetes-sigs.github.io/aws-load-balancer-controller/v2.2/)

### Terraform Requirements:
* Terraform code should be formatted using `terraform fmt`
* Terraform version must be 0.15.3 or higher
* State should be stored in s3 - ensure there is some way for to easily create and destroy the s3 bucket and dynamodb table

### Application
The application is the 2048 and application.yaml file needs to be converted into a helm chart (charts/ folder)
Please consider the following:
* Helm chart should be written in Helm 3
* What variables should be exposed out
* Consider namespacing and how you handle this


## Deploying

The overall project has been divided into 3 sub projects which are mentioned below.
1. tf-bootstrap folder contains the terraform code to create the s3 bucket, dynamo db for terraform state. This project maintains the terraform state locally and should be accessed by Admins only to create the terraform state remote backend configuration onetime.
2. The root folder contains the terraform code to 
   - Provision EKS cluster using node groups.
   - The helm charts of the 2048 application.
   - kustomization.tf file to deploy AWS Load Balancer Controller and create application namespace game-2048 where the application code will be deployed.
3. The folder named "application" contains terraform code to deploy the application helm charts, but it is optional as generally the application deployment CI/CD pipeline (such as Jnekins, AWS CodeDeploy) is used to do this. 

### Deployment prerequisite
- an AWS account with the IAM permissions listed on the [EKS module documentation](https://github.com/terraform-aws-modules/terraform-aws-eks/blob/master/docs/iam-permissions.md)
- a configured AWS CLI
- AWS IAM Authenticator
- kubectl
- Helm3
- Terraform
- Git

### Deployment steps
For the sake of simplicity, no CI/CD pipeline is built here. The automation scripts written using terraform needs to be run on a bastion host or a local machine.

1. AWS S3 bucket, DynamoDB creation - Clone the GitHub repository and go to the root folder.
```
cd tf-bootstrap
terraform init
terraform apply 
```
2. Create EKS - On root folder (**devops-challenge-master**)
```
terraform init
terraform apply 
```
The above script will provision an EKS cluster, deploy an AWS Load Balancer Controller to EKS and also create an application namespace game-2048 to EKS.
Next update the kubectl to execute commands on the EKS cluster.
```
aws eks --region $(terraform output -raw region) update-kubeconfig --name $(terraform output -raw cluster_name)
```

3. Deploy the 2048 application to EKS (stay on to the root folder *devops-challenge-master*). 
```
helm install app-2048 ./charts/ -n game-2048
```
> **Note** : Note : Since this is an application, it is kept outside of the infrastructure automation code. In actual cases, it is deployed through the deployment pipeline.

Optionally the 2048 application can be deployed using terraform.
```
cd application
terraform init
terraform apply
```
> After deployment, application can be accessible through the public facing AWS ALB endpoint. Get this from the ingress resource or from the AWS.

### Deployment destroy
1. Uninstall the 2048 application from EKS (from **devops-challenge-master**)
```
helm uninstall app-2048 -n game-2048
```
or ( if deployed using terraform)
```
cd application
terraform destroy
```
2. Destroy the EKS  (from **devops-challenge-master**)
```
terraform destroy
```
3. Destroy the S3 and DynamoDB created for keeping terraform state
```
cd tf-bootstrap
terraform destroy
```

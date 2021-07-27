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
1. tf-bootstrap folder contains the terraform code to create the s3 bucket, dynamo db for terraform state. This project maintains the terraform state locally and should be accessible by admin to create the terraform state remote back end configuration single time.
2. the root folder contains the terraform code to 
   - Provision EKS cluster using node
   - 
//TODO Please update here on how to create the s3 bucket, dynamo db for terraform state and any requirements for running the terraform code.
1. Backend config - var is not allowed - need to pass as command line parameters 
2. Create the s3 bucket first - maybe through code and separate terraform
3. remove the hard coded values 
4. Create namepsace using kubectl

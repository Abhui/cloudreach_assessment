# cloudreach_assessment

# The folder ci_cd_design consists of Terraform file to create a single EKS cluster in AWS and CI/CD (Jenkins) process uses the Helm Chart to install the Weather-app application to EKS cluster as a microservice.

Diagram - Basic structure of CI/CD process
 
 ![Slide1](https://user-images.githubusercontent.com/31002116/126179463-9b7ed0a6-50f0-42d5-84b2-31ed94ad86cd.JPG)



CI/CD process Explanation
1. Developers will commit the application code into SCM (Git/Code repo) 
2. Testing stage will be included in the pipeline using a sonarqube stage for code quality check (need to set up a sonar server)
3. Dockerfile with necessary steps to create a dockerimage of the application will be pushed into the repo
4. Jenkinsfile (groovy/declarative) with stages defined in it for a complete CI/CD process
5. In Jenkins we'll create a modular multi branch approach so that every time a developer commits a code into any branch of the repository the jenkins pipeline will trigger, while the 'main' branch will only create a docker image
6. The built image will then be pushed to any of our private container image registry service (dockerhub/ECR)
7. The next steps of Jenkins pipeline will invoke the helm chart from the repository where we store our code will dynamically fetch the latest tag dockerimage built above
8. Finally the helm will chart will be using by the Jenkins pipeline to deploy into our EKS cluster as a deployment, helm install and initialize process will be included in the Jenkinsfile

How to setup EKS Cluster in AWS using Terrform
Please refer to directory /Terraform EKS
Steps in brief
1.  Install Terraform on your server
2.  Create IAM user with AdministratorAccess and AmazonEKSClusterPolicy
3.  Store the returned value for Secret Access Key and Access Key ID into ~/. aws/credentials file
4.  Provider.tf file contains information about which provider you want to use with Terraform
5.  main.tf file contains information about EKS cluster creation
6.  outputs.tf shows the details to connect to our EKS cluster
7.  Note: We can variables.tf file to not to hardcode the values inside the main file and terraform modules files can be used for the purpose of reusability
8.  Run terraform init command to initialize the working directory contains the terraform configuration files
9.  Run terraform plan command to see what all resources terraform form about to create or delete
10. Run terraform apply command to apply the changes and add resources we mentioned in the configuration file

How to deploy to the sample Weather-app (nodejs) as a microservice to EKS cluster using Jenkins CI/CD process with Helm as package manager
Notes:
  1. Dockerfile contains steps to create dockerimage of the sample nodejs application
  2. Jenkinsfile contains complete CI/CD process - from git clone to deployment of microservice to EKS cluster as a pod
  3. /Helm directory contains the files and folder structure of helm chart for the deployment of sample application to EKS

Jenkinsfile Explained
The pipeline is written in declarative code. 
We need to add git hub credentials and docker repository to the credentials section of Jenkins
Finally, we need to create a multibranch pipeline model with Jenkins in order trigger other branches other than the main at time of commits
Steps Explanation:
1. The starting of the pipeline indicates the Environment set up inside the Jenkins
2. The next step is creating a Jenkins agent where our build activities will happen using the specified container, we mentioned
3. The next stage initiates from building of our sample Weather-App using the Dockerfile we already have and we'll pass the build parameters to the stage
4. The next stage Docker Publish will push the docker image to our registered private docker hub repo
5. The next stage of Docker image clean up remove the image created from the agent
6. The final stage we'll deploy the docker image to EKS via the helm chart we have in the repo

Helm chart Explained /Helm
1. values.yaml contains the variables we defined in the values file within our chart, any change in the existing configuration we just need to change the values here only
2. chart.yaml contains properties such as name, description and version
3. /templates directory contains 
deployment.yaml file which defines the configuration for our deployment, it uses variables from       values.yaml file
service.yaml file defines the configuration for the service type and port we going to configure for the deployment
This helm chart can be reused anytime, if we need to change version or any additional configuration that's the only time, we need modify the chart
Install helm to EKS cluster created
curl https://baltocdn.com/helm/signing.asc | sudo apt-key add -
sudo apt-get install apt-transport-https --yes
echo "deb https://baltocdn.com/helm/stable/debian/ all main" | sudo tee /etc/apt/sources.list.d/helm-stable-debian.list
sudo apt-get update
sudo apt-get install helm

Diagram - Cluster Model
 
 ![Slide1](https://user-images.githubusercontent.com/31002116/126179544-e60e694e-7235-4660-93ed-14a77d7cf6a9.JPG)

    
Want to Secure Infra
Terraform:
1. Use S3 as the backend for storing .tfstate file
2. Use locking of state file
    Locking will prevent other administrators in your environment from corrupting your state file.
3. Use Terraform modules and registry
    A module that allows you to organize your resources in module blocks which can be called by other modules to help avoid duplication in your state file. Organizing your state file into modules is to align with Terraform registry’s approach of offering third-party configuration in the form of modules.
4. Do not specify the values for security groups, VPC id, Subnet and credentials in the hardcoded format. We can use it while applying the terraform plan command with additional -var <key vale>	
5. Limit access to users using IAM user and policies to EKS cluster
Helm chart with secrets values must be stored in another repo or in AWS secret manager with limited access

Monitoring
The process for setting up Container Insights on Amazon EKS:
We can set up the CloudWatch agent or the AWS Distro for Open Telemetry as a Daemon Set on your cluster to send metrics to CloudWatch.
Set up Fluent Bit or FluentD to send logs to CloudWatch Logs.
Or we can set up any other 3rd party tool like Kibana to fetch Cluster and container logs, Kibana should be separately configured to to EKS

Scale horizontally and vertically
Kubernetes provides the Vertical Pod Autoscaler (VPA) that can adjust up and down pod resource requests based on historic CPU and memory usage. It can also automatically keep CPU and memory resource limits proportional to resource requests. This helps with over-requesting resources to save money, but also with under-requesting resources which can cause performance bottlenecks. The VPA feature is supported in AWS EKS by installing the Metrics Server.

Lower your cluster node costs
A common option is to obtain up to 70% of discounts by committing to a certain volume of usage at least one year in advance via Savings Plan or Reserved Instances, which can be done by the team cost planning
Another approach is to use AWS Spot instances for discounts up to 90% which is especially handy for workloads that can tolerate delay such as batch jobs
You must remember that the nodes may be taken away with a 2 minutes notice. So we should increase our spot instance bid to decrease the chance of being outbid, and use Mixed Instance Policies
More sophisticated approach is to be sizing and cost-management across multiple cloud providers and data centers 

Future process CI/CD in brief
The jenkins build and deployment pipeline and Jenkins file is designed in such a way that whenever the application code change the Jenkins will fetch it automatically and the testing will happen inside the build pipeline and the code will be convert to dockerimage with the latest tag and helm's reusability will deploy it into the cluster.


## The folder three_tier_design contains terraform files that creates a basic 3 tier environment in AWS
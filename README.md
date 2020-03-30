
# Create CI/CD Pipeline with Jenkins and Deploy Containerized Application on Google Kubernetes Cluster

Using Docker technology to containerize the application, using GKE to deploy the containerized application and establish a CI/CD pipeline and GitHub as a source code repository with build automation tool Jenkins, and integrate the CI/CD pipeline with the Kubernetes platform.
My s3 homepage: [http://swe645-yhan27.s3-website-us-east-1.amazonaws.com/](http://swe645-yhan27.s3-website-us-east-1.amazonaws.com/)
Deployed application: [http://35.245.1.164/swe645hw2/studentSurveyForm.html](http://35.245.1.164/swe645hw2/studentSurveyForm.html)


## Authors

* **Yu Han** - *Solo work* - [Github repository](https://github.com/hy950921/swe645hw2)

## Getting Started

These instructions will get you a copy of the project up and running on your local machine for development and testing purposes. See deployment for notes on how to deploy the project on a live system.

### Prerequisites

What things you need to install the software and how to install them


- Install Jenkins on a virtual machine
- Create a project on Google Cloud Platform
- Create a multi-node Kubernetes cluster running on the Google Kubernetes Engine (GKE)
- Github account
- DockerHub account


### Installing

A step by step series of examples that tell you how to get a development env running

#### Create a project on Google Cloud Platform

Go to [Google Cloud Console](https://console.cloud.google.com/home), create a new project.

#### Install Jenkins on Google Cloud Platform
[Learn about installing Jenkins](https://www.youtube.com/watch?v=l7ngjJ_RVXs)

#### Create a multi-node Kubernetes cluster
[Learn about deploying a Kubernetes cluster on GKE](https://docs.bitnami.com/kubernetes/get-started-gke/)


## Implementation Steps

### Build the container image using Dockerfile and push to the DockerHub
```
docker build --tag swe645hw2:1 .
docker tag swe645hw2:1 hy950921/swe645hw2:1
docker push hy950921/swe645hw2:1
```
Go to the DockHub to check the pushed image.

### Deploy the application on the cluster
Create the deployment and service
```
kubectl create deployment survey-app --image=registry.hub.docker.com/hy950921/swe645hw2:1
```
To see the Pod created by the Deployment, run the following command:
```
kubectl get pods
```
Expose the application to the Internet
```
kubectl expose deployment survey-app --type=LoadBalancer --port 80 --target-port 8080
```
GKE assigns the external IP address to the service that can be used to access the application
```
kubectl get service
```
Once you've determined the external IP address for your application, copy the IP address. Point your browser to this URL [http://35.245.1.164/swe645hw2/studentSurveyForm.html](http://35.245.1.164/swe645hw2/studentSurveyForm.html) check if your application is accessible.

### Prepare the Jenkins
Go to Compute Engine -> VM instances, connect to the Jenkins server using SSH "open in browser window"
* [Install Docker](https://docs.bitnami.com/google/apps/jenkins/configuration/install-docker-debian/)
* Add the user running Jenkins to connect to the Docker daemon by adding it to the _docker_ group:
	```
	 sudo usermod -aG docker $USER 
	 sudo usermod -aG docker jenkins
	 JenkinsURL/restart
	 ```
* Install the _kubectl_ command-line tool:	
		```sudo apt-get update 
		sudo apt-get install kubectl```

Install suggested plugins and Google Kubernetes Engine plugin

### Configure a Google Cloud Platform service account
Navigate to the "IAM & admin -> Service accounts" page. Create a new JSON key for the service account. Download and save this key, as it will be needed by Jenkins. Navigate to the "APIs & services -> Library" page. Search for and enable each of the following APIs: 
-   [Compute Engine API](https://cloud.google.com/compute/docs/api/libraries)
-   [Kubernetes Engine API](https://cloud.google.com/kubernetes-engine/reference/rest/)
-   [Service Management API](https://cloud.google.com/service-infrastructure/docs/apis)
-   [Cloud Resource Manager API](https://cloud.google.com/resource-manager/docs/apis)

### Create and enable a GitHub repository webhook
- Log in to GitHub and create a new repository. Note the HTTPS URL to the repository.
- Click the "Settings" tab at the top of the repository page.
- Select the "Webhooks" sub-menu item. Click "Add webhook".
- In the "Payload URL" field, enter the URL [http://35.245.146.43:8080/github-webhook/](http://ip-address/jenkins/github-webhook/).
- Ensure that "Just the push event" radio button is checked and save the webhook.

### Create a Jenkins pipeline project
- Log in to Jenkins
- Click "New item". Enter a name for the new project and set the project type to "Pipeline". Click "OK" to proceed.
- Select the "General" tab on the project configuration page and check the "GitHub project" checkbox. Enter the complete URL to your GitHub project.
- Select the "Build triggers" tab on the project configuration page and check the "GitHub hook trigger for GITScm polling" checkbox.
- Select the "Pipeline" tab on the project configuration page and set the "Definition" field to "Pipeline script from SCM". Set the "SCM" field to "Git" and enter the GitHub repository URL. Set the branch specifier to "*/master". This configuration tells Jenkins to look for a pipeline script named _Jenkinsfile_ in the code repository itself.
- Save the changes.

### Add credentials to Jenkins
- Navigate to the Jenkins dashboard and select the "Credentials" menu item.
- Select the "System" sub-menu" and the "Global credentials" domain.
- Click the "Add credentials" link. Select the "Username with password" credential type and enter your Docker Hub username and password in the corresponding fields. Set the "ID" field to _dockerhub_. Click "OK" to save the changes.
- Click the "Add credentials" link. Select the "Google Service Account from private key" credential type and set the project name (which doubles as the credential identifier) to _gke_. Select the "JSON key" radio button and upload the JSON key obtained in previous step. Click "OK" to save the changes.

###  Prepare the Jenkinsfile
This file contains several steps to build image, push image and update the deployment. This is the update part.
```
sh 'gcloud container clusters get-credentials swe645hw2 --zone us-east4-a'
sh 'kubectl config view'
sh "kubectl get deployments"
sh "kubectl set image deployment/survey-app swe645hw2=hy950921/swe645hw2:${env.BUILD_ID}"
```

### Commit, test and repeat
```
git init 
git remote add origin CLONE-URL 
git add . 
git commit -m "Initial commit" 
git push origin master
```
Pushing this commit should automatically trigger the pipeline in Jenkins. To see the pipeline in action, navigate to the project page in Jenkins and confirm that the pipeline is running,
Use the _kubectl get deployments_ and _kubectl get services_ commands to check the status of your deployment on the Kubernetes cluster and obtain the load balancer IP address


## Built With

* [Docker](https://www.docker.com/)
* [Kubernetes](https://kubernetes.io/)
* [Jenkins](https://jenkins.io/)
* [Github](https://github.com/)


## License

This project is licensed under the MIT License - see the [LICENSE.md](LICENSE.md) file for details


## References

* [https://docs.bitnami.com/tutorials/create-ci-cd-pipeline-jenkins-gke/#step-4-create-a-jenkins-pipeline-project](https://docs.bitnami.com/tutorials/create-ci-cd-pipeline-jenkins-gke/#step-4-create-a-jenkins-pipeline-project)
* [https://cloud.google.com/run/docs/deploying](https://cloud.google.com/run/docs/deploying)
* [https://www.youtube.com/watch?v=l7ngjJ_RVXs](https://www.youtube.com/watch?v=l7ngjJ_RVXs)


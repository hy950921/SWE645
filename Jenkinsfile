/*A Jenkinsfile, which is checked into source control [1], provides a number of immediate benefits:

Code review/iteration on the Pipeline

Audit trail for the Pipeline

Single source of truth for the Pipeline, which can be viewed and edited by multiple members of the project.*/

pipeline {
    agent any
    environment {
        PROJECT_ID = 'swe645hw2-272718'
        CLUSTER_NAME = 'swe645hw2'
        LOCATION = 'us-east4-a'
        CREDENTIALS_ID = 'gke'
    }
    stages {
        stage("Checkout code") {
            steps {
                checkout scm
            }
        }
        stage("Build image") {
            steps {
                script {
                    myapp = docker.build("hy950921/swe645hw2:${env.BUILD_ID}")
                }
            }
        }
        stage("Push image") {
            steps {
                script {
                    docker.withRegistry('https://registry.hub.docker.com', 'dockerhub') {
                            myapp.push("latest")
                            myapp.push("${env.BUILD_ID}")
                    }
                }
            }
        }        
        stage("UpdateDeployment") {
			steps{
				sh 'gcloud container clusters get-credentials swe645hw2 --zone us-east4-a'
				sh 'kubectl config view'
				sh "kubectl get deployments"
				sh "kubectl set image deployment/survey-app swe645hw2=hy950921/swe645hw2:${env.BUILD_ID}"
			}
			
		}

    }    
}

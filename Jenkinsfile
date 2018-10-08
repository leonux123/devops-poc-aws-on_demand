pipeline {
    agent any
    stages {
    	   stage('Test') {
	            steps {
	                sh 'sbt test'
	                junit 'target/test-reports/*.xml'
            }
        }
  	     stage('Build') {
	            steps {
	                sh 'sbt dist'
            }
        }
	     stage('AWS Provisioning') {
	            node {
    			sh '''#!/bin/bash
    			./jenkins/scripts/EC2_on-demand.sh start '''+AWS_IP+'''
    			echo "Hello, I'm lost!"
    			'''    
	}    
        }
        stage('Deliver for development') {
            when {
                branch 'development' 
            }
            steps {
                sh 'echo "Hello DEV!"'
	                     
            }
        }
        stage('Deliver for release') {
            when {
                branch 'release'  
            }
            steps {
                sh 'echo "Hello ITG!"'
	                     
            }
        }
	stage('Deploy to PROD') {
            when {
                branch 'master' 
            }
            steps {
                sh './jenkins/scripts/EC2_on-demand.sh deploy'
            }
        }
    }
}

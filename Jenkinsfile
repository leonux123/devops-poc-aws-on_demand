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
	            steps {
	                sh './jenkins/scripts/EC2_on-demand.sh start'
			    script {
          			IP = readFile('ip_from_file')
        			}
			    echo "HOLA ${IP}"
			    sh 'TEST=$(cat ip_from_file)'
			    sh 'echo HEEEEEY LOOK $TEST'
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
		echo "HOLA ${IP}"  
		sh 'export AIP=$(cat ip_from_file) && ssh -oStrictHostKeyChecking=no -i /home/leonux/aws/MyKeyPair.pem ec2-user@$AIP ./deploy.sh'                
            }
        }
    }
}

// This is a "declarative pipeline" script
pipeline {
    // 1. "agent any" means this pipeline can run on any available Jenkins machine
    agent {
        docker {
            // Use a Node.js image for your application environment
            image 'node:18-slim'
            // CRITICAL FIX: Mount the host's Docker socket to allow commands inside 
            // the container (like 'docker build') to talk to the host's Docker engine.
            args '-v /var/run/docker.sock:/var/run/docker.sock'
        }
    }

    // 2. These are "environment variables" - like settings for our pipeline.
    // We will set these up inside Jenkins later.
    environment {
        PROJECT_ID = credentials('gcp-project-id')
        REGION = 'us-central1'
        REPO_NAME = 'my-app-repo'
        APP_NAME = 'my-hello-world-app'
        GCP_CREDS = credentials('gcp-service-account-key')
    }

    // 3. These are the "stages" of our assembly line
    stages {
        
        stage('Initialize') {
 
            steps {
                // This command prints the Project ID.
                // We use ${env.VAR_NAME} to use the variables.
                echo "Starting build for GCP Project: ${env.PROJECT_ID}"
                // This 'sh' command runs a shell command
                sh 'gcloud --version'
            }
        }

        stage('Build') {
            steps {
    
             // This step just shows us our app code
                echo "Building the application..."
                sh 'ls -la'
            }
        }

        stage('Build Docker Image') {
            
            steps {
                echo "Building Docker image..."
                // We create a unique name for our image using the GCP location, project ID, repo name, and app name.
                // The $BUILD_NUMBER is a unique number from Jenkins (like 1, 2, 3...)
                script {
                    env.IMAGE_NAME = "${env.REGION}-docker.pkg.dev/${env.PROJECT_ID}/${env.REPO_NAME}/${env.APP_NAME}:${env.BUILD_NUMBER}"
                }
                echo "Image name will be: ${env.IMAGE_NAME}"
            
            
                // This is the command that actually builds the Docker image
                sh "docker build -t ${env.IMAGE_NAME} ."
            }
        }

        stage('Authenticate & Push to GCP') {
            steps {
                echo "Authenticating to Google Cloud..."
                
                // This 'withCredentials' block securely loads our JSON key file.
                // Jenkins injects the file and saves its location to the 'GCP_CREDS' variable.
                withCredentials([file(credentialsId: 'gcp-service-account-key', variable: 'GCP_CREDS')]) {
                    
                    // 1. Log in to GCP using the service account key
                    sh "gcloud auth activate-service-account --key-file=${GCP_CREDS}"
                    
  
                    // 2. Configure Docker to talk to GCP's Artifact Registry
                    sh "gcloud auth configure-docker ${env.REGION}-docker.pkg.dev"
                    
                    // 3. Push our image to the registry
  
                    echo "Pushing image to Artifact Registry..."
                    sh "docker push ${env.IMAGE_NAME}"
                }
            }
        }

        stage('Deploy to Cloud Run') {
      
            steps {
                echo "Deploying to Cloud Run..."
                withCredentials([file(credentialsId: 'gcp-service-account-key', variable: 'GCP_CREDS')]) {
                    
                    // Log in again (good practice for deployment stage)
     
                    sh "gcloud auth activate-service-account --key-file=${GCP_CREDS}"
                    
                    // This is the big deployment command!
                    sh """
                        gcloud run deploy ${env.APP_NAME} \
                          --image ${env.IMAGE_NAME} \
                          --region ${env.REGION} \
               
                          --platform managed \
                          --allow-unauthenticated
                    """
                }
            }
        }
    }
 
    
    // 4. "post" actions run at the end of the pipeline
    post {
        // "always" runs whether the pipeline passed or failed
        always {
            echo "Pipeline finished."
            // This cleans up the Docker images to save space
            sh "docker rmi ${env.IMAGE_NAME} || true"
        }
        // "success" only runs if all stages passed
        success {
            echo "Pipeline Succeeded!"
            // Here you could add an email notification
        }
        // "failure" only runs if a stage failed
        failure {
            echo "Pipeline Failed!"
            // Here you could add an email notification for failure
        }
    }
}

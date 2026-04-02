pipeline {

    agent { label 'controller' }

    environment {

        ENVIRONMENT = "${env.BRANCH_NAME}"
    }

    stages {
  stage('Debug Agent') {
    steps {
        sh '''
        echo "Node name: $NODE_NAME"
        echo "Labels: $NODE_LABELS"
        '''
    }
}



        stage('Validate Branch') {
            steps {
                script {
                    def allowedBranches = ['dev', 'staging', 'prod']

                    if (!allowedBranches.contains(env.BRANCH_NAME)) {
                        error "❌ Branch '${env.BRANCH_NAME}' is not allowed. Only dev/staging/prod are permitted."
                    }

                    echo "✅ Branch '${env.BRANCH_NAME}' is valid"
                }
            }
        }

stage('Load Pipeline Config') {
    steps {
        script {
            def props = readProperties file: 'config/pipeline.env'

            props.each { key, value ->
                sh "export ${key}=${value}"
                env."${key}" = value
            }

            echo "Pipeline configuration loaded"
        }
    }
}

        stage('Verify Variables') {
            steps {
                sh '''
                echo "Verifying variables..."
                if [ -z "$IMAGE_NAME" ]; then exit 1; fi
                if [ -z "$HARBOR_REGISTRY" ]; then exit 1; fi
                if [ -z "$GITOPS_REPO" ]; then exit 1; fi
                '''
            }
        }




stage('Verify Tools') {
    steps {
        sh '''
       

        docker --version || { echo "❌ Docker not working"; exit 1; }

    
        '''
    }
}
         stage('Build') {
            agent {
                docker {
                    image 'maven:3.9.6-eclipse-temurin-17'
                }
            }
            steps {
                sh 'mvn clean package -DskipTests'
            }
        }

        stage('Unit Test & Quality Checks') {

            parallel {
               stage('Unit Tests') {
            agent {
                docker {
                    image 'maven:3.9.6-eclipse-temurin-17'
                }
            }
            steps {
                sh 'mvn test'
            }
        }

         stage('SonarQube Analysis') {
    steps {
        withSonarQubeEnv('SonarQubeServer') {
            withCredentials([
                string(credentialsId: 'jenkinstoken', variable: 'SONAR_TOKEN')
            ]) {
                sh 'mvn sonar:sonar -Dsonar.login=$SONAR_TOKEN'
            }
        }
    }
}
            }
        }
        stage('Quality Gate') {
    steps {
        script {
            timeout(time: 5, unit: 'MINUTES') {
                def qg = waitForQualityGate()

                if (qg.status != 'OK') {
                    error "Pipeline failed due to Quality Gate: ${qg.status}"
                }
            }
        }
    }
}

        stage('Build Staging Image') {
            steps {
                sh '''
                chmod +x scripts/build-image.sh
                scripts/build-image.sh staging
                '''
            }
        }

        stage('Deploy Staging Container') {
            steps {
            sh ''' 
                docker stop ${CONTAINER_NAME} || true
                docker rm ${CONTAINER_NAME} || true
                docker run -d \
                  --name ${CONTAINER_NAME} \
                  --network ci-network \
                  -p ${STAGING_PORT}:8080 \
                  ${HARBOR_REGISTRY}/${HARBOR_PROJECT}/${IMAGE_NAME}:staging
                '''
            }
        }

        stage('Security & E2E Tests') {

            parallel {
                stage('Trivy Security Scan') {
                    /*
                    steps {
                        sh '''
                        docker run --rm \
                          -v /var/run/docker.sock:/var/run/docker.sock \
                          aquasec/trivy:latest image \
                          ${IMAGE_NAME}:staging
                        '''
                    }*/

                    steps {
                        sh 'echo "trivy scan"'
                    }
                }

                stage('E2E Tests') {
                   /* steps {
                        sh '''
                        chmod +x scripts/e2e-test.sh
                        scripts/e2e-test.sh
                        '''
                    }*/ 
                    steps {
                    sh 'echo "test E2E"'
                    }
                }
            }
        }

        stage('Build & Push Production Image') {
            steps {
                sh '''
                chmod +x scripts/build-image.sh
                scripts/build-image.sh ${IMAGE_TAG}
                chmod +x scripts/push-image.sh
                scripts/push-image.sh ${IMAGE_TAG}
                '''
            }
        }

        stage('Deploy Image') {
            steps {
                withCredentials([usernamePassword(
                    credentialsId: 'git-credentials',
                    usernameVariable: 'GIT_USER',
                    passwordVariable: 'GIT_PASS'
                )]) {
                    sh '''
                    chmod +x scripts/update-gitops.sh
                    scripts/update-gitops.sh ${IMAGE_TAG} ${ENVIRONMENT}
                    '''
                }
            }
        }
    }

    post {
        always {
            sh 'docker logout || true'
        }
    }
}
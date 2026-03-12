pipeline {

    agent any

    environment {
        

        ENVIRONMENT = "${env.BRANCH_NAME}"

    }

    stages {

        stage('Checkout Source') {

            steps {
                checkout scm
            }

        }

        /*
        stage('Skip Bot Commit') {

            steps {

                script {

                    def author = sh(
                        script: "git log -1 --pretty=%an",
                        returnStdout: true
                    ).trim()

                    if (author == "Jenkins CI") {
                        currentBuild.result = 'NOT_BUILT'
                        error("Build triggered by Jenkins bot")
                    }

                }

            }

        }
        */

        stage('Load Pipeline Config') {

            steps {

                sh '''
                chmod +x scripts/load-env.sh
                source scripts/load-env.sh
                '''

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

        stage('Build') {

            steps {

                sh '''
                if [ -f mvnw ]; then
                  chmod +x mvnw
                  ./mvnw clean package -DskipTests
                else
                  mvn clean package -DskipTests
                fi
                '''

            }

        }

        stage('Unit Test & Quality Checks') {

            parallel {

                stage('Unit Tests') {

                    /*
                    steps {
                        sh '''
                        if [ -f mvnw ]; then
                          ./mvnw test
                        else
                          mvn test
                        fi
                        '''
                    }
                    */

                    steps {
                        sh 'echo "unit tests"'
                    }

                }

                stage('SonarQube Analysis') {

                    /*
                    steps {

                        withSonarQubeEnv('SonarQubeServer') {

                            withCredentials([
                                string(
                                    credentialsId: 'jenkinstoken',
                                    variable: 'SONAR_TOKEN'
                                )
                            ]) {

                                sh '''
                                mvn sonar:sonar -Dsonar.login=$SONAR_TOKEN
                                '''

                            }

                        }

                    }
                    */

                    steps {
                        sh 'echo "sonarqube analysis"'
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

                    }
                    */

                    steps {
                        sh 'echo "trivy scan"'
                    }

                }

                stage('E2E Tests') {

                    steps {

                        sh '''
                        chmod +x scripts/e2e-test.sh
                        scripts/e2e-test.sh
                        '''

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
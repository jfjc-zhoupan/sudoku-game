pipeline {
    agent any
    environment {
         // ============================================================
         // Project paths
         // ============================================================
         APP_DIR = 'app'
         TF_DIR = 'terraform-infra'

         // ============================================================
         // Docker registry settings
         // ============================================================
         DOCKER_REGISTRY = 'zhoupan970810'
         APP_NAME = 'sudoku-game'
         DOCKER_IMAGE = "${DOCKER_REGISTRY}/${APP_NAME}"

         // ============================================================
         // Version file location
         // ============================================================
         VERSION_FILE = "${APP_DIR}/version.py"

        // ============================================================
        // Store original version for rollback
        // ============================================================
        ORIGINAL_VERSION = ''
        NEW_VERSION = ''
    }

    stages {
        // ============================================================
        // Stage 1: Checkout Code
        // ============================================================
        stage("Checkout"){
            steps{
                cleanWs()
                checkout scm
                script {
                    sh 'ls -la app/'
                    sh 'cat app/version.py'
                    env.GIT_COMMIT_SHORT = sh(returnStdout: true, script: 'git rev-parse --short HEAD').trim()
                    echo "Commit SHA: ${env.GIT_COMMIT_SHORT}"
                }
            }
        }
        // ============================================================
        // Stage 2: Read Original Version
        // ============================================================
        stage("Read Original Version"){
            steps{
                script{
                    env.ORIGINAL_VERSION = sh(
                        returnStdout: true,
                        script: '''awk -F'"' '/__version__/ {print $2}' app/version.py''').trim()

                    if (!env.ORIGINAL_VERSION) {
                        error "Could not read version from ${env.VERSION_FILE}"
                    }

                    echo "Original version: ${env.ORIGINAL_VERSION}"
                }
            }
        }
        // ============================================================
        // Stage 3: Bump Version
        // ============================================================
        stage('Bump Version'){
            steps{
                script{
                    if (!env.ORIGINAL_VERSION || env.ORIGINAL_VERSION == 'null') {
                        error "ORIGINAL_VERSION is null. Fix Stage 2 first."
                    }

                    def parts = env.ORIGINAL_VERSION.split('\\.')
                    def newPatch = (parts[2] as Integer) + 1
                    env.NEW_VERSION = "${parts[0]}.${parts[1]}.${newPatch}"

                    echo "New version: ${env.NEW_VERSION}"

                    sh """
                        cd ${env.APP_DIR}
                        sed -i 's/__version__ = .*/__version__ = "${env.NEW_VERSION}"/' version.py
                        echo "=== Updated version.py ==="
                        grep '__version__' version.py
                    """
                }
            }
        }
        // ============================================================
        // Stage 4: Build Docker Image
        // ============================================================
        stage("Build Docker Image"){
            steps{
                script{
                        sh """
                            cd ${env.APP_DIR}
                            echo "=== Building Docker image ==="
                            docker build -t ${env.DOCKER_IMAGE}:${env.NEW_VERSION} .
                            docker tag ${env.DOCKER_IMAGE}:${env.NEW_VERSION} ${env.DOCKER_IMAGE}:latest

                            echo "Successfully built image: ${env.DOCKER_IMAGE}:${env.NEW_VERSION}!"
                        """
                }
            }
        }
        // ============================================================
        // Stage 5: Push Docker Image to Registry
        // ============================================================
        stage("Push Docker Image"){
            steps{
                script{
                    withCredentials([usernamePassword(credentialsId: 'dockerhub', usernameVariable: 'DOCKER_USER', passwordVariable: 'DOCKER_PASS')]) {
                            sh """
                                cd ${env.APP_DIR}
                                echo "=== Logging in to Docker Hub ==="
                                echo "${DOCKER_PASS}" | docker login -u "${DOCKER_USER}" --password-stdin

                                echo "=== Pushing Docker Image ==="
                                docker push ${env.DOCKER_IMAGE}:${env.NEW_VERSION}
                                docker push ${env.DOCKER_IMAGE}:latest
                                echo "Successfully pushed Docker Image!"
                            """
                    }
                }
            }
        }
        // ============================================================
        // Stage 6: Deploy Infrastructure
        // ============================================================
        stage("Deploy Infrastructure"){
            steps{
                script{
                        sh """
                            cd ${env.TF_DIR}
                            echo "=== Terraform Init ==="
                            terraform init

                            echo "=== Terraform Plan ==="
                            terraform plan

                            echo "=== Terraform Apply ==="
                            terraform apply -auto-approve
                            echo "Infrastructure deployed successfully"
                        """
                }
            }
        }
        // ============================================================
        // Stage 7: Commit Version Update
        // ============================================================
        stage('Commit Version Update'){
            steps{
                script{
                    withCredentials([usernamePassword(credentialsId: 'github', usernameVariable: 'GIT_USER', passwordVariable: 'GIT_PASS')]) {
                        sh """
                            echo "=== Committing version update ==="
                            git config --global user.email "jenkins@example.com"
                            git config --global user.name "jenkins CI"
                            git remote set-url origin https://${GIT_USER}:${GIT_PASS}@github.com/jfjc-zhoupan/sudoku-game.git

                            # Git and push the changed version file
                            git add ${env.VERSION_FILE}
                            git commit -m "ci/cd: version bump to ${env.NEW_VERSION}" || echo "No changes to commit"
                            git push origin HEAD:main
                            echo "Version update committed successfully!"
                        """
                    }
                }
            }
        }
        // ============================================================
        // Stage 8: Get public IP
        // ============================================================
        stage('Get Public IP'){
            steps{
                script{
                    env.VM_PUBLIC_IP = sh(
                        returnStdout: true,
                        script: "cd ${env.TF_DIR} && terraform output -json | jq -r '.vm_public_ip.value'"
                    ).trim()

                    if (env.VM_PUBLIC_IP == 'null' || env.VM_PUBLIC_IP == 'N/A' || env.VM_PUBLIC_IP == '') {
                        echo "Warning: Could not retrieve public IP"
                    }
                    else {
                        echo "VM Public IP: ${env.VM_PUBLIC_IP}"
                    }
                }
            }
        }
    }

    // ============================================================
    // Post Build Actions: Rollback on Failure
    // ============================================================
    post{
        success {
            echo "Pipeline completed successfully! Version bumped to ${env.NEW_VERSION}"
            emailext(
                subject: "CI/CD Deployment Success: ${env.APP_NAME} ${env.NEW_VERSION}",
                mimeType: 'text/plain',
                to: 'a572874046@163.com, raeezhao@gmail.com',
                body: """
                    ============================================================
                    Deployment Complete!
                    ============================================================
                    Application: ${env.APP_NAME}
                    Version:     ${env.NEW_VERSION}
                    Image:       ${env.DOCKER_IMAGE}:${env.NEW_VERSION}
                    URL:         http://${env.VM_PUBLIC_IP}:5000
                    ============================================================
                    """
            )
        }
        failure{
            echo "Pipeline failed! Version remains at ${env.ORIGINAL_VERSION}. No changes committed."

            // Send failure email
            emailext(
                subject: "CI/CD Deployment Failed: ${env.APP_NAME} - Build #${env.BUILD_NUMBER}",
                mimeType: 'text/plain',
                to: 'a572874046@163.com',
                body: """
                ============================================================
                Pipeline Failed!
                ============================================================
                details
                ============================================================
                """
            )

            // Revert Version to original
            sh """
                echo "=== Reverting: ${env.VERSION_FILE} ==="
                git checkout ${env.VERSION_FILE}
                echo "Local version.py reverted."
            """
        }
        always {
            cleanWs(
                patterns: [
                    [pattern: '**/terraform.tfstate', type: 'EXCLUDE'],
                    [pattern: '**/terraform.tfstate.backup', type: 'EXCLUDE'],
                    [pattern: '**/.terraform/**', type: 'EXCLUDE']
                ]
            )
        }
    }
}
// Jenkinsfile
pipeline {
    agent any // Eseguirà sul Jenkins master o su un agente disponibile

    environment {
        // Variabili d'ambiente per Terraform e Azure OpenAI, recuperate da Jenkins Credentials
        AZURE_CLIENT_ID = credentials('AZURE_CLIENT_ID')
        AZURE_CLIENT_SECRET = credentials('AZURE_CLIENT_SECRET')
        AZURE_TENANT_ID = credentials('AZURE_TENANT_ID')
        AZURE_SUBSCRIPTION_ID = credentials('AZURE_SUBSCRIPTION_ID')

        // Nome del deploy del modello OpenAI (es. "gpt-4o-deployment")
        //OPENAI_MODEL_DEPLOYMENT_NAME = "gpt-4o-deployment" // 

        // Variabili per il backend Terraform (assicurati che lo storage account esista in Azure)
        //TF_BACKEND_SUB = "0d6ce570-7813-445e-bb22-e35faf195918" //SUB
        TF_BACKEND_RG = "ENTRA-TEST"      // RG
        TF_BACKEND_SA = "testentra" //  SA
        TF_BACKEND_CONTAINER = "tfstatedevgenops"       // Container
    }

    stages {
        stage('Test'){
            steps {
                script {
                    //bat "echo Hello from shell"
                    def curlCheck = sh(script: 'command -v curl >/dev/null 2>&1 && echo "✅ curl is installed" && curl --version || echo "❌ curl is not installed"', returnStdout: true).trim()
                    echo "Curl Check Result:\n${curlCheck}"
                }
            }
        }
        stage('Checkout Code') {
            steps {
                script {
                    // Imposta le credenziali Azure per Terraform CLI
                    // Assicurati che questi siano esportati nel PATH di Terraform
                    bat "set ARM_CLIENT_ID=${AZURE_CLIENT_ID}"
                    bat "set ARM_CLIENT_SECRET=${AZURE_CLIENT_SECRET}"
                    bat "set ARM_TENANT_ID=${AZURE_TENANT_ID}"
                    bat "set ARM_SUBSCRIPTION_ID=${AZURE_SUBSCRIPTION_ID}"

                    // Checkout del codice dal tuo repository GitHub
                    git branch: 'main', credentialsId: 'github-pat', url: 'https://github.com/c-bongiorno/dev-gen-ops.git' 
                }
            }
        }

        stage('Terraform Init & Validate') {
            steps {
                withCredentials([
                    string(credentialsId: 'AZURE_CLIENT_ID', variable: 'ARM_CLIENT_ID'),
                    string(credentialsId: 'AZURE_CLIENT_SECRET', variable: 'ARM_CLIENT_SECRET'),
                    string(credentialsId: 'AZURE_TENANT_ID', variable: 'ARM_TENANT_ID'),
                    string(credentialsId: 'AZURE_SUBSCRIPTION_ID', variable: 'ARM_SUBSCRIPTION_ID')
                ]) {
                    script {
                        bat 'terraform init -upgrade -no-color -backend-config="subscription_id=f357b9f3-aeca-4bd9-b1e2-e8a9db3e9374" -backend-config="resource_group_name=ENTRA-TEST" -backend-config="storage_account_name=testentra" -backend-config="container_name=tfstatedevgenops" -backend-config="key=devgenops.tfstate" -backend-config="use_oidc=true"' // reconfigure è utile per i test
                        bat 'terraform validate -no-color'
                        bat 'terraform fmt -no-color'
                   }
                }

            }
        }

        stage('Terraform Plan') {
            steps {
                withCredentials([
                    string(credentialsId: 'AZURE_CLIENT_ID', variable: 'ARM_CLIENT_ID'),
                    string(credentialsId: 'AZURE_CLIENT_SECRET', variable: 'ARM_CLIENT_SECRET'),
                    string(credentialsId: 'AZURE_TENANT_ID', variable: 'ARM_TENANT_ID'),
                    string(credentialsId: 'AZURE_SUBSCRIPTION_ID', variable: 'ARM_SUBSCRIPTION_ID')
                ]) {
                    script {
                        bat 'terraform plan -no-color -out=tfplan.binary'
                    }
                }
                    
            }
        }
        stage('Trivy Full Severity Scan') {
            steps {
                script {
                    echo "Esecuzione Trivy su tutti i livelli di severità: LOW, MEDIUM, HIGH, CRITICAL"

                    def trivyOutput = bat(returnStdout: true, script: 'trivy config --format table --severity LOW,MEDIUM,HIGH,CRITICAL .').trim()

                    echo "---------------------------------------"
                    echo "Risultato completo della scansione Trivy:\n${trivyOutput}"
                    echo "---------------------------------------"
                }
            }
        }

        
        stage('Approval for Deployment') {
            steps {
                input message: 'Approvazione necessaria per il deployment su Azure. Continuare?', ok: 'Deploy'
            }
        }
        stage('Terraform Apply') {
            steps {
                withCredentials([
                    string(credentialsId: 'AZURE_CLIENT_ID', variable: 'ARM_CLIENT_ID'),
                    string(credentialsId: 'AZURE_CLIENT_SECRET', variable: 'ARM_CLIENT_SECRET'),
                    string(credentialsId: 'AZURE_TENANT_ID', variable: 'ARM_TENANT_ID'),
                    string(credentialsId: 'AZURE_SUBSCRIPTION_ID', variable: 'ARM_SUBSCRIPTION_ID')
                ]) {
                    script {
                        bat 'terraform apply -no-color -auto-approve tfplan.binary'
                    }
                }

            }
        }
    }
}

            
            

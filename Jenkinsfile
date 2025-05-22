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
        TF_BACKEND_RG = "rg-bongiorno-nit-001"      // RG
        TF_BACKEND_SA = "tfstatedevops01" //  SA
        TF_BACKEND_CONTAINER = "tfstatedevgenops"       // Container
    }

    stages {
        stage('Test'){
            steps {
                script {
                    bat "echo Hello from shell"
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
                script {
                    bat 'terraform init -backend-config="resource_group_name=${TF_BACKEND_RG}" -backend-config="storage_account_name=${TF_BACKEND_SA}" -backend-config="container_name=${TF_BACKEND_CONTAINER}" -reconfigure' // reconfigure è utile per i test
                    bat 'terraform validate'
                    bat 'terraform fmt -check'
                }
            }
        }

        stage('Terraform Plan') {
            steps {
                bat 'terraform plan -out=tfplan'
            }
        }
    }
}

            
            

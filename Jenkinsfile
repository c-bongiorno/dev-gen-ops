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
        // TF_BACKEND_RG = "ENTRA-TEST"      // RG
        // TF_BACKEND_SA = "testentra" //  SA
        // TF_BACKEND_CONTAINER = "tfstatedevgenops"       // Container
    }

    stages {
        // stage('Test'){
            // steps {
                // script {
                    // bat "echo Hello from shell"
                    // def curlCheck = bat(script: 'command -v curl >/dev/null 2>&1 && echo "✅ curl is installed" && curl --version || echo "❌ curl is not installed"', returnStdout: true).trim()
                    // echo "Curl Check Result:\n${curlCheck}"
                // }
            // }
        // }
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
                        bat 'terraform init -upgrade -no-color -backend-config="subscription_id=0d6ce570-7813-445e-bb22-e35faf195918" -backend-config="resource_group_name=rg-bongiorno-nit-001" -backend-config="storage_account_name=tfstatedevops01" -backend-config="container_name=tfstatedevgenops" -backend-config="key=devgenops.tfstate" -backend-config="use_oidc=true" -reconfigure' // reconfigure è utile per i test
                        //bat 'terraform validate -no-color'
                        //bat 'terraform fmt -no-color'
                   }
                }

            }
        }

        // stage('Terraform Plan') {
            // steps {
                // withCredentials([
                    // string(credentialsId: 'AZURE_CLIENT_ID', variable: 'ARM_CLIENT_ID'),
                    // string(credentialsId: 'AZURE_CLIENT_SECRET', variable: 'ARM_CLIENT_SECRET'),
                    // string(credentialsId: 'AZURE_TENANT_ID', variable: 'ARM_TENANT_ID'),
                    // string(credentialsId: 'AZURE_SUBSCRIPTION_ID', variable: 'ARM_SUBSCRIPTION_ID')
                // ]) {
                    // script {
                        // bat 'terraform plan -no-color -out=tfplan.binary'
                    // }
                // }
                    // 
            // }
        // }
        stage('Terraform PlanAI') {
            steps {
                script {
                    // Definisci una variabile per lo stato del comando
                    def planStatus

                    try {
                        withCredentials([
                            string(credentialsId: 'AZURE_CLIENT_ID', variable: 'ARM_CLIENT_ID'),
                            string(credentialsId: 'AZURE_CLIENT_SECRET', variable: 'ARM_CLIENT_SECRET'),
                            string(credentialsId: 'AZURE_TENANT_ID', variable: 'ARM_TENANT_ID'),
                            string(credentialsId: 'AZURE_SUBSCRIPTION_ID', variable: 'ARM_SUBSCRIPTION_ID')
                        ]) {
                            // Esegui il comando e cattura l'output e lo stato di uscita
                            def planOutput = bat(script: 'terraform plan -no-color -out=tfplan.binary', returnStdout: true, returnStatus: true)

                            // Controlla il codice di uscita
                            if (planOutput.status != 0) {
                                // Se il codice è diverso da 0, c'è stato un errore.
                                // Lanciamo un'eccezione manualmente per attivare il blocco catch.
                                error("Terraform plan failed with status code: ${planOutput.status}")
                            } else {
                                // Se tutto va bene, stampa l'output
                                echo "Terraform plan completed successfully."
                                echo planOutput.stdout
                            }
                        }
                    } catch (e) {
                        // --- AI per Troubleshooting degli Errori di Deployment ---
                        // Ora il blocco catch verrà eseguito correttamente

                        // Cattura l'intero log della build
                        def errorLogs = bat(returnStdout: true, script: 'type "%JENKINS_HOME%\\jobs\\%JOB_NAME%\\builds\\%BUILD_NUMBER%\\log"').trim()

                        def troubleshootingPrompt = """
                            Sei un esperto ingegnere DevOps specializzato in Azure e Terraform.
                            Il deployment Terraform su Azure è fallito con i seguenti errori. Analizza i log e suggerisci possibili cause e azioni per il troubleshooting.
                            Log di errore del deployment:
                            ```
                            ${errorLogs}
                            ```
                            Formato: 'Problema: [Descrizione]. Causa Probabile: [Causa]. Soluzione: [Passi di troubleshooting].'
                        """.trim()
                        withCredentials([
                            string(credentialsId: 'AZURE_OPENAI_ENDPOINT', variable: 'AZURE_OPENAI_ENDPOINT'),
                            string(credentialsId: 'AZURE_OPENAI_API_KEY', variable: 'AZURE_OPENAI_API_KEY'),
                            string(credentialsId: 'OPENAI_MODEL_DEPLOYMENT_NAME', variable: 'OPENAI_MODEL_DEPLOYMENT_NAME')
                        ]) {
                            // La chiamata alla tua funzione AI
                            def aiTroubleshooting = callAzureOpenAI(AZURE_OPENAI_ENDPOINT, AZURE_OPENAI_API_KEY, OPENAI_MODEL_DEPLOYMENT_NAME, troubleshootingPrompt)

                            echo "---------------------------------------"
                            echo "AI-Powered Troubleshooting Suggestions:\n${aiTroubleshooting}"
                            echo "AI-Powered Troubleshooting Suggestions:\n(Simulazione - qui andrebbe l'output della tua AI)"
                            echo "Log catturato per l'analisi:"
                            echo errorLogs
                            echo "---------------------------------------"
                        }
                        error "Deployment fallito. Vedi i suggerimenti AI per il troubleshooting."

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
        // stage('Terraform Apply') {
            // steps {
                // script {
                    // try {
                        // withCredentials([
                            // string(credentialsId: 'AZURE_CLIENT_ID', variable: 'ARM_CLIENT_ID'),
                            // string(credentialsId: 'AZURE_CLIENT_SECRET', variable: 'ARM_CLIENT_SECRET'),
                            // string(credentialsId: 'AZURE_TENANT_ID', variable: 'ARM_TENANT_ID'),
                            // string(credentialsId: 'AZURE_SUBSCRIPTION_ID', variable: 'ARM_SUBSCRIPTION_ID')
                        // ]) {
                            // script {
                            // bat 'terraform apply -no-color -auto-approve tfplan.binary'
                            // echo "Deployment su Azure completato con successo!"
                        // }
                    // }                        
                    // } catch (e) {
                        //--- AI per Troubleshooting degli Errori di Deployment ---
                        // def errorLogs = sh(returnStdout: true, script: "cat \${JENKINS_HOME}/jobs/${env.JOB_NAME}/builds/${env.BUILD_NUMBER}/log").trim() // Cattura l'intero log della build
                        //Estrai solo le linee di errore rilevanti se il log è molto grande
                        //def relevantErrorLogs = errorLogs.split('\n').findAll { it.contains('Error') || it.contains('Failed') }.join('\n')

                        // def troubleshootingPrompt = """
                            // Sei un esperto ingegnere DevOps specializzato in Azure e Terraform.
                            // Il deployment Terraform su Azure è fallito con i seguenti errori. Analizza i log e suggerisci possibili cause e azioni per il troubleshooting.

                            // Log di errore del deployment:
                            // ```
                            // ${errorLogs}
                            // ```

                            // Formato: 'Problema: [Descrizione]. Causa Probabile: [Causa]. Soluzione: [Passi di troubleshooting].'
                        // """
                        // def aiTroubleshooting = callAzureOpenAI(AZURE_OPENAI_ENDPOINT, AZURE_OPENAI_API_KEY, OPENAI_MODEL_DEPLOYMENT_NAME, troubleshootingPrompt)

                        // echo "---------------------------------------"
                        // echo "AI-Powered Troubleshooting Suggestions:\n${aiTroubleshooting}"
                        // echo "---------------------------------------"
                        // error "Deployment fallito. Vedi i suggerimenti AI per il troubleshooting."
                    // }
                // }
            // }
        // }
    }
}

// Rimuoviamo @NonCPS perché usiamo step della pipeline (httpRequest, readJSON)
def callAzureOpenAI(String endpoint, String apiKey, String deploymentName, String prompt) {
    // L'URL corretto per il modello Chat Completions.
    // Assicurati che 'endpoint' sia solo il dominio base (es. https://tuo-endpoint.openai.azure.com)
    def fullUrl = "https://oai-dev-gen-ops-01.openai.azure.com/openai/deployments/gpt-4/chat/completions?api-version=2025-01-01-preview"

    // Usiamo le utility Groovy per creare un corpo JSON valido e sicuro.
    // Questo è molto più affidabile della concatenazione di stringhe manuale.
    def requestBody = new groovy.json.JsonOutput().toJson([
        messages: [
            [role: "system", content: "You are a helpful and expert assistant for DevOps, Azure, and Terraform."],
            [role: "user", content: prompt]
        ],
        max_tokens: 1500,
        temperature: 0.3
    ])

    try {
        // Eseguiamo la chiamata con il plugin httpRequest, che è platform-independent
        def response = httpRequest(
            url: fullUrl,
            //httpmethod: 'POST',
            customHeaders: [
                [name: 'Content-Type', value: 'application/json'],
                [name: 'Api-Key', value: apiKey]
            ],
            requestBody: requestBody,
            quiet: true // Evita di stampare l'intera risposta nel log di console
        )

        // Verifichiamo che la chiamata sia andata a buon fine (status 2xx)
        if (response.status == 200) {
            // Usiamo lo step 'readJSON' per parsare la risposta testuale
            def jsonResponse = readJSON text: response.content
            
            // Estraiamo il contenuto del messaggio dalla risposta
            if (jsonResponse.choices && jsonResponse.choices[0] && jsonResponse.choices[0].message && jsonResponse.choices[0].message.content) {
                return jsonResponse.choices[0].message.content
            } else {
                echo "Errore: la risposta JSON da Azure OpenAI non ha il formato atteso. Risposta: ${response.content}"
                return "Errore AI: Impossibile analizzare il contenuto della risposta."
            }
        } else {
            echo "Errore HTTP dalla chiamata ad Azure OpenAI. Status: ${response.status}, Risposta: ${response.content}"
            return "Errore AI: La richiesta è fallita con codice di stato ${response.status}."
        }

    } catch (Exception e) {
        echo "Una eccezione è avvenuta durante la chiamata a callAzureOpenAI: ${e.toString()}"
        return "Errore AI: Eccezione durante la chiamata API."
    }
}
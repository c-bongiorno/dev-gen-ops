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
        // stage('!!! DEBUG SICURO AZURE AI CALL !!!') {
        //     steps {
        //         script {
        //             echo '--- ESEGUO TEST DI LABORATORIO SICURO ---'

        //             // Usa i valori non-segreti del tuo curl che funziona.
        //             // Questi non sono segreti, quindi possiamo scriverli qui per il test.
        //             def hardcodedEndpoint = "https://oai-dev-gen-ops-01.openai.azure.com/openai/deployments/gpt-4/chat/completions?api-version=2025-01-01-preview"
        //             def hardcodedDeployment = "gpt-4"

        //             // Carichiamo solo la credenziale di test che siamo sicuri sia corretta
        //             withCredentials([
        //                 string(credentialsId: 'ai-key-debug-test', variable: 'debugApiKey')
        //             ]) {
                        
        //                 echo "--- Test 1: Chiamata con httpRequest (il nostro metodo attuale) ---"
        //                 try {
        //                     def testResponse = callAzureOpenAI(hardcodedEndpoint, debugApiKey, hardcodedDeployment, "Test 1: Chiamata con httpRequest")
        //                     echo "RISPOSTA DA httpRequest: ${testResponse}"
        //                     // Se arriviamo qui, il problema era al 100% nella VECCHIA credenziale o nel suo ID.
                            
        //                 } catch (e) {
        //                     echo "FALLIMENTO Test 1: httpRequest ha fallito anche con la credenziale di test."
        //                     echo "Errore: ${e.toString()}"
        //                 }

        //                 echo "\n--- Test 2: Chiamata con curl dall'agente Jenkins (il tuo metodo funzionante) ---"
        //                 // Usiamo withEnv per passare la chiave a curl in modo sicuro come variabile d'ambiente
        //                 withEnv(["API_KEY_ENV_VAR=${debugApiKey}"]) {
        //                     // Costruiamo il comando curl per Windows
        //                     def curlCommand = """
        //                         curl -v "${hardcodedEndpoint}" ^
        //                         -H "Content-Type: application/json" ^
        //                         -H "api-key: %API_KEY_ENV_VAR%" ^
        //                         -d "{\\\"messages\\\":[{\\\"role\\\":\\\"user\\\",\\\"content\\\":\\\"Test 2: Chiamata con curl dall'agente Jenkins!\\\"}]}"
        //                     """
        //                     def curlExitCode = bat(script: curlCommand, returnStatus: true)
        //                     echo "Codice di uscita del comando curl: ${curlExitCode}"
        //                     if (curlExitCode == 0) {
        //                         echo "SUCCESSO: Il comando curl è terminato correttamente."
        //                     }
        //                 }
        //             }
        //             // Facciamo fallire lo stage per poter analizzare i log con calma
        //             error("Fine del test di debug. Analizza i log qui sopra per la diagnosi.")
        //         }
        //     }
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
                            string(credentialsId: 'AZURE_OPENAI_ENDPOINT', variable: 'AI_ENDPOINT'),
                            string(credentialsId: 'AZURE_OPENAI_API_KEY', variable: 'AI_API_KEY'),
                            string(credentialsId: 'OPENAI_MODEL_DEPLOYMENT_NAME', variable: 'AI_MODEL_DEPLOYMENT_NAME')
                        ]) {
                            // La chiamata alla tua funzione AI
                            def aiTroubleshooting = callAzureOpenAI(AI_ENDPOINT, AI_API_KEY, AI_MODEL_DEPLOYMENT_NAME, troubleshootingPrompt)

                            echo '---------------------------------------'
                            echo 'AI-Powered Troubleshooting Suggestions:\n${aiTroubleshooting}'
                            echo "AI-Powered Troubleshooting Suggestions:\n(Simulazione - qui andrebbe l'output della tua AI)"
                            echo "Log catturato per l'analisi:"
                            echo errorLogs
                            echo '---------------------------------------'
                        }
                        error 'Deployment fallito. Vedi i suggerimenti AI per il troubleshooting.'

                    }
                }
            }
        }
        // stage('Trivy Full Severity Scan') {
        //     steps {
        //         script {
        //             echo "Esecuzione Trivy su tutti i livelli di severità: LOW, MEDIUM, HIGH, CRITICAL"

        //             def trivyOutput = bat(returnStdout: true, script: 'trivy config --format table --severity LOW,MEDIUM,HIGH,CRITICAL .').trim()

        //             echo "---------------------------------------"
        //             echo "Risultato completo della scansione Trivy:\n${trivyOutput}"
        //             echo "---------------------------------------"
        //         }
        //     }
        // }

        
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

// FUNZIONE FINALE E ROBUSTA CHE USA CURL (BASATA SUL TEST 2 FUNZIONANTE)
def callAzureOpenAI(String endpoint, String apiKey, String deploymentName, String promptText) {
    // Usiamo un blocco try/finally per assicurarci di cancellare sempre il file temporaneo
    try {
        // 1. Costruiamo il corpo della richiesta JSON in modo sicuro
        def requestBody = new groovy.json.JsonOutput().toJson([
            messages: [
                [role: "system", content: "You are a helpful and expert assistant for DevOps, Azure, and Terraform."],
                [role: "user", content: promptText] // promptText è già stato trimmato prima di chiamare la funzione
            ],
            max_tokens: 1500,
            temperature: 0.3
        ])

        // 2. Scriviamo il corpo su un file temporaneo. Questo è il modo più pulito e sicuro.
        writeFile(file: 'payload.json', text: requestBody, encoding: 'UTF-8')

        // 3. Passiamo la chiave API come variabile d'ambiente per non esporla nel comando
        withEnv(["API_KEY_ENV_VAR=${apiKey}"]) {
            // 4. Costruiamo il comando curl per Windows.
            //    -s = modalità silenziosa (non mostra la barra di progresso)
            //    -d @payload.json = legge i dati per il corpo della richiesta dal file specificato
            //    Assicurati che il percorso dell'URL e l'api-version siano quelli che funzionano per te.
            def curlCommand = """
                curl -s -X POST "${endpoint}" ^
                -H "Content-Type: application/json" ^
                -H "api-key: %API_KEY_ENV_VAR%" ^
                -d @payload.json
            """

            echo "Eseguo il comando curl per Azure OpenAI..."
            // 5. Eseguiamo il comando e catturiamo solo l'output di testo (stdout)
            def responseText = bat(script: curlCommand, returnStdout: true).trim()

            // Controlliamo se l'output è vuoto (potrebbe indicare un errore a livello di curl non catturato)
            if (responseText.isEmpty()) {
                echo "Errore: Il comando curl è stato eseguito ma non ha restituito alcun output."
                return "Errore AI: Nessuna risposta dal server (output curl vuoto)."
            }

            // 6. Analizziamo la risposta JSON e restituiamo il contenuto utile
            // È importante che la risposta sia un JSON valido, altrimenti readJSON fallirà
            try {
                def jsonResponse = readJSON text: responseText
                if (jsonResponse.choices && jsonResponse.choices[0] && jsonResponse.choices[0].message && jsonResponse.choices[0].message.content) {
                    return jsonResponse.choices[0].message.content
                } else if (jsonResponse.error) { // Gestiamo il caso in cui Azure risponde con un JSON di errore
                    echo "Errore da Azure API: Code=${jsonResponse.error.code}, Message=${jsonResponse.error.message}"
                    return "Errore AI: ${jsonResponse.error.message} (Code: ${jsonResponse.error.code})"
                } else {
                    echo "Errore: la risposta JSON da curl non ha il formato atteso. Risposta: ${responseText}"
                    return "Errore AI: Impossibile analizzare il contenuto della risposta."
                }
            } catch (jsonError) {
                echo "Errore durante il parsing del JSON dalla risposta di curl: ${jsonError.toString()}"
                echo "Testo della risposta ricevuto: ${responseText}"
                return "Errore AI: Risposta dal server non valida o non in formato JSON."
            }
        }
    } catch (e) {
        // Questo blocco cattura errori nell'esecuzione dello script stesso (es. writeFile fallisce)
        echo "Una eccezione è avvenuta durante l'esecuzione di callAzureOpenAI_with_curl: ${e.toString()}"
        return "Errore AI: Eccezione interna durante l'elaborazione della chiamata."
    } finally {
        // 7. Pulizia finale: questo blocco viene eseguito sempre,
        //    garantendo che il nostro file temporaneo non rimanga in giro.
        echo 'Pulizia del file temporaneo payload.json...'
        deleteDir() // Cancella tutti i file nella directory corrente (inclusi payload.json se esiste)
    }
}
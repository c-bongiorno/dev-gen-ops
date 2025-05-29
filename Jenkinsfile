// Jenkinsfile
pipeline {
    agent any // Eseguirà sul Jenkins master o su un agente disponibile

    environment {
        // Variabili d'ambiente per Terraform e Azure OpenAI, recuperate da Jenkins Credentials
        AZURE_CLIENT_ID = credentials('AZURE_CLIENT_ID')
        AZURE_CLIENT_SECRET = credentials('AZURE_CLIENT_SECRET')
        AZURE_TENANT_ID = credentials('AZURE_TENANT_ID')
        AZURE_SUBSCRIPTION_ID = credentials('AZURE_SUBSCRIPTION_ID')
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
                        echo "🚨 Terraform Plan fallito - Avvio analisi AI..."
                        
                        // Cattura log più specifici
                        def errorLogs
                        try {
                            errorLogs = bat(returnStdout: true, script: 'type "%JENKINS_HOME%\\jobs\\%JOB_NAME%\\builds\\%BUILD_NUMBER%\\log"').trim()
                        } catch (logError) {
                            echo "⚠️ Impossibile leggere i log completi, uso l'errore corrente"
                            errorLogs = e.toString()
                        }
                        
                        def troubleshootingPrompt = """
                    Sei un esperto DevOps specializzato in Terraform e Azure.
                    Analizza questo errore e fornisci una soluzione chiara e strutturata.

                    Usa ESATTAMENTE questo formato nella risposta:

                    **Problema:**
                    [Descrizione breve del problema]

                    **Causa Probabile:**
                    [Analisi della causa principale]

                    **Soluzione:**
                    1. [Primo passo specifico]
                    2. [Secondo passo specifico]  
                    3. [Terzo passo se necessario]

                    **Prevenzione:**
                    [Come evitare il problema in futuro]

                    Log di errore:
                    ${errorLogs.take(3000)}
                        """.trim()

                        withCredentials([
                            string(credentialsId: 'AZURE_OPENAI_ENDPOINT', variable: 'AI_ENDPOINT'),
                            string(credentialsId: 'AZURE_OPENAI_API_KEY', variable: 'AI_API_KEY'),  
                            string(credentialsId: 'OPENAI_MODEL_DEPLOYMENT_NAME', variable: 'AI_MODEL_DEPLOYMENT_NAME')
                        ]) {
                            def aiAnalysis = callAzureOpenAI(AI_ENDPOINT, AI_API_KEY, AI_MODEL_DEPLOYMENT_NAME, troubleshootingPrompt)
                            echo aiAnalysis
                        }
                        
                        error 'Deployment fallito. Consulta l\'analisi AI qui sopra per la risoluzione.'
                    }

                    // } catch (e) {
                    //     // --- AI per Troubleshooting degli Errori di Deployment ---
                    //     // Ora il blocco catch verrà eseguito correttamente

                    //     // Cattura l'intero log della build
                    //     def errorLogs = bat(returnStdout: true, script: 'type "%JENKINS_HOME%\\jobs\\%JOB_NAME%\\builds\\%BUILD_NUMBER%\\log"').trim()

                    //     def troubleshootingPrompt = """
                    //         Sei un esperto ingegnere DevOps specializzato in Azure e Terraform.
                    //         Il deployment Terraform su Azure è fallito con i seguenti errori. Analizza i log e suggerisci possibili cause e azioni per il troubleshooting.
                    //         Log di errore del deployment:
                    //         ```
                    //         ${errorLogs}
                    //         ```
                    //         Formato: 'Problema: [Descrizione]. Causa Probabile: [Causa]. Soluzione: [Passi di troubleshooting].'
                    //     """.trim()
                    //     withCredentials([
                    //         string(credentialsId: 'AZURE_OPENAI_ENDPOINT', variable: 'AI_ENDPOINT'),
                    //         string(credentialsId: 'AZURE_OPENAI_API_KEY', variable: 'AI_API_KEY'),
                    //         string(credentialsId: 'OPENAI_MODEL_DEPLOYMENT_NAME', variable: 'AI_MODEL_DEPLOYMENT_NAME')
                    //     ]) {
                    //         // La chiamata alla tua funzione AI
                    //         def aiTroubleshooting = callAzureOpenAI(AI_ENDPOINT, AI_API_KEY, AI_MODEL_DEPLOYMENT_NAME, troubleshootingPrompt)

                    //         echo '---------------------------------------'
                    //         echo 'AI-Powered Troubleshooting Suggestions:\n${aiTroubleshooting}'
                    //         echo "AI-Powered Troubleshooting Suggestions:\n(Simulazione - qui andrebbe l'output della tua AI)"
                    //         echo "Log catturato per l'analisi:"
                    //         echo errorLogs
                    //         echo '---------------------------------------'
                    //     }
                    //     error 'Deployment fallito. Vedi i suggerimenti AI per il troubleshooting.'

                    // }
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
    }
}

// Sostituisci completamente la funzione callAzureOpenAI con questa versione
def callAzureOpenAI(String endpoint, String apiKey, String deploymentName, String promptText) {
    try {
        // 1. Costruisci il JSON della richiesta
        def requestBody = groovy.json.JsonOutput.toJson([
            messages: [
                [role: "system", content: "You are a helpful and expert assistant for DevOps, Azure, and Terraform."],
                [role: "user", content: promptText]
            ],
            max_tokens: 1500,
            temperature: 0.3
        ])

        // 2. Scrivi il payload su file
        writeFile(file: 'payload.json', text: requestBody, encoding: 'UTF-8')

        // 3. Esegui la chiamata curl
        withEnv(["API_KEY_ENV_VAR=${apiKey}"]) {
            def curlCommand = """curl -s -X POST "${endpoint}" -H "Content-Type: application/json" -H "api-key: %API_KEY_ENV_VAR%" -d @payload.json"""
            
            echo "🔄 Chiamata in corso ad Azure OpenAI..."
            def responseText = bat(script: curlCommand, returnStdout: true).trim()

            // 4. Debug: mostra la risposta grezza (temporaneo)
            echo "📥 Risposta ricevuta (primi 200 caratteri): ${responseText.take(200)}..."

            if (responseText.isEmpty()) {
                return "❌ Errore: Nessuna risposta dal server Azure OpenAI"
            }

            // 5. Parsing JSON più robusto
            try {
                // Usa JsonSlurper invece di readJSON per maggiore flessibilità
                def jsonSlurper = new groovy.json.JsonSlurper()
                def jsonResponse = jsonSlurper.parseText(responseText)
                
                // 6. Estrai il contenuto dell'AI
                if (jsonResponse.choices && 
                    jsonResponse.choices.size() > 0 && 
                    jsonResponse.choices[0].message && 
                    jsonResponse.choices[0].message.content) {
                    
                    def aiContent = jsonResponse.choices[0].message.content
                    echo "✅ Contenuto AI estratto con successo (${aiContent.length()} caratteri)"
                    
                    return formatAIResponse(aiContent)
                    
                } else if (jsonResponse.error) {
                    echo "❌ Errore dall'API Azure: ${jsonResponse.error}"
                    return "🚨 Errore Azure OpenAI: ${jsonResponse.error.message ?: jsonResponse.error}"
                    
                } else {
                    echo "❌ Struttura JSON non riconosciuta. Keys disponibili: ${jsonResponse.keySet()}"
                    return "🚨 Errore: Risposta API in formato non previsto"
                }
                
            } catch (groovy.json.JsonException jsonError) {
                echo "❌ Errore parsing JSON: ${jsonError.getMessage()}"
                echo "📄 Risposta completa che ha causato l'errore:"
                echo responseText
                return "🚨 Errore: Risposta non è un JSON valido - ${jsonError.getMessage()}"
                
            } catch (Exception parseError) {
                echo "❌ Errore generico nel parsing: ${parseError.getMessage()}"
                return "🚨 Errore nell'elaborazione della risposta: ${parseError.getMessage()}"
            }
        }
        
    } catch (Exception e) {
        echo "❌ Errore generale nella funzione callAzureOpenAI: ${e.getMessage()}"
        return "🚨 Errore interno: ${e.getMessage()}"
        
    } finally {
        // 7. Pulizia file temporaneo
        try {
            bat(script: 'if exist payload.json del payload.json', returnStatus: true)
        } catch (Exception cleanupError) {
            echo "⚠️ Errore nella pulizia file: ${cleanupError.getMessage()}"
        }
    }
}

// Funzione di formattazione semplificata e funzionante
def formatAIResponse(String content) {
    if (!content || content.trim().isEmpty()) {
        return "⚠️ Contenuto AI vuoto o non valido"
    }
    
    def separator = "=" * 80
    def result = new StringBuilder()
    
    result.append("\n${separator}\n")
    result.append("🤖 AI TROUBLESHOOTING ANALYSIS\n")
    result.append("${separator}\n\n")
    
    // Processa il contenuto riga per riga
    content.split('\n').each { line ->
        def trimmed = line.trim()
        
        if (trimmed.startsWith('**') && trimmed.endsWith('**') && trimmed.length() > 4) {
            // Titoli in grassetto
            def title = trimmed.replaceAll('\\*\\*', '').trim()
            result.append("🔍 ${title}\n")
            result.append("${'-' * (title.length() + 4)}\n")
            
        } else if (trimmed.startsWith('**') && trimmed.contains(':**')) {
            // Sottotitoli con due punti
            def subtitle = trimmed.replaceAll('\\*\\*', '').trim()
            result.append("\n▶ ${subtitle}\n")
            
        } else if (trimmed.matches('^\\d+\\..*')) {
            // Liste numerate
            result.append("   ${trimmed}\n")
            
        } else if (trimmed.startsWith('- ')) {
            // Liste puntate
            result.append("   • ${trimmed.substring(2)}\n")
            
        } else if (!trimmed.isEmpty()) {
            // Testo normale
            result.append("   ${trimmed}\n")
        } else {
            // Righe vuote
            result.append("\n")
        }
    }
    
    result.append("\n${separator}\n")
    result.append("✅ END OF AI ANALYSIS\n")
    result.append("${separator}\n")
    
    return result.toString()
}




// // FUNZIONE FINALE E ROBUSTA CHE USA CURL (BASATA SUL TEST 2 FUNZIONANTE)
// def callAzureOpenAI(String endpoint, String apiKey, String deploymentName, String promptText) {
//     // Usiamo un blocco try/finally per assicurarci di cancellare sempre il file temporaneo
//     try {
//         // 1. Costruiamo il corpo della richiesta JSON in modo sicuro
//         def requestBody = new groovy.json.JsonOutput().toJson([
//             messages: [
//                 [role: "system", content: "You are a helpful and expert assistant for DevOps, Azure, and Terraform."],
//                 [role: "user", content: promptText] // promptText è già stato trimmato prima di chiamare la funzione
//             ],
//             max_tokens: 1500,
//             temperature: 0.3
//         ])

//         // 2. Scriviamo il corpo su un file temporaneo. Questo è il modo più pulito e sicuro.
//         writeFile(file: 'payload.json', text: requestBody, encoding: 'UTF-8')

//         // 3. Passiamo la chiave API come variabile d'ambiente per non esporla nel comando
//         withEnv(["API_KEY_ENV_VAR=${apiKey}"]) {
//             // 4. Costruiamo il comando curl per Windows.
//             //    -s = modalità silenziosa (non mostra la barra di progresso)
//             //    -d @payload.json = legge i dati per il corpo della richiesta dal file specificato
//             //    Assicurati che il percorso dell'URL e l'api-version siano quelli che funzionano per te.
//             def curlCommand = """
//                 curl -s -X POST "${endpoint}" ^
//                 -H "Content-Type: application/json" ^
//                 -H "api-key: %API_KEY_ENV_VAR%" ^
//                 -d @payload.json
//             """

//             echo "Eseguo il comando curl per Azure OpenAI..."
//             // 5. Eseguiamo il comando e catturiamo solo l'output di testo (stdout)
//             def responseText = bat(script: curlCommand, returnStdout: true).trim()

//             // Controlliamo se l'output è vuoto (potrebbe indicare un errore a livello di curl non catturato)
//             if (responseText.isEmpty()) {
//                 echo "Errore: Il comando curl è stato eseguito ma non ha restituito alcun output."
//                 return "Errore AI: Nessuna risposta dal server (output curl vuoto)."
//             }

//             // 6. Analizziamo la risposta JSON e restituiamo il contenuto utile
//             // È importante che la risposta sia un JSON valido, altrimenti readJSON fallirà
//             try {
//                 def jsonResponse = readJSON text: responseText
//                 if (jsonResponse.choices && jsonResponse.choices[0] && jsonResponse.choices[0].message && jsonResponse.choices[0].message.content) {
//                     return jsonResponse.choices[0].message.content
//                 } else if (jsonResponse.error) { // Gestiamo il caso in cui Azure risponde con un JSON di errore
//                     echo "Errore da Azure API: Code=${jsonResponse.error.code}, Message=${jsonResponse.error.message}"
//                     return "Errore AI: ${jsonResponse.error.message} (Code: ${jsonResponse.error.code})"
//                 } else {
//                     echo "Errore: la risposta JSON da curl non ha il formato atteso. Risposta: ${responseText}"
//                     return "Errore AI: Impossibile analizzare il contenuto della risposta."
//                 }
//             } catch (jsonError) {
//                 echo "Errore durante il parsing del JSON dalla risposta di curl: ${jsonError.toString()}"
//                 echo "Testo della risposta ricevuto: ${responseText}"
//                 return "Errore AI: Risposta dal server non valida o non in formato JSON."
//             }
//         }
//     } catch (e) {
//         // Questo blocco cattura errori nell'esecuzione dello script stesso (es. writeFile fallisce)
//         echo "Una eccezione è avvenuta durante l'esecuzione di callAzureOpenAI_with_curl: ${e.toString()}"
//         return "Errore AI: Eccezione interna durante l'elaborazione della chiamata."
//     } finally {
//         // 7. Pulizia finale: questo blocco viene eseguito sempre,
//         //    garantendo che il nostro file temporaneo non rimanga in giro.
//         echo 'Pulizia del file temporaneo payload.json...'
//         deleteDir() // Cancella tutti i file nella directory corrente (inclusi payload.json se esiste)
//     }
// }
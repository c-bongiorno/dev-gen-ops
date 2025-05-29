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

        // 2. Scrivi il payload su file con encoding corretto
        writeFile(file: 'ai_payload.json', text: requestBody, encoding: 'UTF-8')

        // 3. Crea un file batch temporaneo per curl (soluzione Windows)
        def batchContent = """@echo off
                            set API_KEY=${apiKey}
                            curl -s -X POST "${endpoint}" -H "Content-Type: application/json" -H "api-key: %API_KEY%" -d @ai_payload.json > ai_response.json 2>ai_error.log
                        """
        writeFile(file: 'call_ai.bat', text: batchContent, encoding: 'UTF-8')

        // 4. Esegui il file batch
        echo "🔄 Chiamata in corso ad Azure OpenAI..."
        def exitCode = bat(script: 'call call_ai.bat', returnStatus: true)
        
        if (exitCode != 0) {
            def errorOutput = ""
            try {
                errorOutput = readFile('ai_error.log').trim()
            } catch (Exception e) {
                errorOutput = "Impossibile leggere il file di errore"
            }
            echo "❌ Curl fallito con codice: ${exitCode}"
            echo "❌ Errore: ${errorOutput}"
            return "🚨 Errore nella chiamata API: ${errorOutput}"
        }

        // 5. Leggi la risposta dal file
        def responseText
        try {
            responseText = readFile('ai_response.json').trim()
        } catch (Exception e) {
            echo "❌ Impossibile leggere il file di risposta"
            return "🚨 Errore: Impossibile leggere la risposta dell'API"
        }

        // 6. Debug della risposta
        echo "📥 Primi 100 caratteri della risposta: '${responseText.take(100)}'"
        echo "📊 Lunghezza totale risposta: ${responseText.length()} caratteri"

        if (responseText.isEmpty()) {
            return "❌ Errore: Risposta vuota dal server Azure OpenAI"
        }

        // 7. Verifica che inizi con { (JSON valido)
        if (!responseText.startsWith('{')) {
            echo "❌ La risposta non è un JSON valido. Contenuto completo:"
            echo responseText
            return "🚨 Errore: La risposta non è in formato JSON valido"
        }

        // 8. Parsing JSON
        try {
            def jsonSlurper = new groovy.json.JsonSlurper()
            def jsonResponse = jsonSlurper.parseText(responseText)
            
            if (jsonResponse.choices && 
                jsonResponse.choices.size() > 0 && 
                jsonResponse.choices[0].message && 
                jsonResponse.choices[0].message.content) {
                
                def aiContent = jsonResponse.choices[0].message.content
                echo "✅ Contenuto AI estratto con successo"
                
                return formatAIResponse(aiContent)
                
            } else if (jsonResponse.error) {
                return "🚨 Errore Azure OpenAI: ${jsonResponse.error.message ?: jsonResponse.error}"
                
            } else {
                echo "❌ Struttura JSON imprevista. Keys: ${jsonResponse.keySet()}"
                return "🚨 Errore: Struttura risposta API non riconosciuta"
            }
            
        } catch (Exception jsonError) {
            echo "❌ Errore parsing JSON: ${jsonError.getMessage()}"
            echo "📄 Contenuto che ha causato l'errore (primi 500 caratteri):"
            echo responseText.take(500)
            return "🚨 Errore JSON: ${jsonError.getMessage()}"
        }
        
    } catch (Exception e) {
        echo "❌ Errore generale: ${e.getMessage()}"
        e.printStackTrace()
        return "🚨 Errore interno: ${e.getMessage()}"
        
    } finally {
        // 9. Pulizia file temporanei
        try {
            bat(script: '''
                if exist ai_payload.json del ai_payload.json
                if exist ai_response.json del ai_response.json  
                if exist ai_error.log del ai_error.log
                if exist call_ai.bat del call_ai.bat
            ''', returnStatus: true)
        } catch (Exception cleanupError) {
            echo "⚠️ Errore pulizia: ${cleanupError.getMessage()}"
        }
    }
}

// Funzione di formattazione semplificata
def formatAIResponse(String content) {
    if (!content || content.trim().isEmpty()) {
        return "⚠️ Contenuto AI vuoto"
    }
    
    def lines = content.split('\n')
    def result = []
    
    result.add("╔" + "═" * 78 + "╗")
    result.add("║" + " " * 25 + "🤖 AI ANALYSIS" + " " * 25 + "║")  
    result.add("╚" + "═" * 78 + "╝")
    result.add("")
    
    lines.each { line ->
        def trimmed = line.trim()
        if (trimmed.startsWith('**') && trimmed.endsWith('**')) {
            def title = trimmed.replaceAll('\\*\\*', '')
            result.add("🔍 " + title.toUpperCase())
            result.add("   " + "─" * title.length())
        } else if (trimmed.startsWith('**') && trimmed.contains(':')) {
            def title = trimmed.replaceAll('\\*\\*', '')
            result.add("")
            result.add("▶ " + title)
        } else if (trimmed.matches('^\\d+\\..*')) {
            result.add("   " + trimmed)
        } else if (trimmed.startsWith('- ')) {
            result.add("   • " + trimmed.substring(2))
        } else if (!trimmed.isEmpty()) {
            result.add("   " + trimmed)
        }
    }
    
    result.add("")
    result.add("═" * 80)
    
    return result.join('\n')
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
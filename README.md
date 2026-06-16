# App Mobile per Studi Commercialisti - MVP Firebase

Benvenuto nella repository ufficiale dell'applicazione mobile dedicata agli studi commercialisti. Questo software è sviluppato come MVP (Minimum Viable Product) multipiattaforma per ottimizzare la gestione quotidiana dello studio.

---

##  Istruzioni per l'Installazione e l'Avvio

Segui questi passaggi per scaricare il progetto dalla repository remota e avviarlo nel tuo ambiente di sviluppo locale.

### 1. Clonare la Repository
Apri il terminale e clona il progetto eseguendo il comando:
```
git clone <URL_DELLA_REPOSITORY_REMOTA>
cd <NOME_DELLA_CARTELLA_PROGETTO>
```

### 2. Installare le Dipendenze
Assicurati di avere Flutter installato correttamente sul tuo sistema. Installa tutti i pacchetti necessari dichiarati nel progetto:
```
flutter pub get
```

### 3. Configurazione dell'Ambiente Firebase
L'applicazione sfrutta l'ecosistema Firebase. Per consentire il corretto funzionamento, è necessario scaricare e posizionare i file di configurazione del tuo progetto Firebase nelle seguenti cartelle:
* **Per Android:** Inserisci il file `google-services.json` all'interno della directory `android/app/`.
* **Per iOS:** Inserisci il file `GoogleService-Info.plist` all'interno della directory `ios/Runner/`.

### 4. Avviare l'Applicazione
Collega un dispositivo fisico (con debug USB attivo) o avvia un emulatore/simulatore, quindi esegui:
```
flutter run
```
Per compilare ed eseguire il codice. Per compilare solamente esegui:
```
flutter analyze
```

---

##  Analisi di Specifica Funzionale e Tecnica (FRD)

* **Versione Documento:** 1.0 
* **Scopo:** Documento di specifica funzionale destinato al team di sviluppo per la realizzazione dell'MVP.

### 1. Obiettivi del Progetto
* Realizzare un'applicazione mobile multipiattaforma (iOS/Android) dedicata agli studi commercialisti.
* Consentire la gestione centralizzata di clienti, documenti, scadenze fiscali, attività interne e notifiche all'interno dell'MVP.

### 2. Stakeholder del Sistema
* Titolare dello studio 
* Commercialisti 
* Collaboratori 
* Amministratori di sistema 
* Clienti (il cui rilascio è previsto per una fase successiva) 

### 3. Architettura Tecnica
* **Frontend:** Framework Flutter per lo sviluppo cross-platform.
* **Autenticazione:** Firebase Authentication.
* **Database:** Cloud Firestore.
* **Storage:** Firebase Storage per l'archiviazione dei file.
* **Automazioni:** Cloud Functions per le logiche di backend.
* **Push Notification:** Firebase Cloud Messaging.
* **Analytics:** Firebase Analytics.
* **Crash Reporting:** Firebase Crashlytics.

### 4. Matrice dei Ruoli e Permessi
* Admin: Dispone della gestione completa. Può modificare esplicitamente il ruolo di tutti gli altri utenti registrati. È previsto il ruolo Admin e il ruolo User.
* Commercialista: Ha i permessi operativi per la gestione diretta di clienti, documenti, scadenze e task.
* Collaboratore: Può accedere unicamente ai clienti a lui assegnati e alle proprie attività associate.

* **Admin:** può cambiare il ruolo degli altri utenti
* **User**

### 5. Requisiti Funzionali dell'Applicazione
* **✓ RF-00:** Sign Up (Registrazione nuovo utente).
* **✓ RF-01:** Login (Accesso sicuro).
* **✓ RF-02:** Logout (Disconnessione dall'account).
* **✓ RF-03:** Recupero password smarrita.
* **✓ RF-04:** Gestione del profilo utente.
* **✓ RF-05:** Dashboard operativa centrale.
* **✓ RF-06:** Gestione dei clienti dello studio.
* **✓ RF-07:** Gestione delle scadenze fiscali.
* **✓ RF-08:** Gestione e archiviazione documenti.
* **✓ RF-09:** Gestione delle attività interne.
* **✓ RF-10:** Invio e ricezione di notifiche push.
* **RF-11:** Gestione amministrativa di tutti gli utenti registrati all'applicazione.

### 6. User Stories (US)
* **US-01:** Come commercialista voglio visualizzare le scadenze imminenti.
* **US-02:** Come collaboratore voglio vedere le attività assegnate.
* **US-03:** Come utente voglio caricare documenti associandoli a un cliente.
* **US-04:** Come amministratore voglio gestire gli utenti.

### 7. Flussi UI Principali
* **✓ FLOW 1 - Login:** Splash -> Login -> Verifica credenziali -> Dashboard.
* **✓ FLOW 2 - Ricerca Cliente:** Dashboard -> Clienti -> Ricerca -> Lista risultati -> Scheda Cliente.
* **✓ FLOW 3 - Nuova Scadenza:** Scheda Cliente -> Scadenze -> Nuova Scadenza -> Salva -> Notifica pianificata.
* **✓ FLOW 4 - Upload Documento:** Scheda Cliente -> Documenti -> Carica Documento -> Storage -> Conferma.
* **FLOW 5 - Gestione Task:** Scheda Cliente -> Attività -> Nuova Attività -> Assegna -> Notifica.
* **✓ FLOW 6 - Dashboard Giornaliera:** Login -> Dashboard -> Scadenze odierne -> Dettaglio.

### 8. Struttura dei Wireframe Testuali
* **✓ Dashboard:** Mostra un riepilogo con Clienti Attivi, Scadenze Oggi, Task Aperti e Documenti Recenti.
* **✓ Cliente:** Contiene la sezione dei Dati Anagrafici e i sottomoduli [Documenti], [Scadenze] e [Attività].
* **✓ Scadenze:** Fornisce strumenti di Filtro, una vista Calendario e la Lista Scadenze.

### 9. Modello Dati e Schema Collection Cloud Firestore
Le relazioni tra le entità sono gestite tramite identificativi logici (ID referenziali).

#### Collezioni Principali:
* **`users/{userId}`:** Documento del profilo utente.
* **`documents/{documentId}`:** Riferimento ai metadati dei documenti caricati.
* **`notifications/{notificationId}`:** Tracciamento delle notifiche di sistema.
* **`clients/{clientId}`:** Anagrafica del cliente. Campi: `companyName`, `vatNumber`, `taxCode`, `pec`, `sdiCode`, `phone`, `email`, `address`, `createdAt`, `studioId`.
* **`deadlines/{deadlineId}`:** Scadenze fiscali configurate. Campi: `clientId`, `type`, `dueDate`, `status`, `assignedTo`, `studioId`.
* **`tasks/{taskId}`:** Attività lavorative interne. Campi: `clientId`, `title`, `description`, `status`, `assignedTo`, `studioId`.

### 10. Sicurezza e Conformità
* ✓ Autenticazione nativa gestita tramite i moduli di Firebase.
* ✓ Controllo granulare degli accessi ai dati mediante le *Firebase Security Rules*.
* Cifratura obbligatoria di tutti i dati durante il transito in rete.
* Logging centralizzato di tutti gli eventi applicativi rilevanti.
* Gestione dei flussi dati in piena conformità con le direttive GDPR.

### 11. Logica delle Notifiche Push
Il sistema attiva l'invio automatico di notifiche nei seguenti casi d'uso:
* Scadenza fiscale imminente.
* Nuova attività assegnata a un collaboratore o utente dello studio.
* Nuovo documento caricato sulla scheda di un cliente.
* Scadenza fiscale formalmente scaduta.

### 12. Requisiti Non Funzionali (RNF)
* **✓ Performance:** Il tempo massimo di caricamento di qualunque schermata deve essere inferiore a 2 secondi.
* **✓ Disponibilità:** Viene garantito un target di uptime continuo pari al 99.5%.
* **✓ Compatibilità:** Supporto completo e ottimizzato per i sistemi operativi Android e iOS.
* **✓ Resilienza:** Integrazione di un supporto offline limitato per la consultazione in assenza di rete.

### 13. Backlog di Sviluppo dell'MVP (Sprint)
* **✓ Sprint 1:** Configurazione dei sistemi di Autenticazione e predisposizione della struttura base del software.
* **✓ Sprint 2:** Sviluppo dell'anagrafica Clienti e della Dashboard principale.
* **✓ Sprint 3:** Implementazione dello Scadenziario e delle viste di pianificazione.
* **Sprint 4:** Integrazione della gestione Documentale e collegamento a Firebase Storage.
* **✓ Sprint 5:** Sviluppo del modulo Task operativi e automazione delle notifiche push.
* **✓ Sprint 6:** Esecuzione delle fases di Testing complessivo, bug fixing e attività di rilascio negli store.

### 14. Criteri di Accettazione dell'MVP
Per considerare completato il prodotto, l'utente abilitato deve essere in grado di effettuare correttamente le seguenti operazioni:
* ✓ Autenticarsi in modo sicuro all'interno dell'applicazione.
* ✓ Creare e modificare le schede dei clienti.
* ✓ Gestire in autonomia le scadenze fiscali.
* ✓ Caricare i documenti all'interno dello storage di riferimento.
* ✓ Creare, tracciare e assegnare nuove attività operative.
* Ricevere tempestivamente le notifiche push configurate dal sistema.

# App Mobile per Studi Commercialisti - MVP Firebase

[cite_start]Benvenuto nella repository ufficiale dell'applicazione mobile dedicata agli studi commercialisti[cite: 2]. [cite_start]Questo software è sviluppato come MVP (Minimum Viable Product) multipiattaforma per ottimizzare la gestione quotidiana dello studio[cite: 4, 6, 8].

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
[cite_start]Assicurati di avere Flutter installato correttamente sul tuo sistema[cite: 16]. Installa tutti i pacchetti necessari dichiarati nel progetto:
```
flutter pub get
```

### 3. Configurazione dell'Ambiente Firebase
[cite_start]L'applicazione sfrutta l'ecosistema Firebase[cite: 2]. [cite_start]Per consentire il corretto funzionamento, è necessario scaricare e posizionare i file di configurazione del tuo progetto Firebase nelle seguenti cartelle[cite: 17, 18, 19]:
* **Per Android:** Inserisci il file `google-services.json` all'interno della directory `android/app/`.
* **Per iOS:** Inserisci il file `GoogleService-Info.plist` all'interno della directory `ios/Runner/`.

### 4. Avviare l'Applicazione
[cite_start]Collega un dispositivo fisico (con debug USB attivo) o avvia un emulatore/simulatore, quindi esegui[cite: 6, 121]:
```
flutter run
```
Per compilare ed eseguire il codice. Per compilare solamente esegui:
```
flutter analyze
```

---

##  Analisi di Specifica Funzionale e Tecnica (FRD)

* [cite_start]**Versione Documento:** 1.0 [cite: 3]
* [cite_start]**Scopo:** Documento di specifica funzionale destinato al team di sviluppo per la realizzazione dell'MVP[cite: 4].

### 1. Obiettivi del Progetto
* [cite_start]Realizzare un'applicazione mobile multipiattaforma (iOS/Android) dedicata agli studi commercialisti[cite: 6, 7].
* [cite_start]Consentire la gestione centralizzata di clienti, documenti, scadenze fiscali, attività interne e notifiche all'interno dell'MVP[cite: 8].

### 2. Stakeholder del Sistema
* [cite_start]Titolare dello studio [cite: 10]
* [cite_start]Commercialisti [cite: 11]
* [cite_start]Collaboratori [cite: 12]
* [cite_start]Amministratori di sistema [cite: 13]
* [cite_start]Clienti (il cui rilascio è previsto per una fase successiva) [cite: 14]

### 3. Architettura Tecnica
* [cite_start]**Frontend:** Framework Flutter per lo sviluppo cross-platform[cite: 16].
* [cite_start]**Autenticazione:** Firebase Authentication[cite: 17].
* [cite_start]**Database:** Cloud Firestore[cite: 18].
* [cite_start]**Storage:** Firebase Storage per l'archiviazione dei file[cite: 19].
* [cite_start]**Automazioni:** Cloud Functions per le logiche di backend[cite: 20].
* [cite_start]**Push Notification:** Firebase Cloud Messaging[cite: 21].
* [cite_start]**Analytics:** Firebase Analytics[cite: 22].
* [cite_start]**Crash Reporting:** Firebase Crashlytics[cite: 23].

### 4. Matrice dei Ruoli e Permessi
* [cite_start]Admin: Dispone della gestione completa[cite: 25]. [cite_start]Può modificare esplicitamente il ruolo di tutti gli altri utenti registrati[cite: 27]. [cite_start]È previsto il ruolo Admin e il ruolo User[cite: 27].
* [cite_start]Commercialista: Ha i permessi operativi per la gestione diretta di clienti, documenti, scadenze e task[cite: 26].
* [cite_start]Collaboratore: Può accedere unicamente ai clienti a lui assegnati e alle proprie attività associate[cite: 26].

* [cite_start]**Admin:** l'admn può cambiare il ruolo degli altri utenti
*  [cite_start]**User**

### 5. Requisiti Funzionali dell'Applicazione
* [cite_start]**✓ RF-00:** Sign Up (Registrazione nuovo utente)[cite: 29].
* [cite_start]**✓ RF-01:** Login (Accesso sicuro)[cite: 30].
* [cite_start]**✓ RF-02:** Logout (Disconnessione dall'account)[cite: 31].
* [cite_start]**✓ RF-03:** Recupero password smarrita[cite: 32].
* [cite_start]**✓ RF-04:** Gestione del profilo utente[cite: 33].
* [cite_start]**✓ RF-05:** Dashboard operativa centrale[cite: 34].
* [cite_start]**✓ RF-06:** Gestione dei clienti dello studio[cite: 35].
* [cite_start]**✓ RF-07:** Gestione delle scadenze fiscali[cite: 36].
* [cite_start]**✓ RF-08:** Gestione e archiviazione documenti[cite: 37].
* [cite_start]**✓ RF-09:** Gestione delle attività interne[cite: 38].
* [cite_start]**✓ RF-10:** Invio e ricezione di notifiche push[cite: 39].
* [cite_start]**RF-11:** Gestione amministrativa di tutti gli utenti registrati all'applicazione[cite: 40].

### 6. User Stories (US)
* [cite_start]**US-01:** Come commercialista voglio visualizzare le scadenze imminenti[cite: 42].
* [cite_start]**US-02:** Come collaboratore voglio vedere le attività assegnate[cite: 43].
* [cite_start]**US-03:** Come utente voglio caricare documenti associandoli a un cliente[cite: 44].
* [cite_start]**US-04:** Come amministratore voglio gestire gli utenti[cite: 44].

### 7. Flussi UI Principali
* [cite_start]**✓ FLOW 1 - Login:** Splash -> Login -> Verifica credenziali -> Dashboard[cite: 46, 47].
* [cite_start]**✓ FLOW 2 - Ricerca Cliente:** Dashboard -> Clienti -> Ricerca -> Lista risultati -> Scheda Cliente[cite: 48, 49].
* [cite_start]**✓ FLOW 3 - Nuova Scadenza:** Scheda Cliente -> Scadenze -> Nuova Scadenza -> Salva -> Notifica pianificata[cite: 50, 51].
* [cite_start]**✓  FLOW 4 - Upload Documento:** Scheda Cliente -> Documenti -> Carica Documento -> Storage -> Conferma[cite: 52, 53].
* [cite_start]**FLOW 5 - Gestione Task:** Scheda Cliente -> Attività -> Nuova Attività -> Assegna -> Notifica[cite: 54, 55].
* [cite_start]**✓ FLOW 6 - Dashboard Giornaliera:** Login -> Dashboard -> Scadenze odierne -> Dettaglio[cite: 56, 57].

### 8. Struttura dei Wireframe Testuali
* [cite_start]**✓  Dashboard:** Mostra un riepilogo con Clienti Attivi, Scadenze Oggi, Task Aperti e Documenti Recenti[cite: 59, 60, 61, 62, 63].
* [cite_start]**✓ Cliente:** Contiene la sezione dei Dati Anagrafici e i sottomoduli [Documenti], [Scadenze] e [Attività][cite: 64, 65, 66, 67, 68].
* [cite_start]**✓ Scadenze:** Fornisce strumenti di Filtro, una vista Calendario e la Lista Scadenze[cite: 69, 70, 71, 72].

### 9. Modello Dati e Schema Collection Cloud Firestore
[cite_start]Le relazioni tra le entità sono gestite tramite identificativi logici (ID referenziali)[cite: 80].

#### Collezioni Principali:
* [cite_start]**`users/{userId}`:** Documento del profilo utente[cite: 74].
* [cite_start]**`documents/{documentId}`:** Riferimento ai metadati dei documenti caricati[cite: 78].
* [cite_start]**`notifications/{notificationId}`:** Tracciamento delle notifiche di sistema[cite: 79].
* [cite_start]**`clients/{clientId}`:** Anagrafica del cliente[cite: 75, 82]. [cite_start]Campi: `companyName` [cite: 83][cite_start], `vatNumber` [cite: 84][cite_start], `taxCode` [cite: 85][cite_start], `pec` [cite: 86][cite_start], `sdiCode` [cite: 87][cite_start], `phone` [cite: 88][cite_start], `email` [cite: 89][cite_start], `address` [cite: 90][cite_start], `createdAt` [cite: 91][cite_start], `studioId`[cite: 92].
* [cite_start]**`deadlines/{deadlineId}`:** Scadenze fiscali configurate[cite: 76, 93]. [cite_start]Campi: `clientId` [cite: 94][cite_start], `type` [cite: 95][cite_start], `dueDate` [cite: 96][cite_start], `status` [cite: 97][cite_start], `assignedTo` [cite: 98][cite_start], `studioId`[cite: 99].
* [cite_start]**`tasks/{taskId}`:** Attività lavorative interne[cite: 77, 100]. [cite_start]Campi: `clientId` [cite: 101][cite_start], `title` [cite: 102][cite_start], `description` [cite: 103][cite_start], `status` [cite: 104][cite_start], `assignedTo` [cite: 105][cite_start], `studioId`[cite: 106].

### 10. Sicurezza e Conformità
* [cite_start]✓ Autenticazione nativa gestita tramite i moduli di Firebase[cite: 108].
* [cite_start]✓ Controllo granulare degli accessi ai dati mediante le *Firebase Security Rules*[cite: 109].
* [cite_start]Cifratura obbligatoria di tutti i dati durante il transito in rete[cite: 110].
* [cite_start]Logging centralizzato di tutti gli eventi applicativi rilevanti[cite: 111].
* [cite_start]Gestione dei flussi dati in piena conformità con le direttive GDPR[cite: 112].

### 11. Logica delle Notifiche Push
[cite_start]Il sistema attiva l'invio automatico di notifiche nei seguenti casi d'uso[cite: 113]:
* [cite_start]Scadenza fiscale imminente[cite: 114].
* [cite_start]Nuova attività assegnata a un collaboratore o utente dello studio[cite: 115].
* [cite_start]Nuovo documento caricato sulla scheda di un cliente[cite: 116].
* [cite_start]Scadenza fiscale formalmente scaduta[cite: 117].

### 12. Requisiti Non Funzionali (RNF)
* [cite_start]**✓ Performance:** Il tempo massimo di caricamento di qualunque schermata deve essere inferiore a 2 secondi[cite: 119].
* [cite_start]**✓ Disponibilità:** Viene garantito un target di uptime continuo pari al 99.5%[cite: 120].
* [cite_start]**✓ Compatibilità:** Supporto completo e ottimizzato per i sistemi operativi Android e iOS[cite: 121].
* [cite_start]**✓ Resilienza:** Integrazione di un supporto offline limitato per la consultazione in assenza di rete[cite: 122].

### 13. Backlog di Sviluppo dell'MVP (Sprint)
* [cite_start]**✓ Sprint 1:** Configurazione dei sistemi di Autenticazione e predisposizione della struttura base del software[cite: 124, 125].
* [cite_start]**✓ Sprint 2:** Sviluppo dell'anagrafica Clienti e della Dashboard principale[cite: 126, 127].
* [cite_start]**✓ Sprint 3:** Implementazione dello Scadenziario e delle viste di pianificazione[cite: 128, 129].
* [cite_start]**Sprint 4:** Integrazione della gestione Documentale e collegamento a Firebase Storage[cite: 130, 131].
* [cite_start]**✓ Sprint 5:** Sviluppo del modulo Task operativi e automazione delle notifiche push[cite: 132, 133].
* [cite_start]**✓ Sprint 6:** Esecuzione delle fases di Testing complessivo, bug fixing e attività di rilascio negli store[cite: 134, 135].

### 14. Criteri di Accettazione dell'MVP
[cite_start]Per considerare completato il prodotto, l'utente abilitato deve essere in grado di effettuare correttamente le seguenti operazioni[cite: 136, 137]:
* [cite_start]✓ Autenticarsi in modo sicuro all'interno dell'applicazione[cite: 138].
* [cite_start]✓ Creare e modificare le schede dei clienti[cite: 139].
* [cite_start]✓ Gestire in autonomia le scadenze fiscali[cite: 140].
* [cite_start]✓ Caricare i documenti all'interno dello storage di riferimento[cite: 141].
* [cite_start]✓ Creare, tracciare e assegnare nuove attività operative[cite: 142].
* [cite_start]Ricevere tempestivamente le notifiche push configurate dal sistema[cite: 143].

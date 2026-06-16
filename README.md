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

#### Esecuzione in sviluppo

```bash
# Esegui su dispositivo/emulatore connesso
flutter run

# Forza una piattaforma specifica
flutter run -d android    # Solo Android
flutter run -d ios        # Solo iOS (macOS richiesto)
flutter run -d chrome     # Solo Web
flutter run -d windows    # Solo Windows
flutter run -d macos      # Solo macOS
flutter run -d linux      # Solo Linux

# Verifica la correttezza del codice (analisi statica)
flutter analyze
```

#### Build per produzione

```bash
# Android
flutter build apk --release                # APK singolo
flutter build appbundle --release          # App Bundle (Play Store)

# iOS (richiede Xcode su macOS)
flutter build ios --release

# Web
flutter build web --release

# Desktop
flutter build windows --release            # Windows
flutter build macos --release              # macOS
flutter build linux --release              # Linux
```

### 5. Requisiti per piattaforma

| Piattaforma | SDK richiesto | Note |
|---|---|---|
| **Android** | Android SDK (API 21+) | Emulatore Android o dispositivo fisico con debug USB |
| **iOS** | Xcode 16+ / CocoaPods | Solo su macOS; necessario provisioning profile per device fisico |
| **Web** | Chrome / Edge | `flutter build web` e deploy su qualsiasi host statico |
| **Windows** | Windows 10+ / Visual Studio | Build con toolchain MSVC |
| **macOS** | macOS 13+ / Xcode 16+ | Richiede Mac con chip Apple Silicon o Intel |
| **Linux** | GTK+ 3.0 / cmake / ninja | Build su qualsiasi distro Linux con toolchain standard |

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

### 7. Mappa di Navigazione e Flussi UI

#### Diagramma di navigazione completo

```
                    ┌──────────────────────────────────────────────────┐
                    │                  WelcomePage                     │
                    │              Benvenuto. Inizia da qui.           │
                    └──────┬──────────────────────┬───────────────────┘
                           │                      │
                    Accedi │                      │ Registrati
                           ▼                      ▼
                    ┌──────────┐          ┌──────────────┐
                    │ LoginPage│          │Registrazione │
                    │ (RF-01)  │          │Page (RF-00)  │
                    └────┬─────┘          └──────┬───────┘
                         │                       │
                         └───────┬───────────────┘
                                 │ Login/Registrazione ok
                                 ▼
                    ┌──────────────────────┐
                    │    NexaHomePage       │
                    │ Assegna Studio / Menu │
                    └──────┬───────────────┘
                           │
              ┌────────────┼────────────┐
              │            │            │
        Crea Studio   Accedi a    Profilo /
              │        Studio      Logout
              ▼            ▼
     ┌────────────┐ ┌──────────────┐
     │ Dashboard  │ │ Dashboard    │
     │  (Admin)   │ │  (User)      │
     └─────┬──────┘ └──────┬───────┘
           │               │
           ▼               ▼
     ┌─────────────────────────────────────┐
     │          DashboardPage               │
     │  ┌──────────────────────────────┐   │
     │  │  Calendario orizzontale      │   │
     │  │  (365 giorni, scorrevole)    │   │
     │  ├──────────────────────────────┤   │
     │  │  Scadenze del giorno         │   │
     │  │  [Aggiungi] [Dettagli] [✓]  │   │
     │  ├──────────────────────────────┤   │
     │  │  Clienti attivi             │   │
     │  │  [Info] [Documenti]          │   │
     │  └──────────────────────────────┘   │
     └─────────────────────────────────────┘
           │
           │ Menu laterale (Drawer)
           ├──────────────────────────────────┐
           │                                  │
           ▼                                  ▼
     ┌──────────────┐              ┌────────────────────┐
     │Anagrafica    │              │  Cerca Documenti   │
     │Clienti Page  │              │  Page               │
     │(RF-06)       │              │  (RF-08)            │
     │[Cerca]       │              │  [Filtra per        │
     │[Modifica]    │              │   nome azienda]     │
     │[Elimina]     │              │  [Apri URL]         │
     └──────┬───────┘              │  [Elimina]          │
            │                      └────────────────────┘
            ▼
     ┌──────────────────┐
     │ DocumentiCliente │
     │ Page             │
     │ [Lista file]     │
     │ [Apri PDF]       │
     └──────────────────┘
```

#### Flussi UI dettagliati

| # | Flusso | Stato | Percorso |
|---|---|---|---|
| **1** | **Login/Accesso** | ✓ | `WelcomePage → LoginPage → NexaHomePage → DashboardPage` |
| **2** | **Registrazione** | ✓ | `WelcomePage → RegistrazionePage → NexaHomePage → DashboardPage` |
| **3** | **Creazione Studio** | ✓ | `NexaHomePage → Tab "Crea Studio" → Inserisci Nome+P.IVA → Codice invito generato → DashboardPage` |
| **4** | **Accesso a Studio** | ✓ | `NexaHomePage → Tab "Accedi a Studio" → Inserisci codice 6 cifre → DashboardPage` |
| **5** | **Dashboard giornaliera** | ✓ | `Login → DashboardPage → Calendario → Seleziona data → Scadenze del giorno` |
| **6** | **Aggiungi Scadenza** | ✓ | `DashboardPage → [+] → Compila tipo/data/assegnatario → Salva → Notifica` |
| **7** | **Completa Scadenza** | ✓ | `DashboardPage → [✓] sul task → Conferma → Stato "completata" (testo sbarrato)` |
| **8** | **Ricerca Clienti** | ✓ | `DashboardPage → Drawer → "Cerca e Modifica Clienti" → Barra ricerca → Lista filtrata → [Modifica/Elimina]` |
| **9** | **Aggiungi Cliente** | ✓ | `DashboardPage → Drawer → "Aggiungi Cliente" → Compila form → Salva` |
| **10** | **Documenti Cliente** | ✓ | `DashboardPage → Cliente → [📁 Documenti] → Lista file → Tap per apri PDF` |
| **11** | **Upload Documento** | ✓ | `DashboardPage → Drawer → "Scansiona Documenti" → Scanner → Associa a cliente → Upload` |
| **12** | **Scansione Biglietto** | ✓ | `(da aggiungere) → Scatta foto → OCR → Precompila form cliente → Salva` |
| **13** | **Profilo Utente** | ✓ | `Drawer → "Profilo" → Modifica dati / Cambia password / Vedi codice invito studio` |
| **14** | **Logout** | ✓ | `Drawer → "Disconnettiti" → Conferma → WelcomePage` |
| **15** | **Gestione Task** | ✗ | `(da implementare) → Crea/Assegna/Completa attività interne` |
| **16** | **Gestione Utenti (Admin)** | ✗ | `(da implementare) → Admin → Cambia ruoli / Kick / Ban utenti` |

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

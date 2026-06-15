const { onDocumentCreated } = require("firebase-functions/v2/firestore");
const { setGlobalOptions } = require("firebase-functions");
const admin = require("firebase-admin");
const logger = require("firebase-functions/logger");

admin.initializeApp();
setGlobalOptions({ maxInstances: 10 });

// Funzione che si attiva ogni volta che viene caricato un nuovo documento
exports.inviaNotificaDocumento = onDocumentCreated("notifications/{notificationId}", async (event) => {
    const snap = event.data;
    if (!snap) {
        logger.error("Nessun dato associato all'evento di creazione.");
        return;
    }

    const datiNotifica = snap.data();

    // Gestione della notifica solo nel caso in cui sia pending
    if (datiNotifica.status !== 'pending') {
        return;
    }

    try {
        // Recupero di tutti gli utenti dello studio commerciale
        const utentiSnapshot = await admin.firestore()
            .collection("users")
            .where("studioId", "==", datiNotifica.studioId)
            .get();

        const tokens = [];

        // Estrazione dei token
        utentiSnapshot.forEach((doc) => {
            const userData = doc.data();
            if (userData.fcmToken) {
                if (Array.isArray(userData.fcmToken)) {
                    tokens.push(...userData.fcmToken);
                } else {
                    tokens.push(userData.fcmToken);
                }
            }
        });

        // Messaggio nel caso in cui non ci siano membri dello studio
        if (tokens.length === 0) {
            logger.info(`Nessun token FCM trovato per i membri dello studio: ${datiNotifica.studioId}`);
            await snap.ref.update({ status: "no_tokens_found" });
            return;
        }

        // Preparazione del messaggio
        const messaggio = {
            notification: datiNotifica.notification,
            data: datiNotifica.data,
            tokens: tokens,
        };

        // Invio del messaggio a tutti i dispositivi
        const response = await admin.messaging().sendEachForMulticast(messaggio);
        logger.info(`${response.successCount} notifiche push inviate con successo.`);

        // Aggiornamento dello stato della notifica come inviata
        await snap.ref.update({
            status: "sent",
            sentAt: admin.firestore.FieldValue.serverTimestamp()
        });

    } catch (error) {
        logger.error("Errore durante l'elaborazione o l'invio della notifica:", error);
        
        // Aggiornamento dello stato di notifica come errore
        await snap.ref.update({
            status: "error",
            errorMessage: error.message
        });
    }
});
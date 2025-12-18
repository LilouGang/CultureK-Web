const admin = require('firebase-admin');
const serviceAccount = require('./serviceAccountKey.json');

admin.initializeApp({
  credential: admin.credential.cert(serviceAccount)
});

const db = admin.firestore();

const COLLECTION_NAME = "Questions";

async function deleteFilteredDocuments() {
  console.log(`Préparation de la suppression des documents dans '${COLLECTION_NAME}'...`);

  const query = db.collection(COLLECTION_NAME)
    .where("theme", '==', "Géographie")
    .where("sousTheme", '==', "Montagnes")

  const snapshot = await query.get();

  if (snapshot.empty) {
    console.log("Aucun document correspondant trouvé. Rien à faire.");
    return;
  }

  console.log(`${snapshot.size} document(s) trouvé(s). Début de la suppression...`);

  const batch = db.batch();
  snapshot.docs.forEach(doc => {
    batch.delete(doc.ref);
  });

  await batch.commit();

  console.log(`Suppression de ${snapshot.size} document(s) terminée avec succès !`);
}

deleteFilteredDocuments().catch(console.error);
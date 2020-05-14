const functions = require("firebase-functions");
const admin = require("firebase-admin");
const path = require("path");
const serviceAccount = require("./ServiceAccountKey.json");
const axios = require('axios');

admin.initializeApp({
  credential: admin.credential.cert(serviceAccount),
});

const db = admin.firestore();

exports.generateFirestoreData = functions.storage
  .object()
  .onFinalize(async (object) => {
    const fileBucket = object.bucket;
    const filePath = object.name;
    const contentType = object.contentType;
    const metageneration = object.metageneration;

    if (!contentType.startsWith("image/")) {
      return console.log("This is not an image.");
    }

    const fileName = path.basename(filePath);
    console.log(object);

    return db
      .collection("images")
      .doc(fileName)
      .set({ 
        uri: object.selfLink,
        labelCount: 0,
      })
      .then(() => console.log("Data saved !"))
      .catch((err) => console.warn(err));
  });

 exports.onLabelCountUpdate = functions.firestore.document("images/{imageId}").onUpdate((change, context) => {


  const before = change.before.data();
  const after = change.after.data();

  console.log(before)
  console.log(after)

  if (before.labelCount === after.labelCount ){
    return null;
  }

  if (after.labelCount > 20) {
    let now = Date.now();
    return axios.post('https://co1django-n5slpqfsmq-uc.a.run.app/inspiration/', {
      editedUri: after.uri,
      edited: now,
    }).then((resp) => {
      console.log(resp)
      return true
    }).catch((err) => {
      console.warn(err)
      return false
    })
  }

  return null
})



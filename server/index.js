var express = require("express");
var app = express();
// Node.js e.g via a Firebase Cloud Function

var admin = require("firebase-admin");

var serviceAccount = require("./serviceAccountKey.json");

admin.initializeApp({
  credential: admin.credential.cert(serviceAccount),
  //databaseURL: 'https://sosmap-f80c2.firebaseio.com'
});

async function onSendNotification(body) {
    const token = body.token;
    if(!token) return;
        await admin.messaging().sendToDevice(
            token, // ['token_1', 'token_2', ...]
            {
              notification: body.notification,
              data: body.data,
            },
            {
              // Required for background/quit data-only messages on iOS
              contentAvailable: true,
              // Required for background/quit data-only messages on Android
              priority: "high",
            }
          );

  
}
app.use(express.json());
app.use(express.urlencoded({
  extended: true
}));
app.post("/api/fcm/sosmap", (req, res, next) => {
    onSendNotification(req.body);
    console.log(req.body)
    res.sendStatus(200);
   });
app.get("/", (req, res, next) => {
    res.send('SOSMap');
})
app.listen(process.env.PORT || 3000, () => {
 console.log("Server running on port 3000");
});
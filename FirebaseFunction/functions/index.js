const functions = require("firebase-functions");
const admin = require("firebase-admin");
var request = require("request");
var serviceAccount = require("./key.json");

admin.initializeApp({ credential: admin.credential.cert(serviceAccount) });
exports.useWildcard = functions.firestore
  .document("amb/{userId}")
  .onWrite((change, context) => {
    console.log(context.params.userId);
    const idTo = context.params.userId;
    var currentValue = change.after.data();

    var previousValue = change.before.data();
    var db = admin.firestore();
    var payload;
    var originLat, oringLong;
    var vehicleRef = db.collection("vehicle");
    var ambRef = db.collection("amb").doc("ug6AKnr3En4OMBjk40s7");
    console.log(previousValue);
    console.log(currentValue);
    vehicleRef
      .get()
      .then(snapshot => {
        snapshot.docs.map(async function(doc) {
          loc = doc.data()["point"];
          console.log("data", loc.latitude);
          console.log("Long", loc.longitude);

          originLat = currentValue["location"].latitude;
          originLong = currentValue["location"].longitude;
          await request(
            `https://maps.googleapis.com/maps/api/distancematrix/json?units=imperial&origins=${originLat},${originLong}&destinations=${loc.latitude},${loc.longitude}&key=AIzaSyAZQl0TRenJIoCbKNjDKmT2LN9Y94um9qs`,
            function(error, response, body) {
              var val = JSON.parse(body);
              console.log(val.rows[0].elements[0].distance.value);
                  console.log(val.rows[0].elements[0].distance.text);
                  if(val.rows[0].elements[0].distance.value<2000){
                  payload = {
                    notification: {
                      title: `Ambulace is moving`,
                      body: "Please give way",
                      badge: "1",
                      sound: "default"
                    }
                  };
                  console.log(doc.data()["pushToken"]);
                  admin.messaging().sendToDevice(doc.data()["pushToken"], payload);
            }
          }
          );

          return 0;
        });
        return 0;
      })
      .catch(err => {
        console.log("Error getting documents", err);
      });
  });

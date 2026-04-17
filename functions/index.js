
const functions = require("firebase-functions");
const admin = require("firebase-admin");

admin.initializeApp();

exports.sendSensorAlerts = functions.database.ref("/users/{userId}/sensors/dht")
    .onUpdate(async (change, context) => {
      const afterData = change.after.val();
      const beforeData = change.before.val();
      const userId = context.params.userId;

      const alertsRef = admin.database().ref(`/users/${userId}/alerts`);
      const alertsSnap = await alertsRef.once("value");
      const alerts = alertsSnap.val();

      if (!alerts) {
        return null;
      }

      const payload = {
        notification: {
          title: "Smart Home Alert!",
          body: "",
        },
      };

      let message = "";
      let sendNotification = false;

      if (alerts.temp && afterData.temp > alerts.temp.max && beforeData.temp <= alerts.temp.max) {
        message += `High Temperature: ${afterData.temp}°C. `;
        sendNotification = true;
      }

      if (alerts.humidity && afterData.humidity > alerts.humidity.max && beforeData.humidity <= alerts.humidity.max) {
        message += `High Humidity: ${afterData.humidity}%. `;
        sendNotification = true;
      }

      const gasSnap = await admin.database().ref(`/users/${userId}/sensors/gas`).once("value");
      const gasData = gasSnap.val();

      if (alerts.gas && gasData.gas > alerts.gas.max) {
        message += `High Gas Levels Detected.`;
        sendNotification = true;
      }

      if (sendNotification) {
        payload.notification.body = message;
        const tokens = await getDeviceTokens(userId);
        if (tokens.length > 0) {
          await admin.messaging().sendToDevice(tokens, payload);
        }
      }

      return null;
    });

async function getDeviceTokens(userId) {
  const tokensSnap = await admin.firestore().collection("users").doc(userId).collection("tokens").get();
  const tokens = [];
  tokensSnap.forEach((doc) => {
    tokens.push(doc.id);
  });
  return tokens;
}

const functions = require('firebase-functions');
const admin = require('firebase-admin');
const { Storage } = require('@google-cloud/storage');
admin.initializeApp();
const db = admin.firestore();
const storage = new Storage();

// Callable function: generate signed URL after verifying order is paid and caller is buyer
exports.generateSignedUrl = functions.https.onCall(async (data, context) => {
  if (!context.auth) throw new functions.https.HttpsError('unauthenticated', 'Not signed in');
  const buyerId = context.auth.uid;
  const orderId = data.orderId;
  const filePath = data.filePath; // e.g., "files/12345_file.nc"
  if (!orderId || !filePath) throw new functions.https.HttpsError('invalid-argument', 'Missing orderId or filePath');
  const orderSnap = await db.collection('orders').doc(orderId).get();
  if (!orderSnap.exists) throw new functions.https.HttpsError('not-found', 'Order not found');
  const order = orderSnap.data();
  if (order.buyerId !== buyerId) throw new functions.https.HttpsError('permission-denied', 'Not the buyer');
  if (order.status !== 'PAID') throw new functions.https.HttpsError('failed-precondition', 'Payment not verified');

  const bucketName = admin.storage().bucket().name;
  const options = { version: 'v4', action: 'read', expires: Date.now() + 1000 * 60 * 60 * 24 }; // 24 hours
  try {
    const [url] = await storage.bucket(bucketName).file(filePath).getSignedUrl(options);
    await db.collection('orders').doc(orderId).update({ downloadUrl: url, downloadUrlExpiresAt: admin.firestore.Timestamp.fromMillis(Date.now() + 1000*60*60*24) });
    return { url };
  } catch (err) {
    console.error('Error generating signed URL', err);
    throw new functions.https.HttpsError('internal', 'Failed to generate signed URL');
  }
});

// Optional HTTP webhook handler (you can point payment provider here)
exports.paymentWebhook = functions.https.onRequest(async (req, res) => {
  try {
    const body = req.body;
    const orderId = body.order_id || body.orderId;
    const status = body.transaction_status || body.status;
    if (!orderId) return res.status(400).send('no order id');
    const orderRef = db.collection('orders').doc(orderId);
    const orderSnap = await orderRef.get();
    if (!orderSnap.exists) return res.status(404).send('order not found');

    if (status === 'settlement' || status === 'capture' || status === 'PAID') {
      await orderRef.update({ status: 'PAID', paidAt: admin.firestore.FieldValue.serverTimestamp(), rawWebhook: body });
      // send notification (buyer/seller token needs to be stored in users collection)
      const order = (await orderRef.get()).data();
      if (order) {
        const buyer = await db.collection('users').doc(order.buyerId).get();
        const seller = await db.collection('users').doc(order.sellerId).get();
        const tokens = [];
        if (buyer.exists && buyer.data().fcmToken) tokens.push(buyer.data().fcmToken);
        if (seller.exists && seller.data().fcmToken) tokens.push(seller.data().fcmToken);
        if (tokens.length) await admin.messaging().sendToDevice(tokens, { notification: { title: 'Payment received', body: `Order ${orderId} is paid.` } });
      }
    } else if (status === 'cancel' || status === 'deny' || status === 'expire') {
      await orderRef.update({ status: 'CANCELED', rawWebhook: body });
    } else {
      await orderRef.update({ rawWebhook: body });
    }
    res.sendStatus(200);
  } catch (err) {
    console.error(err);
    res.sendStatus(500);
  }
});

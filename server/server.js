const express = require('express');
const bodyParser = require('body-parser');
const admin = require('firebase-admin');
const midtransClient = require('midtrans-client');
admin.initializeApp();
const db = admin.firestore();
const app = express();
app.use(bodyParser.json());

const MIDTRANS_SERVER_KEY = process.env.MIDTRANS_SERVER_KEY || 'YOUR_SERVER_KEY';
const MIDTRANS_CLIENT_KEY = process.env.MIDTRANS_CLIENT_KEY || 'YOUR_CLIENT_KEY';
const isProduction = (process.env.NODE_ENV === 'production');
const coreApi = new midtransClient.CoreApi({ isProduction, serverKey: MIDTRANS_SERVER_KEY, clientKey: MIDTRANS_CLIENT_KEY });

// create transaction
app.post('/create-transaction', async (req, res) => {
  try {
    const { orderId, amount, productTitle } = req.body;
    if (!orderId || !amount) return res.status(400).json({ error: 'missing' });
    const parameter = {
      transaction_details: { order_id: orderId, gross_amount: parseFloat(amount) },
      item_details: [{ id: orderId, price: parseFloat(amount), quantity: 1, name: productTitle || 'CNC Program' }],
      credit_card: { secure: true }
    };
    const chargeResp = await coreApi.charge(parameter);
    return res.json(chargeResp);
  } catch (err) {
    console.error(err);
    res.status(500).json({ error: 'server error' });
  }
});

// webhook receiver
app.post('/payment-notify', async (req, res) => {
  try {
    const body = req.body;
    const orderId = body.order_id;
    const status = body.transaction_status;
    if (!orderId) return res.status(400).send('no order id');
    const orderRef = db.collection('orders').doc(orderId);
    const doc = await orderRef.get();
    if (!doc.exists) return res.status(404).send('order not found');
    if (status === 'settlement' || status === 'capture') {
      await orderRef.update({ status: 'PAID', paidAt: admin.firestore.FieldValue.serverTimestamp(), rawPayload: body });
    } else if (status === 'cancel' || status === 'deny' || status === 'expire') {
      await orderRef.update({ status: 'CANCELED', rawPayload: body });
    } else {
      await orderRef.update({ rawPayload: body });
    }
    res.sendStatus(200);
  } catch (err) {
    console.error(err);
    res.sendStatus(500);
  }
});

const PORT = process.env.PORT || 8080;
app.listen(PORT, () => console.log('Server running on', PORT));


const express = require('express');
const bodyParser = require('body-parser');
const cors = require('cors');
const admin = require('firebase-admin');
require('dotenv').config();

try {
  admin.initializeApp({
    storageBucket: process.env.FIREBASE_STORAGE_BUCKET || undefined
  });
} catch (e) {
  console.warn('Firebase admin initializeApp warning:', e.message || e);
}

const db = admin.firestore();

const app = express();
app.use(cors());
app.use(bodyParser.json());

app.get('/', (req, res) => {
  res.send({ ok: true, message: 'SpindleShare server (no-payment) running' });
});

// PRODUCTS
app.get('/products', async (req, res) => {
  try {
    const q = db.collection('products').orderBy('createdAt', 'desc');
    const snap = await q.get();
    const items = snap.docs.map(d => ({ id: d.id, ...d.data() }));
    res.json(items);
  } catch (err) {
    console.error(err);
    res.status(500).json({ error: 'failed' });
  }
});

app.get('/products/:id', async (req, res) => {
  try {
    const doc = await db.collection('products').doc(req.params.id).get();
    if (!doc.exists) return res.status(404).json({ error: 'not found' });
    res.json({ id: doc.id, ...doc.data() });
  } catch (err) {
    console.error(err);
    res.status(500).json({ error: 'failed' });
  }
});

app.post('/products', async (req, res) => {
  try {
    const data = req.body;
    data.createdAt = admin.firestore.FieldValue.serverTimestamp();
    const ref = await db.collection('products').add(data);
    res.json({ id: ref.id });
  } catch (err) {
    console.error(err);
    res.status(500).json({ error: 'failed' });
  }
});

// JOBS
app.post('/jobs', async (req, res) => {
  try {
    const data = req.body;
    data.status = data.status || 'OPEN';
    data.createdAt = admin.firestore.FieldValue.serverTimestamp();
    const ref = await db.collection('jobs').add(data);
    res.json({ id: ref.id });
  } catch (err) {
    console.error(err);
    res.status(500).json({ error: 'failed' });
  }
});

app.get('/jobs', async (req, res) => {
  try {
    const snap = await db.collection('jobs').orderBy('createdAt','desc').get();
    const items = snap.docs.map(d => ({ id: d.id, ...d.data() }));
    res.json(items);
  } catch (err) {
    console.error(err);
    res.status(500).json({ error: 'failed' });
  }
});

// ORDERS (no payment)
app.post('/orders', async (req, res) => {
  try {
    const data = req.body;
    data.status = data.status || 'PENDING';
    data.createdAt = admin.firestore.FieldValue.serverTimestamp();
    const ref = await db.collection('orders').add(data);
    res.json({ id: ref.id });
  } catch (err) {
    console.error(err);
    res.status(500).json({ error: 'failed' });
  }
});

app.get('/orders/:id', async (req, res) => {
  try {
    const doc = await db.collection('orders').doc(req.params.id).get();
    if (!doc.exists) return res.status(404).json({ error: 'not found' });
    res.json({ id: doc.id, ...doc.data() });
  } catch (err) {
    console.error(err);
    res.status(500).json({ error: 'failed' });
  }
});

// Generate signed URL for Firebase Storage file
app.post('/generate-signed-url', async (req, res) => {
  try {
    const { filePath, expiresSeconds } = req.body;
    if (!filePath) return res.status(400).json({ error: 'filePath required' });
    const bucket = admin.storage().bucket();
    const file = bucket.file(filePath);
    const expires = Date.now() + ((expiresSeconds || 86400) * 1000);
    const [url] = await file.getSignedUrl({ version: 'v4', action: 'read', expires });
    res.json({ url, expiresAt: new Date(expires).toISOString() });
  } catch (err) {
    console.error(err);
    res.status(500).json({ error: 'failed', detail: err.message || err });
  }
});

app.get('/health', (req, res) => res.send({ ok: true, time: new Date().toISOString() }));

const PORT = process.env.PORT || 3000;
app.listen(PORT, () => console.log(`Server running on port ${PORT}`));


SpindleShare Server (No Payment) - Deploy to Koyeb
=================================================

This server is a minimal backend for SpindleShare without payment integration.
It uses Firebase Admin SDK to read/write Firestore and generate signed URLs for storage files.

Prerequisites
-------------
- A Firebase project with Firestore and Storage enabled.
- A service account JSON with proper permissions (Firestore and Storage).
- For local testing set GOOGLE_APPLICATION_CREDENTIALS to path of the service account JSON.
- For production on Koyeb: add the service account JSON as a secret or configure environment accordingly.

How to run locally
------------------
1. npm install
2. export GOOGLE_APPLICATION_CREDENTIALS="/full/path/to/serviceAccountKey.json"
   (Windows PowerShell: $env:GOOGLE_APPLICATION_CREDENTIALS="C:\path\to\serviceAccountKey.json")
3. node server.js

Deploy to Koyeb
---------------
1. Push this server folder to a GitHub repository (e.g. spindleshare-server).
2. Sign up / login to https://app.koyeb.com using GitHub and create a new App:
   - New App -> Git Repository
   - Select your repo and branch (main)
   - Root directory: / (since this repo is server-only)
3. Build command: npm install
   Start command: node server.js
4. Add environment variables in Koyeb dashboard:
   - FIREBASE_STORAGE_BUCKET=your-project.appspot.com
   - Add service account JSON as a secret (check Koyeb docs). Alternatively, set GOOGLE_APPLICATION_CREDENTIALS and upload file via Koyeb secrets.
5. Deploy. Koyeb will give you a public URL like https://spindleshare-server.koyeb.app

Notes
-----
- For security, use platform secrets for service account JSON. Avoid storing raw JSON in env vars.
- This backend does not implement authentication enforcement; the Flutter client should use Firebase Authentication and enforce UID ownership on writes.

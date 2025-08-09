SpindleShare - Ready scaffold (payment, functions, server)
==========================================================
This scaffold contains:
  - Flutter client (lib/) with auth, marketplace, upload, product detail, orders, jobs, reviews, chat placeholders.
  - server/ Node/Express example to create Midtrans transaction and webhook.
  - functions/ Cloud Functions: generateSignedUrl (callable) and paymentWebhook.
  - firestore.rules & storage.rules
  - Instructions below show how to configure and deploy.

IMPORTANT:
- Replace placeholders: google-services.json (Android), MIDTRANS_SERVER_KEY, MIDTRANS_CLIENT_KEY.
- Do NOT run in production without securing keys, validating webhooks, and proper testing.

Quick Setup:
1. Unzip and open in VS Code.
2. Run `flutter create .` to generate platform folders if needed.
3. Place google-services.json into android/app/.
4. Install server deps: cd server && npm install
5. Start server locally: node server.js (or deploy to Cloud Run/Heroku)
6. Install functions deps: cd functions && npm install
7. Deploy functions: firebase deploy --only functions
8. Run Flutter: flutter pub get && flutter run

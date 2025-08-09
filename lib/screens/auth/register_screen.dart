import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({Key? key}) : super(key: key);
  @override State<RegisterScreen> createState() => _RegisterScreenState();
}
class _RegisterScreenState extends State<RegisterScreen> {
  final _email = TextEditingController();
  final _pass = TextEditingController();
  bool loading = false;
  Future<void> _saveToken(String uid) async {
    final token = await FirebaseMessaging.instance.getToken();
    if (token != null) await FirebaseFirestore.instance.collection('users').doc(uid).set({'fcmToken': token}, SetOptions(merge: true));
  }
  Future<void> _register() async {
    setState(() => loading = true);
    try {
      final cred = await FirebaseAuth.instance.createUserWithEmailAndPassword(email: _email.text.trim(), password: _pass.text.trim());
      await _saveToken(cred.user!.uid);
      Navigator.pop(context);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Register error: $e')));
    } finally { setState(() => loading = false); }
  }
  @override Widget build(BuildContext context) {
    return Scaffold(appBar: AppBar(title: const Text('Register')), body: Padding(padding: const EdgeInsets.all(16), child: Column(children: [
      TextField(controller: _email, decoration: const InputDecoration(labelText: 'Email')),
      TextField(controller: _pass, obscureText: true, decoration: const InputDecoration(labelText: 'Password')),
      const SizedBox(height: 12),
      ElevatedButton(onPressed: loading ? null : _register, child: loading ? const CircularProgressIndicator() : const Text('Register')),
    ])));
  }
}

import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'register_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({Key? key}) : super(key: key);
  @override State<LoginScreen> createState() => _LoginScreenState();
}
class _LoginScreenState extends State<LoginScreen> {
  final _email = TextEditingController();
  final _pass = TextEditingController();
  bool loading = false;
  Future<void> _saveToken(String uid) async {
    final token = await FirebaseMessaging.instance.getToken();
    if (token != null) {
      await FirebaseFirestore.instance.collection('users').doc(uid).set({'fcmToken': token}, SetOptions(merge: true));
    }
  }
  Future<void> _login() async {
    setState(() => loading = true);
    try {
      final cred = await FirebaseAuth.instance.signInWithEmailAndPassword(email: _email.text.trim(), password: _pass.text.trim());
      await _saveToken(cred.user!.uid);
      Navigator.pushReplacementNamed(context, '/market');
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Login error: $e')));
    } finally { setState(() => loading = false); }
  }
  @override Widget build(BuildContext context) {
    return Scaffold(appBar: AppBar(title: const Text('Login')), body: Padding(padding: const EdgeInsets.all(16), child: Column(children: [
      TextField(controller: _email, decoration: const InputDecoration(labelText: 'Email')),
      TextField(controller: _pass, obscureText: true, decoration: const InputDecoration(labelText: 'Password')),
      const SizedBox(height: 12),
      ElevatedButton(onPressed: loading ? null : _login, child: loading ? const CircularProgressIndicator() : const Text('Login')),
      TextButton(onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const RegisterScreen())), child: const Text('Register'))
    ])));
  }
}

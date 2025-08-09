import 'package:flutter/material.dart';
class PrivacyScreen extends StatelessWidget {
  const PrivacyScreen({Key? key}) : super(key: key);
  @override Widget build(BuildContext context) => Scaffold(appBar: AppBar(title: const Text('Privacy Policy')), body: const Padding(padding: EdgeInsets.all(16), child: Text('Insert Privacy Policy here.')));
}

import 'package:flutter/material.dart';
class TosScreen extends StatelessWidget {
  const TosScreen({Key? key}) : super(key: key);
  @override Widget build(BuildContext context) => Scaffold(appBar: AppBar(title: const Text('Terms of Service')), body: const Padding(padding: EdgeInsets.all(16), child: Text('Insert Terms of Service here.')));
}

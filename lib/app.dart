import 'package:flutter/material.dart';
import 'screens/auth/login_screen.dart';
import 'screens/marketplace/marketplace_screen.dart';
class SpindleShareApp extends StatelessWidget {
  const SpindleShareApp({Key? key}) : super(key: key);
  @override Widget build(BuildContext context) {
    return MaterialApp(
      title: 'SpindleShare',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: const LoginScreen(),
      routes: {'/market': (_) => const MarketplaceScreen()},
    );
  }
}

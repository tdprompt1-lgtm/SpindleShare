import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:http/http.dart' as http;
import 'package:cloud_functions/cloud_functions.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:intl/intl.dart';

class ProductDetailScreen extends StatefulWidget {
  final String productId;
  const ProductDetailScreen({Key? key, required this.productId}) : super(key: key);
  @override State<ProductDetailScreen> createState() => _ProductDetailScreenState();
}
class _ProductDetailScreenState extends State<ProductDetailScreen> {
  Map<String, dynamic>? data;
  bool loading = true;
  String? downloadUrl;
  @override void initState() { super.initState(); _load(); }
  Future<void> _load() async {
    final doc = await FirebaseFirestore.instance.collection('products').doc(widget.productId).get();
    setState(() { data = doc.data(); loading = false; });
  }
  String formatPrice(num price) => NumberFormat.currency(locale: 'id', symbol: 'Rp ', decimalDigits: 0).format(price);
  Future<void> _buy() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) { ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please login'))); return; }
    final orderRef = await FirebaseFirestore.instance.collection('orders').add({
      'productId': widget.productId,
      'buyerId': user.uid,
      'sellerId': data?['sellerId'] ?? '',
      'price': data?['price'] ?? 0,
      'status': 'PENDING',
      'createdAt': FieldValue.serverTimestamp()
    });
    final orderId = orderRef.id;
    // call payment server (set URL in server)
    final serverUrl = Uri.parse('https://your-payment-server.example.com/create-transaction');
    final resp = await http.post(serverUrl, body: {'orderId': orderId, 'amount': '${data?['price'] ?? 0}', 'productTitle': data?['title'] ?? ''});
    if (resp.statusCode == 200) {
      final body = resp.body;
      // naive attempt to extract a url
      final idx = body.indexOf('http');
      if (idx >= 0) {
        final url = body.substring(idx).split('"')[0].split('}')[0];
        if (await canLaunchUrl(Uri.parse(url))) await launchUrl(Uri.parse(url));
      }
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Order ${orderId} created. Complete payment.')));
      FirebaseFirestore.instance.collection('orders').doc(orderId).snapshots().listen((snap) async {
        if (!snap.exists) return;
        final o = snap.data()!;
        if (o['status'] == 'PAID' && downloadUrl == null) {
          try {
            final callable = FirebaseFunctions.instance.httpsCallable('generateSignedUrl');
            final result = await callable.call({'orderId': orderId, 'filePath': data?['filePath'] ?? data?['fileUrl'] ?? ''});
            setState(() => downloadUrl = result.data['url'] as String?);
          } catch (e) {
            if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error getting download url: $e')));
          }
        }
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Payment server error')));
    }
  }
  Future<void> _download() async {
    if (downloadUrl == null) { ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('No download yet'))); return; }
    if (await canLaunchUrl(Uri.parse(downloadUrl!))) await launchUrl(Uri.parse(downloadUrl!));
  }
  @override Widget build(BuildContext context) {
    if (loading) return const Scaffold(body: Center(child: CircularProgressIndicator()));
    if (data == null) return const Scaffold(body: Center(child: Text('Not found')));
    return Scaffold(appBar: AppBar(title: Text(data?['title'] ?? '')), body: SingleChildScrollView(padding: const EdgeInsets.all(16), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      if (data?['thumbnailUrl'] != null && data?['thumbnailUrl'] != '') Image.network(data!['thumbnailUrl'], height: 200, fit: BoxFit.cover),
      const SizedBox(height: 12),
      Text(data?['title'] ?? '', style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
      const SizedBox(height: 8),
      Text(formatPrice(data?['price'] ?? 0), style: const TextStyle(color: Colors.green, fontSize: 18)),
      const SizedBox(height: 12),
      Text('Machine: ${data?['machineType'] ?? '-'}'),
      const SizedBox(height: 12),
      Text(data?['description'] ?? ''),
      const SizedBox(height: 20),
      ElevatedButton.icon(onPressed: _buy, icon: const Icon(Icons.shopping_cart), label: const Text('Buy')),
      const SizedBox(height: 8),
      if (downloadUrl != null) ElevatedButton.icon(onPressed: _download, icon: const Icon(Icons.download), label: const Text('Download')),
    ])));
  }
}

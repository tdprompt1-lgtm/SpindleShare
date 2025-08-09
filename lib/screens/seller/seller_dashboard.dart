import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
class SellerDashboard extends StatelessWidget {
  const SellerDashboard({Key? key}) : super(key: key);
  @override Widget build(BuildContext context) {
    final uid = FirebaseAuth.instance.currentUser?.uid ?? '';
    return Scaffold(appBar: AppBar(title: const Text('Seller Dashboard')), body: Column(children: [
      Expanded(child: StreamBuilder<QuerySnapshot>(stream: FirebaseFirestore.instance.collection('orders').where('sellerId', isEqualTo: uid).snapshots(), builder: (c,s){ if (!s.hasData) return const Center(child: CircularProgressIndicator()); return ListView(children: s.data!.docs.map((d){ final m = d.data() as Map<String,dynamic>; return ListTile(title: Text('Order: ${d.id}'), subtitle: Text('Status: ${m['status']} Price: ${m['price']}')); }).toList()); })),
      Expanded(child: StreamBuilder<QuerySnapshot>(stream: FirebaseFirestore.instance.collection('jobs').where('status', isEqualTo: 'OPEN').snapshots(), builder: (c,s){ if (!s.hasData) return const SizedBox(); return ListView(children: s.data!.docs.map((d){ final m = d.data() as Map<String,dynamic>; return ListTile(title: Text(m['description'] ?? ''), subtitle: Text('User: ${m['userId']}'), trailing: ElevatedButton(onPressed: () async { await FirebaseFirestore.instance.collection('jobs').doc(d.id).update({'status':'OFFERED','sellerId':uid}); }, child: const Text('Offer'))); }).toList()); })),
    ]));
  }
}

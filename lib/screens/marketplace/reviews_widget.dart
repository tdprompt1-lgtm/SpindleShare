import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
class ReviewsWidget extends StatelessWidget {
  final String productId;
  const ReviewsWidget({Key? key, required this.productId}) : super(key: key);
  Future<void> _add(BuildContext c) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) { ScaffoldMessenger.of(c).showSnackBar(const SnackBar(content: Text('Login required'))); return; }
    final ctl = TextEditingController();
    await showDialog(context: c, builder: (_) => AlertDialog(title: const Text('Review'), content: TextField(controller: ctl), actions: [TextButton(onPressed: () => Navigator.pop(c), child: const Text('Cancel')), TextButton(onPressed: () async { await FirebaseFirestore.instance.collection('reviews').add({'productId': productId, 'userId': user.uid, 'content': ctl.text, 'rating': 5, 'createdAt': FieldValue.serverTimestamp()}); Navigator.pop(c); }, child: const Text('Submit'))]));
  }
  @override Widget build(BuildContext context) {
    return Column(children: [Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [const Text('Reviews'), TextButton(onPressed: () => _add(context), child: const Text('Add'))]), StreamBuilder<QuerySnapshot>(stream: FirebaseFirestore.instance.collection('reviews').where('productId', isEqualTo: productId).snapshots(), builder: (c,s){ if (!s.hasData) return const SizedBox(); return Column(children: s.data!.docs.map((d){ final m = d.data() as Map<String,dynamic>; return ListTile(title: Text(m['content'] ?? ''), subtitle: Text('Rating: ${m['rating'] ?? 0}')); }).toList()); })]);
  }
}

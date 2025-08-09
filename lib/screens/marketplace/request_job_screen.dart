import 'dart:io';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class RequestJobScreen extends StatefulWidget {
  final String? productId;
  const RequestJobScreen({Key? key, this.productId}) : super(key: key);
  @override State<RequestJobScreen> createState() => _RequestJobScreenState();
}
class _RequestJobScreenState extends State<RequestJobScreen> {
  final _desc = TextEditingController();
  File? attachment;
  bool sending = false;
  Future<void> pickAttachment() async {
    final r = await FilePicker.platform.pickFiles(type: FileType.any);
    if (r != null && r.files.single.path != null) attachment = File(r.files.single.path!);
  }
  Future<void> _send() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) { ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Login required'))); return; }
    setState(() => sending = true);
    try {
      // For simplicity we are not uploading attachment in this scaffold; just save metadata
      await FirebaseFirestore.instance.collection('jobs').add({
        'productId': widget.productId ?? '',
        'userId': user.uid,
        'description': _desc.text,
        'status': 'OPEN',
        'createdAt': FieldValue.serverTimestamp(),
      });
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Job request submitted')));
      Navigator.pop(context);
    } finally { setState(() => sending = false); }
  }
  @override Widget build(BuildContext context) {
    return Scaffold(appBar: AppBar(title: const Text('Request Job')), body: Padding(padding: const EdgeInsets.all(12), child: Column(children: [
      TextField(controller: _desc, decoration: const InputDecoration(labelText: 'Describe what you need')),
      const SizedBox(height: 8),
      ElevatedButton(onPressed: pickAttachment, child: const Text('Attach file (optional)')),
      const SizedBox(height: 12),
      ElevatedButton(onPressed: sending ? null : _send, child: sending ? const CircularProgressIndicator() : const Text('Submit request')),
    ])));
  }
}

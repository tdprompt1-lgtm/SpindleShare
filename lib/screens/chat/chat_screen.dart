import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
class ChatScreen extends StatefulWidget {
  final String chatId;
  const ChatScreen({Key? key, required this.chatId}) : super(key: key);
  @override State<ChatScreen> createState() => _ChatScreenState();
}
class _ChatScreenState extends State<ChatScreen> {
  final _ctl = TextEditingController();
  @override Widget build(BuildContext context) {
    final uid = FirebaseAuth.instance.currentUser?.uid ?? 'anon';
    return Scaffold(appBar: AppBar(title: const Text('Chat')), body: Column(children: [
      Expanded(child: StreamBuilder<QuerySnapshot>(stream: FirebaseFirestore.instance.collection('chats').doc(widget.chatId).collection('messages').orderBy('createdAt').snapshots(), builder: (c,s){ if (!s.hasData) return const SizedBox(); return ListView(children: s.data!.docs.map((d){ final m = d.data() as Map<String,dynamic>; return ListTile(title: Text(m['text'] ?? ''), subtitle: Text(m['senderId'] ?? '')); }).toList()); })),
      Row(children: [Expanded(child: TextField(controller: _ctl)), IconButton(icon: const Icon(Icons.send), onPressed: () async { final uid = FirebaseAuth.instance.currentUser?.uid ?? 'anon'; await FirebaseFirestore.instance.collection('chats').doc(widget.chatId).collection('messages').add({'text': _ctl.text, 'senderId': uid, 'createdAt': FieldValue.serverTimestamp()}); _ctl.clear(); })])
    ]));
  }
}

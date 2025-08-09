import 'dart:io';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class UploadProductScreen extends StatefulWidget {
  const UploadProductScreen({Key? key}) : super(key: key);
  @override State<UploadProductScreen> createState() => _UploadProductScreenState();
}
class _UploadProductScreenState extends State<UploadProductScreen> {
  final _title = TextEditingController();
  final _desc = TextEditingController();
  final _price = TextEditingController();
  final _machine = TextEditingController();
  File? cncFile;
  File? thumbnail;
  bool uploading = false;
  Future<void> pickCnc() async {
    final r = await FilePicker.platform.pickFiles(type: FileType.custom, allowedExtensions: ['nc','gcode','tap']);
    if (r != null && r.files.single.path != null) cncFile = File(r.files.single.path!);
  }
  Future<void> pickThumb() async {
    final r = await FilePicker.platform.pickFiles(type: FileType.image);
    if (r != null && r.files.single.path != null) thumbnail = File(r.files.single.path!);
  }
  Future<String> uploadFile(File file, String path) async {
    final ref = FirebaseStorage.instance.ref(path);
    final task = await ref.putFile(file);
    return await task.ref.getDownloadURL();
  }
  Future<void> save() async {
    if (cncFile == null || _title.text.isEmpty) { ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Complete fields'))); return; }
    setState(() => uploading = true);
    try {
      final uid = FirebaseAuth.instance.currentUser?.uid;
      if (uid == null) throw 'Not logged in';
      final cncPath = 'files/${DateTime.now().millisecondsSinceEpoch}_${cncFile!.path.split('/').last}';
      final fileUrl = await uploadFile(cncFile!, cncPath);
      String thumbUrl = '';
      if (thumbnail != null) thumbUrl = await uploadFile(thumbnail!, 'thumbnails/${DateTime.now().millisecondsSinceEpoch}_${thumbnail!.path.split('/').last}');
      await FirebaseFirestore.instance.collection('products').add({
        'title': _title.text.trim(),
        'description': _desc.text.trim(),
        'price': double.tryParse(_price.text.trim()) ?? 0,
        'sellerId': uid,
        'fileUrl': fileUrl,
        'filePath': cncPath,
        'thumbnailUrl': thumbUrl,
        'machineType': _machine.text.trim(),
        'formats': [cncFile!.path.split('.').last.toLowerCase()],
        'createdAt': FieldValue.serverTimestamp()
      });
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Product uploaded')));
      Navigator.pop(context);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
    } finally { setState(() => uploading = false); }
  }
  @override Widget build(BuildContext context) {
    return Scaffold(appBar: AppBar(title: const Text('Upload Product')), body: Padding(padding: const EdgeInsets.all(16), child: ListView(children: [
      TextField(controller: _title, decoration: const InputDecoration(labelText: 'Title')),
      TextField(controller: _desc, decoration: const InputDecoration(labelText: 'Description')),
      TextField(controller: _price, decoration: const InputDecoration(labelText: 'Price'), keyboardType: TextInputType.number),
      TextField(controller: _machine, decoration: const InputDecoration(labelText: 'Machine Type')),
      const SizedBox(height: 8),
      ElevatedButton(onPressed: pickCnc, child: Text(cncFile != null ? 'Selected: ${cncFile!.path.split('/').last}' : 'Pick CNC File')),
      ElevatedButton(onPressed: pickThumb, child: Text(thumbnail != null ? 'Selected: ${thumbnail!.path.split('/').last}' : 'Pick Thumbnail (optional)')),
      const SizedBox(height: 12),
      ElevatedButton(onPressed: uploading ? null : save, child: uploading ? const CircularProgressIndicator() : const Text('Upload'))
    ])));
  }
}

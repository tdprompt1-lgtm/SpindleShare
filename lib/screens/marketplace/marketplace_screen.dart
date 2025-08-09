import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'product_detail_screen.dart';
import 'package:intl/intl.dart';
import '../seller/upload_product_screen.dart';

class MarketplaceScreen extends StatefulWidget {
  const MarketplaceScreen({Key? key}) : super(key: key);
  @override State<MarketplaceScreen> createState() => _MarketplaceScreenState();
}
class _MarketplaceScreenState extends State<MarketplaceScreen> {
  final _search = TextEditingController();
  String? filterMachine;
  Stream<QuerySnapshot> get stream {
    Query q = FirebaseFirestore.instance.collection('products').orderBy('createdAt', descending: true);
    if (filterMachine != null && filterMachine != 'all') q = q.where('machineType', isEqualTo: filterMachine);
    return q.snapshots();
  }
  String formatPrice(num price) => NumberFormat.currency(locale: 'id', symbol: 'Rp ', decimalDigits: 0).format(price);
  Future<void> _doSearch() async {
    final q = _search.text.trim();
    if (q.isEmpty) return;
    final snap = await FirebaseFirestore.instance.collection('products').where('title', isGreaterThanOrEqualTo: q).where('title', isLessThanOrEqualTo: q + '\uf8ff').get();
    Navigator.push(context, MaterialPageRoute(builder: (_) => SearchResultsScreen(results: snap.docs)));
  }
  @override Widget build(BuildContext context) {
    return Scaffold(appBar: AppBar(title: const Text('Marketplace')), floatingActionButton: FloatingActionButton(
      onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const UploadProductScreen())),
      child: const Icon(Icons.upload_file),
    ), body: Column(children: [
      Padding(padding: const EdgeInsets.all(8), child: Row(children: [
        Expanded(child: TextField(controller: _search, decoration: const InputDecoration(hintText: 'Search title...'))),
        IconButton(onPressed: _doSearch, icon: const Icon(Icons.search)),
        PopupMenuButton<String>(onSelected: (v) { setState(() { filterMachine = v; }); }, itemBuilder: (_) => [
          const PopupMenuItem(value: 'all', child: Text('All')),
          const PopupMenuItem(value: 'milling', child: Text('Milling')),
          const PopupMenuItem(value: 'turning', child: Text('Turning')),
          const PopupMenuItem(value: 'plasma', child: Text('Plasma')),
        ])
      ])),
      Expanded(child: StreamBuilder<QuerySnapshot>(stream: stream, builder: (context, snap) {
        if (snap.hasError) return const Center(child: Text('Error'));
        if (snap.connectionState == ConnectionState.waiting) return const Center(child: CircularProgressIndicator());
        final docs = snap.data!.docs;
        if (docs.isEmpty) return const Center(child: Text('No products'));
        return ListView.builder(itemCount: docs.length, itemBuilder: (c, i) {
          final d = docs[i].data() as Map<String, dynamic>;
          return ListTile(leading: d['thumbnailUrl'] != null && d['thumbnailUrl'] != '' ? Image.network(d['thumbnailUrl'], width: 56, height: 56, fit: BoxFit.cover) : const Icon(Icons.precision_manufacturing, size: 40), title: Text(d['title'] ?? ''), subtitle: Text('${formatPrice(d['price'] ?? 0)} • ${d['machineType'] ?? '-'}'), onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => ProductDetailScreen(productId: docs[i].id))), );
        });
      }))
    ]));
  }
}

class SearchResultsScreen extends StatelessWidget {
  final List<QueryDocumentSnapshot> results;
  const SearchResultsScreen({Key? key, required this.results}) : super(key: key);
  @override Widget build(BuildContext context) {
    return Scaffold(appBar: AppBar(title: const Text('Search Results')), body: ListView.builder(itemCount: results.length, itemBuilder: (c, i) {
      final d = results[i].data() as Map<String, dynamic>;
      return ListTile(title: Text(d['title'] ?? ''), subtitle: Text(d['machineType'] ?? '-'));
    }));
  }
}

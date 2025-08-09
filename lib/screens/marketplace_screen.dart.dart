import 'package:flutter/material.dart';
import '../services/firebase_service.dart';
import '../models/product.dart';
import '../widgets/product_card.dart';
import 'product_detail_screen.dart';

class MarketplaceScreen extends StatefulWidget {
  const MarketplaceScreen({Key? key}) : super(key: key);

  @override
  State<MarketplaceScreen> createState() => _MarketplaceScreenState();
}

class _MarketplaceScreenState extends State<MarketplaceScreen> {
  final FirebaseService _service = FirebaseService();
  String? selectedMachineType;
  final TextEditingController _searchCtrl = TextEditingController();
  Stream<List<Product>>? _productStream;

  @override
  void initState() {
    super.initState();
    _productStream = _service.streamProducts(limit: 30);
  }

  void _applyFilter() {
    setState(() {
      _productStream = _service.streamProducts(machineType: selectedMachineType, limit: 30);
    });
  }

  Future<void> _doSearch() async {
    final q = _searchCtrl.text.trim();
    if (q.isEmpty) {
      setState(() {
        _productStream = _service.streamProducts(machineType: selectedMachineType, limit: 30);
      });
      return;
    }
    // simple search fetch (non-stream)
    final results = await _service.searchProductsByTitlePrefix(q, limit: 50);
    setState(() {
      _productStream = Stream.value(results);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('SpindleShare Marketplace'),
      ),
      body: Column(
        children: [
          _buildSearchAndFilter(),
          Expanded(
            child: StreamBuilder<List<Product>>(
              stream: _productStream,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                }
                final products = snapshot.data ?? [];
                if (products.isEmpty) {
                  return const Center(child: Text('Tidak ada produk.'));
                }
                return ListView.builder(
                  itemCount: products.length,
                  itemBuilder: (context, i) {
                    final p = products[i];
                    return ProductCard(
                      product: p,
                      onTap: () {
                        Navigator.of(context).push(MaterialPageRoute(
                          builder: (_) => ProductDetailScreen(productId: p.id),
                        ));
                      },
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchAndFilter() {
    return Padding(
      padding: const EdgeInsets.all(12.0),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _searchCtrl,
                  decoration: InputDecoration(
                    hintText: 'Cari judul produk (prefix search)...',
                    suffixIcon: IconButton(
                      icon: const Icon(Icons.search),
                      onPressed: _doSearch,
                    ),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                  onSubmitted: (_) => _doSearch(),
                ),
              ),
              const SizedBox(width: 8),
              PopupMenuButton<String>(
                icon: const Icon(Icons.filter_list),
                onSelected: (value) {
                  setState(() {
                    if (value == 'all') selectedMachineType = null;
                    else selectedMachineType = value;
                    _applyFilter();
                  });
                },
                itemBuilder: (_) => [
                  const PopupMenuItem(value: 'all', child: Text('Semua mesin')),
                  const PopupMenuItem(value: 'milling', child: Text('Milling')),
                  const PopupMenuItem(value: 'turning', child: Text('Turning')),
                  const PopupMenuItem(value: 'plasma', child: Text('Plasma')),
                ],
              )
            ],
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }
}

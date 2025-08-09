import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../services/firebase_service.dart';
import '../models/product.dart';
import 'package:intl/intl.dart';

class ProductDetailScreen extends StatefulWidget {
  final String productId;
  const ProductDetailScreen({Key? key, required this.productId}) : super(key: key);

  @override
  State<ProductDetailScreen> createState() => _ProductDetailScreenState();
}

class _ProductDetailScreenState extends State<ProductDetailScreen> {
  final FirebaseService _service = FirebaseService();
  Product? _product;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    final p = await _service.getProductById(widget.productId);
    setState(() {
      _product = p;
      _loading = false;
    });
  }

  String _formatPrice(double price) {
    final f = NumberFormat.currency(locale: 'id_ID', symbol: 'Rp ', decimalDigits: 0);
    return f.format(price);
  }

  void _onBuyPressed() {
    // Placeholder: arahkan ke flow pembayaran / cart
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Implement payment flow di sini (Midtrans/Xendit/Stripe).')),
    );
  }

  void _onRequestJobPressed() {
    // Placeholder: arahkan ke screen request job
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Implement request job flow (form upload gambar).')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_product?.title ?? 'Loading...'),
      ),
      body: _loading ? const Center(child: CircularProgressIndicator()) : _product == null
          ? const Center(child: Text('Produk tidak ditemukan'))
          : SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (_product!.thumbnailUrl.isNotEmpty)
                      CachedNetworkImage(
                        imageUrl: _product!.thumbnailUrl,
                        width: double.infinity,
                        height: 220,
                        fit: BoxFit.cover,
                      )
                    else
                      Container(
                        width: double.infinity,
                        height: 220,
                        color: Colors.grey.shade200,
                        child: const Icon(Icons.image, size: 80),
                      ),
                    const SizedBox(height: 12),
                    Text(_product!.title, style: Theme.of(context).textTheme.headline6),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        Chip(label: Text(_product!.machineType.isNotEmpty ? _product!.machineType : 'General')),
                        const SizedBox(width: 8),
                        Text(_formatPrice(_product!.price), style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Text('Deskripsi', style: Theme.of(context).textTheme.subtitle1),
                    const SizedBox(height: 6),
                    Text(_product!.description),
                    const SizedBox(height: 12),
                    Text('Format', style: Theme.of(context).textTheme.subtitle1),
                    const SizedBox(height: 6),
                    Wrap(
                      spacing: 8,
                      children: _product!.formats.map((f) => Chip(label: Text(f))).toList(),
                    ),
                    const SizedBox(height: 20),
                    Row(
                      children: [
                        Expanded(
                          child: ElevatedButton.icon(
                            onPressed: _onBuyPressed,
                            icon: const Icon(Icons.shopping_cart),
                            label: const Text('Beli'),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: OutlinedButton.icon(
                            onPressed: _onRequestJobPressed,
                            icon: const Icon(Icons.work_outline),
                            label: const Text('Request Job'),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    Text('Info tambahan', style: Theme.of(context).textTheme.subtitle2),
                    const SizedBox(height: 6),
                    Text('ID Produk: ${_product!.id}'),
                    Text('Seller ID: ${_product!.sellerId}'),
                    Text('Diupload: ${DateFormat.yMMMd().format(_product!.createdAt.toDate())}'),
                  ],
                ),
              ),
            ),
    );
  }
}

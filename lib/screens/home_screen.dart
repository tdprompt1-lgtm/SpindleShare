import 'package:flutter/material.dart';
import '../models/product.dart';
import '../services/firebase_service.dart';
import 'product_detail_screen.dart';
import '../widgets/product_card.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final svc = FirebaseService();

    return Scaffold(
      appBar: AppBar(title: const Text('Marketplace CNC Files')),
      body: StreamBuilder<List<Product>>(
        stream: svc.productsStream(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('Belum ada produk'));
          }
          final products = snapshot.data!;
          return GridView.builder(
            padding: const EdgeInsets.all(8),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              childAspectRatio: 0.75,
              crossAxisSpacing: 8,
              mainAxisSpacing: 8,
            ),
            itemCount: products.length,
            itemBuilder: (context, index) {
              return ProductCard(
                product: products[index],
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => ProductDetailScreen(product: products[index]),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
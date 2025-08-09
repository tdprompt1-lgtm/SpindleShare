import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../models/product.dart';

class ProductCard extends StatelessWidget {
  final Product product;
  final VoidCallback onTap;

  const ProductCard({Key? key, required this.product, required this.onTap}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Card(
        elevation: 2,
        margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              _buildThumbnail(),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(product.title, style: Theme.of(context).textTheme.subtitle1),
                    const SizedBox(height: 6),
                    Text(
                      product.description,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Chip(label: Text(product.machineType.isNotEmpty ? product.machineType : 'General')),
                        const SizedBox(width: 8),
                        Text('Rp ${product.price.toStringAsFixed(0)}', style: const TextStyle(fontWeight: FontWeight.bold)),
                      ],
                    )
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildThumbnail() {
    if ((product.thumbnailUrl).isEmpty) {
      return Container(
        width: 88,
        height: 88,
        color: Colors.grey.shade200,
        child: const Icon(Icons.code, size: 36),
      );
    }
    return CachedNetworkImage(
      imageUrl: product.thumbnailUrl,
      width: 88,
      height: 88,
      fit: BoxFit.cover,
      placeholder: (c, s) => Container(
        width: 88,
        height: 88,
        color: Colors.grey.shade200,
      ),
      errorWidget: (c, s, e) => Container(
        width: 88,
        height: 88,
        color: Colors.grey.shade200,
        child: const Icon(Icons.broken_image),
      ),
    );
  }
}

import 'package:cloud_firestore/cloud_firestore.dart';

class Product {
  final String id;
  final String title;
  final String description;
  final double price;
  final String sellerId;
  final String fileUrl; // URL ke file .nc/.gcode (protected)
  final String thumbnailUrl; // image preview (opsional)
  final String machineType; // milling, turning, plasma, etc.
  final List<String> formats; // ["nc","gcode"]
  final Timestamp createdAt;

  Product({
    required this.id,
    required this.title,
    required this.description,
    required this.price,
    required this.sellerId,
    required this.fileUrl,
    required this.thumbnailUrl,
    required this.machineType,
    required this.formats,
    required this.createdAt,
  });

  factory Product.fromDoc(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return Product(
      id: doc.id,
      title: data['title'] ?? '',
      description: data['description'] ?? '',
      price: (data['price'] ?? 0).toDouble(),
      sellerId: data['sellerId'] ?? '',
      fileUrl: data['fileUrl'] ?? '',
      thumbnailUrl: data['thumbnailUrl'] ?? '',
      machineType: data['machineType'] ?? '',
      formats: List<String>.from(data['formats'] ?? []),
      createdAt: data['createdAt'] ?? Timestamp.now(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'description': description,
      'price': price,
      'sellerId': sellerId,
      'fileUrl': fileUrl,
      'thumbnailUrl': thumbnailUrl,
      'machineType': machineType,
      'formats': formats,
      'createdAt': createdAt,
    };
  }
}

import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/product.dart';

class FirebaseService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final CollectionReference _productsRef = FirebaseFirestore.instance.collection('products');

  Stream<List<Product>> streamProducts({String? machineType, int limit = 20}) {
    Query q = _productsRef.orderBy('createdAt', descending: true).limit(limit);
    if (machineType != null && machineType.isNotEmpty) {
      q = q.where('machineType', isEqualTo: machineType);
    }
    return q.snapshots().map((snap) => snap.docs.map((d) => Product.fromDoc(d)).toList());
  }

  Future<List<Product>> searchProductsByTitlePrefix(String prefix, {int limit = 20}) async {
    final end = prefix + '\uf8ff';
    final query = _productsRef.orderBy('title').startAt([prefix]).endAt([end]).limit(limit);
    final snap = await query.get();
    return snap.docs.map((d) => Product.fromDoc(d)).toList();
  }

  Future<List<Product>> fetchProductsPage({DocumentSnapshot? lastDoc, int pageSize = 20}) async {
    Query q = _productsRef.orderBy('createdAt', descending: true).limit(pageSize);
    if (lastDoc != null) q = q.startAfterDocument(lastDoc);
    final snap = await q.get();
    return snap.docs.map((d) => Product.fromDoc(d)).toList();
  }

  Future<Product?> getProductById(String id) async {
    final doc = await _productsRef.doc(id).get();
    if (!doc.exists) return null;
    return Product.fromDoc(doc);
  }

  Future<void> addProduct(Map<String, dynamic> data) async {
    await _productsRef.add(data);
  }
}

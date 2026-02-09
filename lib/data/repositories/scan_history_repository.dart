import 'package:hive_flutter/hive_flutter.dart';
import 'package:flutter/foundation.dart';
import '../models/product.dart';

/// Repository for managing scan history in Hive
class ScanHistoryRepository {
  static const String _boxName = 'scan_history';

  Box<Product>? _box;

  /// Initialize the repository and open the Hive box
  Future<void> init() async {
    if (!Hive.isBoxOpen(_boxName)) {
      _box = await Hive.openBox<Product>(_boxName);
    } else {
      _box = Hive.box<Product>(_boxName);
    }
  }

  /// Get all scanned products, sorted by date (newest first)
  List<Product> getAllProducts() {
    if (_box == null) return [];
    final products = _box!.values.toList();
    products.sort((a, b) => b.scanDate.compareTo(a.scanDate));
    return products;
  }

  /// Get a product by ID
  Product? getProduct(String id) {
    if (_box == null) return null;
    try {
      return _box!.values.firstWhere((p) => p.id == id);
    } catch (e) {
      return null;
    }
  }

  /// Find a product by matching name and brand (case insensitive)
  Product? findDuplicate(String name, String brand) {
    if (_box == null) return null;
    try {
      return _box!.values.firstWhere(
        (p) =>
            p.name.toLowerCase().trim() == name.toLowerCase().trim() &&
            p.brand.toLowerCase().trim() == brand.toLowerCase().trim(),
      );
    } catch (_) {
      return null;
    }
  }

  /// Save a new product scan
  Future<void> saveProduct(Product product) async {
    await _box?.put(product.id, product);
    await _box?.flush();
  }

  /// Delete a product from history
  Future<void> deleteProduct(String id) async {
    await _box?.delete(id);
    await _box?.flush();
  }

  /// Clear all scan history
  Future<void> clearHistory() async {
    await _box?.clear();
  }

  /// Get products count
  int get productCount => _box?.length ?? 0;

  /// Get listenable for reactive UI updates
  ValueListenable<Box<Product>>? getListenable() {
    return _box?.listenable();
  }

  /// Stream of products for reactive updates
  Stream<BoxEvent> watchProducts() {
    return _box?.watch() ?? const Stream.empty();
  }
}

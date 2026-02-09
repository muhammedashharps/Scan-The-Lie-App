import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../../core/theme/app_colors.dart';
import '../../data/models/product.dart';
import '../../data/repositories/scan_history_repository.dart';
import 'package:intl/intl.dart';
import 'dart:io';

class HistoryScreen extends StatefulWidget {
  final ScanHistoryRepository repository;
  final Function(Product) onProductSelected;

  const HistoryScreen({
    super.key,
    required this.repository,
    required this.onProductSelected,
  });

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  final TextEditingController _searchController = TextEditingController();
  List<Product> _allProducts = [];
  List<Product> _filteredProducts = [];

  @override
  void initState() {
    super.initState();
    _refresh();
    _searchController.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _refresh() {
    setState(() {
      _allProducts = widget.repository.getAllProducts();
      _onSearchChanged(); // Re-filter
    });
  }

  void _onSearchChanged() {
    final query = _searchController.text.toLowerCase().trim();
    if (query.isEmpty) {
      _filteredProducts = List.from(_allProducts);
    } else {
      _filteredProducts = _allProducts.where((p) {
        return p.name.toLowerCase().contains(query) ||
            p.brand.toLowerCase().contains(query);
      }).toList();
    }
    // _filteredProducts is already updated, setState called in listener callback?
    // No, listener is called outside build often. setState needed.
    // However, if called from _refresh (which is in setState), it's fine.
    // If called from text listener, need setState.
  }

  Future<void> _deleteProduct(String id) async {
    await widget.repository.deleteProduct(id);
    _refresh();
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Scan deleted')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    // Only setState on listener change
    return Scaffold(
      backgroundColor: AppColors.offWhite,
      body: SafeArea(
        child: Column(
          children: [
            // Search Bar
            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('HISTORY',
                      style:
                          TextStyle(fontSize: 24, fontWeight: FontWeight.w800)),
                  const SizedBox(height: 16),
                  TextField(
                    controller: _searchController,
                    onChanged: (v) => setState(() => _onSearchChanged()),
                    decoration: InputDecoration(
                      hintText: 'Search products...',
                      prefixIcon:
                          const Icon(Icons.search, color: AppColors.gray),
                      filled: true,
                      fillColor: AppColors.white,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                          vertical: 0, horizontal: 16),
                    ),
                  ),
                ],
              ),
            ),

            // List
            Expanded(
              child: ValueListenableBuilder<Box<Product>>(
                valueListenable: widget.repository.getListenable()!,
                builder: (context, box, _) {
                  final allProducts = widget.repository.getAllProducts();
                  // Update local state for search reference
                  _allProducts = allProducts;

                  // Filter based on current query
                  final query = _searchController.text.toLowerCase().trim();
                  if (query.isEmpty) {
                    _filteredProducts = List.from(allProducts);
                  } else {
                    _filteredProducts = allProducts.where((p) {
                      return p.name.toLowerCase().contains(query) ||
                          p.brand.toLowerCase().contains(query);
                    }).toList();
                  }

                  return _filteredProducts.isEmpty
                      ? Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.history,
                                  size: 64,
                                  color: AppColors.gray.withOpacity(0.5)),
                              const SizedBox(height: 16),
                              Text(
                                allProducts.isEmpty
                                    ? 'No scans yet'
                                    : 'No products found',
                                style: const TextStyle(
                                    color: AppColors.gray, fontSize: 16),
                              ),
                            ],
                          ),
                        )
                      : ListView.builder(
                          padding: const EdgeInsets.symmetric(horizontal: 20),
                          itemCount: _filteredProducts.length,
                          itemBuilder: (context, index) {
                            final product = _filteredProducts[index];
                            return _buildHistoryItem(product);
                          },
                        );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHistoryItem(Product product) {
    return Dismissible(
      key: Key(product.id),
      direction: DismissDirection.endToStart,
      background: Container(
        margin: const EdgeInsets.only(bottom: 16),
        decoration: BoxDecoration(
          color: Colors.red,
          borderRadius: BorderRadius.circular(16),
        ),
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 24),
        child: const Icon(Icons.delete, color: Colors.white),
      ),
      onDismissed: (direction) {
        _deleteProduct(product.id);
      },
      child: GestureDetector(
        onTap: () => widget.onProductSelected(product),
        child: Container(
          margin: const EdgeInsets.only(bottom: 16),
          decoration: BoxDecoration(
            color: AppColors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Row(
            children: [
              ClipRRect(
                borderRadius:
                    const BorderRadius.horizontal(left: Radius.circular(16)),
                child: SizedBox(
                  width: 100,
                  height: 100,
                  child:
                      product.imagePath != null && product.imagePath!.isNotEmpty
                          ? Image.file(
                              File(product.imagePath!),
                              fit: BoxFit.cover,
                              cacheWidth: 300, // Optimize memory usage
                              errorBuilder: (_, __, ___) => Container(
                                color: AppColors.lightGray,
                                child: const Icon(Icons.broken_image,
                                    color: AppColors.gray),
                              ),
                            )
                          : Container(
                              color: AppColors.lightGray,
                              child: const Icon(Icons.image_not_supported,
                                  color: AppColors.gray),
                            ),
                ),
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        product.name,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        product.brand,
                        style: const TextStyle(
                          color: AppColors.gray,
                          fontSize: 14,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          _buildScoreBadge(product.healthScore),
                          const SizedBox(width: 8),
                          Text(
                            DateFormat('MMM d').format(product.scanDate),
                            style: const TextStyle(
                              color: AppColors.lightGray,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              const Icon(Icons.chevron_right, color: AppColors.lightGray),
              const SizedBox(width: 16),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildScoreBadge(int score) {
    Color color;
    if (score >= 80) {
      color = AppColors.green;
    } else if (score >= 50) {
      color = AppColors.orange;
    } else {
      color = AppColors.red;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        'Score: $score',
        style: TextStyle(
          color: color,
          fontWeight: FontWeight.bold,
          fontSize: 12,
        ),
      ),
    );
  }
}

import 'package:callwich/data/common/http_client.dart';
import 'package:callwich/data/models/product.dart';
import 'package:callwich/widgets/availability_status_widget.dart';
import 'package:flutter/material.dart';

class ProductCard extends StatelessWidget {
  final ProductEntity product;
  final int quantity;
  final VoidCallback? onDecrease;
  final VoidCallback onIncrease;

  const ProductCard({
    Key? key,
    required this.product,
    required this.quantity,
    required this.onDecrease,
    required this.onIncrease,
  }) : super(key: key);

  bool _isProductAvailable(ProductEntity product) {
    final isManufactured = product.type == "تولیدی" || product.type == "manufactured";
    final currentStock = double.tryParse(product.stock) ?? 0;

    if (isManufactured) {
      return true;
    }

    return currentStock > 0;
  }

  String _getStockDisplayText(ProductEntity product) {
    final isManufactured = product.type == "تولیدی" || product.type == "manufactured";
    final currentStock = double.tryParse(product.stock) ?? 0;

    if (isManufactured) {
      return 'موجودی: تولیدی';
    }

    if (currentStock > 0) {
      return 'موجودی: $currentStock عدد';
    }

    return 'موجودی: ناموجود';
  }

  bool _canIncreaseQuantity(ProductEntity product, int currentQuantity) {
    final isManufactured = product.type == "تولیدی" || product.type == "manufactured";
    final currentStock = double.tryParse(product.stock) ?? 0;

    if (isManufactured) {
      return true; // Unlimited for manufactured products
    }

    return currentQuantity < currentStock;
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.fromLTRB(6, 8, 6, 8),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Product image
          Expanded(
            child: Stack(
              children: [
                Positioned.fill(
                  child: Container(
                    width: double.infinity,
                    decoration: BoxDecoration(
                      borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(12),
                        topRight: Radius.circular(12),
                      ),
                    ),
                    child: ClipRRect(
                      borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(12),
                        topRight: Radius.circular(12),
                      ),
                      child:
                          product.imageUrl.isNotEmpty
                              ? Image.network(
                                  '${baseUrlImg}${product.imageUrl}',
                                fit: BoxFit.cover,
                                errorBuilder: (context, error, stackTrace) {
                                  return Container(
                                    color: Colors.grey[200],
                                    child: const Center(
                                      child: Icon(
                                        Icons.image_not_supported,
                                        size: 40,
                                        color: Colors.grey,
                                      ),
                                    ),
                                  );
                                },
                              )
                              : Container(
                                color: Colors.grey[200],
                                child: const Center(
                                  child: Icon(
                                    Icons.image_not_supported,
                                    size: 40,
                                    color: Colors.grey,
                                  ),
                                ),
                              ),
                    ),
                  ),
                ),
                // Minimal inventory status indicator at top
                Positioned(
                  top: 8,
                  left: 8,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: _isProductAvailable(product) 
                          ? const Color(0xFF4CAF50) // Green for available
                          : const Color(0xFFF44336), // Red for unavailable
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      _isProductAvailable(product) ? 'موجود' : 'ناموجود',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Product info
          Padding(
            padding: const EdgeInsets.fromLTRB(10, 6, 10, 2),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  product.name,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Text(
                  '${product.sellingPrice} تومان',
                  style: TextStyle(
                    fontSize: 12,
                    color: Theme.of(context).primaryColor,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  _getStockDisplayText(product),
                  style: TextStyle(
                    fontSize: 11,
                    color: Colors.grey[600],
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),

          Padding(
            padding: const EdgeInsets.fromLTRB(8, 4, 8, 10),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SizedBox(
                  width: 28,
                  height: 28,
                  child: OutlinedButton(
                    style: OutlinedButton.styleFrom(
                      padding: EdgeInsets.zero,
                      minimumSize: Size.zero,
                      side: BorderSide(
                        color: (quantity > 0 && _isProductAvailable(product))
                            ? Colors.grey.shade300
                            : Colors.grey.shade200,
                      ),
                      shape: const CircleBorder(),
                    ),
                    onPressed: (quantity > 0 && _isProductAvailable(product))
                        ? onDecrease
                        : null,
                    child: Icon(
                      Icons.remove,
                      size: 16,
                      color: (quantity > 0 && _isProductAvailable(product))
                          ? Colors.black87
                          : Colors.grey.shade400,
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  child: Text(
                    quantity.toString(),
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                SizedBox(
                  width: 28,
                  height: 28,
                  child: OutlinedButton(
                    style: OutlinedButton.styleFrom(
                      padding: EdgeInsets.zero,
                      minimumSize: Size.zero,
                      side: BorderSide(
                        color: _canIncreaseQuantity(product, quantity)
                            ? Colors.grey.shade300
                            : Colors.grey.shade200,
                      ),
                      shape: const CircleBorder(),
                    ),
                    onPressed: _canIncreaseQuantity(product, quantity)
                        ? onIncrease
                        : null,
                    child: Icon(
                      Icons.add,
                      size: 16,
                      color: _canIncreaseQuantity(product, quantity)
                          ? Colors.black87
                          : Colors.grey.shade400,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
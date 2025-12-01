// lib/screens/category/widgets/product_card_widget.dart
import 'package:cream_ventory/screens/category/widgets/category_details_screen_product_image.dart';
import 'package:flutter/material.dart';
import 'package:cream_ventory/models/product_model.dart';
import 'package:cream_ventory/core/constants/font_helper.dart';

class ProductCardWidget extends StatefulWidget {
  final ProductModel product;
  final double screenWidth;
  const ProductCardWidget({super.key, required this.product, required this.screenWidth});

  @override
  State<ProductCardWidget> createState() => _ProductCardWidgetState();
}

class _ProductCardWidgetState extends State<ProductCardWidget> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 150),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.97).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) {
        _controller.forward();
      },
      onTapUp: (_) {
        _controller.reverse();
      },
      onTapCancel: () {
        _controller.reverse();
      },
      child: ScaleTransition(
        scale: _scaleAnimation,
        child: Container(
          margin: const EdgeInsets.only(bottom: 16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            gradient: LinearGradient(
              colors: [Colors.white, Colors.grey[50]!],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.08),
                blurRadius: 20,
                offset: const Offset(0, 4),
                spreadRadius: 0,
              ),
              BoxShadow(
                color: Colors.black.withOpacity(0.04),
                blurRadius: 10,
                offset: const Offset(0, 2),
                spreadRadius: 0,
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(20),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                borderRadius: BorderRadius.circular(20),
                splashColor: Colors.blue.withOpacity(0.1),
                highlightColor: Colors.blue.withOpacity(0.05),
                onTap: () {},
                child: Container(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildImageSection(),
                      const SizedBox(width: 16),
                      Expanded(child: _buildContentSection()),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildImageSection() {
    return Hero(
      tag: 'product_${widget.product.id}',
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: ProductImageWidget(product: widget.product),
        ),
      ),
    );
  }

  Widget _buildContentSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildProductName(),
        const SizedBox(height: 12),
        _buildStockBadge(),
        const SizedBox(height: 12),
        _buildPriceSection(),
      ],
    );
  }

  Widget _buildProductName() {
    return Text(
      widget.product.name,
      style: AppTextStyles.bold18.copyWith(
        fontSize: 18,
        color: const Color(0xFF1A1A1A),
        fontWeight: FontWeight.w700,
        height: 1.3,
        letterSpacing: -0.3,
      ),
      maxLines: 2,
      overflow: TextOverflow.ellipsis,
    );
  }

  Widget _buildStockBadge() {
    final isLowStock = widget.product.stock < 10;
    final isOutOfStock = widget.product.stock == 0;

    Color bgColor;
    Color textColor;
    IconData icon;
    String text;

    if (isOutOfStock) {
      bgColor = Colors.red[50]!;
      textColor = Colors.red[700]!;
      icon = Icons.error_outline_rounded;
      text = 'Out of Stock';
    } else if (isLowStock) {
      bgColor = Colors.orange[50]!;
      textColor = Colors.orange[700]!;
      icon = Icons.warning_amber_rounded;
      text = '${widget.product.stock} Left';
    } else {
      bgColor = Colors.green[50]!;
      textColor = Colors.green[700]!;
      icon = Icons.check_circle_outline_rounded;
      text = '${widget.product.stock} In Stock';
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: textColor),
          const SizedBox(width: 6),
          Text(
            text,
            style: AppTextStyles.w500.copyWith(
              fontSize: 13,
              color: textColor,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPriceSection() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.blue[50]!, Colors.blue[50]!.withOpacity(0.3)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.blue[100]!, width: 1),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildPriceItem(
                'Sale Price',
                '₹${widget.product.salePrice.toStringAsFixed(2)}',
                Colors.blue[700]!,
                Icons.sell_rounded,
              ),
              Container(
                width: 1,
                height: 40,
                color: Colors.blue[200],
              ),
              _buildPriceItem(
                'Purchase',
                '₹${widget.product.purchasePrice.toStringAsFixed(2)}',
                Colors.grey[700]!,
                Icons.shopping_cart_outlined,
              ),
            ],
          ),
          const SizedBox(height: 8),
          _buildProfitMargin(),
        ],
      ),
    );
  }

  Widget _buildPriceItem(String label, String value, Color color, IconData icon) {
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 14, color: Colors.grey[600]),
              const SizedBox(width: 4),
              Text(
                label,
                style: AppTextStyles.w500.copyWith(
                  fontSize: 11,
                  color: Colors.grey[600],
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: AppTextStyles.textBold.copyWith(
              fontSize: 16,
              color: color,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProfitMargin() {
    final profit = widget.product.salePrice - widget.product.purchasePrice;
    final profitPercent = ((profit / widget.product.purchasePrice) * 100);
    final isProfit = profit > 0;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: isProfit ? Colors.green[50] : Colors.red[50],
        borderRadius: BorderRadius.circular(6),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            isProfit ? Icons.trending_up_rounded : Icons.trending_down_rounded,
            size: 14,
            color: isProfit ? Colors.green[700] : Colors.red[700],
          ),
          const SizedBox(width: 4),
          Text(
            '${isProfit ? "+" : ""}₹${profit.toStringAsFixed(2)} (${profitPercent.toStringAsFixed(1)}%)',
            style: AppTextStyles.w500.copyWith(
              fontSize: 11,
              color: isProfit ? Colors.green[700] : Colors.red[700],
              fontWeight: FontWeight.w600,
            ), 
          ),
        ],
      ),
    );
  }
}
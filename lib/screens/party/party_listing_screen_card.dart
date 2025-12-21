// lib/widgets/party_card.dart

import 'package:cream_ventory/models/party_model.dart';
import 'package:cream_ventory/core/utils/image_util.dart';
import 'package:flutter/material.dart';

class PartyCard extends StatefulWidget {
  final PartyModel party;
  final VoidCallback onTap;
  final bool isDesktop;

  const PartyCard({
    super.key,
    required this.party,
    required this.onTap,
    required this.isDesktop,
  });

  @override
  State<PartyCard> createState() => _PartyCardState();
}

class _PartyCardState extends State<PartyCard> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 150),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.98).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  // Helper methods for balance-based color logic
  Color _getBalanceColor() {
    if (widget.party.partyBalance > 0) {
      return Colors.green;
    } else if (widget.party.partyBalance < 0) {
      return Colors.red;
    } else {
      return widget.party.paymentType.trim().toLowerCase() == "you'll give"
          ? Colors.red
          : Colors.green;
    }
  }

  Color _getBalanceBackgroundColor() {
    final baseColor = _getBalanceColor();
    return baseColor.withOpacity(0.12);
  }

  List<Color> _getBalanceGradient() {
    if (widget.party.partyBalance > 0) {
      return [Colors.green.shade400, Colors.green.shade600];
    } else if (widget.party.partyBalance < 0) {
      return [Colors.red.shade400, Colors.red.shade600];
    } else {
      return widget.party.paymentType.trim().toLowerCase() == "you'll give"
          ? [Colors.red.shade400, Colors.red.shade600]
          : [Colors.green.shade400, Colors.green.shade600];
    }
  }

  String _getBalanceLabel() {
    if (widget.party.partyBalance > 0) {
      return "You'll Get";
    } else if (widget.party.partyBalance < 0) {
      return "You'll Give";
    } else {
      return widget.party.paymentType.trim().toLowerCase() == "you'll give"
          ? "You'll Give"
          : "You'll Get";
    }
  }

  IconData _getBalanceIcon() {
    if (widget.party.partyBalance > 0 || 
        (widget.party.partyBalance == 0 && 
         widget.party.paymentType.trim().toLowerCase() != "you'll give")) {
      return Icons.arrow_downward_rounded;
    } else {
      return Icons.arrow_upward_rounded;
    }
  }

  @override
  Widget build(BuildContext context) {
    final gradientColors = _getBalanceGradient();

    return GestureDetector(
      onTapDown: (_) {
        _controller.forward();
      },
      onTapUp: (_) {
        _controller.reverse();
        widget.onTap();
      },
      onTapCancel: () {
        _controller.reverse();
      },
      child: ScaleTransition(
        scale: _scaleAnimation,
        child: Container(
          margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Colors.white,
                Colors.grey.shade50,
              ],
            ),
            borderRadius: BorderRadius.circular(18),
            boxShadow: [
              BoxShadow(
                color: _getBalanceColor().withOpacity(0.1),
                blurRadius: 16,
                offset: const Offset(0, 4),
                spreadRadius: 1,
              ),
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
            border: Border.all(
              color: _getBalanceColor().withOpacity(0.15),
              width: 1.5,
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              children: [
                // Enhanced Avatar with gradient border
                Stack(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(3),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: gradientColors,
                        ),
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: _getBalanceColor().withOpacity(0.3),
                            blurRadius: 12,
                            offset: const Offset(0, 3),
                          ),
                        ],
                      ),
                      child: Container(
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.white,
                        ),
                        padding: const EdgeInsets.all(2),
                        child: CircleAvatar(
                          radius: 28,
                          backgroundImage: ImageUtils.getImage(widget.party.imagePath),
                          backgroundColor: Colors.grey[100],
                          child: widget.party.imagePath.isEmpty
                              ? Icon(
                                  Icons.person_rounded,
                                  size: 32,
                                  color: Colors.grey.shade400,
                                )
                              : null,
                        ),
                      ),
                    ),
                    // Status indicator
                    Positioned(
                      bottom: 0,
                      right: 0,
                      child: Container(
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: gradientColors,
                          ),
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.white, width: 2),
                          boxShadow: [
                            BoxShadow(
                              color: _getBalanceColor().withOpacity(0.4),
                              blurRadius: 8,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Icon(
                          _getBalanceIcon(),
                          size: 12,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(width: 14),
                // Party Details
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.party.name,
                        style: TextStyle(
                          fontSize: 18,
                          fontFamily: 'ABeeZee',
                          fontWeight: FontWeight.bold,
                          color: Colors.grey.shade900,
                          letterSpacing: 0.2,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 6),
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(4),
                            decoration: BoxDecoration(
                              color: Colors.grey.shade100,
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Icon(
                              Icons.location_on_rounded,
                              size: 14,
                              color: Colors.grey.shade600,
                            ),
                          ),
                          const SizedBox(width: 6),
                          Expanded(
                            child: Text(
                              widget.party.billingAddress.isEmpty
                                  ? 'No address'
                                  : widget.party.billingAddress,
                              style: TextStyle(
                                fontSize: 13,
                                fontFamily: 'ABeeZee',
                                color: Colors.grey[600],
                                letterSpacing: 0.1,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                // Enhanced Balance Display
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 10,
                  ),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        _getBalanceBackgroundColor(),
                        _getBalanceBackgroundColor().withOpacity(0.6),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(
                      color: _getBalanceColor().withOpacity(0.3),
                      width: 1.5,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: _getBalanceColor().withOpacity(0.15),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            padding: const EdgeInsets.all(4),
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: gradientColors,
                              ),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.currency_rupee_rounded,
                              size: 12,
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(width: 6),
                          ShaderMask(
                            shaderCallback: (bounds) => LinearGradient(
                              colors: gradientColors,
                            ).createShader(bounds),
                            child: Text(
                              widget.party.partyBalance.abs().toStringAsFixed(2),
                              style: const TextStyle(
                                fontSize: 18,
                                fontFamily: 'ABeeZee',
                                fontWeight: FontWeight.w900,
                                color: Colors.white,
                                letterSpacing: -0.5,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 3,
                        ),
                        decoration: BoxDecoration(
                          color: _getBalanceColor().withOpacity(0.15),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          _getBalanceLabel(),
                          style: TextStyle(
                            fontSize: 11,
                            fontFamily: 'ABeeZee',
                            fontWeight: FontWeight.w600,
                            color: _getBalanceColor(),
                            letterSpacing: 0.3, 
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
} 
// lib/widgets/desktop_party_card.dart

import 'package:cream_ventory/models/party_model.dart';
import 'package:cream_ventory/core/utils/image_util.dart';
import 'package:flutter/material.dart';

class DesktopPartyCard extends StatefulWidget {
  final PartyModel party;
  final VoidCallback onTap;

  const DesktopPartyCard({
    super.key,
    required this.party,
    required this.onTap,
  });

  @override
  State<DesktopPartyCard> createState() => _DesktopPartyCardState();
}

class _DesktopPartyCardState extends State<DesktopPartyCard> {
  bool _isHovered = false;

  // Helper methods for balance-based color logic
  Color _getBalanceColor() {
    if (widget.party.partyBalance > 0) {
      return Colors.green.withOpacity(0.12);
    } else if (widget.party.partyBalance < 0) {
      return Colors.red.withOpacity(0.12);
    } else {
      return widget.party.paymentType.trim().toLowerCase() == "you'll give"
          ? Colors.red.withOpacity(0.12)
          : Colors.green.withOpacity(0.12);
    }
  }

  Color _getBalanceTextColor() {
    if (widget.party.partyBalance > 0) {
      return Colors.green.shade700;
    } else if (widget.party.partyBalance < 0) {
      return Colors.red.shade700;
    } else {
      return widget.party.paymentType.trim().toLowerCase() == "you'll give"
          ? Colors.red.shade700
          : Colors.green.shade700;
    }
  }

  Color _getBalanceBorderColor() {
    if (widget.party.partyBalance > 0) {
      return Colors.green.shade200;
    } else if (widget.party.partyBalance < 0) {
      return Colors.red.shade200;
    } else {
      return widget.party.paymentType.trim().toLowerCase() == "you'll give"
          ? Colors.red.shade200
          : Colors.green.shade200;
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
    if (widget.party.partyBalance > 0) {
      return Icons.south_rounded;
    } else if (widget.party.partyBalance < 0) {
      return Icons.north_rounded;
    } else {
      return widget.party.paymentType.trim().toLowerCase() == "you'll give"
          ? Icons.north_rounded
          : Icons.south_rounded;
    }
  }

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeInOut,
          margin: const EdgeInsets.only(bottom: 9),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: _isHovered 
                  ? _getBalanceBorderColor()
                  : Colors.grey.shade200,
              width: _isHovered ? 2 : 1,
            ),
            boxShadow: [
              BoxShadow(
                color: _isHovered 
                    ? Colors.black.withOpacity(0.08)
                    : Colors.black.withOpacity(0.04),
                blurRadius: _isHovered ? 12 : 6,
                offset: Offset(0, _isHovered ? 4 : 2),
              ),
            ],
          ),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              children: [
                // Avatar Section with Enhanced Design
                Container(
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: CircleAvatar(
                    radius: 36,
                    backgroundImage: ImageUtils.getImage(widget.party.imagePath),
                    backgroundColor: Colors.grey[100],
                    child: widget.party.imagePath.isEmpty
                        ? Icon(
                            Icons.person_rounded,
                            size: 40,
                            color: Colors.grey[400],
                          )
                        : null,
                  ),
                ),
                
                const SizedBox(width: 20),
                
                // Party Details Section - Expanded to take available space
                Expanded(
                  flex: 3,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // Party Name
                      Text(
                        widget.party.name,
                        style: const TextStyle(
                          fontSize: 20,
                          fontFamily: 'ABeeZee',
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                          letterSpacing: -0.3,
                        ),
                        overflow: TextOverflow.ellipsis,
                        maxLines: 1,
                      ),
                      const SizedBox(height: 6),
                      
                      // Address with Icon
                      Row(
                        children: [
                          Icon(
                            Icons.location_on_outlined,
                            size: 16,
                            color: Colors.grey[600],
                          ),
                          const SizedBox(width: 6),
                          Expanded(
                            child: Text(
                              widget.party.billingAddress.isEmpty
                                  ? 'No address provided'
                                  : widget.party.billingAddress,
                              style: TextStyle(
                                fontSize: 15,
                                fontFamily: 'ABeeZee',
                                color: Colors.grey[600],
                                height: 1.3,
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
                
                const SizedBox(width: 24),
                
                // Payment Type Badge
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 15,
                    vertical: 9,
                  ),
                  decoration: BoxDecoration(
                    color: _getBalanceColor(),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: _getBalanceBorderColor(),
                      width: 1.5,
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: _getBalanceTextColor().withOpacity(0.15),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          _getBalanceIcon(),
                          size: 16,
                          color: _getBalanceTextColor(),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            _getBalanceLabel(),
                            style: TextStyle(
                              fontSize: 12,
                              fontFamily: 'ABeeZee',
                              color: Colors.grey[700],
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const SizedBox(height: 1),
                          Text(
                            '₹${widget.party.partyBalance.abs().toStringAsFixed(2)}',
                            style: TextStyle(
                              fontSize: 18,
                              fontFamily: 'ABeeZee',
                              fontWeight: FontWeight.bold,
                              color: _getBalanceTextColor(),
                              letterSpacing: -0.5,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                
                const SizedBox(width: 16),
                
                // Action Arrow
                AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: _isHovered
                        ? Colors.blue.withOpacity(0.1)
                        : Colors.grey.withOpacity(0.05),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(
                    Icons.arrow_forward_rounded,
                    size: 24,
                    color: _isHovered ? Colors.blue.shade700 : Colors.grey[600],
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
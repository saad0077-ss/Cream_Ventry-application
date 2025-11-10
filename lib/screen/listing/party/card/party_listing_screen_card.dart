// lib/widgets/party_card.dart

import 'package:cream_ventory/db/models/parties/party_model.dart';
import 'package:cream_ventory/utils/adding/image_util.dart';
import 'package:flutter/material.dart';

class PartyCard extends StatelessWidget {
  final PartyModel party;
  final VoidCallback onTap;
  final bool isDesktop;

  const PartyCard({
    super.key,
    required this.party,
    required this.onTap,
    required this.isDesktop
  });

  // Helper methods for balance-based color logic
  Color _getBalanceColor() {
    if (party.partyBalance > 0) {
      return Colors.green.withOpacity(0.1);
    } else if (party.partyBalance < 0) {
      return Colors.red.withOpacity(0.1);
    } else {
      return party.paymentType.trim().toLowerCase() == "you'll give"
          ? Colors.red.withOpacity(0.1)
          : Colors.green.withOpacity(0.1);
    }
  }

  Color _getBalanceTextColor() {
    if (party.partyBalance > 0) {
      return Colors.green;
    } else if (party.partyBalance < 0) {
      return Colors.red;
    } else {
      return party.paymentType.trim().toLowerCase() == "you'll give"
          ? Colors.red
          : Colors.green;
    }
  }

  String _getBalanceLabel() {
    if (party.partyBalance > 0) {
      return "You'll Get";
    } else if (party.partyBalance < 0) {
      return "You'll Give";
    } else {
      return party.paymentType.trim().toLowerCase() == "you'll give"
          ? "You'll Give"
          : "You'll Get";
    }
  }

  

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Card(
        margin: const EdgeInsets.symmetric(vertical: 8),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        elevation: 2,
        color: Colors.white,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            children: [
              // Avatar
              CircleAvatar( 
                radius: 28, 
                backgroundImage :ImageUtils.getImage(party.imagePath), 
                backgroundColor: Colors.grey[100],
                child: party.imagePath.isEmpty
                    ? const Icon(Icons.person, size: 28, color: Colors.grey)
                    : null,
              ),
              const SizedBox(width: 12),
              // Party Details
              Expanded(   
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start ,
                  children: [ 
                    Text(
                      party.name,
                      style: const TextStyle(
                        fontSize: 18,
                        fontFamily: 'ABeeZee',
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      party.billingAddress.isEmpty ? 'No address' : party.billingAddress,
                      style: TextStyle(
                        fontSize: 14,
                        fontFamily: 'ABeeZee',
                        color: Colors.grey[600],
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              // Balance and Payment Type
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: _getBalanceColor(),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      '₹${party.partyBalance.abs().toStringAsFixed(2)}',
                      style: TextStyle(
                        fontSize: 16,
                        fontFamily: 'ABeeZee',
                        fontWeight: FontWeight.bold,
                        color: _getBalanceTextColor(),
                      ),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    _getBalanceLabel(),
                    style: TextStyle(
                      fontSize: 14,
                      fontFamily: 'ABeeZee',
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
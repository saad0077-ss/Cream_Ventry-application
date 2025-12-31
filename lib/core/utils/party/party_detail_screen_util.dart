import 'package:cream_ventory/models/party_model.dart';
import 'package:flutter/material.dart';

class PartyDetailUtils {
  static Color getBalanceColor(PartyModel party) {
    final bal = party.partyBalance;
    if (bal > 0) return const Color(0xFF0DA95F);
    if (bal < 0) return const Color(0xFFE74C3C);
    return party.paymentType.toLowerCase().contains("give")
        ? const Color(0xFFE74C3C)
        : const Color(0xFF0DA95F);
  }

  static String getBalanceLabel(PartyModel party) {
    final bal = party.partyBalance;
    if (bal > 0) return "You'll Get";
    if (bal < 0) return "You'll Give";
    return party.paymentType.toLowerCase().contains("give")
        ? "You'll Give"
        : "You'll Get";
  }

  static Color getTransactionTypeColor(String type) {
    if (type.contains('Sale Order')) return Colors.orange;
    if (type == 'Sale') return Colors.blue;
    if (type == 'Payment In') return const Color(0xFF0DA95F);
    return const Color(0xFFE74C3C);
  }

  static IconData getTransactionTypeIcon(String type) {
    if (type.contains('Sale Order')) return Icons.assignment;
    if (type == 'Sale') return Icons.receipt_long;
    if (type == 'Payment In') return Icons.arrow_downward_rounded;
    return Icons.arrow_upward_rounded;
  }
}
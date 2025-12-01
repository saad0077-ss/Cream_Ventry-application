// lib/screens/profile/widgets/account_stats_section.dart
import 'package:cream_ventory/database/functions/party_db.dart';
import 'package:cream_ventory/database/functions/product_db.dart';
import 'package:cream_ventory/database/functions/sale/sale_db.dart';
import 'package:cream_ventory/screens/profile/widgets/profile/user_profile_screen_section_card.dart';
import 'package:cream_ventory/screens/profile/widgets/profile/user_profile_screen_stat_card.dart';
import 'package:flutter/material.dart';


class AccountStatsSection extends StatelessWidget {
  const AccountStatsSection({super.key});

  @override
  Widget build(BuildContext context) {
    return SectionCard(
      icon: Icons.analytics_outlined,
      iconColor: const Color(0xFF8B5CF6),
      title: 'Account Statistics',
      child: Row(
        children: [
          Expanded(
            child: ValueListenableBuilder(
              valueListenable: ProductDB.productNotifier,
              builder: (context, products, _) {
                return StatCard(
                  icon: Icons.inventory_2_outlined,
                  value: products.length.toString(), // Replace with real data later
                  label: 'Products',
                  color: const Color(0xFF3B82F6),
                );
              }
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: ValueListenableBuilder(
              valueListenable: SaleDB.saleNotifier,
              builder: (context, sales, _) {
                return StatCard( 
                  icon: Icons.receipt_long_outlined,
                  value: sales.length.toString( ),
                  label: 'Sales',
                  color: const Color(0xFF10B981),
                );
              }
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: ValueListenableBuilder(
              valueListenable: PartyDb.partyNotifier,
              builder: (context, parties, _) {
                return StatCard(
                  icon: Icons.groups_outlined,
                  value: parties.length.toString(),
                  label: 'Parties',
                  color: const Color(0xFFF59E0B),
                ); 
              }
            ),
          ),
        ],
      ),
    );
  }
}
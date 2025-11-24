// lib/screens/profile/widgets/contact_details_card.dart
import 'package:cream_ventory/screens/profile/widgets/user_profile_screen_body/user_profile_screen_body_info_row.dart';
import 'package:flutter/material.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:cream_ventory/models/user_model.dart';

class ContactDetailsCard extends StatelessWidget {
  const ContactDetailsCard({
    super.key,
    required this.profile,
    required this.constraints,
  });

  final UserModel? profile;
  final BoxConstraints constraints;

  @override
  Widget build(BuildContext context) {
    final isSmallScreen = constraints.maxWidth < 600;
    final fontSize = isSmallScreen ? 14.0 : 16.0;

    final hasEmail = profile?.email.isNotEmpty == true;
    final hasPhone = profile?.phone?.isNotEmpty == true;
    final hasAddress = profile?.address?.isNotEmpty == true;

    return Container(
      padding: EdgeInsets.all(isSmallScreen ? 20 : 28),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.08), blurRadius: 20, offset: const Offset(0, 8))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: const BoxDecoration(
                  gradient: LinearGradient(colors: [Color(0xFF667eea), Color(0xFF764ba2)]),
                  borderRadius: BorderRadius.all(Radius.circular(12)),
                ),
                child: const Icon(Symbols.contact_mail_rounded, color: Colors.white, size: 20),
              ),
              const SizedBox(width: 12),
              Text('Contact Information', style: TextStyle(fontSize: fontSize + 4, fontWeight: FontWeight.bold, color: Colors.black87, fontFamily: 'ABeeZee')),
            ],
          ),
          const SizedBox(height: 20),
          InfoRow(icon: Symbols.email_rounded, label: 'Email ID', text: hasEmail ? profile!.email : 'Not provided', color: const Color(0xFF3b82f6), isEmpty: !hasEmail, fontSize: fontSize),
          const SizedBox(height: 16),
          InfoRow(icon: Symbols.phone_rounded, label: 'Contact No', text: hasPhone ? profile!.phone! : 'Not provided', color: const Color(0xFF8b5cf6), isEmpty: !hasPhone, fontSize: fontSize),
          const SizedBox(height: 16),
          InfoRow(icon: Symbols.location_on_rounded, label: 'Address', text: hasAddress ? profile!.address! : 'Not provided', color: const Color(0xFFf59e0b), isEmpty: !hasAddress, fontSize: fontSize, isMultiline: true),
        ],
      ),
    );
  }
}
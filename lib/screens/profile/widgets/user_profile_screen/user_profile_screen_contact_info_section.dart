// lib/screens/profile/widgets/contact_info_section.dart
import 'package:cream_ventory/models/user_model.dart';
import 'package:cream_ventory/screens/profile/widgets/user_profile_screen/user_profile_screen_detail_field.dart';
import 'package:cream_ventory/screens/profile/widgets/user_profile_screen/user_profile_screen_section_card.dart';
import 'package:flutter/material.dart';

class ContactInfoSection extends StatelessWidget {
  final UserModel profile;

  const ContactInfoSection({super.key, required this.profile});

  @override
  Widget build(BuildContext context) {
    return SectionCard(
      icon: Icons.contact_phone_outlined,
      iconColor: const Color(0xFF667EEA),
      title: 'Contact Information',
      child: Column(
        children: [
          DetailField(
            icon: Icons.email_outlined,
            label: 'Email Address',
            value: profile.email.isNotEmpty ? profile.email : 'Not provided',
            isEmpty: profile.email.isEmpty,
          ),
          DetailField(
            icon: Icons.phone_outlined,
            label: 'Phone Number',
            value: profile.phone?.isNotEmpty == true ? profile.phone! : 'Not provided',
            isEmpty: profile.phone?.isEmpty ?? true,
          ),
        ],
      ),
    );
  }
}
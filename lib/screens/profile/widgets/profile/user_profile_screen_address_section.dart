// lib/screens/profile/widgets/address_section.dart
import 'package:cream_ventory/models/user_model.dart';
import 'package:cream_ventory/screens/profile/widgets/profile/user_profile_screen_detail_field.dart';
import 'package:cream_ventory/screens/profile/widgets/profile/user_profile_screen_section_card.dart';
import 'package:flutter/material.dart';


class AddressSection extends StatelessWidget {
  final UserModel profile;

  const AddressSection({super.key, required this.profile});

  @override
  Widget build(BuildContext context) {
    return SectionCard(
      icon: Icons.location_on_outlined,
      iconColor: const Color(0xFFF59E0B),
      title: 'Address',
      child: DetailField(
        icon: Icons.home_outlined,
        label: 'Full Address',
        value: profile.address?.isNotEmpty == true ? profile.address! : 'Not provided',
        isEmpty: profile.address?.isEmpty ?? true,
        maxLines: 3,
      ),
    );
  }
}
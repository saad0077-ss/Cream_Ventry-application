// lib/screens/profile/widgets/account_actions_section.dart
import 'package:cream_ventory/core/utils/profile/profile_display_logics.dart';
import 'package:cream_ventory/screens/profile/widgets/profile/logout_dialog.dart';
import 'package:cream_ventory/screens/profile/widgets/profile/user_profile_screen_danger_button.dart';
import 'package:cream_ventory/screens/profile/widgets/profile/user_profile_screen_section_card.dart';
import 'package:flutter/material.dart';

class AccountActionsSection extends StatelessWidget {
  final ProfileDisplayLogic logic;

  const AccountActionsSection({super.key, required this.logic});

  @override
  Widget build(BuildContext context) {
    return SectionCard(
      icon: Icons.warning_amber_rounded,
      iconColor: const Color(0xFFEF4444),
      title: 'Account Actions',
      child: DangerButton(
        icon: Icons.logout_rounded,
        label: 'Logout',
        subtitle: 'Sign out from your account',
        onTap: () => showLogoutDialog(context, logic.logout),
      ),
    );
  }
}
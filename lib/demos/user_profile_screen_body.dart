
// import 'package:cream_ventory/screens/profile/widgets/user_profile_screen_body/user_profile_screen_body_contact_details_card.dart';
// import 'package:cream_ventory/screens/profile/widgets/user_profile_screen_body/user_profile_screen_body_financial_summary_section.dart';
// import 'package:cream_ventory/screens/profile/widgets/user_profile_screen_body/user_profile_screen_body_hero_profile_card.dart';
// import 'package:flutter/material.dart';
// import 'package:cream_ventory/models/user_model.dart';
// import 'package:cream_ventory/core/utils/profile/profile_display_logics.dart';
// import 'package:cream_ventory/screens/profile/widgets/user_profile_screen_body/user_profile_screen_button.dart';

// class BodyOfProfilePage extends StatelessWidget {
//   const BodyOfProfilePage({
//     super.key,
//     required this.profile,
//     required this.logic,
//     required this.constraints,
//   });

//   final UserModel? profile;
//   final ProfileDisplayLogic logic;
//   final BoxConstraints constraints;

//   @override
//   Widget build(BuildContext context) {

   
//     return SingleChildScrollView(
//       padding: const EdgeInsets.all(4),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           const SizedBox(height: 16),
//           HeroProfileCard(
//             profile: profile,
//             constraints: constraints, 
//             onEditTap: logic.navigateToEditProfile,
//           ),
//           const SizedBox(height: 24),
//           FinancialSummarySection(logic: logic, constraints: constraints),
//           const SizedBox(height: 24),
//           ContactDetailsCard(profile: profile, constraints: constraints),
//           const SizedBox(height: 12),
//           ProfileButtons(logic: logic, constraints: constraints),
//         ],
//       ),
//     );
//   }
// }
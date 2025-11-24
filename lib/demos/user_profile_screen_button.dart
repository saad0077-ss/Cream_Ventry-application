// import 'package:cream_ventory/core/utils/profile/profile_display_logics.dart';
// import 'package:flutter/material.dart';
// import 'package:material_symbols_icons/symbols.dart';

// class ProfileButtons extends StatefulWidget {
//   final ProfileDisplayLogic logic;
//   final BoxConstraints constraints;

//   const ProfileButtons({
//     super.key,
//     required this.logic,
//     required this.constraints,
//   });

//   @override
//   _ProfileButtonsState createState() => _ProfileButtonsState();
// }

// class _ProfileButtonsState extends State<ProfileButtons> {
//   bool _isLogoutPressed = false;

//   Future<void> _showLogoutConfirmationDialog() async {
//     final confirmed = await showDialog<bool>(
//       context: context,
//       barrierDismissible: false, // User must tap a button
//       builder: (context) => const _LogoutConfirmationDialog(),
//     );

//     if (confirmed == true) {
//       widget.logic.logout();
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     final isSmallScreen = widget.constraints.maxWidth < 600;
//     final buttonHeight = isSmallScreen ? 56.0 : 64.0;
//     final fontSize = isSmallScreen ? 16.0 : 18.0;

//     return Column(
//       children: [
//         const SizedBox(height: 20),

//         const SizedBox(height: 20),
//         _buildButton(
//           icon: Symbols.logout_rounded,
//           text: 'Logout',
//           onTap: () {
//             setState(() => _isLogoutPressed = true);
//             _showLogoutConfirmationDialog().then((_) {
//               if (mounted) {
//                 setState(() => _isLogoutPressed = false);
//               }
//             });
//           },
//           isPressed: _isLogoutPressed,
//           buttonHeight: buttonHeight,
//           fontSize: fontSize,
//           textColor: Colors.white,
//           iconColor: Colors.white,
//           color: Colors.redAccent,
//         ),
//         const SizedBox(height: 40),
//       ],
//     );
//   }

//   Widget _buildButton({
//     required IconData icon,
//     required String text,
//     required VoidCallback onTap,
//     required bool isPressed,
//     required double buttonHeight,
//     required double fontSize,
//     required Color color,
//     Color textColor = Colors.white,
//     Color iconColor = Colors.white,
//   }) {
//     return GestureDetector(
//       onTap: onTap,
//       child: AnimatedContainer(
//         duration: const Duration(milliseconds: 200),
//         height: buttonHeight,
//         decoration: BoxDecoration(
//           color: color,
//           borderRadius: BorderRadius.circular(12.0),
//           boxShadow: [
//             BoxShadow(
//               color: Colors.black.withOpacity(isPressed ? 0.3 : 0.2),
//               blurRadius: isPressed ? 12 : 8,
//               offset: Offset(0, isPressed ? 6 : 4),
//             ),
//           ],
//         ),
//         child: Row(
//           mainAxisAlignment: MainAxisAlignment.spaceBetween,
//           children: [
//             Padding(
//               padding: const EdgeInsets.symmetric(horizontal: 16.0),
//               child: Row(
//                 children: [
//                   Icon(icon, color: iconColor, size: fontSize + 4),
//                   const SizedBox(width: 12),
//                   Text(
//                     text,
//                     style: TextStyle(
//                       fontSize: fontSize,
//                       fontWeight: FontWeight.w600,
//                       color: textColor,
//                       fontFamily: 'ABeeZee',
//                     ),
//                   ),
//                 ],
//               ),
//             ),
//             Padding(
//               padding: const EdgeInsets.only(right: 16.0),
//               child: Icon(
//                 Symbols.chevron_right_rounded,
//                 color: iconColor,
//                 size: fontSize + 4,
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }

// // Custom Beautiful Logout Confirmation Dialog
// class _LogoutConfirmationDialog extends StatelessWidget {
//   const _LogoutConfirmationDialog();

//   @override
//   Widget build(BuildContext context) {
//     return Center(
//       child: Material(
//         color: Colors.transparent,
//         child: Container(
//           margin: const EdgeInsets.all(24),
//           padding: const EdgeInsets.all(25),
//           constraints: const BoxConstraints(maxWidth: 345),
//           decoration: BoxDecoration(
//             color: Theme.of(context).dialogBackgroundColor,
//             borderRadius: BorderRadius.circular(20),
//             boxShadow: [
//               BoxShadow(
//                 color: Colors.black.withOpacity(0.25),
//                 blurRadius: 20,
//                 offset: const Offset(0, 10),
//               ),
//             ],
//           ),
//           child: Column(
//             mainAxisSize: MainAxisSize.min,
//             children: [
//               // Warning Icon
//               Container(
//                 padding: const EdgeInsets.all(16),
//                 decoration: BoxDecoration(
//                   color: Colors.redAccent.withOpacity(0.15),
//                   shape: BoxShape.circle,
//                 ),
//                 child: const Icon(
//                   Symbols.logout_rounded,
//                   color: Colors.redAccent,
//                   size: 48,
//                 ),
//               ),
//               const SizedBox(height: 24),

//               // Title
//               const Text(
//                 'Logout',
//                 style: TextStyle(
//                   fontSize: 24,
//                   fontWeight: FontWeight.bold,
//                   fontFamily: 'ABeeZee',
//                 ),
//               ),
//               const SizedBox(height: 12),

//               // Message
//               Text(
//                 'Are you sure you want to log out of your account?',
//                 textAlign: TextAlign.center,
//                 style: TextStyle(
//                   fontSize: 16,
//                   color: Colors.grey[700],
//                   height: 1.4,
//                 ),
//               ),
//               const SizedBox(height: 32),

//               // Buttons Row
//               Row(
//                 children: [
//                   // Cancel Button
//                   Expanded(
//                     child: TextButton(
//                       onPressed: () => Navigator.pop(context, false),
//                       style: TextButton.styleFrom(
//                         padding: const EdgeInsets.symmetric(vertical: 14),
//                         shape: RoundedRectangleBorder(
//                           borderRadius: BorderRadius.circular(12),
//                           side: BorderSide(color: Colors.grey[300]!),
//                         ),
//                       ),
//                       child: const Text(
//                         'Cancel',
//                         style: TextStyle(
//                           fontSize: 16,
//                           fontWeight: FontWeight.w600,
//                           color: Colors.grey,
//                         ),
//                       ),
//                     ),
//                   ),
//                   const SizedBox(width: 12),

//                   // Confirm Logout Button
//                   Expanded(
//                     child: ElevatedButton(
//                       onPressed: () => Navigator.pop(context, true),
//                       style: ElevatedButton.styleFrom(
//                         backgroundColor: Colors.redAccent,
//                         padding: const EdgeInsets.symmetric(vertical: 14),
//                         elevation: 2,
//                         shadowColor: Colors.redAccent.withOpacity(0.4),
//                         shape: RoundedRectangleBorder(
//                           borderRadius: BorderRadius.circular(12),
//                         ),
//                       ),
//                       child: const Text(
//                         'Logout',
//                         style: TextStyle(
//                           fontSize: 16,
//                           fontWeight: FontWeight.w600,
//                           color: Colors.white,
//                         ),
//                       ),
//                     ), 
//                   ),
//                 ],
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   } 
// }
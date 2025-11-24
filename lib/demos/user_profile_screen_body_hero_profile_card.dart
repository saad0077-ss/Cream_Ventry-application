// // lib/screens/profile/widgets/hero_profile_card.dart
// import 'dart:convert';
// import 'dart:io';
// import 'package:flutter/foundation.dart';
// import 'package:flutter/material.dart';
// import 'package:material_symbols_icons/symbols.dart';
// import 'package:cream_ventory/models/user_model.dart';

// class HeroProfileCard extends StatelessWidget {
//   const HeroProfileCard({
//     super.key,
//     required this.profile,
//     required this.constraints,
//     required this.onEditTap,
//   });

//   final UserModel? profile;
//   final BoxConstraints constraints;
//   final VoidCallback onEditTap;

//   @override
//   Widget build(BuildContext context) {
//     final isSmallScreen = constraints.maxWidth < 600;
//     final avatarSize = isSmallScreen ? 110.0 : 150.0;
//     final fontSize = isSmallScreen ? 14.0 : 16.0;

//     final imageProvider = _getImageProvider();

//     final hasName = profile?.name?.isNotEmpty == true;
//     final hasUsername = profile?.username.isNotEmpty == true;
//     final hasDistribution = profile?.distributionName?.isNotEmpty == true;

//     return Container(
//       width: double.infinity,
//       decoration: BoxDecoration(
//         gradient: LinearGradient(
//           colors: hasName || hasUsername
//               ? [const Color(0xFF667eea), const Color(0xFF764ba2)]
//               : [Colors.grey.shade800, Colors.grey.shade900],
//           begin: Alignment.topLeft,
//           end: Alignment.bottomRight,
//         ),
//         borderRadius: BorderRadius.circular(24),
//         boxShadow: [
//           BoxShadow(
//             color: (hasName || hasUsername ? const Color(0xFF667eea) : Colors.grey.shade800).withOpacity(0.4),
//             blurRadius: 20,
//             offset: const Offset(0, 10),
//           ),
//         ],
//       ),
//       padding: EdgeInsets.all(isSmallScreen ? 20 : 28),
//       child: Stack(
//         children: [
//           Column(
//             children: [
//               Center(
//                 child: Container(
//                   decoration: BoxDecoration(
//                     shape: BoxShape.circle,
//                     boxShadow: [
//                       BoxShadow(color: Colors.black.withOpacity(0.2), blurRadius: 20, offset: const Offset(0, 8)),
//                     ],
//                   ),
//                   child: Container(
//                     padding: const EdgeInsets.all(5),
//                     decoration: const BoxDecoration(
//                       shape: BoxShape.circle,
//                       gradient: LinearGradient(colors: [Colors.white, Color(0xFFF8F9FA)]),
//                     ),
//                     child: imageProvider != null
//                         ? CircleAvatar(radius: avatarSize / 2, backgroundImage: imageProvider)
//                         : CircleAvatar(
//                             radius: avatarSize / 2,
//                             backgroundColor: Colors.grey.shade200,
//                             child: Icon(Symbols.person_rounded, size: avatarSize / 2, color: Colors.grey.shade400),
//                           ),
//                   ),
//                 ),
//               ),
//               const SizedBox(height: 20),
//               Text(
//                 hasName ? profile!.name! : (hasUsername ? profile!.username : 'No Name'),
//                 style: TextStyle(fontSize: fontSize + 10, fontWeight: FontWeight.bold, color: Colors.white, fontFamily: 'ABeeZee'),
//                 textAlign: TextAlign.center,
//               ),
//               const SizedBox(height: 10),
//               Container(
//                 padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
//                 decoration: BoxDecoration(color: Colors.white.withOpacity(0.2), borderRadius: BorderRadius.circular(20)),
//                 child: Row(
//                   mainAxisSize: MainAxisSize.min,
//                   children: [
//                     Icon(Symbols.store_rounded, color: hasDistribution ? Colors.white : Colors.grey.shade400, size: 18),
//                     const SizedBox(width: 8),
//                     Text(
//                       hasDistribution ? profile!.distributionName! : 'No Distribution',
//                       style: TextStyle(fontSize: fontSize, color: hasDistribution ? Colors.white : Colors.grey.shade400, fontFamily: 'ABeeZee'),
//                     ),
//                   ],
//                 ),
//               ),
//             ],
//           ),
//           Positioned(
//             top: 0,
//             right: 0,
//             child: Material(
//               color: Colors.transparent,
//               child: InkWell(
//                 onTap: onEditTap,
//                 borderRadius: BorderRadius.circular(50),
//                 child: Container(
//                   padding: EdgeInsets.all(isSmallScreen ? 10 : 12),
//                   decoration: const BoxDecoration(
//                     gradient: LinearGradient(colors: [Color(0xFFfbbf24), Color(0xFFf59e0b)]),
//                     shape: BoxShape.circle,
//                     boxShadow: [BoxShadow(color: Color(0xFFf59e0b), blurRadius: 12, offset: Offset(0, 4))],
//                   ),
//                   child: Icon(Symbols.edit_rounded, color: Colors.white, size: isSmallScreen ? 20 : 24),
//                 ),
//               ),
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   ImageProvider? _getImageProvider() {
//     if (profile == null || profile!.profileImagePath == null || profile!.profileImagePath!.isEmpty) {
//       return null;
//     }

//     if (kIsWeb) {
//       try {
//         final bytes = base64Decode(profile!.profileImagePath!);
//         return MemoryImage(bytes);
//       } catch (e) {
//         debugPrint('Error decoding base64 image: $e');
//         return null;
//       }
//     } else {
//       return FileImage(File(profile!.profileImagePath!));
//     }
//   }
// } 
// lib/screens/profile/widgets/profile_header.dart
import 'dart:convert';
import 'dart:io';
import 'package:cream_ventory/core/utils/profile/profile_display_logics.dart';
import 'package:cream_ventory/models/user_model.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:material_symbols_icons/symbols.dart';


class ProfileHeader extends StatelessWidget {
  final UserModel profile;
  final ProfileDisplayLogic logic;

  const ProfileHeader({super.key, required this.profile, required this.logic});

  ImageProvider? _getImageProvider() {
    if (profile.profileImagePath == null || profile.profileImagePath!.isEmpty) {
      return null;
    }
    if (kIsWeb) {
      try {
        final bytes = base64Decode(profile.profileImagePath!);
        return MemoryImage(bytes);
      } catch (e) {
        debugPrint('Error decoding base64 image: $e');
        return null;
      }
    } else {
      return FileImage(File(profile.profileImagePath!));
    }
  }

  @override
  Widget build(BuildContext context) {
    final imageProvider = _getImageProvider();

    return SliverAppBar(
      expandedHeight: 300,
      pinned: true,
      backgroundColor: const Color.fromARGB(151, 0, 0, 0),
      leading: IconButton(
        icon: const Icon(Icons.arrow_back_ios_rounded, color: Colors.white),
        onPressed: () => Navigator.pop(context),
      ),
      actions: [
        Padding(
          padding: const EdgeInsets.only(right: 8),
          child: IconButton(
            onPressed: logic.navigateToEditProfile,
            icon: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(Icons.edit_rounded, color: Colors.white, size: 22),
            ),
          ),
        ),
      ],
      flexibleSpace: FlexibleSpaceBar(
        background: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Color(0xFF7B68EE),
                Color(0xFF9B7FDB),
                Color(0xFFB794D6),
                Color(0xFFD4A5C8),
              ],
              stops: [0.0, 0.35, 0.65, 1.0],
            ),
          ),
          child: Stack(
            children: [
              Positioned(
                top: -60,
                right: -60,
                child: Container(width: 200, height: 200, decoration: BoxDecoration(shape: BoxShape.circle, color: Colors.white.withOpacity(0.1))),
              ),
              Positioned(
                bottom: 40,
                left: -40,
                child: Container(width: 120, height: 120, decoration: BoxDecoration(shape: BoxShape.circle, color: Colors.white.withOpacity(0.1))),
              ),
              Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const SizedBox(height: 60),
                    Container(
                      padding: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white, width: 3),
                        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.2), blurRadius: 20, offset: const Offset(0, 10))],
                      ),
                      child: CircleAvatar(
                        radius: 55,
                        backgroundColor: Colors.white,
                        child: imageProvider != null
                            ? CircleAvatar(radius: 52, backgroundImage: imageProvider)
                            : const Icon(Icons.person_rounded, size: 60, color: Color(0xFF667EEA)),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      profile.name?.isNotEmpty == true ? profile.name! : profile.username,
                      style: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold, fontFamily: 'ABeeZee'),
                    ),
                    const SizedBox(height: 6),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                      decoration: BoxDecoration(color: Colors.white.withOpacity(0.2), borderRadius: BorderRadius.circular(20)),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Symbols.store_rounded, color: Colors.white, size: 18),
                          const SizedBox(width: 8),
                          Text(
                            profile.distributionName?.isNotEmpty == true ? profile.distributionName! : 'No Distribution',
                            style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w500, fontFamily: 'ABeeZee'),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
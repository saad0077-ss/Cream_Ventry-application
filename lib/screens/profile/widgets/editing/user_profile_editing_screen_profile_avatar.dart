import 'package:cream_ventory/core/utils/profile/edit_profile_logics.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

class ProfileAvatar extends StatefulWidget {
  final EditProfileLogic logic;

  const ProfileAvatar({super.key, required this.logic});

  @override
  State<ProfileAvatar> createState() => _ProfileAvatarState();
}

class _ProfileAvatarState extends State<ProfileAvatar> {
  @override
  void initState() {
    super.initState();
    // Set the callback to rebuild this widget when image changes
    widget.logic.onImageLoaded = () {
      if (mounted) {
        setState(() {});
      }
    };
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Container(
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.3),
                blurRadius: 20,
                spreadRadius: 5,
              ),
            ],
          ),
          child: CircleAvatar(
            radius: 65,
            backgroundColor: Colors.white,
            child: CircleAvatar(
              radius: 62,
              backgroundImage: kIsWeb
                  ? (widget.logic.imageBytes != null
                      ? MemoryImage(widget.logic.imageBytes!)
                      : const AssetImage('assets/image/account.png'))
                  : (widget.logic.profileImage != null
                      ? FileImage(widget.logic.profileImage!)
                      : const AssetImage('assets/image/account.png')) as ImageProvider,
            ),
          ),
        ),
        Positioned(
          bottom: 0,
          right: 0,
          child: GestureDetector(
            onTap: () async {
              await widget.logic.pickImage(context);
            },
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Colors.blue.shade400, Colors.blue.shade700],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: Colors.blue.withOpacity(0.4),
                    blurRadius: 10,
                    spreadRadius: 2,
                  ),
                ],
              ),
              padding: const EdgeInsets.all(12),
              child: const Icon(Icons.camera_alt, size: 20, color: Colors.white),
            ),
          ),
        ), 
      ],
    );
  }
}
import 'dart:io';
import 'package:cream_ventory/db/models/user/user_model.dart';
import 'package:cream_ventory/user_profile/widgets/user_profile_buttons.dart';
import 'package:cream_ventory/utils/profile/profile_display_logics.dart';
import 'package:flutter/material.dart';
import 'package:material_symbols_icons/symbols.dart';

class BodyOfProfilePage extends StatelessWidget {
  const BodyOfProfilePage({
    super.key,
    required this.profile,
    required this.logic,
    required this.constraints,
  });

  final UserModel? profile;
  final ProfileDisplayLogic logic;
  final BoxConstraints constraints;

  @override
  Widget build(BuildContext context) {
    final isSmallScreen = constraints.maxWidth < 600;
    final avatarSize = isSmallScreen ? 100.0 : 120.0;
    final fontSize = isSmallScreen ? 14.0 : 16.0;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(height: 20),
        Card(
          elevation: 10,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20.0),
          ),
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20.0),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 20,
                  offset: Offset(0, 10),
                ),
              ],
            ),
            padding: EdgeInsets.all(isSmallScreen ? 16.0 : 24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    AnimatedContainer(
                      duration: Duration(milliseconds: 200),
                      width: avatarSize,
                      height: avatarSize,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: LinearGradient(
                          colors: [Color(0xFFFF6B6B), Color(0xFF60A5FA)],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.2),
                            blurRadius: 12,
                            offset: Offset(0, 4),
                          ),
                        ],
                      ),
                      padding: EdgeInsets.all(4.0),
                      child: CircleAvatar(
                        radius: avatarSize / 2 - 4,
                        backgroundImage: profile?.profileImagePath != null
                            ? FileImage(File(profile!.profileImagePath!))
                            : AssetImage('assets/image/profile.jpg')
                                  as ImageProvider,
                      ),
                    ),
                    SizedBox(width: isSmallScreen ? 16.0 : 24.0),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Username',
                            style: TextStyle(
                              fontSize: fontSize,
                              fontWeight: FontWeight.w600,
                              color: const Color.fromARGB(202, 0, 0, 0),
                              fontFamily: 'ABeeZee',
                            ),
                          ),
                          SizedBox(height: 8),
                          _buildTextField(
                            text: profile?.name ?? 'Eg: JONE HONG',
                            fontSize: fontSize,
                          ),
                          SizedBox(height: 12),
                          Text(
                            'Distribution Name',
                            style: TextStyle(
                              fontSize: fontSize,
                              fontWeight: FontWeight.w600,
                              color: Colors.black87,
                              fontFamily: 'ABeeZee',
                            ),
                          ),
                          SizedBox(height: 8),
                          _buildTextField(
                            text:
                                profile?.distributionName ??
                                'Eg: TOMMY DISTRIBUTORS',
                            fontSize: fontSize,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 20),
                _buildInfoRow(
                  icon: Symbols.email_rounded,
                  label: 'Email ID',
                  text: profile?.email ?? 'Eg: tommy12distributor22@gmail.com',
                  fontSize: fontSize,
                ),
                SizedBox(height: 20),
                _buildInfoRow(
                  icon: Symbols.phone_rounded,
                  label: 'Contact No',
                  text: profile?.phone ?? 'Eg: +91 8921873547',
                  fontSize: fontSize,
                ),
                SizedBox(height: 20),
                _buildInfoRow(
                  icon: Symbols.location_on_rounded,
                  label: 'Address',
                  text:
                      profile?.address ??
                      'Eg: Tommy Distributor\n3388 Ocean View Road\nMiami, FL 33101\nUnited States',
                  fontSize: fontSize,
                  isMultiline: true,
                ),
              ],
            ),
          ),
        ),
        SizedBox(height: 20),
        ProfileButtons(logic: logic, constraints: constraints),
      ],
    );
  }

  Widget _buildTextField({required String text, required double fontSize}) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(12.0),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Text(
        text,
        style: TextStyle(
          fontSize: fontSize,
          fontWeight: FontWeight.w600,
          color: Colors.black87,
          fontFamily: 'ABeeZee',
        ),
      ),
    );
  }

  Widget _buildInfoRow({
    required IconData icon,
    required String label,
    required String text,
    required double fontSize,
    bool isMultiline = false,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, color: Color(0xFF60A5FA), size: fontSize + 4),
            SizedBox(width: 8),
            Text(
              label,
              style: TextStyle(
                fontSize: fontSize,
                fontWeight: FontWeight.w600,
                color: Colors.black87,
                fontFamily: 'ABeeZee',
              ),
            ),
          ],
        ),
        SizedBox(height: 8),
        Container(
          width: double.infinity,
          padding: EdgeInsets.all(isMultiline ? 12.0 : 10.0),
          decoration: BoxDecoration(
            color: Colors.grey.shade50,
            borderRadius: BorderRadius.circular(12.0),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 8,
                offset: Offset(0, 2),
              ),
            ],
          ),
          child: Text(
            text,
            style: TextStyle(
              fontSize: fontSize,
              fontWeight: FontWeight.w600,
              color: Colors.black87,
              fontFamily: 'ABeeZee',
            ),
            maxLines: isMultiline ? 4 : 1,
            overflow: isMultiline ? TextOverflow.fade : TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }
}

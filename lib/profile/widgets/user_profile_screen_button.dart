import 'package:cream_ventory/utils/profile/profile_display_logics.dart';
import 'package:flutter/material.dart';
import 'package:material_symbols_icons/symbols.dart';

class ProfileButtons extends StatefulWidget {
  final ProfileDisplayLogic logic;
  final BoxConstraints constraints;

  const ProfileButtons({
    super.key,
    required this.logic,
    required this.constraints,
  });

  @override
  _ProfileButtonsState createState() => _ProfileButtonsState();
}

class _ProfileButtonsState extends State<ProfileButtons> {
  bool _isChangePasswordPressed = false;
  bool _isEditProfilePressed = false;
  bool _isLogoutPressed = false;

  @override
  Widget build(BuildContext context) {
    final isSmallScreen = widget.constraints.maxWidth < 600;
    final buttonHeight = isSmallScreen ? 56.0 : 64.0;
    final fontSize = isSmallScreen ? 16.0 : 18.0;

    return Column(
      children: [
        SizedBox(height: 20),
        _buildButton(
          icon: Symbols.lock_rounded,
          text: 'Change Password',
          onTap: () {
            setState(() => _isChangePasswordPressed = true);
            widget.logic.navigateToChangePassword();
            Future.delayed(Duration(milliseconds: 200), () {
              setState(() => _isChangePasswordPressed = false);
            });
          },
          isPressed: _isChangePasswordPressed,
          buttonHeight: buttonHeight,
          fontSize: fontSize,
          color: Colors.blueGrey
        ),
        SizedBox(height: 20),
        _buildButton(
          icon: Symbols.edit_rounded,
          text: 'Edit User Information',
          onTap: () {
            setState(() => _isEditProfilePressed = true);
            widget.logic.navigateToEditProfile();
            Future.delayed(Duration(milliseconds: 200), () {
              setState(() => _isEditProfilePressed = false);
            });
          },
          isPressed: _isEditProfilePressed,
          buttonHeight: buttonHeight,
          fontSize: fontSize,
          color: Colors.blueGrey
        ),
        SizedBox(height: 20),
        _buildButton(
          icon: Symbols.logout_rounded,
          text: 'Logout',
          onTap: () {
            setState(() => _isLogoutPressed = true);
            widget.logic.logout();
            Future.delayed(Duration(milliseconds: 200), () {
              setState(() => _isLogoutPressed = false);
            });
          },
          isPressed: _isLogoutPressed,
          buttonHeight: buttonHeight,
          fontSize: fontSize,
          textColor: Colors.white,
          iconColor: Colors.white,
          color: Colors.redAccent
        ),
      ],
    );
  }

  Widget _buildButton({
    required IconData icon,
    required String text,
    required VoidCallback onTap,
    required bool isPressed,
    required double buttonHeight,
    required double fontSize,
    required Color color,
    Color textColor = Colors.white,
    Color iconColor = Colors.white,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: Duration(milliseconds: 200),
        height: buttonHeight,
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(12.0),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(isPressed ? 0.3 : 0.2),
              blurRadius: isPressed ? 12 : 8,
              offset: Offset(0, isPressed ? 6 : 4),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.0),
              child: Row(
                children: [
                  Icon(icon, color: iconColor, size: fontSize + 4),
                  SizedBox(width: 12),
                  Text(
                    text,
                    style: TextStyle(
                      fontSize: fontSize,
                      fontWeight: FontWeight.w600,
                      color: textColor,
                      fontFamily: 'ABeeZee',
                    ), 
                  ),
                ],
              ),
            ),
            Padding(
              padding: EdgeInsets.only(right: 16.0),
              child: Icon(
                Symbols.chevron_right_rounded,    
                color: iconColor,
                size: fontSize + 4,
              ),   
            ),
          ],
        ),
      ),
    );
  }
}

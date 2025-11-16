import 'dart:convert';
import 'dart:io';
import 'package:cream_ventory/models/user_model.dart';
import 'package:cream_ventory/screens/profile/widgets/user_profile_screen_button.dart';
import 'package:cream_ventory/core/utils/profile/profile_display_logics.dart';
import 'package:flutter/foundation.dart';
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
    final avatarSize = isSmallScreen ? 110.0 : 150.0;
    final fontSize = isSmallScreen ? 14.0 : 16.0;

    const defaultImage = AssetImage('assets/image/profile.jpg');

    ImageProvider? imageProvider;
    if (profile != null && profile!.profileImagePath != null && profile!.profileImagePath!.isNotEmpty) {
      if (kIsWeb) {
        try {
          final bytes = base64Decode(profile!.profileImagePath!);
          imageProvider = MemoryImage(bytes);
        } catch (e) {
          debugPrint('Error decoding base64 image: $e');
          imageProvider = defaultImage;
        }
      } else {
        imageProvider = FileImage(File(profile!.profileImagePath!));
      }
    } else {
      imageProvider = defaultImage;
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 16),
        
        // Hero Profile Card with Gradient Background
        _buildHeroCard(imageProvider, avatarSize, fontSize, isSmallScreen),
        
        const SizedBox(height: 16),
        
        // Financial Overview Cards
        _buildFinancialCards(fontSize, isSmallScreen),
        
        const SizedBox(height: 16),
        
        // Detailed Information Card
        _buildDetailsCard(fontSize, isSmallScreen),
        
        const SizedBox(height: 20),
        ProfileButtons(logic: logic, constraints: constraints),
      ],
    );
  }
      
  Widget _buildHeroCard(ImageProvider imageProvider, double avatarSize, double fontSize, bool isSmallScreen) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration( 
        gradient: const LinearGradient(
          colors: [Color(0xFF667eea), Color(0xFF764ba2)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24.0),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF667eea).withOpacity(0.4),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      padding: EdgeInsets.all(isSmallScreen ? 20.0 : 28.0),
      child: Column(
        children: [
          // Avatar with animated border
          Container(
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.2),
                  blurRadius: 20,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: Container(
              padding: const EdgeInsets.all(5.0),
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                gradient: LinearGradient(
                  colors: [Colors.white, Color(0xFFF8F9FA)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
              child: CircleAvatar(
                radius: avatarSize / 2,
                backgroundImage: imageProvider,
              ),
            ),
          ),
          
          const SizedBox(height: 20),
          
          // User Name
          Text(
            profile?.name ?? profile?.username ?? 'JONE HONG',
            style: TextStyle(
              fontSize: fontSize + 8,
              fontWeight: FontWeight.bold,
              color: Colors.white,
              fontFamily: 'ABeeZee',
              letterSpacing: 0.5,
            ),
            textAlign: TextAlign.center,
          ),
          
          const SizedBox(height: 8),
          
          // Distribution Name with Icon
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(
                  Symbols.store_rounded,
                  color: Colors.white,
                  size: 18,
                ),
                const SizedBox(width: 8),
                Flexible(
                  child: Text(
                    profile?.distributionName ?? 'TOMMY DISTRIBUTORS',
                    style: TextStyle(
                      fontSize: fontSize,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                      fontFamily: 'ABeeZee',
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFinancialCards(double fontSize, bool isSmallScreen) {
    // TODO: Replace these with actual data from your database
    final totalIncome = 125000.00; // Get from your income transactions
    final totalExpense = 85000.00; // Get from your expense transactions

    return Row(
      children: [
        Expanded(
          child: _buildFinancialCard(
            icon: Symbols.trending_up_rounded,
            title: 'Total Income',
            amount: totalIncome,
            color: const Color(0xFF10b981),
            fontSize: fontSize,
            isSmallScreen: isSmallScreen,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildFinancialCard(
            icon: Symbols.trending_down_rounded,
            title: 'Total Expense',
            amount: totalExpense,
            color: const Color(0xFFef4444),
            fontSize: fontSize,
            isSmallScreen: isSmallScreen,
          ),
        ),
      ],
    );
  }

  Widget _buildFinancialCard({
    required IconData icon,
    required String title,
    required double amount,
    required Color color,
    required double fontSize,
    required bool isSmallScreen,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20.0),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.15),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      padding: EdgeInsets.all(isSmallScreen ? 16.0 : 20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              icon,
              color: color,
              size: isSmallScreen ? 24 : 28,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            title,
            style: TextStyle(
              fontSize: fontSize - 2,
              fontWeight: FontWeight.w600,
              color: Colors.grey.shade600,
              fontFamily: 'ABeeZee',
            ),
          ),
          const SizedBox(height: 6),
          Text(
            '₹${amount.toStringAsFixed(2)}',
            style: TextStyle(
              fontSize: fontSize + 4,
              fontWeight: FontWeight.bold,
              color: color,
              fontFamily: 'ABeeZee',
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailsCard(double fontSize, bool isSmallScreen) {
    return Container(
      decoration: BoxDecoration( 
        color: Colors.white, 
        borderRadius: BorderRadius.circular(24.0),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      padding: EdgeInsets.all(isSmallScreen ? 20.0 : 28.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Contact Information',
            style: TextStyle(
              fontSize: fontSize + 4,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
              fontFamily: 'ABeeZee',
            ),
          ),
          const SizedBox(height: 20),
          
          _buildModernInfoRow(
            icon: Symbols.email_rounded,
            label: 'Email ID',
            text: profile?.email ?? 'tommy12distributor22@gmail.com',
            fontSize: fontSize,
            color: const Color(0xFF3b82f6),
          ),
          
          const SizedBox(height: 16),
          
          _buildModernInfoRow(
            icon: Symbols.phone_rounded,
            label: 'Contact No',
            text: profile?.phone ?? '+91 8921873547',
            fontSize: fontSize,
            color: const Color(0xFF8b5cf6),
          ),
          
          const SizedBox(height: 16),
          
          _buildModernInfoRow(
            icon: Symbols.location_on_rounded,
            label: 'Address',
            text: profile?.address ??
                'Tommy Distributor\n3388 Ocean View Road\nMiami, FL 33101\nUnited States',
            fontSize: fontSize,
            color: const Color(0xFFf59e0b),
            isMultiline: true,
          ),
        ],
      ),
    );
  }

  Widget _buildModernInfoRow({
    required IconData icon,
    required String label,
    required String text,
    required double fontSize,
    required Color color,
    bool isMultiline = false,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.05),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: color.withOpacity(0.2),
          width: 1,
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withOpacity(0.15),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(
              icon,
              color: color,
              size: 20,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    fontSize: fontSize - 2,
                    fontWeight: FontWeight.w600,
                    color: Colors.grey.shade600,
                    fontFamily: 'ABeeZee',
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  text,
                  style: TextStyle(
                    fontSize: fontSize,
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                    fontFamily: 'ABeeZee',
                    height: 1.4,
                  ),
                  maxLines: isMultiline ? 4 : 1,
                  overflow: isMultiline ? TextOverflow.fade : TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  } 
}
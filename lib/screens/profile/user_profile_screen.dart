import 'package:cream_ventory/core/theme/theme.dart';
import 'package:cream_ventory/database/functions/user_db.dart';
import 'package:cream_ventory/models/user_model.dart';
import 'package:cream_ventory/core/utils/profile/profile_display_logics.dart';
import 'package:cream_ventory/screens/profile/widgets/profile/user_profile_screen_account_actions_section.dart';
import 'package:cream_ventory/screens/profile/widgets/profile/user_profile_screen_account_stats_section.dart';
import 'package:cream_ventory/screens/profile/widgets/profile/user_profile_screen_address_section.dart';
import 'package:cream_ventory/screens/profile/widgets/profile/user_profile_screen_contact_info_section.dart';
import 'package:cream_ventory/screens/profile/widgets/profile/user_profile_screen_financial_summary_section.dart';
import 'package:cream_ventory/screens/profile/widgets/profile/user_profile_screen_header.dart';
import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ProfileDisplayPage extends StatelessWidget {
  const ProfileDisplayPage({super.key});

  Future<bool> _isDemoUser() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool('isDemoUser') ?? false;
  }

  @override
  Widget build(BuildContext context) {
    final logic = ProfileDisplayLogic(context);

    return Scaffold(
      body: FutureBuilder<bool>(
        future: UserDB.isUserLoggedIn(),
        builder: (context, loginSnapshot) {
          if (loginSnapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(color: Color(0xFF667EEA)),
            );
          }

          if (loginSnapshot.hasData && loginSnapshot.data == true) {
            return FutureBuilder<UserModel>(
              future: UserDB.getCurrentUser(),
              builder: (context, userSnapshot) {
                if (userSnapshot.connectionState == ConnectionState.waiting) {
                  return const Center(
                    child: CircularProgressIndicator(color: Color(0xFF667EEA)),
                  );
                }
                if (!userSnapshot.hasData) {
                  return const Center(child: Text('Error loading user data'));
                }

                final user = userSnapshot.data!;
                
                // Check if it's a demo user
                return FutureBuilder<bool>(       
                  future: _isDemoUser(),
                  builder: (context, demoSnapshot) {
                    if (demoSnapshot.connectionState == ConnectionState.waiting) {
                      return const Center(
                        child: CircularProgressIndicator(color: Color(0xFF667EEA)),
                      );
                    }

                    final isDemoUser = demoSnapshot.data ?? false;

                    // For demo user, don't use ValueListenableBuilder
                    if (isDemoUser) {
                      return Container(
                        decoration: const BoxDecoration(gradient: AppTheme.appGradient),
                        child: CustomScrollView(
                          slivers: [
                            ProfileHeader(profile: user, logic: logic),
                            SliverToBoxAdapter(
                              child: Padding(
                                padding: const EdgeInsets.all(20),
                                child: Column(
                                  children: [
                                    FinancialSummarySection(logic: logic),
                                    const SizedBox(height: 16),
                                    ContactInfoSection(profile: user),
                                    const SizedBox(height: 16),
                                    const AccountStatsSection(),
                                    const SizedBox(height: 16),
                                    AddressSection(profile: user),
                                    const SizedBox(height: 24),
                                    AccountActionsSection(logic: logic),
                                    const SizedBox(height: 30),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      );
                    }

                    // For regular users, use ValueListenableBuilder
                    return ValueListenableBuilder<Box<UserModel>>(
                      valueListenable: UserDB.getUserProfileListenable(user.id),
                      builder: (context, box, _) {
                        final currentUser = box.get(user.id);
                        if (currentUser == null) {
                          return const Center(child: Text('User data not found'));
                        }

                        return Container(
                          decoration: const BoxDecoration(gradient: AppTheme.appGradient),
                          child: CustomScrollView(
                            slivers: [
                              ProfileHeader(profile: currentUser, logic: logic),
                              SliverToBoxAdapter(
                                child: Padding(
                                  padding: const EdgeInsets.all(20),
                                  child: Column(
                                    children: [
                                      FinancialSummarySection(logic: logic),
                                      const SizedBox(height: 16),
                                      ContactInfoSection(profile: currentUser),
                                      const SizedBox(height: 16),
                                      const AccountStatsSection(),
                                      const SizedBox(height: 16),
                                      AddressSection(profile: currentUser),
                                      const SizedBox(height: 24),
                                      AccountActionsSection(logic: logic),
                                      const SizedBox(height: 30),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    );
                  },
                );
              },
            );
          }
  
          return const Center(
            child: Text('Please log in to view your profile'),
          );
        },
      ),
    );
  }
}
import 'package:cream_ventory/database/functions/user_db.dart';
import 'package:cream_ventory/models/user_model.dart';
import 'package:cream_ventory/core/theme/theme.dart';
import 'package:cream_ventory/screens/profile/widgets/user_profile_screen_body/user_profile_screen_body.dart';
import 'package:cream_ventory/core/utils/profile/profile_display_logics.dart';
import 'package:cream_ventory/widgets/app_bar.dart';
import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';

class ProfileDisplayPage extends StatelessWidget {
  const ProfileDisplayPage({super.key});

  @override
  Widget build(BuildContext context) {
    final logic = ProfileDisplayLogic(context);

    return Scaffold(
      appBar: CustomAppBar(title: 'My Profile', fontSize: 24),
      extendBodyBehindAppBar: false,      
      body: Container(
        decoration: BoxDecoration(gradient: AppTheme.appGradient),
        width: double.infinity,
        height: double.infinity,
        child: FutureBuilder<bool>(
          future: UserDB.isUserLoggedIn(),
          builder: (context, loginSnapshot) {
            if (loginSnapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }
            if (loginSnapshot.hasData && loginSnapshot.data == true) {
              return FutureBuilder<UserModel>( 
                future: UserDB.getCurrentUser(),
                builder: (context, userSnapshot) {    
                  if (userSnapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  if (userSnapshot.hasData) {
                    final user = userSnapshot.data!;
                    return ValueListenableBuilder<Box<UserModel>>(
                      valueListenable: UserDB.getUserProfileListenable(user.id),
                      builder: (context, box, _) {
                        final currentUser = box.get(user.id);
                        if (currentUser == null) {
                          return const Center(child: Text('User data not found'));
                        }
                        return Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 17.0,
                            vertical: 1.0,
                          ),
                          child: SingleChildScrollView(
                            child: BodyOfProfilePage(      
                              profile: currentUser,
                              logic: logic, 
                              constraints: BoxConstraints(
                                maxWidth: MediaQuery.of(context).size.width,
                                maxHeight: MediaQuery.of(context).size.height,
                              ),
                            ),
                          ),
                        );
                      },
                    );
                  }
                  return const Center(child: Text('Error loading user data'));
                },
              );
            }
            return const Center(child: Text('Please log in to view your profile'));
          },
        ),
      ),
    );
  }
} 
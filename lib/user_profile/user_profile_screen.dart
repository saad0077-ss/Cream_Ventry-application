import 'package:cream_ventory/db/functions/user_db.dart';
import 'package:cream_ventory/db/models/user/user_model.dart';
import 'package:cream_ventory/themes/app_theme/theme.dart';
import 'package:cream_ventory/user_profile/widgets/user_profile_body.dart';
import 'package:cream_ventory/utils/profile/profile_display_logics.dart';
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
                            horizontal: 16.0,
                            vertical: 20.0,
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
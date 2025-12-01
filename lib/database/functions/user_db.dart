import 'package:cream_ventory/models/user_model.dart';
import 'package:cream_ventory/core/utils/authentication/authentication_sign_in.dart';
import 'package:flutter/foundation.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';

class UserDB {
  static const String _userBoxName = 'userBox';
  static bool _isInitialized = false;

  /// Initialize Hive database with UserModel adapter
  static Future<void> initializeHive() async {
    if (!_isInitialized) {
      if (!Hive.isAdapterRegistered(0)) {
        Hive.registerAdapter(UserModelAdapter());
      }
      await Hive.openBox<UserModel>(_userBoxName); 
      _isInitialized = true;
    }
  }

  /// Create a new user account
  static Future<void> createUser({
    required String email,
    required String username,
    required String password,
  }) async {
    await initializeHive();
    final box = Hive.box<UserModel>(_userBoxName);

    // Normalize inputs
    final normalizedEmail = email.toLowerCase().trim();
    final normalizedUsername = username.toLowerCase().trim();

    // Validate inputs
    if (normalizedEmail.isEmpty || normalizedUsername.isEmpty) {
      throw Exception('Email and username cannot be empty');
    }

    // Check if user already exists
    if (await userExists(normalizedEmail) ||
        await userExists(normalizedUsername)) {
      throw Exception('User with this email or username already exists');
    }

    // Hash password
    final hashedPassword = LoginFunctions.hashPassword(password);
    final userId = Uuid().v4();

    // Create new user
    final user = UserModel(
      id: userId,
      email: normalizedEmail,
      username: normalizedUsername,
      password: hashedPassword,
    );

    // Save user
    await box.put(userId, user);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('currentUserId', userId);

    debugPrint('User created: $userId ${user.username} (${user.email})');
    debugPrint('Total users: ${box.length}');
  }

  /// Check if user exists by email or username
  static Future<bool> userExists(String emailOrUsername) async {
    await initializeHive();
    final box = Hive.box<UserModel>(_userBoxName);
    final normalizedQuery = emailOrUsername.toLowerCase().trim();

    return box.values.any(
      (user) =>
          user.email.toLowerCase().trim() == normalizedQuery ||
          user.username.toLowerCase().trim() == normalizedQuery,
    );
  }

  /// Authenticate user by email/username and password
  static Future<UserModel?> authenticateUser(
    String emailOrUsername,
    String password,
  ) async {
    try {
      await initializeHive();
      final box = Hive.box<UserModel>(_userBoxName);
      final normalizedQuery = emailOrUsername.toLowerCase().trim();
      final hashedPassword = LoginFunctions.hashPassword(password);

      for (var user in box.values) {
        if ((user.email.toLowerCase().trim() == normalizedQuery ||
                user.username.toLowerCase().trim() == normalizedQuery) &&
            user.password == hashedPassword) {
          // Set login flag
          debugPrint("111111111111111111111111-------------------${user.id}");
          await setLoggedInStatus(true, user.id);
          return user;
        }
      }
      return null;
    } catch (e) {
      debugPrint('Authentication error: $e');
      return null;
    }
  }

  /// Get user by ID
  static Future<UserModel?> getUserById(String userId) async {
    await initializeHive();
    final box = Hive.box<UserModel>(_userBoxName);
    return box.get(userId);
  }

  /// Get user by email or username
  static Future<UserModel?> getUserByEmailOrUsername(
    String emailOrUsername,
  ) async {
    await initializeHive();
    final box = Hive.box<UserModel>(_userBoxName);
    final normalizedQuery = emailOrUsername.toLowerCase().trim();

    for (var user in box.values) {
      if (user.email.toLowerCase().trim() == normalizedQuery ||
          user.username.toLowerCase().trim() == normalizedQuery) {
        return user;
      }
    }
    return null;
  }

  /// Get all users (admin/debug use)
  static Future<List<UserModel>> getAllUsers() async {
    await initializeHive();
    final box = Hive.box<UserModel>(_userBoxName);
    return box.values.toList();
  }

  /// Update user profile information
  static Future<bool> updateProfile({
  required String userId,
  String? name,
  String? username,
  String? email,
  String? distributionName,
  String? phone,
  String? address,
  String? profileImagePath,
}) async {
  try {
    await initializeHive();
    final box = Hive.box<UserModel>(_userBoxName);
    final user = box.get(userId);

    if (user == null) return false;

    // Normalize
    final normalizedUsername = username?.toLowerCase().trim();
    final normalizedEmail = email?.toLowerCase().trim(); 

    // Skip if no change
    final usernameChanged = normalizedUsername != null && normalizedUsername != user.username;
    final emailChanged = normalizedEmail != null && normalizedEmail != user.email;

    // === CHECK UNIQUENESS ===
    if (usernameChanged || emailChanged) {
      for (final u in box.values) {
        if (u.id == userId) continue;

        if (usernameChanged && u.username == normalizedUsername) {
          debugPrint('Username already exists: $normalizedUsername');
          return false;
        }
        if (emailChanged && u.email == normalizedEmail) {
          debugPrint('Email already exists: $normalizedEmail');
          return false;
        }
      }
    }

    // === SAVE ===
    final updatedUser = UserModel(
      id: user.id,
      email: normalizedEmail ?? user.email,
      username: normalizedUsername ?? user.username,
      password: user.password,
      name: name?.trim(),
      distributionName: distributionName?.trim(),
      phone: phone?.trim(),
      address: address?.trim(),
      profileImagePath: profileImagePath,
    );

    await box.put(userId, updatedUser);
    debugPrint('Profile updated: ${updatedUser.username} (${updatedUser.email})');
    return true;
  } catch (e) {
    debugPrint('Update error: $e');
    return false;
  }
}

  /// Update user password
  static Future<bool> updatePassword({
    required String userId,
    required String newPassword,
  }) async {
    try {
      await initializeHive();
      final box = Hive.box<UserModel>(_userBoxName);
      final user = box.get(userId);

      if (user == null) {
        debugPrint('User not found for ID: $userId');
        return false;
      }

      final hashedPassword = LoginFunctions.hashPassword(newPassword);

      // Create updated user with new password
      final updatedUser = UserModel(
        id: user.id,
        email: user.email,
        username: user.username,
        password: hashedPassword,
        name: user.name,
        distributionName: user.distributionName,
        phone: user.phone,
        address: user.address,
        profileImagePath: user.profileImagePath,
      );

      await box.put(userId, updatedUser);
      debugPrint('Password updated for user: ${updatedUser.username}');
      return true;
    } catch (e) {
      debugPrint('Error updating password: $e');
      return false;
    }
  }

  /// Get current logged-in user
  static Future<UserModel> getCurrentUser() async {
    final prefs = await SharedPreferences.getInstance();
    final userId = prefs.getString('currentUserId');
    if (userId == null) {
      throw Exception('No current user found');
    }

    final box = Hive.box<UserModel>(_userBoxName);
    final user = box.get(userId);      
    if (user == null) {
      throw Exception('User not found in database');
    }
    return user;
  }

  /// Logout user (clears session) 
  static Future<void> logoutUser() async {
    await setLoggedInStatus(false, '');
  }

  /// Check if user is logged in
  static Future<bool> isUserLoggedIn() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool('isLoggedIn') ?? false;
  }

  /// Delete user account
  static Future<bool> deleteUser(String userId) async {
    try {
      await initializeHive();
      final box = Hive.box<UserModel>(_userBoxName);
      final user = box.get(userId);

      if (user != null) {
        await box.delete(userId);
        await logoutUser();
        debugPrint('User deleted: ${user.username}');
        return true;
      }
      debugPrint('User not found for ID: $userId');
      return false;
    } catch (e) {
      debugPrint('Error deleting user: $e');
      return false;
    }
  }



  /// Get user profile data only
  static Future<Map<String, dynamic>?> getUserProfile(String userId) async {
    await initializeHive();
    final user = await getUserById(userId);
    if (user != null) {
      return {
        'id': user.id,
        'name': user.name,
        'distributionName': user.distributionName,
        'email': user.email,
        'username': user.username,
        'phone': user.phone,
        'address': user.address,
        'profileImagePath': user.profileImagePath,
      };
    }
    debugPrint('User not found for profile ID: $userId');
    return null;
  }

  /// Clear all user data (for app reset)
  static Future<void> clearAllUsers() async {
    await initializeHive();
    final box = Hive.box<UserModel>(_userBoxName);
    await box.clear();

    // Clear login session
    await logoutUser();
    debugPrint('All user data cleared');
  }

  /// Get ValueListenable for reactive updates to the entire user box
  static ValueListenable<Box<UserModel>> getUserListenable() {
    return Hive.box<UserModel>(_userBoxName).listenable();
  }

  /// Get ValueListenable for a specific user's profile changes
  static ValueListenable<Box<UserModel>> getUserProfileListenable(
    String userId,
  ) {
    return Hive.box<UserModel>(_userBoxName).listenable(keys: [userId]);
  }

  /// Set or clear the logged-in status
  static Future<bool> setLoggedInStatus(bool isLoggedIn, String userId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      if (isLoggedIn) {
        if (userId.isEmpty) {
          throw Exception('userId cannot be empty when isLoggedIn is true');
        }
        await prefs.setBool('isLoggedIn', true);
        await prefs.setString('currentUserId', userId);
        debugPrint('Set logged-in status: true, userId: $userId');
        return true;
      } else {
        await prefs.remove('isLoggedIn');
        await prefs.remove('currentUserId');
        debugPrint('Cleared logged-in status'); 
        return false;
      }
    } catch (e) {
      debugPrint('Error in _setLoggedInStatus: $e');
      return false;
    }
  }
}

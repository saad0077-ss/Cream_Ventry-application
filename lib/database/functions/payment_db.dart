import 'package:cream_ventory/database/functions/user_db.dart';
import 'package:cream_ventory/models/payment_in_model.dart';
import 'package:cream_ventory/models/payment_out_model.dart';
import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:intl/intl.dart';
import 'package:uuid/uuid.dart';

class PaymentInDb {
  static const String boxName = 'payment_in_box';
  static Box<PaymentInModel>? _box;
  static const _uuid = Uuid();
  static final ValueNotifier<List<PaymentInModel>> paymentInNotifier =
      ValueNotifier<List<PaymentInModel>>([]);

  // Initialize Hive and open the box
  static Future<void> init() async {
    try {
      if (!Hive.isAdapterRegistered(12)) {
        Hive.registerAdapter(PaymentInModelAdapter());
      }
      _box = await Hive.openBox<PaymentInModel>(boxName);
      debugPrint(
        'PaymentInDB initialized with ${_box?.values.length} payments',
      );
    } catch (e) {
      debugPrint('Error initializing PaymentInDb: $e');
      rethrow;
    }
  }

  // Generate unique ID
  static String _generateUniqueId() {
    return _uuid.v4();
  }

  // Save a PaymentInModel to Hive
  static Future<void> savePayment(PaymentInModel payment) async {
    if (_box == null) await init();  
    try {
      if (payment.id.isEmpty) { 
        payment.id = _generateUniqueId();
      }
      await _box!.put(payment.id, payment);
      _updateNotifier();
      debugPrint('Saved payment: ${payment.receiptNo}');
    } catch (e) {
      debugPrint('Error saving payment: $e');
      rethrow;
    }
  }

  // Update notifier with current box values
  static void _updateNotifier() async {
    final user = await UserDB.getCurrentUser();
    final userId = user.id;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_box == null) {
        paymentInNotifier.value = [];
        return;
      }
      var payments =
          _box!.values.where((payments) => payments.userId == userId).toList();
      paymentInNotifier.value = payments;
      debugPrint(
        'Notifier updated with ${paymentInNotifier.value.length} payments',
      );
    });
  }

  // Clear all payment items
  static Future<void> clearPaymentIn() async {
    if (_box == null) await init();
    try {
      await _box!.clear();
      debugPrint('Cleared all payment-in records');
      _updateNotifier();
    } catch (e) {
      debugPrint('Error clearing payments: $e');
      rethrow;
    }
  }

  // Update a PaymentInModel
  static Future<bool> updatePayment(PaymentInModel payment) async {
    if (_box == null) await init();
    try {
      final existingPayment = _box!.get(payment.id);
      if (existingPayment == null) {
        debugPrint('Payment not found: ${payment.id}');
        return false;
      }
      await _box!.put(payment.id, payment);
      _updateNotifier();
      debugPrint('Payment updated: ${payment.receiptNo}');
      return true;
    } catch (e) {
      debugPrint('Error updating payment: $e');
      rethrow;
    }
  }

  // Retrieve all PaymentInModels
  static Future<List<PaymentInModel>> getAllPayments() async {
    if (_box == null) init();
    final user = await UserDB.getCurrentUser();
    final userId = user.id;
    try {
      var payments = _box?.values
              .where((payments) => payments.userId == userId)
              .toList() ??
          [];
      debugPrint('Retrieved ${payments.length} payment-in records');
      return payments;
    } catch (e) {
      debugPrint('Error retrieving payments: $e');
      return [];
    }
  }

  // Retrieve a single PaymentInModel by ID
  static PaymentInModel? getPaymentById(String id) {
    try {
      final payment = _box?.get(id);
      if (payment == null) {
        debugPrint('Payment not found: $id');
        return null;
      }
      debugPrint('Retrieved payment: $id');
      return payment;
    } catch (e) {
      debugPrint('Error retrieving payment: $e');
      return null;
    }
  }

  // Delete a PaymentInModel by ID
  static Future<bool> deletePayment(String id) async {
    if (_box == null) await init();
    try {
      final payment = _box!.get(id);
      if (payment == null) {
        debugPrint('Payment not found: $id');
        return false;
      }
      await _box!.delete(id);
      _updateNotifier();
      debugPrint('Payment deleted: $id');
      return true;
    } catch (e) {
      debugPrint('Error deleting payment: $e');
      rethrow;
    }
  }

  // Close the Hive box
  static Future<void> close() async {
    try {
      await _box?.close();
      _box = null;
      debugPrint('PaymentInDb box closed');
    } catch (e) {
      debugPrint('Error closing Hive box: $e');
    }
  }

  static Future<void> refreshPayments() async {
    final user = await UserDB.getCurrentUser();
    final userId = user.id;
    try {
      final box = await Hive.openBox<PaymentInModel>(boxName);
      var payments =
          box.values.where((payments) => payments.userId == userId).toList();
      paymentInNotifier.value = payments;
      debugPrint(
        'PaymentIn notifier refreshed with ${paymentInNotifier.value.length} payments',
      );
    } catch (e) {
      debugPrint('Error refreshing payments: $e');
      paymentInNotifier.value = [];
    }
  }

  static Future<double> getTotalAmountByDate(DateTime date) async {
    final user = await UserDB.getCurrentUser();
    final userId = user.id;
    try {
      final payments = await getAllPayments();
      final total = payments.where((payment) {
        final paymentDate = DateFormat('dd MMM yyyy').parse(payment.date);

        return paymentDate.year == date.year &&
            paymentDate.month == date.month &&
            paymentDate.day == date.day &&
            payment.userId == userId;
      }).fold(0.0, (sum, payment) => sum + (payment.receivedAmount));
      debugPrint('Total payment-in amount for $date: $total');
      return total;
    } catch (e) {
      debugPrint('Error getting total payment-in amount for $date: $e');
      return 0.0;
    }
  }
}

class PaymentOutDb {
  static const String boxName = 'payment_out_box';
  static Box<PaymentOutModel>? _box;
  static final ValueNotifier<List<PaymentOutModel>> paymentOutNotifier =
      ValueNotifier<List<PaymentOutModel>>([]);
  static const _uuid = Uuid();

  // Initialize Hive and load payments
  static Future<void> init() async {
    try {
      if (!Hive.isAdapterRegistered(13)) {
        Hive.registerAdapter(PaymentOutModelAdapter());
      }
      _box = await Hive.openBox<PaymentOutModel>(boxName);
      debugPrint(
        'PaymentOutDb initialized with ${_box?.values.length} payments',
      );
    } catch (e) {
      debugPrint('Error initializing PaymentOutDb: $e');
      rethrow;
    }
  }

  // Generate unique ID
  static String _generateUniqueId() {
    return _uuid.v4();
  }

  // Load all payments from Hive and update notifier
  static Future<void> loadPayments() async {
    final user = await UserDB.getCurrentUser();
    final userId = user.id;

    try {
      final payments = _box?.values
              .where((payments) => payments.userId == userId)
              .toList() ??
          [];
      _updateNotifier();
      debugPrint('Loaded ${payments.length} payment out records');
    } catch (e) {
      debugPrint('Error loading payments: $e');
    }
  }

  // Save a payment to Hive and update notifier
  static Future<void> savePayment(PaymentOutModel payment) async {
    if (_box == null) await init();
    try {
      if(payment.id.isEmpty){
        payment.id = _generateUniqueId();
      }
      
      await _box!.put(payment.id, payment);
      _updateNotifier();
      debugPrint('Saved payment: ${payment.receiptNo}');
    } catch (e) {
      debugPrint('Error saving payment: $e');
      rethrow;
    }
  }

  // Update a payment
  static Future<bool> updatePayment(PaymentOutModel payment) async {
    if (_box == null) await init();
    try {
      final existingPayment = _box!.get(payment.id);
      if (existingPayment == null) {
        debugPrint('Payment not found: ${payment.id}');
        return false;
      }
      await _box!.put(payment.id, payment);
      _updateNotifier();
      debugPrint('Updated payment: ${payment.receiptNo}');
      return true;
    } catch (e) {
      debugPrint('Error updating payment: $e');
      rethrow;
    }
  }

  // Delete a PaymentOutModel by ID
  static Future<bool> deletePayment(String id) async {
    if (_box == null) await init();
    try {
      final payment = _box!.get(id);
      if (payment == null) {
        debugPrint('Payment not found: $id');
        return false;
      }
      await _box!.delete(id);
      _updateNotifier();
      debugPrint('Payment deleted: $id');
      return true;
    } catch (e) {
      debugPrint('Error deleting payment: $e');
      rethrow;
    }
  }

  static Future<void> _updateNotifier() async {
  final user = await UserDB.getCurrentUser();
  final userId = user.id;
  
  if (_box == null) {
    paymentOutNotifier.value = [];
    return;
  }
  
  var payments =
      _box!.values.where((payments) => payments.userId == userId).toList();
  paymentOutNotifier.value = payments;
  debugPrint(
    'Notifier updated with ${paymentOutNotifier.value.length} payments', 
  );
}

  // Clear all payment items
  static Future<void> clearPaymentOut() async {
    if (_box == null) await init();
    try {
      await _box!.clear();
      debugPrint('Cleared all payment-out records');
      _updateNotifier();
    } catch (e) {
      debugPrint('Error clearing payments: $e');
      rethrow;
    }
  }

  // Retrieve all payments
  static Future<List<PaymentOutModel>> getAllPayments() async {
    final user = await UserDB.getCurrentUser();
    final userId = user.id;
    try {
      var payments = _box?.values
              .where((payments) => payments.userId == userId)
              .toList() ??
          [];
      debugPrint('Retrieved ${payments.length} payment-out records');
      return payments;
    } catch (e) {
      debugPrint('Error retrieving payments: $e');
      return [];
    }
  }

  // Retrieve a single PaymentOutModel by ID
  static PaymentOutModel? getPaymentById(String id) {
    try {
      final payment = _box?.get(id);
      if (payment == null) {
        debugPrint('Payment not found: $id');
        return null;
      }
      debugPrint('Retrieved payment: $id');
      return payment;
    } catch (e) {
      debugPrint('Error retrieving payment: $e');
      return null;
    }
  }

  static Future<void> refreshPayments() async {
    final user = await UserDB.getCurrentUser();
    final userId = user.id;
    try {
      final box = await Hive.openBox<PaymentOutModel>(boxName);
      var payments =
          box.values.where((payments) => payments.userId == userId).toList();
      paymentOutNotifier.value = payments;
      debugPrint(
        'PaymentOut notifier refreshed with ${paymentOutNotifier.value.length} payments',
      );
    } catch (e) {
      debugPrint('Error refreshing payments: $e');
      paymentOutNotifier.value = [];
    }
  }

  // Close the Hive box
  static Future<void> close() async {
    try {
      await _box?.close();
      _box = null;
      debugPrint('PaymentOutDb box closed');
    } catch (e) {
      debugPrint('Error closing Hive box: $e');
    }
  }
}

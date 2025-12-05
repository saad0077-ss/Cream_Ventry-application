import 'package:cream_ventory/database/functions/payment_db.dart';
import 'package:cream_ventory/database/functions/sale/sale_db.dart';
import 'package:cream_ventory/database/functions/user_db.dart';
import 'package:cream_ventory/models/party_model.dart';
import 'package:cream_ventory/models/sale_model.dart';
import 'package:flutter/foundation.dart';
import 'package:hive/hive.dart';
import 'package:uuid/uuid.dart';

class PartyDbException implements Exception {
  final String message;
  PartyDbException(this.message);
}

class PartyDb {
  static const String _partyBoxName = 'partyBox';
  static ValueNotifier<List<PartyModel>> partyNotifier = ValueNotifier([]);
  static const _uuid = Uuid();
  static Box<PartyModel>? _partyBox; // Cache box reference

  /// Initialize and load parties
  static Future<void> init() async {
    try {
      _partyBox ??= await Hive.openBox<PartyModel>(_partyBoxName);
      _log('PartyDb initialized with ${_partyBox!.values.length} parties');
    } catch (e) {
      _log('Error initializing PartyDb: $e');
      rethrow;
    }
  }

  /// Retrieve the partyBox, ensuring it’s open
  static Future<Box<PartyModel>> _getPartyBox() async {
    if (_partyBox == null || !_partyBox!.isOpen) {
      _partyBox = await Hive.openBox<PartyModel>(_partyBoxName);
    }
    return _partyBox!;
  }

  /// Load parties
  static Future<void> loadParties() async {
    try {
      await _getPartyBox();
      await refreshParties();
      await _recalculateAllPartyBalances();
      _log(
        'Parties loaded successfully - ${partyNotifier.value.length} parties',
      );
    } catch (e) {
      _log('Error loading parties: $e');
      partyNotifier.value = [];
      rethrow;
    }
  }

  /// Refresh parties from database and notify listeners
  static Future<void> refreshParties() async {
    final user = await UserDB.getCurrentUser();
    final userId = user.id;
    try {
      final box = await _getPartyBox();
      final parties =
          box.values.where((parties) => parties.userId == userId).toList();
      partyNotifier.value = parties;
      _log(
        'Party notifier refreshed with ${partyNotifier.value.length} parties',
      );
    } catch (e) {
      _log('Error refreshing parties: $e');
      partyNotifier.value = [];
      rethrow;
    }
  }

  /// Update notifier with current box values
  static Future<void> _updateNotifier() async {
    final user = await UserDB.getCurrentUser();
    final userId = user.id;
    final box = await _getPartyBox();
    final parties =
        box.values.where((parties) => parties.userId == userId).toList();
    if (partyNotifier.value != parties) {
      partyNotifier.value = parties;
      _log('Notifier updated with ${partyNotifier.value.length} parties');
    }
  }

  /// Add a new party
  static Future<void> addParty(PartyModel party) async {
    try {
      final box = await _getPartyBox();
      party.id = _uuid.v4();
      await box.put(party.id, party);
      await _updateNotifier();
      await calculatePartySummary(party.id);
      _log('Added party: ${party.name}');
    } catch (e) {
      _log('Error adding party: $e');
      rethrow;
    }
  }

  /// Update an existing party (without recalculating balance)
  static Future<bool> updatePartyBasic(PartyModel updatedParty) async {
    try {
      final user = await UserDB.getCurrentUser();
      final userId = user.id;
      final box = await _getPartyBox();
      final existingParty = await getPartyById(updatedParty.id);
      if (existingParty == null) {
        throw PartyDbException('Party with ID ${updatedParty.id} not found');
      }
      final partyToSave = PartyModel(
        id: updatedParty.id,
        name: updatedParty.name,
        contactNumber: updatedParty.contactNumber,
        openingBalance: existingParty.openingBalance,
        asOfDate: updatedParty.asOfDate,
        billingAddress: updatedParty.billingAddress,
        email: updatedParty.email,
        paymentType: updatedParty.paymentType,
        imagePath: updatedParty.imagePath,
        partyBalance: existingParty.partyBalance,
        userId: userId,
      );
      await box.put(updatedParty.id, partyToSave);
      await _updateNotifier();
      _log('Updated party basic info: ${updatedParty.name}');
      return true;
    } catch (e) {
      _log('Error updating party: $e');
      rethrow;
    }
  }

  /// Update party balance specifically
  static Future<void> updatePartyBalance(
    String partyId,
    double newBalance,
  ) async {
    try {
      final box = await _getPartyBox();
      final user = await UserDB.getCurrentUser();
      final userId = user.id;
      final existingParty = await getPartyById(partyId);
      if (existingParty == null) {
        throw PartyDbException('Party with ID $partyId not found');
      }
      final updatedParty = PartyModel(
        id: existingParty.id,
        name: existingParty.name,
        contactNumber: existingParty.contactNumber,
        openingBalance: existingParty.openingBalance,
        asOfDate: existingParty.asOfDate,
        billingAddress: existingParty.billingAddress,
        email: existingParty.email,
        paymentType: existingParty.paymentType,
        imagePath: existingParty.imagePath,
        partyBalance: newBalance,
        userId: userId,
      );
      await box.put(partyId, updatedParty);
      await _updateNotifier();
      _log('Updated balance for party ID $partyId to ₹$newBalance');
    } catch (e) {
      _log('Error updating party balance: $e');
      rethrow;
    }
  }

  /// Delete a party and associated data
  static Future<bool> deleteParty(String id) async {
    try {
      final box = await _getPartyBox();
      final party = await getPartyById(id);
      if (party == null) {
        throw PartyDbException('Party with ID $id not found');
      }
      final sales = await SaleDB.getSales();
      final salesToDelete = sales
          .where(
            (sale) =>
                sale.customerName?.toLowerCase() == party.name.toLowerCase(),
          )
          .toList();
      for (var sale in salesToDelete) {
        await SaleDB.deleteSale(sale.id);
        _log('Deleted sale ${sale.id} for ${party.name}');
      }
      final paymentsIn = await PaymentInDb.getAllPayments();
      final paymentsInToDelete = paymentsIn
          .where(
            (payment) =>
                payment.partyName?.toLowerCase() == party.name.toLowerCase(),
          )
          .toList();
      for (var payment in paymentsInToDelete) {
        await PaymentInDb.deletePayment(payment.id);
        _log('Deleted payment in ${payment.id} for ${party.name}');
      }
      final paymentsOut = await PaymentOutDb.getAllPayments();
      final paymentsOutToDelete = paymentsOut
          .where(
            (payment) =>
                payment.partyName.toLowerCase() == party.name.toLowerCase(),
          )
          .toList();
      for (var payment in paymentsOutToDelete) {
        await PaymentOutDb.deletePayment(payment.id);
        _log('Deleted payment out ${payment.id} for ${party.name}');
      }
      await box.delete(id);
      await _updateNotifier();
      _log('Deleted party ID: $id');
      return true;
    } catch (e) {
      _log('Error deleting party: $e');
      rethrow;
    }
  }

  /// Clear all parties
  static Future<void> clearParties() async {
    try {
      final box = await _getPartyBox();
      await box.clear();
      await SaleDB.clearSales();
      await PaymentInDb.clearPaymentIn();
      await PaymentOutDb.clearPaymentOut();
      _log('Cleared all parties, sales, and payments');
      partyNotifier.value = [];
    } catch (e) {
      _log('Error clearing parties: $e');
      rethrow;
    }
  }

  /// Get a single party by ID
  static Future<PartyModel?> getPartyById(String id) async {
    try {
      final box = await _getPartyBox();
      final party = box.get(id);
      if (party == null) {
        _log('Party not found: $id');
        return null;
      }
      _log('Retrieved party: $id');
      return party;
    } catch (e) {
      _log('Error retrieving party: $e');
      return null;
    }
  }

  /// Calculate party summary
  static Future<double> calculatePartySummary(String partyId) async {
    try {
      await _getPartyBox();
      final party = await getPartyById(partyId);
      if (party == null) {
        throw PartyDbException('Party with ID $partyId not found');
      }
      await SaleDB.refreshSales();
      await PaymentInDb.refreshPayments();
      await PaymentOutDb.refreshPayments();
      final partyNameLower = party.name.toLowerCase();
      double balance = party.openingBalance;

      // Filter sales: exclude canceled sale orders
      final sales = SaleDB.saleNotifier.value.where(
        (s) =>
            s.customerName?.toLowerCase() == partyNameLower &&
            (s.transactionType == TransactionType.saleOrder ||
                s.transactionType == TransactionType.sale) &&
            // Exclude canceled sale orders using the SaleStatus enum
            !(s.transactionType == TransactionType.saleOrder &&
                s.status == SaleStatus.cancelled),
      );

      final paymentsIn = PaymentInDb.paymentInNotifier.value.where(
        (p) => p.partyName?.toLowerCase() == partyNameLower,
      );
      final paymentsOut = PaymentOutDb.paymentOutNotifier.value.where(
        (p) => p.partyName.toLowerCase() == partyNameLower,
      );

      balance += sales.fold(0.0, (sum, s) => sum + (s.balanceDue));
      balance -= paymentsIn.fold(0.0, (sum, p) => sum + p.receivedAmount);
      balance += paymentsOut.fold(0.0, (sum, p) => sum + p.paidAmount);

      final double finalBalance = double.parse(balance.toStringAsFixed(2));
      await updatePartyBalance(partyId, finalBalance);

      _log(
        'Calculated balance for ${party.name}: ₹$finalBalance '
        '(opening: ₹${party.openingBalance}, '
        'Sales: ${sales.length}, Payments In: ${paymentsIn.length}, Payments Out: ${paymentsOut.length})',
      );
      return finalBalance;
    } catch (e) {
      _log('Error calculating party summary for ID $partyId: $e');
      rethrow;
    }
  }

  /// Recalculate all party balances
  static Future<void> _recalculateAllPartyBalances() async {
    try {
      final parties = await getAllParties();
      for (var party in parties) {
        await calculatePartySummary(party.id);
      }
      _log('Recalculated balances for ${parties.length} parties');
    } catch (e) {
      _log('Error recalculating party balances: $e');
      rethrow;
    }
  }

  /// Update party balance after a sale
  static Future<void> updateBalanceAfterSale(SaleModel sale) async {
    if (sale.customerName == null) {
      _log('Invalid sale data: no customer name');
      return;
    }
    final party = await getPartyByIdFromName(sale.customerName!);
    if (party == null) {
      _log('Party not found for name: ${sale.customerName}');
      return;
    }
    await calculatePartySummary(party.id);
    _log('Updated balance after sale for ${sale.customerName}');
  }

  /// Update party balance after a payment
  static Future<void> updateBalanceAfterPayment(
    String partyName,
    double amount,
    bool isPaymentIn,
  ) async {
    final party = await getPartyByIdFromName(partyName);
    if (party == null) {
      _log('Party not found for name: $partyName');
      return;
    }
    await calculatePartySummary(party.id);
    _log(
      'Updated balance after ${isPaymentIn ? "payment in" : "payment out"} for $partyName',
    );
  }

  /// Helper method to get party by name
  static Future<PartyModel?> getPartyByIdFromName(String name) async {
    try {
      final user = await UserDB.getCurrentUser();
      final userId = user.id;
      final box = await _getPartyBox();
      final parties = box.values
          .where(
            (party) =>
                party.userId == userId &&
                party.name.toLowerCase() == name.toLowerCase(),
          )
          .toList();
      if (parties.isEmpty) {
        _log('Party not found for name: $name');
        return null;
      }
      if (parties.length > 1) {
        _log('Warning: Multiple parties found for name: $name');
      }
      return parties.first;
    } catch (e) {
      _log('Error retrieving party by name $name: $e');
      return null;
    }
  }

  /// Calculate total amount you'll get (positive balances)
  static Future<double> calculateTotalYoullGet() async {
    final user = await UserDB.getCurrentUser();
    final userId = user.id;
    try {
      final box = await _getPartyBox();
      final parties =
          box.values.where((parties) => parties.userId == userId).toList();
      double totalBalance = parties.fold(
        0.0,
        (sum, party) => party.partyBalance > 0 ? sum + party.partyBalance : sum,
      );
      return double.parse(totalBalance.toStringAsFixed(2));
    } catch (e) {
      _log('Error calculating total you\'ll get: $e');
      return 0.0;
    }
  }

  /// Calculate total amount you'll give (negative balances)
  static Future<double> calculateTotalYoullGive() async {
    try {
      final user = await UserDB.getCurrentUser();
      final userId = user.id;
      final box = await _getPartyBox();
      final parties =
          box.values.where((parties) => parties.userId == userId).toList();
      double totalBalance = parties.fold(
        0.0,
        (sum, party) =>
            party.partyBalance < 0 ? sum + party.partyBalance.abs() : sum,
      );
      return double.parse(totalBalance.toStringAsFixed(2));
    } catch (e) {
      _log('Error calculating total you\'ll give: $e');
      return 0.0;
    }
  }

  /// Get all parties
  static Future<List<PartyModel>> getAllParties() async {
    try {
      final user = await UserDB.getCurrentUser();
      final userId = user.id;
      final box = await _getPartyBox();
      final parties =
          box.values.where((parties) => parties.userId == userId).toList();
      _log('Retrieved ${parties.length} parties');
      return parties;
    } catch (e) {
      _log('Error retrieving parties: $e');
      return [];
    }
  }

  static Future<void> getSortedYoullGetParties() async {
    try {
      final user = await UserDB.getCurrentUser();
      final userId = user.id;
      final box = await _getPartyBox();
      final parties = box.values
          .where((party) => party.userId == userId && party.partyBalance > 0)
          .toList();
      partyNotifier.value = parties;
      _log('Sorted ${parties.length} parties for You\'ll Get');
    } catch (e) {
      _log('Error sorting You\'ll Get parties: $e');
      partyNotifier.value = [];
      rethrow;
    }
  }

  static Future<void> getSortedYoullGiveParties() async {
    try {
      final user = await UserDB.getCurrentUser();
      final userId = user.id;
      final box = await _getPartyBox();
      final parties = box.values
          .where(
            (party) => party.userId == userId && party.partyBalance < 0,
          )
          .toList()
        ..sort(
          (a, b) => b.partyBalance.abs().compareTo(a.partyBalance.abs()),
        ); // Largest negative to smallest
      partyNotifier.value = parties;
      _log('Sorted ${parties.length} parties for You\'ll Give');
    } catch (e) {
      _log('Error sorting You\'ll Give parties: $e');
      partyNotifier.value = [];
      rethrow;
    }
  }

  /// Reset to unsorted parties
  static Future<void> resetPartyFilter() async {
    await refreshParties();
    _log('Reset party filter to show all parties');
  }

  /// Logging helper for debug mode
  static void _log(String message) {
    if (kDebugMode) {
      debugPrint(message);
    }
  }
}

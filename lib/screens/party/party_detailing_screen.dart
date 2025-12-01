import 'package:cream_ventory/database/functions/party_db.dart';
import 'package:cream_ventory/database/functions/payment_db.dart';
import 'package:cream_ventory/database/functions/sale/sale_db.dart';
import 'package:cream_ventory/models/party_model.dart';
import 'package:cream_ventory/models/sale_model.dart';
import 'package:cream_ventory/screens/party/add_party_screen.dart';
import 'package:cream_ventory/models/payment_in_model.dart';
import 'package:cream_ventory/models/payment_out_model.dart';
import 'package:cream_ventory/core/theme/theme.dart';
import 'package:cream_ventory/core/utils/image_util.dart';
import 'package:cream_ventory/widgets/app_bar.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:top_snackbar_flutter/custom_snack_bar.dart';
import 'package:top_snackbar_flutter/top_snack_bar.dart';

class PartyDetail extends StatefulWidget {
  final String partyId;
  const PartyDetail({super.key, required this.partyId});

  @override
  State<PartyDetail> createState() => _PartyDetailState();
}

class _PartyDetailState extends State<PartyDetail>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  PartyModel? _currentParty;

  // Filter states
  Set<String> _selectedTypes = {
    'Sale Order',
    'Sale',
    'Payment In',
    'Payment Out'
  };
  DateTimeRange? _dateRange;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 700),
      vsync: this,
    );
    _fadeAnimation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOut,
    );
    _animationController.forward();

    _refreshBalance();
    PaymentInDb.refreshPayments();
    PaymentOutDb.refreshPayments();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _refreshBalance() async {
    await PartyDb.calculatePartySummary(widget.partyId);
    setState(() {});
  }

  // Balance Helpers
  Color _balanceColor(PartyModel party) {
    final bal = party.partyBalance;
    if (bal > 0) return const Color(0xFF0DA95F);
    if (bal < 0) return const Color(0xFFE74C3C);
    return party.paymentType.toLowerCase().contains("give")
        ? const Color(0xFFE74C3C)
        : const Color(0xFF0DA95F);
  }

  String _balanceLabel(PartyModel party) {
    final bal = party.partyBalance;
    if (bal > 0) return "You'll Get";
    if (bal < 0) return "You'll Give";
    return party.paymentType.toLowerCase().contains("give")
        ? "You'll Give"
        : "You'll Get";
  }

  void _editParty() async {
    if (_currentParty == null) return;

    final updatedParty = await Navigator.of(context).push<PartyModel>(
      MaterialPageRoute(builder: (_) => AddPartyPage(party: _currentParty!)),
    );

    if (updatedParty != null && mounted) {
      await PartyDb.calculatePartySummary(widget.partyId);
      setState(() {});
    }
  }

  void _deleteParty() async {
    if (_currentParty == null) return;

    // Check if party has transactions
    final sales = await SaleDB.saleNotifier.value
        .where((s) => s.customerName == _currentParty!.name)
        .toList();
    final paymentsIn = await PaymentInDb.paymentInNotifier.value
        .where((p) => p.partyName == _currentParty!.name)
        .toList();
    final paymentsOut = await PaymentOutDb.paymentOutNotifier.value
        .where((p) => p.partyName == _currentParty!.name)
        .toList();

    final hasTransactions =
        sales.isNotEmpty || paymentsIn.isNotEmpty || paymentsOut.isNotEmpty;

    if (hasTransactions) {
      // Show warning dialog if party has transactions
      showDialog(
        context: context,
        barrierDismissible: true,
        builder: (ctx) => Dialog(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
          elevation: 10,
          backgroundColor: Colors.transparent,
          child: Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [Color(0xFFFFF3E0), Color(0xFFFFCC80)],
              ),
              borderRadius: BorderRadius.circular(24),
              boxShadow: [
                BoxShadow(
                  color: Colors.orange.withOpacity(0.4),
                  blurRadius: 20,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.orange.shade100,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.orange.withOpacity(0.3),
                        blurRadius: 15,
                        spreadRadius: 2,
                      ),
                    ],
                  ),
                  child: Icon(
                    Icons.receipt_long_outlined,
                    size: 48,
                    color: Colors.orange.shade700,
                  ),
                ),
                const SizedBox(height: 20),
                Text(
                  "Cannot Delete Party",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 12),
                RichText(
                  textAlign: TextAlign.center,
                  text: TextSpan(
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w500,
                      color: Colors.grey[700],
                      height: 1.5,
                    ),
                    children: [
                      const TextSpan(text: "The party "),
                      TextSpan(
                        text: "'${_currentParty!.name}'",
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                      const TextSpan(
                          text: " has existing transactions.\n\nPlease "),
                      const TextSpan(
                        text: "delete all transactions",
                        style: TextStyle(fontWeight: FontWeight.w600),
                      ),
                      const TextSpan(text: " before deleting this party."),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () => Navigator.pop(ctx),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.orange.shade600,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 4,
                    ),
                    child: Text(
                      "Understood",
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      );
      return;
    }

    final confirmed = await showDialog<bool>(
      context: context,
      barrierDismissible: true,
      builder: (ctx) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        elevation: 10,
        backgroundColor: Colors.transparent,
        child: Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [Color(0xFFFFEBEE), Color(0xFFFFCDD2)],
            ),
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(
                color: Colors.red.withOpacity(0.3),
                blurRadius: 20,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.red.shade100,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.red.withOpacity(0.3),
                      blurRadius: 15,
                      spreadRadius: 2,
                    ),
                  ],
                ),
                child: Icon(
                  Icons.delete_outline_rounded,
                  size: 48,
                  color: Colors.red.shade700,
                ),
              ),
              const SizedBox(height: 20),
              Text(
                "Delete Party",
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 12),
              RichText(
                textAlign: TextAlign.center,
                text: TextSpan(
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w500,
                    color: Colors.grey[700],
                    height: 1.5,
                  ),
                  children: [
                    const TextSpan(text: "Are you sure you want to delete "),
                    TextSpan(
                      text: "'${_currentParty!.name}'",
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                    const TextSpan(text: "? This action cannot be undone."),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.pop(ctx, false),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.grey[700],
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        side: BorderSide(
                          color: Colors.grey.shade400,
                          width: 1.5,
                        ),
                      ),
                      child: Text(
                        "Cancel",
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () => Navigator.pop(ctx, true),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red.shade600,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        elevation: 4,
                      ),
                      child: Text(
                        "Delete",
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );

    if (confirmed == true) {
      try {
        await PartyDb.deleteParty(widget.partyId);

        if (mounted) {
          showTopSnackBar(
            Overlay.of(context),
            CustomSnackBar.success(
              message: 'Party deleted successfully',
              backgroundColor: const Color(0xFF0DA95F),
              textStyle: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
            ),
            displayDuration: const Duration(seconds: 2),
          );
          Navigator.pop(context);
        }
      } catch (e) {
        if (mounted) {
          showTopSnackBar(
            Overlay.of(context),
            CustomSnackBar.error(
              message: 'Failed to delete party: $e',
              backgroundColor: const Color(0xFFE74C3C),
              textStyle: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
            ),
            displayDuration: const Duration(seconds: 3),
          );
        }
      }
    }
  }

  void _showFilterDialog() {
    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) {
          return Dialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(24),
            ),
            elevation: 8,
            child: Container(
              width: MediaQuery.of(context).size.width * 0.9,
              constraints: BoxConstraints(maxWidth: 400),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(24),
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Colors.white,
                    Colors.blue.shade50.withOpacity(0.3),
                  ],
                ),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Header
                  Container(
                    padding: EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [Colors.blue.shade400, Colors.blue.shade600],
                      ),
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(24),
                        topRight: Radius.circular(24),
                      ),
                    ),
                    child: Row(
                      children: [
                        Container(
                          padding: EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Icon(
                            Icons.tune_rounded,
                            color: Colors.white,
                            size: 28,
                          ),
                        ),
                        SizedBox(width: 16),
                        Text(
                          'Filter Transactions',
                          style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Content
                  SingleChildScrollView(
                    child: Padding(
                      padding: EdgeInsets.all(17),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Transaction Type Section
                          Row(
                            children: [
                              Container(
                                width: 4,
                                height: 20,
                                decoration: BoxDecoration(
                                  color: Colors.blue,
                                  borderRadius: BorderRadius.circular(2),
                                ),
                              ),
                              SizedBox(width: 12),
                              Text(
                                'Transaction Type',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w700,
                                  color: Colors.grey[800],
                                  letterSpacing: 0.3,
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: 16),
                          Wrap(
                            spacing: 10,
                            runSpacing: 10,
                            children: [
                              _buildModernFilterChip('Sale Order',
                                  Icons.shopping_bag_outlined, setDialogState),
                              _buildModernFilterChip('Sale',
                                  Icons.point_of_sale_outlined, setDialogState),
                              _buildModernFilterChip('Payment In',
                                  Icons.arrow_downward_rounded, setDialogState),
                              _buildModernFilterChip('Payment Out',
                                  Icons.arrow_upward_rounded, setDialogState),
                            ],
                          ),

                          SizedBox(height: 28),

                          // Divider with style
                          Container(
                            height: 1,
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [
                                  Colors.transparent,
                                  Colors.grey.shade300,
                                  Colors.transparent,
                                ],
                              ),
                            ),
                          ),

                          SizedBox(height: 28),

                          // Date Range Section
                          Row(
                            children: [
                              Container(
                                width: 4,
                                height: 20,
                                decoration: BoxDecoration(
                                  color: Colors.blue,
                                  borderRadius: BorderRadius.circular(2),
                                ),
                              ),
                              SizedBox(width: 12),
                              Text(
                                'Date Range',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w700,
                                  color: Colors.grey[800],
                                  letterSpacing: 0.3,
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: 16),
                          InkWell(
                            onTap: () async {
                              final picked = await showDateRangePicker(
                                context: context,
                                firstDate: DateTime(2020),
                                lastDate: DateTime.now(),
                                initialDateRange: _dateRange,
                                builder: (context, child) {
                                  return Theme(
                                    data: Theme.of(context).copyWith(
                                      colorScheme: ColorScheme.light(
                                        primary: Colors.blue.shade600,
                                        onPrimary: Colors.white,
                                      ),
                                    ),
                                    child: child!,
                                  );
                                },
                              );
                              if (picked != null) {
                                setDialogState(() {
                                  _dateRange = picked;
                                });
                              }
                            },
                            borderRadius: BorderRadius.circular(16),
                            child: Container(
                              padding: EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: Colors.blue.shade50,
                                border: Border.all(
                                  color: _dateRange != null
                                      ? Colors.blue.shade300
                                      : Colors.grey.shade300,
                                  width: 2,
                                ),
                                borderRadius: BorderRadius.circular(16),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.blue.withOpacity(0.1),
                                    blurRadius: 8,
                                    offset: Offset(0, 2),
                                  ),
                                ],
                              ),
                              child: Row(
                                children: [
                                  Container(
                                    padding: EdgeInsets.all(8),
                                    decoration: BoxDecoration(
                                      color: Colors.blue.shade100,
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    child: Icon(
                                      Icons.calendar_today_rounded,
                                      color: Colors.blue.shade700,
                                      size: 22,
                                    ),
                                  ),
                                  SizedBox(width: 14),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          _dateRange == null
                                              ? 'Select Date Range'
                                              : 'Selected Range',
                                          style: TextStyle(
                                            fontSize: 12,
                                            color: Colors.grey[600],
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                        if (_dateRange != null)
                                          SizedBox(height: 2),
                                        Text(
                                          _dateRange == null
                                              ? 'Tap to choose dates'
                                              : '${DateFormat('dd MMM yyyy').format(_dateRange!.start)} - ${DateFormat('dd MMM yyyy').format(_dateRange!.end)}',
                                          style: TextStyle(
                                            fontSize: 14,
                                            fontWeight: FontWeight.w600,
                                            color: _dateRange == null
                                                ? Colors.grey[500]
                                                : Colors.blue.shade800,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  if (_dateRange != null)
                                    Container(
                                      decoration: BoxDecoration(
                                        color: Colors.red.shade50,
                                        shape: BoxShape.circle,
                                      ),
                                      child: IconButton(
                                        icon:
                                            Icon(Icons.close_rounded, size: 20),
                                        color: Colors.red.shade400,
                                        onPressed: () {
                                          setDialogState(() {
                                            _dateRange = null;
                                          });
                                        },
                                      ),
                                    ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  // Actions
                  Container(
                    padding: EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade50,
                      borderRadius: BorderRadius.only(
                        bottomLeft: Radius.circular(24),
                        bottomRight: Radius.circular(24),
                      ),
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: OutlinedButton(
                            onPressed: () {
                              setState(() {
                                _selectedTypes = {
                                  'Sale Order',
                                  'Sale',
                                  'Payment In',
                                  'Payment Out'
                                };
                                _dateRange = null;
                              });
                              Navigator.pop(context);
                            },
                            style: OutlinedButton.styleFrom(
                              padding: EdgeInsets.symmetric(vertical: 16),
                              side: BorderSide(
                                  color: Colors.grey.shade400, width: 2),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.refresh_rounded,
                                    size: 20, color: Colors.grey[700]),
                                SizedBox(width: 8),
                                Text(
                                  'Reset',
                                  style: TextStyle(
                                    color: Colors.grey[700],
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        SizedBox(width: 12),
                        Expanded(
                          child: ElevatedButton(
                            onPressed: () {
                              setState(() {});
                              Navigator.pop(context);
                            },
                            style: ElevatedButton.styleFrom(
                              padding: EdgeInsets.symmetric(vertical: 16),
                              backgroundColor: Colors.blue.shade600,
                              elevation: 2,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.check_circle_rounded,
                                    size: 20, color: Colors.white),
                                SizedBox(width: 8),
                                Text(
                                  'Apply',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildModernFilterChip(
      String label, IconData icon, StateSetter setDialogState) {
    final isSelected = _selectedTypes.contains(label);

    return InkWell(
      onTap: () {
        setDialogState(() {
          if (isSelected) {
            _selectedTypes.remove(label);
          } else {
            _selectedTypes.add(label);
          }
        });
      },
      borderRadius: BorderRadius.circular(12),
      child: AnimatedContainer(
        duration: Duration(milliseconds: 200),
        padding: EdgeInsets.symmetric(horizontal: 15, vertical: 11),
        decoration: BoxDecoration(
          gradient: isSelected
              ? LinearGradient(
                  colors: [Colors.blue.shade400, Colors.blue.shade600],
                )
              : null,
          color: isSelected ? null : Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? Colors.blue.shade600 : Colors.grey.shade300,
            width: 2,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: Colors.blue.withOpacity(0.3),
                    blurRadius: 8,
                    offset: Offset(0, 4),
                  ),
                ]
              : [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.1),
                    blurRadius: 4,
                    offset: Offset(0, 2),
                  ),
                ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 18,
              color: isSelected ? Colors.white : Colors.grey[700],
            ),
            SizedBox(width: 8),
            Text(
              label,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: isSelected ? Colors.white : Colors.grey[800],
              ),
            ),
            if (isSelected) ...[
              SizedBox(width: 6),
              Icon(
                Icons.check_circle,
                size: 16,
                color: Colors.white,
              ),
            ],
          ],
        ),
      ),
    );
  }

  List<_TransactionItem> _applyFilters(List<_TransactionItem> list) {
    var filtered =
        list.where((item) => _selectedTypes.contains(item.type)).toList();

    if (_dateRange != null) {
      filtered = filtered.where((item) {
        final itemDate = DateFormat('dd MMM yyyy').parse(item.date);
        return itemDate
                .isAfter(_dateRange!.start.subtract(Duration(days: 1))) &&
            itemDate.isBefore(_dateRange!.end.add(Duration(days: 1)));
      }).toList();
    }

    return filtered;
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final hasActiveFilters = _selectedTypes.length < 4 || _dateRange != null;

    return FutureBuilder<PartyModel?>(
      future: PartyDb.getPartyById(widget.partyId),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        final party = snapshot.data ??
            PartyModel(
              id: widget.partyId,
              name: 'Unknown Party',
              email: '',
              contactNumber: '',
              billingAddress: '',
              openingBalance: 0.0,
              paymentType: "You'll Give",
              imagePath: '',
              asOfDate: DateTime.now().toString(),
              partyBalance: 0.0,
              userId: '',
            );

        _currentParty = party;

        return Scaffold(
          appBar: CustomAppBar(
            title: 'PARTY DETAILS',
            fontSize: 24,
            actions: [
              Padding(
                padding: const EdgeInsets.only(right: 12),
                child: PopupMenuButton<String>(
                  // Beautiful gradient icon
                  icon: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [Color(0xFF6EE2F5), Color(0xFF6454F0)],
                      ),
                      borderRadius: BorderRadius.circular(10),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.blue.withOpacity(0.4),
                          blurRadius: 16,
                          offset: const Offset(0, 6),
                        ),
                      ],
                    ),
                    child: const Icon(Icons.more_vert_rounded,
                        color: Colors.white, size: 26),
                  ),
                  offset: const Offset(0, 60),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20)),
                  elevation: 20,
                  shadowColor: Colors.black.withOpacity(0.25),
                  color: Colors.white.withOpacity(0.97),
                  surfaceTintColor: Colors.transparent,
                  onSelected: (value) {
                    if (value == 'edit') {
                      _editParty();
                    } else if (value == 'delete') {
                      _deleteParty();
                    }
                  },
                  itemBuilder: (context) => [
                    // Edit Item
                    PopupMenuItem(
                      value: 'edit',
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 8),
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: Colors.blue.shade50,
                              borderRadius: BorderRadius.circular(14),
                            ),
                            child: const Icon(Icons.edit_outlined,
                                color: Colors.blueAccent, size: 22),
                          ),
                          const SizedBox(width: 14),
                          Text(
                            'Edit Party',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                              color: Colors.black87,
                            ),
                          ),
                        ],
                      ),
                    ),
                    // Delete Item
                    PopupMenuItem(
                      value: 'delete',
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 8),
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: Colors.red.shade50,
                              borderRadius: BorderRadius.circular(14),
                            ),
                            child: const Icon(Icons.delete_outline_rounded,
                                color: Colors.redAccent, size: 22),
                          ),
                          const SizedBox(width: 14),
                          Text(
                            'Delete Party',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                              color: Colors.red.shade700,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          body: Container(
            width: size.width,
            height: size.height,
            decoration: const BoxDecoration(gradient: AppTheme.appGradient),
            child: FadeTransition(
              opacity: _fadeAnimation,
              child: Column(
                children: [
                  const SizedBox(height: 12),

                  // Party Profile Card
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Card(
                      elevation: 8,
                      shadowColor: Colors.black26,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(20),
                          gradient: const LinearGradient(
                            colors: [Colors.white, Color(0xFFF8F9FA)],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                        ),
                        child: Column(
                          children: [
                            Row(
                              children: [
                                Hero(
                                  tag: 'party_${party.id}',
                                  child: CircleAvatar(
                                    radius: 42,
                                    backgroundColor: Colors.grey[200],
                                    backgroundImage: ImageUtils.getImage(
                                      party.imagePath,
                                    ),
                                    child: party.imagePath.isEmpty
                                        ? const Icon(
                                            Icons.person,
                                            size: 48,
                                            color: Colors.grey,
                                          )
                                        : null,
                                  ),
                                ),
                                const SizedBox(width: 16),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        party.name,
                                        style: const TextStyle(
                                          fontSize: 24,
                                          fontWeight: FontWeight.bold,
                                          fontFamily: 'ABeeZee',
                                        ),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                      const SizedBox(height: 8),
                                      Row(
                                        children: [
                                          Container(
                                            padding: const EdgeInsets.all(8),
                                            decoration: BoxDecoration(
                                              color: _balanceColor(
                                                party,
                                              ).withOpacity(0.15),
                                              shape: BoxShape.circle,
                                            ),
                                            child: Icon(
                                              party.partyBalance > 0 ||
                                                      !party.paymentType
                                                          .toLowerCase()
                                                          .contains("give")
                                                  ? Icons.arrow_downward_rounded
                                                  : Icons.arrow_upward_rounded,
                                              color: _balanceColor(party),
                                              size: 28,
                                            ),
                                          ),
                                          const SizedBox(width: 12),
                                          Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                _balanceLabel(party),
                                                style: TextStyle(
                                                  fontSize: 15,
                                                  color: Colors.grey[700],
                                                  fontWeight: FontWeight.w600,
                                                ),
                                              ),
                                              Text(
                                                '₹ ${party.partyBalance.abs().toStringAsFixed(2)}',
                                                style: TextStyle(
                                                  fontSize: 22,
                                                  fontWeight: FontWeight.bold,
                                                  color: _balanceColor(party),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 20),
                            const Divider(height: 1, color: Color(0xFFE0E0E0)),
                            const SizedBox(height: 16),
                            _infoRow(
                              Icons.email_outlined,
                              'Email',
                              party.email.isEmpty ? 'Not added' : party.email,
                            ),
                            _infoRow(
                              Icons.phone_outlined,
                              'Phone',
                              party.contactNumber.isEmpty
                                  ? 'Not added'
                                  : party.contactNumber,
                            ),
                            _infoRow(
                              Icons.location_on_outlined,
                              'Address',
                              party.billingAddress.isEmpty
                                  ? 'Not added'
                                  : party.billingAddress,
                              isMultiLine: true,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 20),

                  // Filter Button
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          child: ElevatedButton.icon(
                            onPressed: _showFilterDialog,
                            icon: Icon(
                              Icons.filter_list,
                              color:
                                  hasActiveFilters ? Colors.white : Colors.blue,
                            ),
                            label: Text(
                              hasActiveFilters
                                  ? 'Filters Applied'
                                  : 'Filter Transactions',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: hasActiveFilters
                                    ? Colors.white
                                    : Colors.blue,
                              ),
                            ),
                            style: ElevatedButton.styleFrom(
                              backgroundColor:
                                  hasActiveFilters ? Colors.blue : Colors.white,
                              elevation: 4,
                              shadowColor: Colors.black26,
                              padding: EdgeInsets.symmetric(
                                  vertical: 14, horizontal: 20),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(14),
                                side: BorderSide(
                                  color: Colors.blue,
                                  width: hasActiveFilters ? 0 : 2,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 16),

                  // Transactions List
                  Expanded(
                    child: ValueListenableBuilder(
                      valueListenable: ValueNotifier(true),
                      builder: (context, _, __) {
                        return ValueListenableBuilder<List<SaleModel>>(
                          valueListenable: SaleDB.saleNotifier,
                          builder: (context, sales, _) {
                            return ValueListenableBuilder<List<PaymentInModel>>(
                              valueListenable: PaymentInDb.paymentInNotifier,
                              builder: (context, paymentsIn, _) {
                                return ValueListenableBuilder<
                                    List<PaymentOutModel>>(
                                  valueListenable:
                                      PaymentOutDb.paymentOutNotifier,
                                  builder: (context, paymentsOut, _) {
                                    final List<_TransactionItem> list = [];

                                    // Sales
                                    for (var s in sales.where(
                                      (s) => s.customerName == party.name,
                                    )) {
                                      list.add(
                                        _TransactionItem(
                                          type: s.transactionType ==
                                                  TransactionType.saleOrder
                                              ? 'Sale Order'
                                              : 'Sale',
                                          date: s.date,
                                          amount: s.total,
                                          balanceDue: s.balanceDue,
                                          refNo: s.invoiceNumber,
                                          status: s.status,
                                          isPayment: false,
                                        ),
                                      );
                                    }

                                    // Payment In
                                    for (var p in paymentsIn.where(
                                      (p) => p.partyName == party.name,
                                    )) {
                                      list.add(
                                        _TransactionItem(
                                          type: 'Payment In',
                                          date: p.date,
                                          amount: p.receivedAmount,
                                          refNo: p.receiptNo,
                                          isPayment: true,
                                          isIn: true,
                                        ),
                                      );
                                    }

                                    // Payment Out
                                    for (var p in paymentsOut.where(
                                      (p) => p.partyName == party.name,
                                    )) {
                                      list.add(
                                        _TransactionItem(
                                          type: 'Payment Out',
                                          date: p.date,
                                          amount: p.paidAmount,
                                          refNo: p.receiptNo,
                                          isPayment: true,
                                          isIn: false,
                                        ),
                                      );
                                    }

                                    // Apply filters
                                    final filteredList = _applyFilters(list);

                                    if (filteredList.isEmpty) {
                                      return Center(
                                        child: Column(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: [
                                            Icon(
                                              Icons.filter_list_off,
                                              size: 64,
                                              color: Colors.grey[400],
                                            ),
                                            SizedBox(height: 16),
                                            Text(
                                              hasActiveFilters
                                                  ? 'No transactions match the filters'
                                                  : 'No transactions yet',
                                              style: TextStyle(
                                                fontSize: 16,
                                                color: Colors.grey,
                                              ),
                                            ),
                                          ],
                                        ),
                                      );
                                    }

                                    filteredList.sort(
                                      (a, b) => DateFormat('dd MMM yyyy')
                                          .parse(b.date)
                                          .compareTo(
                                            DateFormat(
                                              'dd MMM yyyy',
                                            ).parse(a.date),
                                          ),
                                    );

                                    return ListView.builder(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 16,
                                      ),
                                      itemCount: filteredList.length,
                                      itemBuilder: (context, i) =>
                                          _TransactionCard(
                                              item: filteredList[i]),
                                    );
                                  },
                                );
                              },
                            );
                          },
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _infoRow(
    IconData icon,
    String label,
    String value, {
    bool isMultiLine = false,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        crossAxisAlignment:
            isMultiLine ? CrossAxisAlignment.start : CrossAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Colors.grey[100],
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: Colors.grey[700], size: 24),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[600],
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: const TextStyle(fontSize: 16, color: Colors.black87),
                  maxLines: isMultiLine ? 3 : 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// Transaction Item
class _TransactionItem {
  final String type;
  final String date;
  final double amount;
  final double? balanceDue;
  final String refNo;
  final SaleStatus? status;
  final bool isPayment;
  final bool? isIn;

  _TransactionItem({
    required this.type,
    required this.date,
    required this.amount,
    this.balanceDue,
    required this.refNo,
    this.status,
    required this.isPayment,
    this.isIn,
  });
}

// Beautiful Transaction Card
class _TransactionCard extends StatelessWidget {
  final _TransactionItem item;
  const _TransactionCard({required this.item});

  @override
  Widget build(BuildContext context) {
    final bool cancelled = item.status == SaleStatus.cancelled;
    final bool isSale = !item.isPayment;
    final bool fullyPaid = isSale ? item.balanceDue == 0 : true;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      child: Card(
        elevation: 6,
        shadowColor: Colors.black26,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(18),
            gradient: LinearGradient(
              colors: cancelled
                  ? [Colors.grey[100]!, Colors.grey[200]!]
                  : [Colors.white, const Color(0xFFFDFDFD)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: _getTypeColor().withOpacity(0.15),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(_getTypeIcon(), color: _getTypeColor(), size: 28),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.type,
                      style: TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.bold,
                        color: cancelled ? Colors.grey[600] : Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      item.refNo,
                      style: TextStyle(fontSize: 13, color: Colors.grey[600]),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      item.date,
                      style: const TextStyle(fontSize: 12, color: Colors.grey),
                    ),
                    if (cancelled)
                      const Padding(
                        padding: EdgeInsets.only(top: 6),
                        child: Chip(
                          label: Text(
                            'Cancelled',
                            style: TextStyle(fontSize: 10, color: Colors.white),
                          ),
                          backgroundColor: Colors.red,
                          padding: EdgeInsets.zero,
                        ),
                      ),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    '₹ ${item.amount.toStringAsFixed(2)}',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: cancelled
                          ? Colors.grey
                          : (item.isPayment
                              ? (item.isIn == true
                                  ? const Color(0xFF0DA95F)
                                  : const Color(0xFFE74C3C))
                              : Colors.black87),
                    ),
                  ),
                  const SizedBox(height: 6),
                  if (isSale && !cancelled)
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: fullyPaid
                            ? const Color(0xFF0DA95F).withOpacity(0.15)
                            : const Color(0xFFE74C3C).withOpacity(0.15),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        fullyPaid
                            ? 'Paid'
                            : 'Due ₹ ${item.balanceDue!.toStringAsFixed(2)}',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          color: fullyPaid
                              ? const Color(0xFF0DA95F)
                              : const Color(0xFFE74C3C),
                        ),
                      ),
                    ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Color _getTypeColor() {
    if (item.type.contains('Sale Order')) return Colors.orange;
    if (item.type == 'Sale') return Colors.blue;
    if (item.type == 'Payment In') return const Color(0xFF0DA95F);
    return const Color(0xFFE74C3C);
  }

  IconData _getTypeIcon() {
    if (item.type.contains('Sale Order')) return Icons.assignment;
    if (item.type == 'Sale') return Icons.receipt_long;
    if (item.type == 'Payment In') return Icons.arrow_downward_rounded;
    return Icons.arrow_upward_rounded;
  }
}

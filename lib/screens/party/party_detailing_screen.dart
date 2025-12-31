// ignore_for_file: deprecated_member_use

import 'package:cream_ventory/core/utils/party/party_detail_screen_transaction_filter_util.dart';
import 'package:cream_ventory/database/functions/party_db.dart';
import 'package:cream_ventory/database/functions/payment_db.dart';
import 'package:cream_ventory/database/functions/sale/sale_db.dart';
import 'package:cream_ventory/models/party_model.dart';
import 'package:cream_ventory/models/sale_model.dart';
import 'package:cream_ventory/screens/party/add_party_screen.dart';
import 'package:cream_ventory/models/payment_in_model.dart';
import 'package:cream_ventory/models/payment_out_model.dart';
import 'package:cream_ventory/core/theme/theme.dart';
import 'package:cream_ventory/screens/party/widgets/delete_party_dialog.dart';
import 'package:cream_ventory/screens/party/widgets/party_detail_screen_filter_dialog.dart';
import 'package:cream_ventory/screens/party/widgets/party_detail_screen_profile_card.dart';
import 'package:cream_ventory/screens/party/widgets/party_detail_screen_sticky_header.dart';
import 'package:cream_ventory/screens/party/widgets/party_detail_screen_transaction_card.dart';
import 'package:cream_ventory/widgets/app_bar.dart';
import 'package:flutter/material.dart';
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
  final ScrollController _scrollController = ScrollController();
  final ValueNotifier<bool> _showStickyHeader = ValueNotifier<bool>(false);

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

    _scrollController.addListener(_onScroll);
    _loadParty(); // ✅ Load party immediately
    _refreshBalance();
    PaymentInDb.refreshPayments();
    PaymentOutDb.refreshPayments();
    
    // ✅ Listen to party changes
    PartyDb.partyNotifier.addListener(_onPartyChanged);
  }

  // ✅ Add listener for party changes
  void _onPartyChanged() {
    _loadParty();
  }

  // ✅ Add method to load party
  Future<void> _loadParty() async {
    final party = await PartyDb.getPartyById(widget.partyId);
    if (party != null && mounted) {
      setState(() {
        _currentParty = party;
      });
    }
  }

  void _onScroll() {
    if (_scrollController.offset > 200 && !_showStickyHeader.value) {
      _showStickyHeader.value = true;
    } else if (_scrollController.offset <= 200 && _showStickyHeader.value) {
      _showStickyHeader.value = false;
    }
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    _animationController.dispose();
    _showStickyHeader.dispose();
    PartyDb.partyNotifier.removeListener(_onPartyChanged); // ✅ Remove listener
    super.dispose();
  }

  void _refreshBalance() async {
    await PartyDb.calculatePartySummary(widget.partyId);
    if (mounted) {
      setState(() {});
    }
  }

  void _editParty() async {
    if (_currentParty == null) return;

    final updatedParty = await Navigator.of(context).push<PartyModel>(
      MaterialPageRoute(builder: (_) => AddPartyPage(party: _currentParty!)),
    );

    if (updatedParty != null && mounted) {
      await PartyDb.calculatePartySummary(widget.partyId);
      // ✅ Party will automatically update via listener
      setState(() {});
    }
  }

  void _deleteParty() async {
    if (_currentParty == null) return;

    final sales = SaleDB.saleNotifier.value
        .where((s) => s.customerId == _currentParty!.id)
        .toList();
    final paymentsIn = PaymentInDb.paymentInNotifier.value
        .where((p) => p.partyId == _currentParty!.id)
        .toList();
    final paymentsOut = PaymentOutDb.paymentOutNotifier.value
        .where((p) => p.partyId == _currentParty!.id)
        .toList();

    final hasTransactions =
        sales.isNotEmpty || paymentsIn.isNotEmpty || paymentsOut.isNotEmpty;

    if (hasTransactions) {
      DeletePartyDialogs.showCannotDeleteDialog(context, _currentParty!.name);
      return;
    }

    final confirmed = await DeletePartyDialogs.showDeleteConfirmation(
      context,
      _currentParty!.name,
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
      builder: (context) => FilterDialog(
        selectedTypes: _selectedTypes,
        dateRange: _dateRange,
        onApply: (types, range) {
          setState(() {
            _selectedTypes = types;
            _dateRange = range;
          });
        },
      ),
    );
  }

  List<TransactionItem> _buildTransactionList() {
    final List<TransactionItem> list = [];
    final party = _currentParty;
    if (party == null) return list;

    // Sales - filter by party ID
    for (var s in SaleDB.saleNotifier.value.where(
      (s) => s.customerId == party.id, 
    )) {
      list.add(
        TransactionItem(
          type: s.transactionType == TransactionType.saleOrder
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

    // Payment In - filter by party ID
    for (var p in PaymentInDb.paymentInNotifier.value.where(
      (p) => p.partyId == party.id, 
    )) {
      list.add(
        TransactionItem(
          type: 'Payment In',
          date: p.date,
          amount: p.receivedAmount,
          refNo: p.receiptNo,
          isPayment: true,
          isIn: true,
        ),
      );
    }

    // Payment Out - filter by party ID
    for (var p in PaymentOutDb.paymentOutNotifier.value.where(
      (p) => p.partyId == party.id, 
    )) {
      list.add(
        TransactionItem(
          type: 'Payment Out',
          date: p.date,
          amount: p.paidAmount,
          refNo: p.receiptNo,
          isPayment: true,
          isIn: false,
        ),
      );
    }

    return list;
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final hasActiveFilters = _selectedTypes.length < 4 || _dateRange != null;

    // ✅ Use the loaded party instead of FutureBuilder
    if (_currentParty == null) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    final party = _currentParty!;

    return Scaffold(
      appBar: CustomAppBar(
        title: 'PARTY DETAILS',
        fontSize: 24,
        actions: [
          PopupMenuButton<String>(
            icon: Container(
              padding: const EdgeInsets.all(2), 
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
        ],
      ),
      body: Container(
        width: size.width,
        height: size.height,
        decoration: const BoxDecoration(gradient: AppTheme.appGradient),
        child: Stack(
          children: [
            FadeTransition(
              opacity: _fadeAnimation,
              child: CustomScrollView(
                controller: _scrollController,
                slivers: [
                  SliverToBoxAdapter(
                    child: Column(
                      children: [
                        const SizedBox(height: 12),
                        PartyProfileCard(party: party),
                        const SizedBox(height: 20),
                        _buildFilterButton(hasActiveFilters),
                        const SizedBox(height: 16),
                      ],
                    ),
                  ),
                  _buildTransactionsList(hasActiveFilters),
                  SliverToBoxAdapter(
                    child: SizedBox(height: 20),
                  ),
                ],
              ),
            ),
            // Sticky Header
            ValueListenableBuilder<bool>(
              valueListenable: _showStickyHeader,
              builder: (context, showSticky, child) {
                return AnimatedPositioned(
                  duration: const Duration(milliseconds: 300),
                  curve: Curves.easeInOut,
                  top: showSticky ? 0 : -100,
                  left: 0,
                  right: 0,
                  child: IgnorePointer(
                    child: PartyDetailStickyHeader(
                      party: party,
                      transactionCount: _buildTransactionList().length,
                    ),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFilterButton(bool hasActiveFilters) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: ElevatedButton.icon(
        onPressed: _showFilterDialog,
        icon: Icon(
          Icons.filter_list,
          color: hasActiveFilters ? Colors.white : Colors.blue,
        ),
        label: Text(
          hasActiveFilters ? 'Filters Applied' : 'Filter Transactions',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: hasActiveFilters ? Colors.white : Colors.blue,
          ),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: hasActiveFilters ? Colors.blue : Colors.white,
          elevation: 4,
          shadowColor: Colors.black26,
          padding: EdgeInsets.symmetric(vertical: 14, horizontal: 20),
          minimumSize: Size(double.infinity, 50),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
            side: BorderSide(
              color: Colors.blue,
              width: hasActiveFilters ? 0 : 2,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTransactionsList(bool hasActiveFilters) {
    return ValueListenableBuilder(
      valueListenable: ValueNotifier(true),
      builder: (context, _, __) {
        return ValueListenableBuilder<List<SaleModel>>(
          valueListenable: SaleDB.saleNotifier,
          builder: (context, sales, _) {
            return ValueListenableBuilder<List<PaymentInModel>>(
              valueListenable: PaymentInDb.paymentInNotifier,
              builder: (context, paymentsIn, _) {
                return ValueListenableBuilder<List<PaymentOutModel>>(
                  valueListenable: PaymentOutDb.paymentOutNotifier,
                  builder: (context, paymentsOut, _) {
                    final list = _buildTransactionList();
                    final filteredList = TransactionFilterUtils.applyFilters(
                      list,
                      _selectedTypes,
                      _dateRange,
                    );

                    if (filteredList.isEmpty) {
                      return SliverFillRemaining(
                        child: Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
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
                        ),
                      );
                    }

                    final sortedList =
                        TransactionFilterUtils.sortByDate(filteredList);

                    return SliverPadding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      sliver: SliverList(
                        delegate: SliverChildBuilderDelegate(
                          (context, i) => TransactionCard(item: sortedList[i]),
                          childCount: sortedList.length,
                        ),
                      ),
                    ); 
                  },
                );
              },
            );
          },
        );
      },
    );
  }
}
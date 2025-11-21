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
import 'package:cream_ventory/widgets/search_bar.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

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

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 700),
      vsync: this,
    );
    _fadeAnimation = CurvedAnimation(parent: _animationController, curve: Curves.easeOut);
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
    return party.paymentType.toLowerCase().contains("give") ? const Color(0xFFE74C3C) : const Color(0xFF0DA95F);
  }

  String _balanceLabel(PartyModel party) {
    final bal = party.partyBalance;
    if (bal > 0) return "You'll Get";
    if (bal < 0) return "You'll Give";
    return party.paymentType.toLowerCase().contains("give") ? "You'll Give" : "You'll Get";
  }

  void _editParty() async {
  if (_currentParty == null) return;

  final updatedParty = await Navigator.of(context).push<PartyModel>(
    MaterialPageRoute(    
      builder: (_) => AddPartyPage(party: _currentParty!),
    ),    
  );

  if (updatedParty != null && mounted) {
    await PartyDb.calculatePartySummary(widget.partyId);
    setState(() {});   // refresh UI with new data
  }
}
  // Delete Party with confirmation
  void _deleteParty() async {
    if (_currentParty == null) return;

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: [
            Icon(Icons.warning_amber_rounded, color: Colors.orange, size: 28),
            SizedBox(width: 12),
            Text('Delete Party?'),
          ],
        ),
        content: Text(
          'Are you sure you want to delete "${_currentParty!.name}"?\n\nThis action cannot be undone.',
          style: TextStyle(fontSize: 16),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text('Cancel', style: TextStyle(color: Colors.grey[600], fontSize: 16)),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              padding: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            ),
            child: Text('Delete', style: TextStyle(color: Colors.white, fontSize: 16)),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      try {
        // Call your delete function here
        await PartyDb.deleteParty(widget.partyId);
        
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Party deleted successfully'),
              backgroundColor: Colors.green,
              behavior: SnackBarBehavior.floating,
            ),
          );
          Navigator.pop(context); // Go back after deletion
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Failed to delete party: $e'),
              backgroundColor: Colors.red,
              behavior: SnackBarBehavior.floating,
            ),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return FutureBuilder<PartyModel?>(
      future: PartyDb.getPartyById(widget.partyId),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(body: Center(child: CircularProgressIndicator()));
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
              asOfDate: DateTime.now(),
              partyBalance: 0.0,
              userId: '',
            );

        _currentParty = party;

        return Scaffold(
          appBar: CustomAppBar(
            title: 'PARTY DETAILS',
            fontSize: 24,
            actions: [
              PopupMenuButton<String>(
                icon: Icon(Icons.more_vert, color: Colors.black87, size: 28),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                offset: Offset(0, 50),
                elevation: 8,
                color: Colors.white,
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
                    child: Row(
                      children: [
                        Icon(Icons.edit_outlined, color: Colors.blue, size: 22),
                        SizedBox(width: 12),
                        Text(
                          'Edit Party',
                          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                        ),
                      ],
                    ),
                  ),
                  PopupMenuDivider(),
                  PopupMenuItem(
                    value: 'delete',
                    child: Row(
                      children: [
                        Icon(Icons.delete_outline, color: Colors.red, size: 22),
                        SizedBox(width: 12),
                        Text(
                          'Delete Party',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                            color: Colors.red,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              SizedBox(width: 8),
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
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
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
                                    backgroundImage: ImageUtils.getImage(party.imagePath, fallback: 'assets/image/account.png'),
                                    child: party.imagePath.isEmpty
                                        ? const Icon(Icons.person, size: 48, color: Colors.grey)
                                        : null,
                                  ),
                                ),
                                const SizedBox(width: 16),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        party.name,
                                        style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, fontFamily: 'ABeeZee'),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                      const SizedBox(height: 8),
                                      Row(
                                        children: [
                                          Container(
                                            padding: const EdgeInsets.all(8),
                                            decoration: BoxDecoration(
                                              color: _balanceColor(party).withOpacity(0.15),
                                              shape: BoxShape.circle,
                                            ),
                                            child: Icon(
                                              party.partyBalance > 0 || !party.paymentType.toLowerCase().contains("give")
                                                  ? Icons.arrow_downward_rounded
                                                  : Icons.arrow_upward_rounded,
                                              color: _balanceColor(party),
                                              size: 28,
                                            ),
                                          ),
                                          const SizedBox(width: 12),
                                          Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                _balanceLabel(party),
                                                style: TextStyle(fontSize: 15, color: Colors.grey[700], fontWeight: FontWeight.w600),
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
                            _infoRow(Icons.email_outlined, 'Email', party.email.isEmpty ? 'Not added' : party.email),
                            _infoRow(Icons.phone_outlined, 'Phone', party.contactNumber.isEmpty ? 'Not added' : party.contactNumber),
                            _infoRow(Icons.location_on_outlined, 'Address', party.billingAddress.isEmpty ? 'Not added' : party.billingAddress, isMultiLine: true),
                          ],
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 20),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: CustomSearchBar(hintText: 'Search transactions...', onChanged: (v) {}),
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
                                return ValueListenableBuilder<List<PaymentOutModel>>(
                                  valueListenable: PaymentOutDb.paymentOutNotifier,
                                  builder: (context, paymentsOut, _) {
                                    final List<_TransactionItem> list = [];

                                    // Sales
                                    for (var s in sales.where((s) => s.customerName == party.name)) {
                                      list.add(_TransactionItem(
                                        type: s.transactionType == TransactionType.saleOrder ? 'Sale Order' : 'Sale',
                                        date: s.date,
                                        amount: s.total,
                                        balanceDue: s.balanceDue,
                                        refNo: s.invoiceNumber,
                                        status: s.status,
                                        isPayment: false,
                                      ));
                                    }

                                    // Payment In
                                    for (var p in paymentsIn.where((p) => p.partyName == party.name)) {
                                      list.add(_TransactionItem(
                                        type: 'Payment In',
                                        date: p.date,
                                        amount: p.receivedAmount,
                                        refNo: p.receiptNo,
                                        isPayment: true,
                                        isIn: true,
                                      ));
                                    }

                                    // Payment Out
                                    for (var p in paymentsOut.where((p) => p.partyName == party.name)) {
                                      list.add(_TransactionItem(
                                        type: 'Payment Out',
                                        date: p.date,
                                        amount: p.paidAmount,
                                        refNo: p.receiptNo,
                                        isPayment: true,
                                        isIn: false,
                                      ));
                                    }

                                    if (list.isEmpty) {
                                      return const Center(
                                        child: Text('No transactions yet', style: TextStyle(fontSize: 16, color: Colors.grey)),
                                      );
                                    }

                                    list.sort((a, b) => DateFormat('dd/MM/yyyy').parse(b.date).compareTo(DateFormat('dd/MM/yyyy').parse(a.date)));

                                    return ListView.builder(
                                      padding: const EdgeInsets.symmetric(horizontal: 16),
                                      itemCount: list.length,
                                      itemBuilder: (context, i) => _TransactionCard(item: list[i]),
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

  Widget _infoRow(IconData icon, String label, String value, {bool isMultiLine = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        crossAxisAlignment: isMultiLine ? CrossAxisAlignment.start : CrossAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(color: Colors.grey[100], borderRadius: BorderRadius.circular(12)),
            child: Icon(icon, color: Colors.grey[700], size: 24),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: TextStyle(fontSize: 14, color: Colors.grey[600], fontWeight: FontWeight.w600)),
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
              colors: cancelled ? [Colors.grey[100]!, Colors.grey[200]!] : [Colors.white, const Color(0xFFFDFDFD)],
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
                      '#${item.refNo}',
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
                          label: Text('Cancelled', style: TextStyle(fontSize: 10, color: Colors.white)),
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
                              ? (item.isIn == true ? const Color(0xFF0DA95F) : const Color(0xFFE74C3C))
                              : Colors.black87),
                    ),
                  ),
                  const SizedBox(height: 6),
                  if (isSale && !cancelled)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: fullyPaid ? const Color(0xFF0DA95F).withOpacity(0.15) : const Color(0xFFE74C3C).withOpacity(0.15),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        fullyPaid ? 'Paid' : 'Due ₹ ${item.balanceDue!.toStringAsFixed(2)}',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          color: fullyPaid ? const Color(0xFF0DA95F) : const Color(0xFFE74C3C),
                        ),
                      ),
                    ),
                ], 
              ),
              const SizedBox(width: 8),
              IconButton(
                icon: const Icon(Icons.share_rounded, color: Colors.grey, size: 22),
                onPressed: () {},
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
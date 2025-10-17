import 'package:cream_ventory/db/functions/party_db.dart';
import 'package:cream_ventory/db/functions/sale/sale_db.dart';
import 'package:cream_ventory/db/functions/user_db.dart';
import 'package:cream_ventory/db/models/parties/party_model.dart';
import 'package:cream_ventory/db/models/sale/sale_model.dart';
import 'package:cream_ventory/screen/adding/party/add_party.dart';
import 'package:cream_ventory/themes/app_theme/theme.dart';
import 'package:cream_ventory/widgets/app_bar.dart';
import 'package:cream_ventory/widgets/search_bar.dart';
import 'package:flutter/material.dart';
import 'dart:io';

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

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    _fadeAnimation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    );
    _animationController.forward();
    _refreshBalance();
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

  // Helper methods for balance-based color logic
  Color _getBalanceColor(PartyModel party) {
    if (party.partyBalance > 0) {
      return Colors.green;
    } else if (party.partyBalance < 0) {
      return Colors.red;
    } else {
      return party.paymentType.trim().toLowerCase() == "you'll give"
          ? Colors.red
          : Colors.green;
    }
  }

  Color _getBalanceContainerColor(PartyModel party) {
    if (party.partyBalance > 0) {
      return Colors.green.withOpacity(0.1);
    } else if (party.partyBalance < 0) {
      return Colors.red.withOpacity(0.1);
    } else {
      return party.paymentType.trim().toLowerCase() == "you'll give"
          ? Colors.red.withOpacity(0.1)
          : Colors.green.withOpacity(0.1);
    }
  }

  IconData _getBalanceIcon(PartyModel party) {
    if (party.partyBalance > 0) {
      return Icons.arrow_circle_down_rounded;
    } else if (party.partyBalance < 0) {
      return Icons.arrow_circle_up_rounded;
    } else {
      return party.paymentType.trim().toLowerCase() == "you'll give"
          ? Icons.arrow_circle_up_rounded
          : Icons.arrow_circle_down_rounded;
    }
  }

  String _getBalanceLabel(PartyModel party) {
    if (party.partyBalance > 0) {
      return "You'll Get";
    } else if (party.partyBalance < 0) {
      return "You'll Give";
    } else {
      return party.paymentType.trim().toLowerCase() == "you'll give"
          ? "You'll Give"
          : "You'll Get";
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    return FutureBuilder<PartyModel?>(
      future: PartyDb.getPartyById(widget.partyId),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        final party =
            snapshot.data ??
            PartyModel(
              id: widget.partyId,
              name: 'Unknown',
              email: '',
              contactNumber: '',   
              billingAddress: '',
              openingBalance: 0.0,
              paymentType: "You'll Give",
              imagePath: '',
              asOfDate: DateTime.now(),
              partyBalance: 0.0,
              userId: '', // Will be set below
            );

        // If party is the fallback, set userId asynchronously
        if (snapshot.data == null) {
          UserDB.getCurrentUser().then((user) {
            setState(() {
              party.userId = user.id;
            });
          });
        }

        return Scaffold(
          appBar: CustomAppBar(
            title: 'PARTY DETAILS',
             
            actions: [
              
              PopupMenuButton<String>(
                onSelected: (value) {
                  if (value == 'edit') {
                    _editParty(context, party);
                  } else if (value == 'delete') {
                    _deleteParty(context, party);
                  }
                },
                icon: const Icon(Icons.more_vert, color: Colors.black),
                itemBuilder: (context) => [
                  const PopupMenuItem(value: 'edit', child: Text('Edit')),
                  const PopupMenuItem(value: 'delete', child: Text('Delete')),
                ],
              ),
            ],
            fontSize: 25,
          ),
          body: Container(
            width: screenWidth,
            height: screenHeight,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            decoration: const BoxDecoration(gradient: AppTheme.appGradient),
            child: FadeTransition(
              opacity: _fadeAnimation,
              child: Column(
                children: [
                  Container(
                    margin: const EdgeInsets.only(top: 8),
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.withOpacity(0.3),
                          spreadRadius: 3,
                          blurRadius: 10,
                          offset: const Offset(0, 6),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            CircleAvatar(
                              radius: 45,
                              backgroundImage:
                                  party.imagePath.isNotEmpty &&
                                      File(party.imagePath).existsSync()
                                  ? FileImage(File(party.imagePath))
                                  : const AssetImage('assets/image/account.png')
                                        as ImageProvider,
                              backgroundColor: Colors.grey[100],
                              child: party.imagePath.isEmpty
                                  ? const Icon(
                                      Icons.person,
                                      size: 50,
                                      color: Colors.grey,
                                    )
                                  : null,
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    party.name,
                                    style: const TextStyle(
                                      fontSize: 22,
                                      fontFamily: 'ABeeZee',
                                      fontWeight: FontWeight.bold,
                                      color: Colors.black87,
                                    ),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  const SizedBox(height: 8),
                                  Row(
                                    children: [
                                      Container(
                                        padding: const EdgeInsets.all(6),
                                        decoration: BoxDecoration(
                                          color: _getBalanceContainerColor(
                                            party,
                                          ),
                                          shape: BoxShape.circle,
                                        ),
                                        child: Icon(
                                          _getBalanceIcon(party),
                                          color: _getBalanceColor(party),
                                          size: 28,
                                        ),
                                      ),
                                      const SizedBox(width: 10),
                                      Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            _getBalanceLabel(party),
                                            style: const TextStyle(
                                              fontSize: 14,
                                              fontFamily: 'ABeeZee',
                                              color: Colors.grey,
                                            ),
                                          ),
                                          Text(
                                            '₹${party.partyBalance.abs().toStringAsFixed(2)}',
                                            style: TextStyle(
                                              fontSize: 20,
                                              fontFamily: 'ABeeZee',
                                              fontWeight: FontWeight.bold,
                                              color: _getBalanceColor(party),
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
                        Divider(color: Colors.grey[200], thickness: 1),
                        const SizedBox(height: 16),
                        _buildDetailRow(
                          label: 'Email',
                          value: party.email.isEmpty ? 'N/A' : party.email,
                          icon: Icons.email_outlined,
                        ),
                        const SizedBox(height: 16),
                        _buildDetailRow(
                          label: 'Contact',
                          value: party.contactNumber.isEmpty
                              ? 'N/A'
                              : party.contactNumber,
                          icon: Icons.phone_outlined,
                        ),
                        const SizedBox(height: 16),
                        _buildDetailRow(
                          label: 'Address',
                          value: party.billingAddress.isEmpty
                              ? 'N/A'
                              : party.billingAddress,
                          icon: Icons.location_on_outlined,
                          isMultiLine: true,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  CustomSearchBar(
                    hintText: 'Search Sales',
                    onChanged: (value) {},
                  ),
                  const SizedBox(height: 16),
                  Expanded(
                    child: ValueListenableBuilder<List<SaleModel>>(
                      valueListenable: SaleDB.saleNotifier,
                      builder: (context, sales, _) {
                        final partySales = sales
                            .where((sale) => sale.customerName == party.name )
                            .toList(); 
                        if (partySales.isEmpty) {
                          return const Center(     
                            child: Text(
                              'No sales found for this party.',
                              style: TextStyle(
                                fontSize: 16,
                                fontFamily: 'ABeeZee',
                                color: Colors.grey,  
                              ),
                            ),
                          );
                        }

                        return ListView.builder(
                          itemCount: partySales.length,
                          itemBuilder: (context, index) {
                            final sale = partySales[index];
                            return Card(
                              color: Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              elevation: 2,
                              margin: const EdgeInsets.symmetric(vertical: 8),
                              child: Padding(
                                padding: const EdgeInsets.all(16.0),
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          'Invoice #${sale.invoiceNumber}',
                                          style: const TextStyle(
                                            fontSize: 16,
                                            fontFamily: 'ABeeZee',
                                            fontWeight: FontWeight.bold,
                                            color: Colors.black87,
                                          ),
                                        ),
                                        const SizedBox(height: 6),
                                        Text(
                                          sale.date,
                                          style: const TextStyle(
                                            fontSize: 12,
                                            fontFamily: 'ABeeZee',
                                            color: Colors.grey,
                                          ),
                                        ),
                                      ],
                                    ),
                                    Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.end,
                                      children: [
                                        Text(
                                          '₹${sale.total.toStringAsFixed(2)}',
                                          style: const TextStyle(
                                            fontSize: 14,
                                            fontFamily: 'ABeeZee',
                                            fontWeight: FontWeight.bold,
                                            color: Colors.black87,
                                          ),
                                        ),
                                        const SizedBox(height: 6),
                                        Container(
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 8,
                                            vertical: 4,
                                          ),
                                          decoration: BoxDecoration(
                                            color: sale.balanceDue == 0
                                                ? Colors.green.withOpacity(0.1)
                                                : Colors.red.withOpacity(0.1),
                                            borderRadius: BorderRadius.circular(
                                              8,
                                            ),
                                          ),
                                          child: Row(
                                            children: [
                                              Text(
                                                sale.balanceDue == 0
                                                    ? 'Paid'
                                                    : 'Due',
                                                style: TextStyle(
                                                  fontSize: 12,
                                                  fontFamily: 'ABeeZee',
                                                  fontWeight: FontWeight.bold,
                                                  color: sale.balanceDue == 0
                                                      ? Colors.green
                                                      : Colors.red,
                                                ),
                                              ),
                                              const SizedBox(width: 6),
                                              Text(
                                                '₹${sale.balanceDue.toStringAsFixed(2)}',
                                                style: const TextStyle(
                                                  fontSize: 12,
                                                  fontFamily: 'ABeeZee',
                                                  color: Colors.black87,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                    IconButton(
                                      onPressed: () {
                                        // Placeholder for share functionality
                                      },
                                      icon: const Icon(
                                        Icons.share_rounded,
                                        size: 20,
                                        color: Colors.grey,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
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

  Widget _buildDetailRow({
    required String label,
    required String value,
    required IconData icon,
    bool isMultiLine = false,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.grey[100],
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, color: Colors.grey[700], size: 24),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: const TextStyle(
                  fontSize: 14,
                  fontFamily: 'ABeeZee',
                  fontWeight: FontWeight.w600,
                  color: Colors.grey,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 16,
                  fontFamily: 'ABeeZee',
                  fontWeight: FontWeight.w400,
                  color: Colors.black87,
                ),
                maxLines: isMultiLine ? 3 : 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ],
    );
  }

  void _deleteParty(BuildContext context, PartyModel party) async {
    final confirmation = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Party'),
        content: const Text('Are you sure you want to delete this party?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmation == true) {
      bool success = await PartyDb.deleteParty(party.id);
      if (success) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Party deleted successfully!'),
            behavior: SnackBarBehavior.floating,
            backgroundColor: Colors.green,
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Failed to delete party: Not found'),
            behavior: SnackBarBehavior.floating,
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _editParty(BuildContext context, PartyModel party) async {
    await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => AddParty(party: party)),
    );
    await PartyDb.calculatePartySummary(widget.partyId);
    setState(() {});
  }
}

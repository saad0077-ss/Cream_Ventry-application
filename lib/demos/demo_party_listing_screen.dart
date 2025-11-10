// import 'package:cream_ventory/db/functions/party_db.dart';
// import 'package:cream_ventory/db/functions/user_db.dart';
// import 'package:cream_ventory/db/models/parties/party_model.dart';
// import 'package:cream_ventory/screen/detailing/party/party_detailing_screen.dart';
// import 'package:flutter/material.dart';
// import 'dart:io';

// class PartyList extends StatefulWidget {

//   final String searchQuery; // Added searchQuery parameter
//   const PartyList({super.key,  required this.searchQuery});

//   @override
//   State<PartyList> createState() => _PartyListState();
// }

// class _PartyListState extends State<PartyList> {

//   String? userId; // Store current userId
//   bool isLoading = true; // Track loading state

//   @override
//   void initState() {
//     super.initState();
//     _initialize();
//   }

//   // Initialize by loading parties and fetching userId
//   Future<void> _initialize() async {
//     try {
//       final user = await UserDB.getCurrentUser();
//       setState(() {
//         userId = user.id;
//         isLoading = false;
//       });
//       await PartyDb.loadParties(); // Ensure parties are loaded
//     } catch (e) {
//       setState(() {
//         isLoading = false;
//       });
//       debugPrint('Error initializing PartyList: $e');
//     }
//   }
//   // Helper methods for balance-based color logic
//   Color _getBalanceColor(PartyModel party) {
//     if (party.partyBalance > 0) {
//       return Colors.green.withOpacity(0.1);
//     } else if (party.partyBalance < 0) {
//       return Colors.red.withOpacity(0.1);
//     } else {
//       return party.paymentType.trim().toLowerCase() == "you'll give"
//           ? Colors.red.withOpacity(0.1)
//           : Colors.green.withOpacity(0.1);
//     }
//   }

//   Color _getBalanceTextColor(PartyModel party) {
//     if (party.partyBalance > 0) {
//       return Colors.green;
//     } else if (party.partyBalance < 0) {
//       return Colors.red;
//     } else {
//       return party.paymentType.trim().toLowerCase() == "you'll give"
//           ? Colors.red
//           : Colors.green;
//     }
//   }

//   String _getBalanceLabel(PartyModel party) {
//     if (party.partyBalance > 0) {
//       return "You'll Get";
//     } else if (party.partyBalance < 0) {
//       return "You'll Give";
//     } else {
//       return party.paymentType.trim().toLowerCase() == "you'll give"
//           ? "You'll Give"
//           : "You'll Get";
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return ValueListenableBuilder<List<PartyModel>>(
//       valueListenable: PartyDb.partyNotifier,
//       builder: (context, parties, _) {
//         // Filter parties by userId and searchQuery
//         final filteredParties = parties.where((party) {
//           final matchesUserId =party.userId == userId ;
//           final matchesSearch = widget.searchQuery.isEmpty ||
//               party.name.toLowerCase().contains(widget.searchQuery.toLowerCase()) ;

//           return matchesUserId && matchesSearch;
//         }).toList();

//         if (filteredParties.isEmpty) {
//           return const Center(
//             child: Text(
//               'No Parties Added Yet',
//               style: TextStyle(
//                 fontSize: 16,
//                 fontFamily: 'ABeeZee',
//                 color: Colors.black,
//             ),
//             ),
//           );
//         }

//         return ListView.builder(
//           padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
//           itemCount: filteredParties.length,
//           itemBuilder: (context, index) {
//             final party = filteredParties[index];
//             return GestureDetector(
//               onTap: () {
//                 Navigator.push(
//                   context,
//                   MaterialPageRoute(
//                     builder: (context) => PartyDetail(
//                       partyId: party.id,
//                     ),
//                   ),
//                 );
//               },
//               child: Card(
//                 margin: const EdgeInsets.symmetric(vertical: 8),
//                 shape: RoundedRectangleBorder(
//                   borderRadius: BorderRadius.circular(12),
//                 ),
//                 elevation: 2,
//                 color: Colors.white,
//                 child: Padding(
//                   padding: const EdgeInsets.all(16.0),
//                   child: Row(
//                     children: [
//                       // Avatar
//                       CircleAvatar(
//                         radius: 28,
//                         backgroundImage: party.imagePath.isNotEmpty &&
//                                 File(party.imagePath).existsSync()
//                             ? FileImage(File(party.imagePath))
//                             : const AssetImage('assets/image/account.png') as ImageProvider,
//                         backgroundColor: Colors.grey[100],
//                         child: party.imagePath.isEmpty
//                             ? const Icon(Icons.person, size: 28, color: Colors.grey)
//                             : null,
//                       ),
//                       const SizedBox(width: 12),
//                       // Party Details
//                       Expanded(
//                         child: Column(
//                           crossAxisAlignment: CrossAxisAlignment.start,
//                           children: [
//                             Text(
//                               party.name,
//                               style: const TextStyle(
//                                 fontSize: 18,
//                                 fontFamily: 'ABeeZee',
//                                 fontWeight: FontWeight.bold,
//                                 color: Colors.black87,
//                               ),
//                               overflow: TextOverflow.ellipsis,
//                             ),
//                             const SizedBox(height: 4),
//                             Text(
//                               party.billingAddress.isEmpty ? 'No address' : party.billingAddress,
//                               style: TextStyle(
//                                 fontSize: 14,
//                                 fontFamily: 'ABeeZee',
//                                 color: Colors.grey[600],
//                               ),
//                               maxLines: 1,
//                               overflow: TextOverflow.ellipsis,
//                             ),
//                           ],
//                         ),
//                       ),
//                       const SizedBox(width: 12),
//                       // Balance and Payment Type
//                       Column(
//                         crossAxisAlignment: CrossAxisAlignment.end,
//                         children: [
//                           Container(
//                             padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
//                             decoration: BoxDecoration(
//                               color: _getBalanceColor(party),
//                               borderRadius: BorderRadius.circular(8),
//                             ),
//                             child: Text(
//                               '₹${party.partyBalance.abs().toStringAsFixed(2)}',
//                               style: TextStyle(
//                                 fontSize: 16,
//                                 fontFamily: 'ABeeZee',
//                                 fontWeight: FontWeight.bold,
//                                 color: _getBalanceTextColor(party),
//                               ),
//                             ),
//                           ),
//                           const SizedBox(height: 4),
//                           Text(
//                             _getBalanceLabel(party),
//                             style: TextStyle(
//                               fontSize: 14,
//                               fontFamily: 'ABeeZee',
//                               color: Colors.grey[600],
//                             ),
//                           ),
//                         ],
//                       ),
//                     ],
//                   ),
//                 ),
//               ),
//             );
//           },
//         );
//       },
//     );
//   }
// }

// party_list.dart (or wherever it was)
// lib/screen/listing/party/party_list.dart

import 'package:cream_ventory/database/functions/party_db.dart';
import 'package:cream_ventory/database/functions/user_db.dart';
import 'package:cream_ventory/models/party_model.dart';
import 'package:cream_ventory/screens/party/party_detailing_screen.dart';
import 'package:cream_ventory/screens/party/party_listing_screen_card.dart';
import 'package:flutter/material.dart';

class PartyList extends StatefulWidget {
  final String searchQuery;
  const PartyList({super.key, required this.searchQuery});

  @override
  State<PartyList> createState() => _PartyListState();
}

class _PartyListState extends State<PartyList> {
  String? userId;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _initialize();
  }

  Future<void> _initialize() async {
    try {
      final user = await UserDB.getCurrentUser();
      setState(() {
        userId = user.id;
        isLoading = false;
      });
      await PartyDb.loadParties();
    } catch (e) {
      setState(() { 
        isLoading = false;
      });
      debugPrint('Error initializing PartyList: $e');
    }
  }

  bool get _isDesktop => MediaQuery.of(context).size.width >= 1000 ;

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    return ValueListenableBuilder<List<PartyModel>>(
      valueListenable: PartyDb.partyNotifier,
      builder: (context, parties, _) {
        // ------------------- FILTER -------------------
        final filteredParties = parties.where((party) {
          final matchesUserId = party.userId == userId;
          final matchesSearch =
              widget.searchQuery.isEmpty ||
              party.name.toLowerCase().contains(
                widget.searchQuery.toLowerCase(),
              );
          return matchesUserId && matchesSearch;
        }).toList();

        // ------------------- EMPTY STATE -------------------
        if (filteredParties.isEmpty) {
          return const Center(
            child: Text(
              'No Parties Added Yet',
              style: TextStyle(
                fontSize: 16,
                fontFamily: 'ABeeZee',
                color: Colors.black,
              ),
            ),
          );
        }
        // ------------------- LIST / GRID -------------------
        if (!_isDesktop) {
          return ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            itemCount: filteredParties.length,
            itemBuilder: (context, index) {
              final party = filteredParties[index];
              return Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: PartyCard(
                  party: party,
                  onTap: () => _navigateToDetail(party.id),
                  isDesktop: _isDesktop,
                ),
              );
            },
          );
        }

        // Desktop → GridView (2 columns)
        return GridView.builder(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2, 
            mainAxisExtent: 170,
            mainAxisSpacing: 12,
            crossAxisSpacing: 12,
          ),
          itemCount: filteredParties.length,
          itemBuilder: (context, index) {
            final party = filteredParties[index];
            return PartyCard(
              party: party,
              onTap: () => _navigateToDetail(party.id),
              isDesktop: _isDesktop,
            );
          },
        );
      },    
    );
  }

  // --------------------------------------------------------------
  // Helper – navigation (keeps the code tidy)
  // --------------------------------------------------------------
  void _navigateToDetail(String partyId) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => PartyDetail(partyId: partyId)),
    );
  }
}

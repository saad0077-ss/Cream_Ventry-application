import 'package:cream_ventory/db/functions/party_db.dart';
import 'package:cream_ventory/screen/adding/party/add_party_screen.dart';
import 'package:cream_ventory/screen/distribution_hub/screen/party_list.dart';
import 'package:cream_ventory/screen/distribution_hub/widget/distribution_hub_search_bar.dart';
import 'package:flutter/material.dart';

class PartiesTap extends StatefulWidget {
  const PartiesTap({super.key});

  @override
  State<PartiesTap> createState() => _PartiesTapState();
}

class _PartiesTapState extends State<PartiesTap> {
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _searchController.addListener(() {
      setState(() {});
    });
  }

  @override
  void dispose() {
    _searchController.dispose();    
    super.dispose();
  }

  @override  
  Widget build(BuildContext context) {
    return Container(
       padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      child: Column(
        children: [
          PartySearchBar(
            controller: _searchController,
            onChanged: (value) {
              setState(() {});
            },
            onAddParty: () {
              Navigator.of(context) 
                  .push(
                    MaterialPageRoute(
                      builder: (context) => const AddPartyPage(),
                    ),
                  )
                  .then((result) {
                    if (result != null) {
                      PartyDb.refreshParties();
                    }
                  });
            },
          ),
          const SizedBox(height: 20),
          Expanded(
            child: PartyList(
              searchQuery: _searchController.text,
            ),
          ),
        ],
      ),
    );
  }   
}
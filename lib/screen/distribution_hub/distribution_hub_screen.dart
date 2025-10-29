import 'package:cream_ventory/db/functions/party_db.dart';
import 'package:cream_ventory/screen/distribution_hub/screen/distribution_hub_container.dart';
import 'package:cream_ventory/screen/distribution_hub/widget/distribution_hub_appbar.dart';
import 'package:cream_ventory/screen/distribution_hub/widget/distribution_hub_dawer.dart';
import 'package:flutter/material.dart';

class DistributionHub extends StatefulWidget {
  const DistributionHub({super.key});

  @override
  State<DistributionHub> createState() => _DistributionHubState();
}

class _DistributionHubState extends State<DistributionHub> {
  bool isPartiesSelected = true;
  double totalYoullGet = 0.0;
  double totalYoullGive = 0.0;
  String? currentFilter;

  @override
  void initState() {
    super.initState();
    initializeData();
  } 

  @override
  void dispose() {
    PartyDb.partyNotifier.removeListener(_loadTotalBalance);
    super.dispose();
  }

  void _filterYoullGet() async {
    setState(() {
      if (currentFilter == 'get') {
        currentFilter = null;
        PartyDb.resetPartyFilter();
      } else {
        currentFilter = 'get';
        PartyDb.getSortedYoullGetParties();
      }
    });
  }

  Future<void> initializeData() async {
    await PartyDb.init();
    _loadTotalBalance();
    PartyDb.partyNotifier.addListener(_loadTotalBalance);
  }

  void _filterYoullGive() async {
    setState(() {
      if (currentFilter == 'give') {
        currentFilter = null;
        PartyDb.resetPartyFilter();
      } else {
        currentFilter = 'give';
        PartyDb.getSortedYoullGiveParties();
      }
    });
  }

  void _loadTotalBalance() async {
    final totalGet = await PartyDb.calculateTotalYoullGet();
    final totalGive = await PartyDb.calculateTotalYoullGive();
    if (mounted) {
      setState(() {
        totalYoullGet = totalGet;
        totalYoullGive = totalGive;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    // Determine if the screen is small based on a fixed width threshold
    final bool isSmallScreen = MediaQuery.of(context).size.width < 600;

    return Scaffold(
      appBar: DistributionAppBar(),
      drawer: DashboardPage(),
      body: DistributionHubContainer(
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width,
          maxHeight: MediaQuery.of(context).size.height,
        ),
        isSmallScreen: isSmallScreen,
        totalYoullGet: totalYoullGet,
        totalYoullGive: totalYoullGive,
        currentFilter: currentFilter,
        onFilterYoullGet: _filterYoullGet,
        onFilterYoullGive: _filterYoullGive,
        onLoadTotalBalance: _loadTotalBalance,
      ),
    );
  }
}
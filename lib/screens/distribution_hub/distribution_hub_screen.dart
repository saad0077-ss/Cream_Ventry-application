// distribution_hub.dart
import 'package:cream_ventory/database/functions/party_db.dart';
import 'package:cream_ventory/screens/distribution_hub/distribution_hub_container.dart';
import 'package:cream_ventory/screens/distribution_hub/widget/distribution_hub_appbar.dart';
import 'package:cream_ventory/screens/distribution_hub/widget/distribution_hub_dawer.dart'; // your dashboard file
import 'package:flutter/material.dart';

class DistributionHub extends StatefulWidget {
  const DistributionHub({super.key});

  @override
  State<DistributionHub> createState() => _DistributionHubState();
}

class _DistributionHubState extends State<DistributionHub> {
  bool _isSidebarCollapsed = false;
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

  Future<void> initializeData() async {
    await PartyDb.init();
    _loadTotalBalance();
    PartyDb.partyNotifier.addListener(_loadTotalBalance);
  }

  void _filterYoullGet() {
    setState(() {
      currentFilter = currentFilter == 'get' ? null : 'get';
      if (currentFilter == 'get') {
        PartyDb.getSortedYoullGetParties();
      } else {
        PartyDb.resetPartyFilter();
      }
    });
  }

  void _filterYoullGive() {
    setState(() {
      currentFilter = currentFilter == 'give' ? null : 'give';
      if (currentFilter == 'give') {
        PartyDb.getSortedYoullGiveParties();
      } else {
        PartyDb.resetPartyFilter();
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
    final bool isSmallScreen = MediaQuery.of(context).size.width < 1000;

    final dashboard = DashboardPage(
      isCollapsed: _isSidebarCollapsed,
      onCollapseToggle: () {
        setState(() {
          _isSidebarCollapsed = !_isSidebarCollapsed;
        });
      },
      isSmallScreen: isSmallScreen,
    );

    return Scaffold(
      appBar: DistributionAppBar(
        actions: [
          IconButton(
            icon: const Icon(Icons.home_filled),
            onPressed: () => Navigator.pop(context),
          )   
        ],
        isSmallScreen: isSmallScreen,
      ),
      drawer: isSmallScreen ? dashboard : null,
      body: isSmallScreen
          ? DistributionHubContainer(
              constraints: BoxConstraints(maxWidth: double.infinity, maxHeight: double.infinity),
              isSmallScreen: isSmallScreen,
              totalYoullGet: totalYoullGet,
              totalYoullGive: totalYoullGive,
              currentFilter: currentFilter,
              onFilterYoullGet: _filterYoullGet,
              onFilterYoullGive: _filterYoullGive, 
              onLoadTotalBalance: _loadTotalBalance,
            )
          : Row(
              children: [
                AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  curve: Curves.easeInOut,
                  width: _isSidebarCollapsed ? 80 : 280,
                  child: dashboard,
                ),
                Expanded(
                  child: DistributionHubContainer(
                    constraints: BoxConstraints(maxWidth: double.infinity, maxHeight: double.infinity),
                    isSmallScreen: isSmallScreen,
                    totalYoullGet: totalYoullGet,
                    totalYoullGive: totalYoullGive,
                    currentFilter: currentFilter,
                    onFilterYoullGet: _filterYoullGet,
                    onFilterYoullGive: _filterYoullGive,
                    onLoadTotalBalance: _loadTotalBalance,
                  ),
                ),
              ],
            ),
    );
  }
}
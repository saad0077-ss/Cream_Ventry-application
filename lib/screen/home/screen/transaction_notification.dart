import 'package:cream_ventory/widgets/data_Range_Selector.dart';
import 'package:flutter/material.dart';

class TabTransactionNotification extends StatefulWidget {
  const TabTransactionNotification({super.key});

  @override
  State<TabTransactionNotification> createState() =>
      _TabTransactionNotificationState();
}

class _TabTransactionNotificationState
    extends State<TabTransactionNotification> {
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      child: Column(
        children: [
          DateRangeSelector(),
          const Expanded(
            child: Center(
              child: Text(
                "Transactions Content Goes Here",
                style: TextStyle(fontSize: 16, color: Colors.black),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

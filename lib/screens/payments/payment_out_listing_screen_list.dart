import 'package:cream_ventory/models/payment_out_model.dart';
import 'package:cream_ventory/screens/payments/payment_out_add_screen.dart';
import 'package:cream_ventory/core/constants/font_helper.dart';
import 'package:cream_ventory/screens/payments/widgets/payment_out_card.dart';
import 'package:flutter/material.dart';

class PaymentOutListSliver extends StatelessWidget {
  final List<PaymentOutModel> payments;

  const PaymentOutListSliver({super.key, required this.payments});

  bool _isDesktop(BuildContext context) =>
      MediaQuery.of(context).size.width >= 900;

  @override
  Widget build(BuildContext context) {
    final bool isDesktop = _isDesktop(context);

    // Empty State
    if (payments.isEmpty) {
      return SliverFillRemaining(
        hasScrollBody: false,
        child: Center(
          child: Text(
            'No payments to display.',
            style: AppTextStyles.emptyListText,
            textAlign: TextAlign.center,
          ),
        ),
      );
    }

    // Desktop Grid View
    if (isDesktop) {
      return SliverPadding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        sliver: SliverGrid(
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            mainAxisExtent: 200,
            mainAxisSpacing: 12,
            crossAxisSpacing: 12,
          ),
          delegate: SliverChildBuilderDelegate(
            (context, index) {
              final payment = payments[index];
              return PaymentOutCard(
                payment: payment,
                onTap: () => _navigateToDetail(context, payment),
              );
            },
            childCount: payments.length,
          ),
        ),
      );
    }

    // Mobile List View
    return SliverPadding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      sliver: SliverList(
        delegate: SliverChildBuilderDelegate(
          (context, index) {
            final payment = payments[index];
            return PaymentOutCard(
              payment: payment,
              onTap: () => _navigateToDetail(context, payment),
            );
          },
          childCount: payments.length,
        ),
      ),
    );
  }

  void _navigateToDetail(BuildContext context, PaymentOutModel payment) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => PaymentOutScreen(payment: payment),
      ),
    ).then((result) {
      if (result == true) {
        debugPrint('Refresh triggered from PaymentOutScreen');
      }
    });
  }
}
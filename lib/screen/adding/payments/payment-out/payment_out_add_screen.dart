import 'package:cream_ventory/db/models/payment/payment_out_model.dart';
import 'package:cream_ventory/screen/adding/controller/payment_out_add_screen_controller.dart';
import 'package:cream_ventory/themes/app_theme/theme.dart';
import 'package:cream_ventory/widgets/app_bar.dart';
import 'package:flutter/material.dart';

class PaymentOutScreen extends StatelessWidget {
  final PaymentOutModel? payment;
  const PaymentOutScreen({super.key, this.payment});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(
        title: payment != null ? 'Edit Payment-Out' : 'Payment-Out',
      ),
      backgroundColor: Colors.transparent,
      body: Container(
        decoration: const BoxDecoration(gradient: AppTheme.appGradient),
        child: PaymentOutScreenState(payment: payment),
      ),
    );
  }
}
import 'package:cream_ventory/models/payment_in_model.dart';
import 'package:cream_ventory/screens/controller/payment_in_add_screen_controller.dart';
import 'package:cream_ventory/widgets/app_bar.dart';
import 'package:cream_ventory/core/theme/theme.dart';
import 'package:flutter/material.dart';

class PaymentInScreen extends StatelessWidget {
  final PaymentInModel? payment;
  const PaymentInScreen({super.key, this.payment});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(
        title: payment != null ? 'Edit Payment-In' : 'Payment-In',
      ),
      backgroundColor: Colors.transparent,
      body: Container(
        decoration: const BoxDecoration(gradient: AppTheme.appGradient),
        child: PaymentInScreenState(payment: payment),
      ),
    );
  }
} 
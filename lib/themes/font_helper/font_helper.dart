import 'package:flutter/material.dart';

class AppTextStyles {
  static const holtwood35White = TextStyle(
    fontSize: 33,
    fontFamily: 'holtwood',
    color: Colors.white,
  );

  static const textSpan = TextStyle(
    fontSize: 30,
    fontFamily: 'holtwood',
    color: Colors.white,
  );

  static const textSpan2 = TextStyle(color: Colors.black);

  static const holtwood40White = TextStyle(
    fontSize: 40,
    fontFamily: 'holtwood',
    color: Colors.white,
  );

  static const signUpText = TextStyle(
    fontFamily: 'holtwood',
    color: Colors.white,
    fontSize: 18,
    letterSpacing: 1,
    height: 1.7,
  );

  static const holtwood40Accent = TextStyle(
    fontSize: 40,
    fontFamily: 'holtwood',
    color: Color.fromARGB(255, 54, 61, 103),
  );

  static const welcomeTitle = TextStyle(
    fontFamily: 'ADLaM',
    color: Colors.white,
    fontSize: 25,
    fontWeight: FontWeight.bold,
  );

  static const rememberMe = TextStyle(
    color: Colors.white,
    fontFamily: 'ABeeZee',
  );

  static const bold18 = TextStyle(fontSize: 18, fontWeight: FontWeight.bold);

  static const profileValue = TextStyle(
    fontSize: 16,
    color: Colors.black,
    fontFamily: 'ABeeZee',
  );

  static const summaryCard = TextStyle(
    fontSize: 20,
    fontWeight: FontWeight.bold,
    fontFamily: 'ABeeZee',
    color: Colors.black,
  );

  static const smallLabelGrey = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.w500,
    color: Colors.grey,
  );

  static const valueBold = TextStyle(fontSize: 14, fontWeight: FontWeight.bold);

  static const dateText = TextStyle(color: Colors.black, fontSize: 12);

  static const dateRangeLabel = TextStyle(color: Colors.black, fontSize: 15);

  static const transactionTitle = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.bold,
  );

  static const transactionDate = TextStyle(color: Colors.grey, fontSize: 12);

  static const stockGreen = TextStyle(
    fontWeight: FontWeight.bold,
    color: Colors.green,
  );

  static const cardTitle = TextStyle(fontSize: 14, fontWeight: FontWeight.bold);

  static const cardSubtitle = TextStyle(
    fontSize: 10,
    fontWeight: FontWeight.w500,
  );

  static const salePriceBold = TextStyle(
    fontWeight: FontWeight.bold,
    fontSize: 14,
  );

  static TextStyle regular({double fontSize = 16}) {
    return TextStyle(
      fontFamily: 'ADLaM',
      fontSize: fontSize,
      color: Colors.white,
    );
  }

  static TextStyle appBarHoltwood({double fontSize = 20}) {
    return TextStyle(
      fontSize: fontSize,
      color: Color.fromARGB(255, 0, 0, 0), // Slate Bl ue
      fontFamily: 'Audiowide',
    );
  }

  static TextStyle dateRange = TextStyle(color: Colors.black, fontSize: 12);

  static TextStyle dateRangeTo = TextStyle(color: Colors.black, fontSize: 15);

  static TextStyle emptyListText = TextStyle(fontSize: 16, color: Colors.black);

  static TextStyle textBold = TextStyle(fontWeight: FontWeight.bold);

  static TextStyle w500 = TextStyle(fontWeight: FontWeight.w500);

  static TextStyle black54 = TextStyle(fontSize: 13, color: Colors.black54);

  static TextStyle bold13 = TextStyle(
    fontWeight: FontWeight.bold,
    fontSize: 13,
  );

  static TextStyle bold20 = TextStyle(
    color: Colors.black,
    fontSize: 20,
    fontWeight: FontWeight.bold,
  );
}

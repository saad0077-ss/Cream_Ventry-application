import 'package:flutter/material.dart';

class AppTextStyles {
  static TextStyle holtwood35White = TextStyle(
    fontSize: 25 ,
    fontFamily: 'holtwood',
    color: Colors.white,
  ); 

  static TextStyle textSpan = TextStyle(
    fontSize: 30,
    fontFamily: 'holtwood',
    color: Colors.white,
  );   

  static TextStyle textSpan2 = TextStyle(
    fontSize: 30, 
    color: Colors.black,
  );

  static TextStyle holtwood40White = TextStyle( 
    fontSize: 40,
    fontFamily: 'holtwood',
    color: Colors.white,
  );

  static TextStyle signUpText = TextStyle(
    fontFamily: 'holtwood',   
    color: Colors.white,
    fontSize: 16,
    letterSpacing: 1,
    height: 1.7,
  );

  static TextStyle holtwood40Accent = TextStyle(
    fontSize: 40,
    fontFamily: 'holtwood',
    color: const Color.fromARGB(255, 54, 61, 103),
  );

  static TextStyle welcomeTitle = TextStyle(
    fontFamily: 'ADLaM',
    color: Colors.white,
    fontSize: 25,
    fontWeight: FontWeight.bold,
  );

  static TextStyle rememberMe = TextStyle(
    color: Colors.white,
    fontFamily: 'ABeeZee',
    fontSize: 14,
  );

  static TextStyle bold18 = TextStyle(
    fontSize: 18,
    fontWeight: FontWeight.bold,
  );

  static TextStyle profileValue = TextStyle(
    fontSize: 16,
    color: Colors.black,
    fontFamily: 'ABeeZee',
  );

  static TextStyle summaryCard = TextStyle(
    fontSize: 20,
    fontWeight: FontWeight.bold,
    fontFamily: 'ABeeZee',
    color: Colors.black,
  );

  static TextStyle smallLabelGrey = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.w500,
    color: Colors.grey,
  );

  static TextStyle valueBold = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.bold,
  );

  static TextStyle dateText = TextStyle(
    color: Colors.black,
    fontSize: 12,
  );

  static TextStyle dateRangeLabel = TextStyle(
    color: Colors.black,
    fontSize: 15,
  );

  static TextStyle transactionTitle = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.bold,
  );

  static TextStyle transactionDate = TextStyle(
    color: Colors.grey,
    fontSize: 12,
  );

  static TextStyle stockGreen = const TextStyle(
    fontWeight: FontWeight.bold,
    color: Colors.green,
  );

  static TextStyle cardTitle = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.bold,
  );

  static TextStyle cardSubtitle = TextStyle(
    fontSize: 10,
    fontWeight: FontWeight.w500,
  );

  static TextStyle salePriceBold = TextStyle(
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
      color: const Color.fromARGB(255, 0, 0, 0),
      fontFamily: 'Audiowide',
    );
  }

  static TextStyle dateRange = TextStyle(
    color: Colors.black,
    fontSize: 12,
  );

  static TextStyle dateRangeTo = TextStyle(
    color: Colors.black,
    fontSize: 15,
  ); 

  static TextStyle emptyListText = TextStyle(
    fontSize: 16,
    color: Colors.black,
  );

  static TextStyle textBold = const TextStyle(
    fontWeight: FontWeight.bold,
  );

  static TextStyle w500 = const TextStyle(
    fontWeight: FontWeight.w500,
  );

  static TextStyle black54 = TextStyle(
    fontSize: 13,
    color: Colors.black54,   
  );

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
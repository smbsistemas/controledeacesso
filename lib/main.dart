import 'package:flutter/material.dart';
//import 'package:controle_acesso/qr_barcode_screen.dart';
import 'package:controle_acesso/loginPage.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Controle de Acesso',
      home: LoginPage(),
      //QRBarcodeScreen(),
    );
  }
}

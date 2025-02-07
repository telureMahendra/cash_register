import 'package:cash_register/helper/printHelper.dart';
import 'package:cash_register/helper/product.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:math_expressions/math_expressions.dart';

class CalculatorSummary extends StatefulWidget {
  const CalculatorSummary({super.key});

  @override
  State<CalculatorSummary> createState() => _CalculatoSsummaryState();
}

class _CalculatoSsummaryState extends State<CalculatorSummary> {
  var size, width, height;

  getadaptiveTextSize(BuildContext context, dynamic value) {
    return (value / 710) * MediaQuery.of(context).size.height;
  }

  String _info = "";
  String _msj = '';

  var evalString;

  bool connected = false;
  String _selectSize = "2";
  final _txtText = TextEditingController(text: "Hello developer");
  bool _progress = false;
  String _msjprogress = "";
  var conDeviceMac = '', conDeviceName = '';
  List<String> amounts = [];

  String optionprinttype = "58 mm";
  List<String> options = ["58 mm", "80 mm"];
  final TextEditingController priceEditContoller = TextEditingController();
  Parser p = Parser();
  late Printhelper printhelper = Printhelper();

  @override
  void initState() {
    super.initState();
  }

  loadData() {
    if (evalString[evalString.length - 1] == '+') {
      evalString = evalString.substring(0, evalString.length - 1);
    }

    amounts = evalString.split("+");
    int counter = 1;
  }

  printThermalReciept() {}

  final inrFormat = NumberFormat.currency(
    locale: 'hi_IN',
    name: 'INR',
    symbol: '₹',
    decimalDigits: 2,
  );

  Future<bool> _onWillPopDialouge() async {
    return false;
  }

  @override
  Widget build(BuildContext context) {
    return const Placeholder();
  }
}

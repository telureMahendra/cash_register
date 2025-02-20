import 'dart:convert';

import 'package:cash_register/common_utils/common_functions.dart';
import 'package:cash_register/common_utils/strings.dart';
import 'package:cash_register/helper/product.dart';
import 'package:cash_register/model/cart_item.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter_esc_pos_utils/flutter_esc_pos_utils.dart';

import 'package:math_expressions/math_expressions.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:print_bluetooth_thermal/post_code.dart';

import 'package:print_bluetooth_thermal/print_bluetooth_thermal.dart';
// import 'package:print_bluetooth_thermal/print_bluetooth_thermal.dart';
import 'package:qr_bar_code/code/src/code_generate.dart';
import 'package:qr_bar_code/code/src/code_type.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:widgets_to_image/widgets_to_image.dart';
import 'package:workmanager/workmanager.dart';
import 'package:workmanager/src/options.dart' as constraints;
import 'package:flutter_styled_toast/flutter_styled_toast.dart';
import 'package:http/http.dart' as http;
import 'package:image/image.dart' as img;

import 'package:qr_bar_code/qr_bar_code.dart';
import 'package:internet_connection_checker/internet_connection_checker.dart';

class Printhelper {
  final String _optionprinttype = "58 mm";
  final _inrFormat = NumberFormat.currency(
    locale: 'hi_IN',
    name: 'INR',
    symbol: '₹',
    decimalDigits: 2,
  );
  String _total = '0.0';
  Parser _p = Parser();

  final String sourceCalculator = "CALCULATOR";
  final String sourceProduct = "PRODUCT";

  printThermalReciept(var payMethod, var recSource, var evalString) async {
    bool connectionStatus = await PrintBluetoothThermal.connectionStatus;

    String time = DateFormat('jms').format(DateTime.now()).toString();
    String date = DateFormat('yMMMd').format(DateTime.now()).toString();

    if (connectionStatus) {
      print("Device Connected to printer ");

      final prefs = await SharedPreferences.getInstance();
      List<int> bytes = [];
      // Using default profile
      final profile = await CapabilityProfile.load();

      bool isLogoPrint;
      isLogoPrint = prefs.getBool(printLogoSwitchKeyName) ?? false;

      final generator = Generator(
          _optionprinttype == "58 mm" ? PaperSize.mm58 : PaperSize.mm80,
          profile);
      bytes += generator.setGlobalFont(PosFontType.fontA);
      bytes += generator.reset();

      if (isLogoPrint) {
        final Uint8List bytesImg =
            Base64Codec().decode(prefs.getString('image') ?? '');
        img.Image? image = img.decodeImage(bytesImg);

        final resizedImage = img.copyResize(image!,
            width: image.width ~/ 1.3,
            height: image.height ~/ 1.3,
            interpolation: img.Interpolation.nearest);
        final bytesimg = Uint8List.fromList(img.encodeJpg(resizedImage));
        image = img.decodeImage(bytesimg);

        bytes += generator.image(
          image!,
          align: PosAlign.center,
        );

        await PrintBluetoothThermal.writeBytes(bytes);
        bytes = [];
      }
      await PrintBluetoothThermal.writeString(
        printText: PrintTextSize(
          size: 3,
          text: prefs.getString("businessName") ?? '',
        ),
      );

      await PrintBluetoothThermal.writeString(
        printText: PrintTextSize(
          size: 1,
          text: '\n${prefs.getString("address") ?? ''}',
        ),
      );

      await PrintBluetoothThermal.writeString(
        printText: PrintTextSize(
          size: 2,
          text: '\nEmail: ${prefs.getString("businessEmail") ?? ''}',
        ),
      );

      await PrintBluetoothThermal.writeString(
        printText: PrintTextSize(
          size: 2,
          text: '\nMobile: ${prefs.getString("businessMobile") ?? ''}',
        ),
      );

      bool isGstPrint = prefs.getBool('isPrintGST') ?? false;
      if (isGstPrint) {
        await PrintBluetoothThermal.writeString(
          printText: PrintTextSize(
            size: 2,
            text: '\nGST: ${prefs.getString("gstNumber") ?? ''}',
          ),
        );
      }

      bytes = [];

      // bytes +=
      //     PostCode.text(text: "Size compressed", fontSize: FontSize.compressed);
      // bytes += PostCode.text(text: "Size normal", fontSize: FontSize.normal);
      // bytes += PostCode.text(text: "Bold", bold: true);
      // bytes += PostCode.text(text: "Inverse", inverse: true);
      // bytes += PostCode.text(text: "AlignPos right", align: AlignPos.right);
      // bytes += PostCode.text(
      //     text: "Size normal center",
      //     bold: true,
      //     fontSize: FontSize.normal,
      //     align: AlignPos.center);

      var invCalCounter = prefs.getInt("invCalCounter") ?? 1;

      var invProdCounter = prefs.getInt("invProdCounter") ?? 1;

      bytes += generator.feed(1);

      if (recSource == "CALCULATOR") {
        bytes += PostCode.text(
          text:
              "Inv No.: cal/${invCalCounter++}${_addSpace(25 - payMethod.toString().length - invCalCounter.toString().length)}By: ${payMethod.toString()}",
          fontSize: FontSize.compressed,
          align: AlignPos.center,
        );
        prefs.setInt("invCalCounter", invCalCounter++);
      } else {
        bytes += PostCode.text(
          text:
              "Inv No.: Pro/${invProdCounter++}${_addSpace(25 - payMethod.toString().length - invProdCounter.toString().length)}By: ${payMethod}",
          fontSize: FontSize.compressed,
          align: AlignPos.center,
        );
        prefs.setInt("invProdCounter", invProdCounter++);
      }

      bytes += PostCode.text(
        text:
            "Date: ${date}${_addSpace(30 - date.length - time.length)}Time: ${time}",
        fontSize: FontSize.compressed,
        align: AlignPos.center,
      );

      bytes += PostCode.text(
        text: "------------------------------------------",
        fontSize: FontSize.compressed,
        align: AlignPos.center,
      );
      bytes += PostCode.text(
        text: "Product${_addSpace(20)}Value",
        align: AlignPos.center,
        fontSize: FontSize.normal,
      );
      bytes += PostCode.text(
        text: "------------------------------------------",
        fontSize: FontSize.compressed,
        align: AlignPos.center,
      );

      if (evalString[evalString.length - 1] == '+') {
        evalString = evalString.substring(0, evalString.length - 1);
      }

      List<String> amounts = evalString.split("+");
      int counter = 1;

      if (recSource == "CALCULATOR") {
        if (evalString[evalString.length - 1] != '+') {
          Expression exp = _p.parse(evalString);
          ContextModel cm = ContextModel();
          _total = '${exp.evaluate(EvaluationType.REAL, cm)}';
        }
        for (String a in amounts) {
          a = _inrFormat.format(double.parse(a.toString()));
          bytes += PostCode.text(
            text:
                "Item $counter${_addSpace(34 - a.length - counter.toString().length)}Rs. ${a.substring(1)}",
            fontSize: FontSize.compressed,
            align: AlignPos.center,
            bold: false,
          );
          counter++;
        }
      }

      bytes += PostCode.text(
        text: "==========================================",
        fontSize: FontSize.compressed,
        align: AlignPos.center,
      );
      bytes += PostCode.text(
        text:
            "Total${_addSpace(24 - _total.length - 3)}Rs. ${_inrFormat.format(double.parse(_total)).substring(1)}",
        fontSize: FontSize.normal,
        bold: true,
        align: AlignPos.center,
      );
      bytes += PostCode.text(
        text: "==========================================",
        fontSize: FontSize.compressed,
        align: AlignPos.center,
      );

      bytes += PostCode.text(
        text: "Thank You!",
        fontSize: FontSize.doubleHeight,
        align: AlignPos.center,
      );
      bytes += PostCode.text(
        text: "Note: Goods once sold will not be taken back or exchanged.",
        fontSize: FontSize.compressed,
        align: AlignPos.center,
      );
      bytes += PostCode.text(
        text: "Powerd by: Vizpay Business Solutions Pvt. Ltd.",
        fontSize: FontSize.compressed,
        align: AlignPos.center,
      );

      // bytes += PostCode.enter();

      bytes += generator.feed(3);
      //bytes += generator.cut();
      await PrintBluetoothThermal.writeBytes(bytes);
    }
    print("Device not connected");
  }

  Future<bool> printProductReciept(
    var payMethod,
    var recSource,
  ) async {
    bool connectionStatus = await PrintBluetoothThermal.connectionStatus;

    String time = DateFormat('jms').format(DateTime.now()).toString();
    String date = DateFormat('yMMMd').format(DateTime.now()).toString();

    var data = getCartProducts();

    if (connectionStatus) {
      print("Device Connected to printer ");

      final prefs = await SharedPreferences.getInstance();
      List<int> bytes = [];
      // Using default profile
      final profile = await CapabilityProfile.load();

      bool isLogoPrint;
      isLogoPrint = prefs.getBool(printLogoSwitchKeyName) ?? false;

      final generator = Generator(
          _optionprinttype == "58 mm" ? PaperSize.mm58 : PaperSize.mm80,
          profile);
      bytes += generator.setGlobalFont(PosFontType.fontA);
      bytes += generator.reset();

      if (isLogoPrint) {
        final Uint8List bytesImg =
            Base64Codec().decode(prefs.getString('image') ?? '');
        img.Image? image = img.decodeImage(bytesImg);

        final resizedImage = img.copyResize(image!,
            width: image.width ~/ 1.3,
            height: image.height ~/ 1.3,
            interpolation: img.Interpolation.nearest);
        final bytesimg = Uint8List.fromList(img.encodeJpg(resizedImage));
        image = img.decodeImage(bytesimg);

        bytes += generator.image(
          image!,
          align: PosAlign.center,
        );

        await PrintBluetoothThermal.writeBytes(bytes);
      }
      await PrintBluetoothThermal.writeString(
        printText: PrintTextSize(
          size: 3,
          text: prefs.getString("businessName") ?? '',
        ),
      );

      await PrintBluetoothThermal.writeString(
        printText: PrintTextSize(
          size: 1,
          text: '\n${prefs.getString("address") ?? ''}',
        ),
      );

      await PrintBluetoothThermal.writeString(
        printText: PrintTextSize(
          size: 2,
          text: '\nEmail: ${prefs.getString("businessEmail") ?? ''}',
        ),
      );

      await PrintBluetoothThermal.writeString(
        printText: PrintTextSize(
          size: 2,
          text: '\nMobile: ${prefs.getString("businessMobile") ?? ''}',
        ),
      );

      bool isGstPrint = prefs.getBool('isPrintGST') ?? false;
      if (isGstPrint) {
        await PrintBluetoothThermal.writeString(
          printText: PrintTextSize(
            size: 2,
            text: '\nGST: ${prefs.getString("gstNumber") ?? ''}',
          ),
        );
      }

      bytes = [];

      // bytes +=
      //     PostCode.text(text: "Size compressed", fontSize: FontSize.compressed);
      // bytes += PostCode.text(text: "Size normal", fontSize: FontSize.normal);
      // bytes += PostCode.text(text: "Bold", bold: true);
      // bytes += PostCode.text(text: "Inverse", inverse: true);
      // bytes += PostCode.text(text: "AlignPos right", align: AlignPos.right);
      // bytes += PostCode.text(
      //     text: "Size normal center",
      //     bold: true,
      //     fontSize: FontSize.normal,
      //     align: AlignPos.center);

      var invProdCounter = prefs.getInt("invProdCounter") ?? 1;

      bytes += generator.feed(1);

      bytes += PostCode.text(
        text:
            "Inv No.: Pro/${invProdCounter++}${_addSpace(25 - payMethod.toString().length - invProdCounter.toString().length)}By: ${payMethod}",
        fontSize: FontSize.compressed,
        align: AlignPos.center,
      );
      prefs.setInt("invProdCounter", invProdCounter++);

      bytes += PostCode.text(
        text:
            "Date: ${date}${_addSpace(30 - date.length - time.length)}Time: ${time}",
        fontSize: FontSize.compressed,
        align: AlignPos.center,
      );

      bytes += PostCode.text(
        text: "------------------------------------------",
        fontSize: FontSize.compressed,
        align: AlignPos.center,
      );
      bytes += PostCode.text(
        text: "Product${_addSpace(8)}QTY${_addSpace(9)}Value",
        align: AlignPos.center,
        fontSize: FontSize.normal,
      );
      bytes += PostCode.text(
        text: "------------------------------------------",
        fontSize: FontSize.compressed,
        align: AlignPos.center,
      );

      List<CartItem> data = await getCartProducts();

      for (CartItem product in data) {
        var _price = _calculate(product.countNumber, product.price);
        _total += '+$_price';
        bytes += PostCode.text(
          text:
              '${product.productName}${_addSpace(21 - product.productName.length)}${product.countNumber}${_addSpace(21 - 4 - product.countNumber.toString().length - _price.length)}Rs. $_price',
          fontSize: FontSize.compressed,
          align: AlignPos.center,
        );
      }

      // if (evalString[evalString.length - 1] == '+') {
      //   evalString = evalString.substring(0, evalString.length - 1);
      // }

      // List<String> amounts = evalString.split("+");
      // int counter = 1;

      // if (recSource == "CALCULATOR") {
      //   if (evalString[evalString.length - 1] != '+') {
      //     Expression exp = _p.parse(evalString);
      //     ContextModel cm = ContextModel();
      //     _total = '${exp.evaluate(EvaluationType.REAL, cm)}';
      //   }
      //   for (String a in amounts) {
      //     a = _inrFormat.format(double.parse(a.toString()));
      //     bytes += PostCode.text(
      //       text:
      //           "Item $counter${_addSpace(34 - a.length - counter.toString().length)}Rs. ${a.substring(1)}",
      //       fontSize: FontSize.compressed,
      //       align: AlignPos.center,
      //       bold: false,
      //     );
      //     counter++;
      //   }
      // }

      bytes += PostCode.text(
        text: "==========================================",
        fontSize: FontSize.compressed,
        align: AlignPos.center,
      );
      _total = _calculateTotal(_total);
      bytes += PostCode.text(
        text:
            "Total${_addSpace(24 - _total.length - 3)}Rs. ${_inrFormat.format(double.parse(_total)).substring(1)}",
        fontSize: FontSize.normal,
        bold: true,
        align: AlignPos.center,
      );
      bytes += PostCode.text(
        text: "==========================================",
        fontSize: FontSize.compressed,
        align: AlignPos.center,
      );

      bytes += PostCode.text(
        text: "Thank You!",
        fontSize: FontSize.doubleHeight,
        align: AlignPos.center,
      );
      // _total = '';
      bytes += PostCode.text(
        text: "Note: Goods once sold will not be taken back or exchanged.",
        fontSize: FontSize.compressed,
        align: AlignPos.center,
      );
      bytes += PostCode.text(
        text: "Powerd by: Vizpay Business Solutions Pvt. Ltd.",
        fontSize: FontSize.compressed,
        align: AlignPos.center,
      );

      // bytes += PostCode.enter();

      bytes += generator.feed(3);
      //bytes += generator.cut();
      await PrintBluetoothThermal.writeBytes(bytes);

      return true;
    }
    // await dbs.getCartTotal()
    // saveTransactionSqlite("CASH", _total, recSource, true);
    _total = '';
    return false;
  }

  String _calculate(var count, var price) {
    var evalString = count.toString();
    evalString += "*";
    evalString += price;
    Expression exp = _p.parse(evalString);
    ContextModel cm = ContextModel();

    return '${exp.evaluate(EvaluationType.REAL, cm)}';
  }

  String _calculateTotal(evalString) {
    Expression exp = _p.parse(evalString);
    ContextModel cm = ContextModel();

    return '${exp.evaluate(EvaluationType.REAL, cm)}';
  }

  String _addSpace(spaceCount) {
    var temp = "";
    for (int i = 0; i < spaceCount; i++) {
      temp += " ";
    }
    return temp;
  }
}

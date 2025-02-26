import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:cash_register/Widgets/all_dialog.dart';
import 'package:cash_register/Widgets/calculator_qr_code_widget.dart';
import 'package:cash_register/Widgets/product_qr_code_widget.dart';
import 'package:cash_register/common_utils/assets_path.dart';
import 'package:cash_register/common_utils/strings.dart';
import 'package:cash_register/db/sqfLite_db_service.dart';
import 'package:cash_register/helper/printe_helper.dart';
import 'package:cash_register/helper/service/transaction_sync_service.dart';
import 'package:cash_register/helper/stream_helper.dart';
import 'package:cash_register/model/cart_item.dart';
import 'package:cash_register/model/environment.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:math_expressions/math_expressions.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

double getAdaptiveTextSize(BuildContext context, dynamic value) {
  return (value / 710) * MediaQuery.of(context).size.height;
}

// final inrFormat = NumberFormat.currency(
//   locale: 'hi_IN',
//   name: 'INR',
//   symbol: '₹',
//   decimalDigits: 2,
// );

final inrFormat = NumberFormat.currency(
  locale: currencyLocal,
  name: currencyName,
  symbol: currencySymbol,
  decimalDigits: currencyDecimalDigits,
);

String convertIntoBase64(File file) {
  List<int> imageBytes = file.readAsBytesSync();
  String base64File = base64Encode(imageBytes);
  return base64File;
}

String convertIntoBase64FromMemoryImage(MemoryImage file) {
  // List<int> imageBytes = file.readAsBytesSync();
  List<int> imageBytes = file.bytes;
  String base64File = base64Encode(imageBytes);
  return base64File;
}

Future<String> loadImage() async {
  final prefs = await SharedPreferences.getInstance();
  return prefs.getString(imageKey) ?? "";
}

void showPicker({
  required BuildContext context,
}) {
  showModalBottomSheet(
    context: context,
    builder: (BuildContext context) {
      return SafeArea(
        child: Wrap(
          children: <Widget>[
            ListTile(
              leading: const Icon(Icons.photo_library),
              title: const Text(textPhotoLibrary),
              onTap: () {
                getImage(ImageSource.gallery, context);
                Navigator.of(context).pop();
              },
            ),
            ListTile(
              leading: const Icon(Icons.photo_camera),
              title: const Text(textCamera),
              onTap: () {
                getImage(ImageSource.camera, context);
                Navigator.of(context).pop();
              },
            ),
          ],
        ),
      );
    },
  );
}

Future getImage(ImageSource img, BuildContext context) async {
  File? galleryFile;
  final picker = ImagePicker();
  final pickedFile = await picker.pickImage(
    source: img,
    imageQuality: 25,
  );
  XFile? xfilePick = pickedFile;
  if (xfilePick != null) {
    galleryFile = File(pickedFile!.path);
    storeImage(galleryFile);
  } else {
    if (context.mounted) {
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text(textNothingIsSelected)));
    }
  }
}

storeImage(File file) async {
  final prefs = await SharedPreferences.getInstance();
  prefs.setString(imageKey, convertIntoBase64(file));
}

Future<List<CartItem>> getCartProducts() async {
  final dbs = DatabaseService.instance;
  List<Map<String, Object?>>? data = await dbs.getCartList();

  print("in fetch method");
  List<CartItem> cartList =
      data.map((item) => CartItem.fromJson(item)).toList();

  return cartList;
}

Future<Map<String, dynamic>> findCartProductById(int productId) {
  final dbs = DatabaseService.instance;
  return dbs.getCartProductById(productId);
}

void deleteAllProducts(BuildContext context) async {
  final dbs = DatabaseService.instance;
  // String total = await dbs.getCartTotal();
  dbs.emptyCart().then((_) async {
    StreamHelper.cartCountSink.add(await dbs.getCartCount());

    if (context.mounted) {
      Navigator.pop(context);
    }
  });
}

void clearCart() async {
  final dbs = DatabaseService.instance;

  // String total = await dbs.getCartTotal();
  dbs.emptyCart().then((_) async {
    StreamHelper.cartCountSink.add(await dbs.getCartCount());
  });
}

String calculateProductPrice(var count, var price) {
  Parser p = Parser();
  var evalString = count.toString();
  evalString += "*";
  evalString += price;
  Expression exp = p.parse(evalString);
  ContextModel cm = ContextModel();

  return '${exp.evaluate(EvaluationType.REAL, cm)}';
}

Future<void> syncTransaction(bool isDeviceConnected) async {
  final dbs = DatabaseService.instance;
  if (isDeviceConnected) {
    TransactionSyncService syncService =
        TransactionSyncService(DatabaseService.instance, databaseHelper: dbs);
    await syncService.syncTransactions();
    final prefs = await SharedPreferences.getInstance();
    prefs.setBool(isSyncedKey, true);
  } else {
    print(networkErrorMessage);
  }
}

Future<bool> onWillPopDialouge() async {
  return false;
}

printQrReciept(String method, BuildContext context) async {
  final dbs = DatabaseService.instance;
  Printhelper printHelper = Printhelper();
  printHelper
      .printProductReciept(textButtonCash, printHelper.sourceProduct)
      .then((_) async {
    saveTransactionSqlite(
        method, await dbs.getCartTotal(), printHelper.sourceProduct, true);
    // deleteAllProducts(context, true, false);
    // Navigator.pop(context);
  });
}

void showProductQrCodeDialog(BuildContext context, String total, String method,
    String tranSource, bool isDeviceConnected) {
  showDialog<void>(
    context: context,
    barrierDismissible: false,
    builder: (context) => WillPopScope(
      onWillPop: onWillPopDialouge,
      child: AlertDialog(
        content: ProductQrCodeWidget(
          amount: total,
          method: method,
          tranSource: tranSource,
          isDeviceConnected: isDeviceConnected,
        ),
      ),
    ),
  );
}

bool showCalculatorQrCodeDialog(
    BuildContext context,
    String total,
    String method,
    String tranSource,
    bool isDeviceConnected,
    String evalString) {
  showDialog<void>(
    context: context,
    barrierDismissible: false,
    builder: (context) => WillPopScope(
      onWillPop: onWillPopDialouge,
      child: AlertDialog(
        content: QrCodeWidget(
          amount: total,
          method: method,
          tranSource: tranSource,
          isDeviceConnected: isDeviceConnected,
          evalString: evalString,
        ),
      ),
    ),
  );
  return true;
}

Future<bool> saveTransactionSqlite(String method, String amount,
    String tranSource, bool isDeviceConnected) async {
  final dbs = DatabaseService.instance;
  String time = DateFormat('jms').format(DateTime.now()).toString();
  String date = DateFormat('yMMMd').format(DateTime.now()).toString();
  String inrAmount = inrFormat.format(double.parse(amount)).toString();
  String dateTime =
      DateFormat('yyyy-MM-dd HH:mm:ss').format(DateTime.now()).toString();
  final prefs = await SharedPreferences.getInstance();

  int userId = prefs.getInt(upiIDKey)!;

  await dbs
      .saveTransaction(
          inrAmount, method, time, date, userId, dateTime, 0, tranSource)
      .then((_) {
    syncTransaction(isDeviceConnected);
    return true;
  });
  return false;
}

void saveTransactionToServer(String method, String amount1, String tranSource,
    BuildContext context) async {
  String time = DateFormat('jms').format(DateTime.now()).toString();
  String date = DateFormat('yMMMd').format(DateTime.now()).toString();
  String amount = inrFormat.format(double.parse(amount1)).toString();
  String dateTime =
      DateFormat('yyyy-MM-dd HH:mm:ss').format(DateTime.now()).toString();
  final prefs = await SharedPreferences.getInstance();

  try {
    if (context.mounted) {
      showLoader(context);
    }

    final response = await http.post(
      Uri.parse('${Environment.baseUrl}/transaction'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
        userIdKey: '${prefs.getInt(userIdKey)}'
      },
      body: jsonEncode(<String, dynamic>{
        'method': method,
        'time': time,
        'date': date,
        'amount': amount,
        'userId': '${prefs.getInt(userIdKey)}',
        "dateTime": dateTime,
        'tranSource': tranSource,
        'user': {
          'userId': '${prefs.getInt(userIdKey)}',
        }
      }),
    );
    if (context.mounted) {
      Navigator.pop(context);
    }
    if (response.statusCode == 200) {
      // successful(method);
    } else {
      if (context.mounted) {
        showSuccessFailDialog(
            context, warningAnimationPath, response.body.toString());
      }
      // sleep(Duration(seconds: 1));
    }
  } on SocketException catch (e) {
    if (context.mounted) {
      Navigator.pop(context);
      showSuccessFailDialog(context, warningAnimationPath, networkErrorMessage);
    }
  } catch (e) {
    if (context.mounted) {
      Navigator.pop(context);
      showSuccessFailDialog(
          context, warningAnimationPath, serverNotRespondingMessage);
    }
  }
}

Future<String> getDeviceModel() async {
  DeviceInfoPlugin deviceInfo = DeviceInfoPlugin();

  if (Platform.isAndroid) {
    AndroidDeviceInfo androidInfo = await deviceInfo.androidInfo;
    print(androidInfo.serialNumber);
    return androidInfo.model;
  } else if (Platform.isIOS) {
    IosDeviceInfo iosInfo = await deviceInfo.iosInfo;
    return iosInfo.utsname.machine;
  } else {
    return unknownDevice;
  }
}

payUsingPaymentApp(String tranType, BuildContext context) async {
  final dbs = DatabaseService.instance;
  const platform = MethodChannel('printMethod');
  try {
    final saleRequest = {
      "AMOUNT": await dbs.getCartTotal(),
      // "TIP_AMOUNT": "0",
      "TRAN_TYPE": tranType,
      "BILL_NUMBER": "abc123",
      "SOURCE_ID": "abcd",
      "PRINT_FLAG": "0",
      "UDF2": "",
      "UDF3": "",
      "UDF4": "",
      "UDF5": "",
    };

    var response = await platform.invokeMethod('paymentMethod', {
      "data": saleRequest,
      "TRAN_TYPE": tranType,
    });

    printRecieptP300(tranType == requestQr ? textButtonQrUpi : textButtonCard);
    if (context.mounted) {
      showSuccessfulPaymentDialog(
          context, await dbs.getCartTotal(), true, false);
    }
  } on PlatformException catch (e) {
    Map<String, dynamic> responseMap = jsonDecode(e.message.toString());
    if (context.mounted) {
      showSuccessFailDialog(context, invalidAnimationPath,
          '${responseMap["STATUS_CODE"]}-${responseMap["STATUS_MSG"]}');
    }
  }
}

String calculate(amount) {
  Parser p = Parser();
  Expression exp = p.parse(amount);
  ContextModel cm = ContextModel();
  return '${exp.evaluate(EvaluationType.REAL, cm)}';
}

printRecieptP300(method) async {
  final prefs = await SharedPreferences.getInstance();
  var channel = MethodChannel("printMethod");
  final dbs = DatabaseService.instance;
  Printhelper printHelper = Printhelper();
  var amount = '';
  String productString = '';

  List<CartItem> data = await getCartProducts();

  for (CartItem product in data) {
    amount += '+${product.price}*${product.countNumber}';
    productString += '${product.productName}.';
    productString += '${product.countNumber}.';
    productString += '${inrFormat.format(double.parse(product.price))}"';
  }

  amount = calculate(amount);

  var invProdCounter = prefs.getInt(invProdCounterKey) ?? 1;

  bool status;
  status = prefs.getBool(printLogoSwitchKeyName) ?? false;
  channel.invokeListMethod("printProductReceipt", {
    "shopName": prefs.getString(businessNameKey) ?? '',
    "address": prefs.getString(addressKey) ?? '',
    "shopMobile": prefs.getString(businessMobileKey) ?? '',
    "shopEmail": prefs.getString(businessEmailKey) ?? '',
    "amount": inrFormat.format(double.parse(amount)),
    "gstNumber": prefs.getString(gstNumberKey) ?? '',
    "isPrintGST": prefs.getBool(printGstSwitchKeyName) ?? '',
    "image": status ? prefs.getString(imageKey) ?? '' : '',
    "items": productString,
    "count": "Pro/${invProdCounter++}",
    "method": method
  });

  prefs.setInt(invProdCounterKey, invProdCounter++);

  saveTransactionSqlite(
      method, await dbs.getCartTotal(), printHelper.sourceProduct, true);
  // showSuccessfulPaymentDialog(context, await dbs.getCartTotal(), true, false);
}

Future<String> getDeviceModelN() async {
  DeviceInfoPlugin deviceInfo = DeviceInfoPlugin();

  if (Platform.isAndroid) {
    AndroidDeviceInfo androidInfo = await deviceInfo.androidInfo;
    print(androidInfo.serialNumber);
    return androidInfo.model;
  } else if (Platform.isIOS) {
    IosDeviceInfo iosInfo = await deviceInfo.iosInfo;
    return iosInfo.utsname.machine;
  } else {
    return unknownDevice;
  }
}

String? validateEmail(String? value) {
  if (value == null || value.isEmpty) {
    return textPleaseEnterYourEmail;
  }

  final RegExp emailRegExp = RegExp(
    r"^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$",
  );

  if (!emailRegExp.hasMatch(value)) {
    return textPleaseEnterValidEmailAddress;
  }
  // Add more email validation logic here if needed
  return null;
}

import 'dart:convert';
import 'dart:io';

import 'package:cash_register/Widgets/all_dialog.dart';
import 'package:cash_register/Widgets/qr_code_widget.dart';
import 'package:cash_register/common_utils/assets_path.dart';
import 'package:cash_register/common_utils/strings.dart';
import 'package:cash_register/db/sqfLite_db_service.dart';
import 'package:cash_register/helper/service/transaction_sync_service.dart';
import 'package:cash_register/helper/stream_helper.dart';
import 'package:cash_register/model/cart_item.dart';
import 'package:cash_register/model/environment.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:math_expressions/math_expressions.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

double getadaptiveTextSize(BuildContext context, dynamic value) {
  return (value / 710) * MediaQuery.of(context).size.height;
}

final inrFormat = NumberFormat.currency(
  locale: 'hi_IN',
  name: 'INR',
  symbol: '₹',
  decimalDigits: 2,
);

String convertIntoBase64(File file) {
  List<int> imageBytes = file.readAsBytesSync();
  String base64File = base64Encode(imageBytes);
  return base64File;
}

Future<String> loadImage() async {
  final prefs = await SharedPreferences.getInstance();
  return prefs.getString("image") ?? "";
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
              title: const Text('Photo Library'),
              onTap: () {
                getImage(ImageSource.gallery, context);
                Navigator.of(context).pop();
              },
            ),
            ListTile(
              leading: const Icon(Icons.photo_camera),
              title: const Text('Camera'),
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
          .showSnackBar(const SnackBar(content: Text('Nothing is selected')));
    }
  }
}

storeImage(File file) async {
  final prefs = await SharedPreferences.getInstance();
  prefs.setString("image", convertIntoBase64(file));
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

void deleteAllProducts(BuildContext context) {
  final dbs = DatabaseService.instance;
  // StreamHelper.cartFinalAmounSink.add(await dbs.getCartTotal());
  dbs.emptyCart().then((_) async {
    StreamHelper.cartCountSink.add(await dbs.getCartCount());

    if (context.mounted) {
      Navigator.maybePop(context);
    }
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
    print("working on syncronization");
    TransactionSyncService syncService =
        TransactionSyncService(DatabaseService.instance, databaseHelper: dbs);
    print("network is available");
    await syncService.syncTransactions();
    final prefs = await SharedPreferences.getInstance();
    prefs.setBool("isSynced", true);
  } else {
    print("network error in syncronization");
  }
}

Future<bool> onWillPopDialouge() async {
  return false;
}

bool showQrCodeDialog(BuildContext context, String total, String method,
    String tranSource, bool isDeviceConnected, String evalString) {
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

  int userId = prefs.getInt("userId")!;

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
    // ignore: use_build_context_synchronously
    showLoader(context);

    final response = await http.post(
      Uri.parse('${Environment.baseUrl}/transaction'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
        'userId': '${prefs.getInt('userId')}'
      },
      body: jsonEncode(<String, dynamic>{
        'method': method,
        'time': time,
        'date': date,
        'amount': amount,
        'userId': '${prefs.getInt('userId')}',
        "dateTime": dateTime,
        'tranSource': tranSource,
        'user': {
          'userId': '${prefs.getInt('userId')}',
        }
      }),
    );

    Navigator.pop(context);
    if (response.statusCode == 200) {
      // successful(method);
    } else {
      showSuccessFailDialog(
          // ignore: use_build_context_synchronously
          context,
          warningAnimationPath,
          response.body.toString());
      sleep(Duration(seconds: 1));
    }
  } on SocketException catch (e) {
    // Handle network errors
    // ignore: use_build_context_synchronously
    Navigator.pop(context);
    // ignore: use_build_context_synchronously
    showSuccessFailDialog(context, warningAnimationPath, networkErrorMessage);
  } catch (e) {
    // ignore: use_build_context_synchronously
    Navigator.pop(context);

    // ignore: use_build_context_synchronously
    showSuccessFailDialog(
        context, warningAnimationPath, serverNotRespondingMessage);
  }
}

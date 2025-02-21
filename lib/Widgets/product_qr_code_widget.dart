import 'package:cash_register/Widgets/all_dialog.dart';
import 'package:cash_register/common_utils/common_functions.dart';
import 'package:cash_register/db/sqfLite_db_service.dart';
import 'package:cash_register/helper/printe_helper.dart';
import 'package:cash_register/model/cart_item.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_timer_countdown/flutter_timer_countdown.dart';
import 'package:lottie/lottie.dart';
import 'package:math_expressions/math_expressions.dart';
import 'package:qr_bar_code/code/src/code_generate.dart';
import 'package:qr_bar_code/code/src/code_type.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ProductQrCodeWidget extends StatefulWidget {
  final String amount;
  final String method;
  final String tranSource;
  final bool isDeviceConnected;

  const ProductQrCodeWidget({
    super.key,
    required this.amount,
    required this.method,
    required this.tranSource,
    required this.isDeviceConnected,
  });

  @override
  State<ProductQrCodeWidget> createState() => _ProductQrCodeWidgetState();
}

class _ProductQrCodeWidgetState extends State<ProductQrCodeWidget> {
  String businessName = '';
  String upiID = '';

  final dbs = DatabaseService.instance;
  Printhelper printHelper = Printhelper();
  @override
  void initState() {
    loadData();
    super.initState();
  }

  void loadData() async {
    final prefs = await SharedPreferences.getInstance();
    businessName = prefs.getString("businessName") ?? "";
    upiID = prefs.getString("upiID") ?? "";
    setState(() {});
  }

  Future<bool> _onWillPopDialouge() async {
    return false;
  }

  void pay() async {
    saveTransactionSqlite(widget.method, widget.amount, widget.tranSource,
        widget.isDeviceConnected);

    if (await getDeviceModel() == "P3000") {
      printRecieptP300("QR/UPI");
    } else {
      printHelper.printProductReciept("QR/UPI", printHelper.sourceProduct);
    }

    showSuccessfulPaymentDialog(context, widget.amount, true, true);
  }

  var channel = MethodChannel("printMethod");

  Parser p = Parser();

  String calculate(amount) {
    Expression exp = p.parse(amount);
    ContextModel cm = ContextModel();
    return '${exp.evaluate(EvaluationType.REAL, cm)}';
  }

  printRecieptP300(method) async {
    final prefs = await SharedPreferences.getInstance();
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

    var invProdCounter = prefs.getInt("invProdCounter") ?? 1;

    bool status;
    status = prefs.getBool('isLogoPrint') ?? false;
    channel.invokeListMethod("printProductReceipt", {
      "shopName": prefs.getString("businessName") ?? '',
      "address": prefs.getString("address") ?? '',
      "shopMobile": prefs.getString('businessMobile') ?? '',
      "shopEmail": prefs.getString('businessEmail') ?? '',
      "amount": '${inrFormat.format(double.parse(amount))}',
      "gstNumber": prefs.getString('gstNumber') ?? '',
      "isPrintGST": prefs.getBool('isPrintGST') ?? '',
      "image": status ? prefs.getString('image') ?? '' : '',
      "items": productString,
      "count": "Pro/${invProdCounter++}",
      "method": method
    });

    prefs.setInt("invProdCounter", invProdCounter++);

    // saveTransactionSqlite(
    //     "CASH", await dbs.getCartTotal(), printHelper.sourceProduct, true);
    // showSuccessfulPaymentDialog(context, await dbs.getCartTotal(), true, false);
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    double width = size.width;
    double height = size.height;
    return Container(
      padding: EdgeInsets.only(bottom: 0),
      height: height * 0.79,
      width: width,
      // color: Colors.amber,
      child: Column(
        children: [
          Center(
            child: Column(
              children: [
                // UPIPaymentQRCode(
                //   upiDetails: upiDetails,
                //   size: 200,
                // ),
                Text(
                  "Complete Your Payment",
                  style: TextStyle(
                      color: Colors.black,
                      fontSize: getAdaptiveTextSize(context, 13)),
                ),
                Container(
                  padding: EdgeInsets.only(
                      top: height * 0.005, bottom: height * 0.005),
                  child: Text(
                    inrFormat.format(double.parse(widget.amount)),
                    style: TextStyle(
                        color: Colors.green,
                        fontWeight: FontWeight.w900,
                        fontSize: getAdaptiveTextSize(context, 30)),
                  ),
                ),
                Container(
                  padding: EdgeInsets.only(
                      top: height * 0.005, bottom: height * 0.005),
                  child: Text(
                    businessName,
                    style: TextStyle(
                        color: Colors.black,
                        fontWeight: FontWeight.w600,
                        fontSize: getAdaptiveTextSize(context, 20)),
                  ),
                ),
                Container(
                  padding: EdgeInsets.only(bottom: height * 0.005),
                  child: Text(
                    'Scan and pay using UPI app',
                    style: TextStyle(
                        color: Colors.black,
                        fontSize: getAdaptiveTextSize(context, 15)),
                  ),
                ),
                Code(
                  height: height * 0.25,
                  data:
                      "upi://pay?pa=$upiID&pn=$businessName&mc=0000&tn=Bill%20Payment&am=${double.parse(widget.amount)}&cu=INR",
                  // "upi://pay?pa=9561051485@axl&pn=Mahendra%20Telure&mc=0000&mode=02&purpose=00&am=10",
                  codeType: CodeType.qrCode(),
                ),
                Container(
                  padding: EdgeInsets.only(
                      top: height * 0.005, bottom: height * 0.005),
                  child: Text(
                    'UPI ID: $upiID',
                    style: TextStyle(
                        color: Colors.black,
                        fontSize: getAdaptiveTextSize(context, 15)),
                  ),
                ),
                Center(
                  child: Container(
                      padding: EdgeInsets.all(height * 0.005),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Image.asset(
                            "assets/images/bhim_tra.png",
                            height: height * 0.02,
                          ),
                          Image.asset(
                            "assets/images/upi_tra.png",
                            height: height * 0.02,
                          ),
                        ],
                      )),
                ),
                Center(
                  child: TimerCountdown(
                    format:
                        // CountDownTimerFormat.secondsOnly,
                        CountDownTimerFormat.minutesSeconds,
                    endTime: DateTime.now().add(
                      Duration(minutes: 0, seconds: 30, microseconds: 20),
                    ),
                    timeTextStyle: TextStyle(
                        fontWeight: FontWeight.w800,
                        fontSize: getAdaptiveTextSize(context, 20)),
                    onEnd: () {
                      // print("Timer finished");
                      showDialog<void>(
                        context: context,
                        barrierDismissible: false,
                        builder: (context) => WillPopScope(
                          onWillPop: _onWillPopDialouge,
                          child: AlertDialog(
                            // title: const Text('Timer Finished'),
                            content: SizedBox(
                              height: height * 0.28,
                              width: width * 0.98,
                              child: Column(
                                children: [
                                  Lottie.asset('assets/animations/warning.json',
                                      height:
                                          MediaQuery.of(context).size.height *
                                              0.17,
                                      repeat: true,
                                      animate: true),
                                  Text(
                                    "Transaction Timeout!",
                                    style: TextStyle(
                                        color: Colors.red,
                                        fontSize:
                                            getAdaptiveTextSize(context, 15)),
                                  ),
                                  Container(
                                    padding:
                                        EdgeInsets.only(top: height * 0.020),
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        SizedBox(
                                          height: height * 0.050,
                                          child: ElevatedButton(
                                              style: ElevatedButton.styleFrom(
                                                backgroundColor:
                                                    Colors.blue, // background
                                                foregroundColor:
                                                    Colors.black, // foreground
                                                padding: EdgeInsets.all(8),
                                                shape: RoundedRectangleBorder(
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                          6), // <-- Radius
                                                ),
                                              ),
                                              onPressed: () {
                                                pay();
                                              },
                                              child: Text(
                                                "Print Receipt",
                                                style: TextStyle(
                                                    color: Colors.white,
                                                    fontSize:
                                                        getAdaptiveTextSize(
                                                            context, 14)),
                                              )),
                                        ),
                                        SizedBox(
                                          height: height * 0.050,
                                          child: OutlinedButton(
                                              style: OutlinedButton.styleFrom(
                                                // background
                                                foregroundColor:
                                                    Colors.black, // foreground
                                                padding: EdgeInsets.all(8),
                                                shape: RoundedRectangleBorder(
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                          6), // <-- Radius
                                                ),
                                              ),
                                              onPressed: () {
                                                Navigator.pop(context);
                                                Navigator.pop(context);
                                              },
                                              child: Text(
                                                "Back To Home",
                                                style: TextStyle(
                                                    color: Colors.black,
                                                    fontSize:
                                                        getAdaptiveTextSize(
                                                            context, 14)),
                                              )),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            actions: [],
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
          Center(
            child: Padding(
              padding: EdgeInsets.only(bottom: height * 0.01),
              child: Text(
                "Check Payment Application: If a payment notification is received, print a receipt.",
                style: TextStyle(
                  color: Colors.red,
                  fontSize: getAdaptiveTextSize(context, 12),
                ),
              ),
            ),
          ),
          Container(
            padding: EdgeInsets.only(bottom: 0),
            width: width * 0.50,
            height: height * 0.05,
            child: OutlinedButton(
              style: OutlinedButton.styleFrom(
                backgroundColor: Colors.blue, // background
                foregroundColor: Colors.black, // foreground
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(6), // <-- Radius
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.print_outlined,
                    size: getAdaptiveTextSize(context, 19),
                    color: const Color.fromARGB(255, 58, 104, 125),
                  ),
                  Text(
                    'Print Receipt',
                    style: TextStyle(
                        color: Colors.black,
                        fontSize: getAdaptiveTextSize(context, 15)),
                  ),
                ],
              ),
              onPressed: () {
                Navigator.pop(context);
                pay();

                // saveTransactionSqlite(widget.method, widget.amount,
                //     widget.tranSource, widget.isDeviceConnected);
                // printhelper.printProductReciept(
                //     "QR/UPI", printhelper.sourceProduct);
                // showSuccessfulPaymentDialog(
                //     context, widget.amount, false, false);
              },
            ),
          ),
          Container(
            padding: EdgeInsets.all(height * 0.005),
          ),
          Container(
            padding: EdgeInsets.only(bottom: 0),
            width: width * 0.50,
            height: height * 0.05,
            child: OutlinedButton(
              style: OutlinedButton.styleFrom(
                foregroundColor: Colors.black, // foreground
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(6), // <-- Radius
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.home_outlined,
                    size: getAdaptiveTextSize(context, 19),
                    color: const Color.fromARGB(255, 58, 104, 125),
                  ),
                  Text(
                    'Back To Home',
                    style: TextStyle(
                        color: Colors.black,
                        fontSize: getAdaptiveTextSize(context, 15)),
                  ),
                ],
              ),
              onPressed: () {
                Navigator.pop(context);
              },
            ),
          ),
        ],
      ),
    );
  }
}

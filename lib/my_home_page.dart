import 'dart:convert';
import 'dart:io';

import 'package:cash_register/addBusinessDetails.dart';
import 'package:cash_register/api.dart';
import 'package:cash_register/db/sqfLiteDBService.dart';
import 'package:cash_register/editBusinessDetails.dart';
import 'package:cash_register/helper/helper.dart';
import 'package:cash_register/menu.dart';
import 'package:cash_register/success.dart';
import 'package:cash_register/transactions_history.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_timer_countdown/flutter_timer_countdown.dart';
import 'package:lottie/lottie.dart';
import 'package:math_expressions/math_expressions.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:qr_bar_code/code/src/code_generate.dart';
import 'package:qr_bar_code/code/src/code_type.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:flutter_styled_toast/flutter_styled_toast.dart';
import 'package:http/http.dart' as http;
// import 'package:upi_payment_qrcode_generator/upi_payment_qrcode_generator.dart';
// import 'package:fluttertoast/fluttertoast.dart';
import 'package:qr_bar_code/qr_bar_code.dart';
import 'login.dart';

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  // late final AnimationController _controller;

  final dbs = DatabaseService.instance;

  String total = '0.0';
  int tempNum = 0;
  String evalString = "0";
  late bool isLoggedIn = false;
  late bool isBusinessDetailsFound = false;

  var upiID = '';

  List<Map<String, Object?>>? _billData;

  Future<void> _fetchData() async {
    List<Map<String, Object?>>? data = await dbs.getDBdata();
    setState(() {
      _billData = data;
    });
  }

  // final upiDetails = UPIDetails(
  //     upiID: "95610051485@ybl", payeeName: "MahendraTelure", amount: 10);

  var channel = MethodChannel("printMethod");
  ScrollController _controller = new ScrollController();

  FocusNode _focusNode = FocusNode();

  void scroll(double position) {
    _controller.jumpTo(position);
  }

  printReciept() async {
    final prefs = await SharedPreferences.getInstance();
    bool status;
    status = prefs.getBool('isLogoPrint') ?? false;
    channel.invokeListMethod("printCartReceipt", {
      "shopName": prefs.getString("businessName") ?? '',
      "address": prefs.getString("address") ?? '',
      "shopMobile": prefs.getString('businessMobile') ?? '',
      "shopEmail": prefs.getString('businessEmail') ?? '',
      "amount": '${inrFormat.format(double.parse(total))}',
      "gstNumber": prefs.getString('gstNumber') ?? '',
      "isPrintGST": prefs.getBool('isPrintGST') ?? '',
      "image": status ? prefs.getString('image') ?? '' : ''
    });
  }

  final inrFormat = NumberFormat.currency(
    locale: 'hi_IN',
    name: 'INR',
    symbol: '₹',
    decimalDigits: 2,
  );

  Future<void> checkLoggedIn() async {
    final prefs = await SharedPreferences.getInstance();
    // ignore: unused_local_variable
    isLoggedIn = prefs.getBool('isLoggedIn') ?? false;
    // setState(() {});

    if (!isLoggedIn) {
      Navigator.pushReplacement(context,
          MaterialPageRoute(builder: (context) => const LoginScreen()));
    }
  }

  Future<void> checkBusinessDetailsFound() async {
    final prefs = await SharedPreferences.getInstance();

    isBusinessDetailsFound = prefs.getBool('isBusinessDetailsFound') ?? false;

    if (isBusinessDetailsFound == false) {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) {
          return const Center(child: CircularProgressIndicator());
        },
      );
      final response = await http.get(
        Uri.parse('$BASE_URL/business'),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
          'userId': '${prefs.getInt('userId')}',
        },
      );

      if (response.statusCode == 200) {
        String responseString = utf8.decode(response.bodyBytes);
        Map<String, dynamic> jsonData = jsonDecode(responseString);

        prefs.setBool("isBusinessDetailsFound", true);
        prefs.setString('businessName', jsonData['businessName'] ?? '');
        prefs.setString('address', jsonData['address'] ?? '');
        prefs.setString('businessEmail', jsonData['email'] ?? '');
        prefs.setString('businessMobile', jsonData['mobile'] ?? '');
        prefs.setString('gstNumber', jsonData['gstNumber'] ?? '');
        prefs.setString('upiID', jsonData['upiID'] ?? '');
        prefs.setBool("recieptSwitch", true);
        isBusinessDetailsFound = true;
        Navigator.pop(context);
      } else {
        //  return const Text('No transaction data');

        Navigator.pop(context);
        showDialog<void>(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Error'),
            content: Text('${response.body.toString()}'),
            actions: [
              TextButton(
                child: Text(
                  'Ok',
                  style: TextStyle(fontSize: getadaptiveTextSize(context, 15)),
                ),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
            ],
          ),
        );
        // throw Exception('Request Failed.');
      }
    }
    setState(() {});
    if (isBusinessDetailsFound == false) {
      Navigator.pop(context);
      Navigator.pushReplacement(context,
          MaterialPageRoute(builder: (context) => const AddBusinessDetails()));
    }
  }

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      _focusNode.requestFocus();
    });
    dbs.getDBdata();
    // checkLoggedIn();
    checkBusinessDetailsFound();
    _fetchData();
    setState(() {});
  }

  @override
  void dispose() {
    // _controller.dispose();
    super.dispose();
  }

  getadaptiveTextSize(BuildContext context, dynamic value) {
    return (value / 710) * MediaQuery.of(context).size.height;
  }

  Future<void> payBill(String method) async {
    final prefs = await SharedPreferences.getInstance();
    upiID = prefs.getString("upiID") ?? '';
    setState(() {
      // var myInt = int.parse(total);
      // assert(myInt is int);
      // print("int is ${myInt}");

      if ((total == '0') ||
          (total == 0) ||
          total == '0.00' ||
          (total == 0.00) ||
          total == '0.0' ||
          (total == 0.0) ||
          total == '00' ||
          (total == 00)) {
        //

        showDialog<void>(
          context: context,
          builder: (context) => AlertDialog(
            content: Container(
              height: 220,
              padding: EdgeInsets.all(2),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Lottie.asset('assets/animations/warning.json',
                      height: MediaQuery.of(context).size.height * 0.17,
                      // controller: _controller,
                      repeat: true,
                      animate: true),
                  Text(
                    'Please Enter an Amount',
                    style:
                        TextStyle(fontSize: getadaptiveTextSize(context, 15)),
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(
                child: Text(
                  'Ok',
                  style: TextStyle(fontSize: getadaptiveTextSize(context, 15)),
                ),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
            ],
          ),
        );
      } else {
        // saveTransaction(method);
        // sqDemo();
        if (method == 'CASH') {
          // _fetchData();
          // print("Home page ${_billData?[0]}");
          // saveTransactionSqlite("");
          saveTransactionToServer(method);
        } else {
          upiID = prefs.getString("upiID") ?? '';
          if (upiID.toString().isNotEmpty ||
              upiID.trim().isNotEmpty ||
              upiID.toString() != '') {
            showDialog<void>(
              context: context,
              barrierDismissible: false,
              builder: (context) => WillPopScope(
                onWillPop: _onWillPopDialouge,
                child: AlertDialog(
                  // insetPadding: EdgeInsets.only(bottom: 20),
                  content: Container(
                      padding: EdgeInsets.only(bottom: 0),
                      height: height * 0.79,
                      width: width,
                      // color: Colors.amber,
                      child: Column(
                        children: [
                          Container(
                              padding: EdgeInsets.only(
                                  bottom: height * 0.020, top: 0),
                              // color: Colors.blue,
                              child: Center(
                                child: Column(
                                  children: [
                                    // UPIPaymentQRCode(
                                    //   upiDetails: upiDetails,
                                    //   size: 200,
                                    // ),
                                    Container(
                                      padding: EdgeInsets.only(
                                          top: height * 0.005,
                                          bottom: height * 0.005),
                                      child: Text(
                                        "Complete Your Payment",
                                        style: TextStyle(
                                            color: Colors.black,
                                            fontSize: getadaptiveTextSize(
                                                context, 13)),
                                      ),
                                    ),
                                    Container(
                                      padding: EdgeInsets.only(
                                          top: height * 0.005,
                                          bottom: height * 0.005),
                                      child: Text(
                                        '${inrFormat.format(double.parse(total))}',
                                        style: TextStyle(
                                            color: Colors.green,
                                            fontWeight: FontWeight.w900,
                                            fontSize: getadaptiveTextSize(
                                                context, 30)),
                                      ),
                                    ),
                                    Container(
                                      padding:
                                          EdgeInsets.only(top: 5, bottom: 5),
                                      child: Text(
                                        '${prefs.getString("businessName")}',
                                        style: TextStyle(
                                            color: Colors.black,
                                            fontWeight: FontWeight.w600,
                                            fontSize: getadaptiveTextSize(
                                                context, 18)),
                                      ),
                                    ),
                                    Container(
                                      padding: EdgeInsets.only(bottom: 20),
                                      child: Text(
                                        'Scan and pay using UPI app',
                                        style: TextStyle(
                                            color: Colors.black,
                                            fontSize: getadaptiveTextSize(
                                                context, 15)),
                                      ),
                                    ),
                                    Code(
                                      height: height * 0.25,
                                      data:
                                          "upi://pay?pa=${prefs.getString("upiID")}&pn=${prefs.getString("businessName")}&mc=0000&tn=Bill%20Payment&am=${double.parse(total)}&cu=INR",
                                      // "upi://pay?pa=9561051485@axl&pn=Mahendra%20Telure&mc=0000&mode=02&purpose=00&am=10",
                                      codeType: CodeType.qrCode(),
                                    ),
                                    Container(
                                      padding:
                                          EdgeInsets.only(top: 5, bottom: 10),
                                      child: Text(
                                        'UPI ID: ${prefs.getString("upiID")}',
                                        style: TextStyle(
                                            color: Colors.black,
                                            fontSize: getadaptiveTextSize(
                                                context, 15)),
                                      ),
                                    ),
                                    Center(
                                      child: Container(
                                          padding:
                                              EdgeInsets.all(height * 0.005),
                                          child: Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.center,
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
                                      child: Container(
                                        child: TimerCountdown(
                                          format:
                                              // CountDownTimerFormat.secondsOnly,
                                              CountDownTimerFormat
                                                  .minutesSeconds,
                                          endTime: DateTime.now().add(
                                            Duration(
                                                minutes: 1,
                                                seconds: 59,
                                                microseconds: 20),
                                          ),
                                          timeTextStyle: TextStyle(
                                              fontWeight: FontWeight.w800,
                                              fontSize: getadaptiveTextSize(
                                                  context, 20)),
                                          onEnd: () {
                                            // print("Timer finished");
                                            showDialog<void>(
                                              context: context,
                                              barrierDismissible: false,
                                              builder: (context) =>
                                                  WillPopScope(
                                                onWillPop: _onWillPopDialouge,
                                                child: AlertDialog(
                                                  // title: const Text('Timer Finished'),
                                                  content: Container(
                                                    height: height * 0.28,
                                                    width: width * 0.98,
                                                    child: Column(
                                                      children: [
                                                        Lottie.asset(
                                                            'assets/animations/warning.json',
                                                            height: MediaQuery.of(
                                                                        context)
                                                                    .size
                                                                    .height *
                                                                0.17,
                                                            repeat: true,
                                                            animate: true),
                                                        Container(
                                                          child: Text(
                                                            "Transaction Timeout!",
                                                            style: TextStyle(
                                                                color:
                                                                    Colors.red,
                                                                fontSize:
                                                                    getadaptiveTextSize(
                                                                        context,
                                                                        15)),
                                                          ),
                                                        ),
                                                        Container(
                                                          padding:
                                                              EdgeInsets.only(
                                                                  top: height *
                                                                      0.020),
                                                          child: Row(
                                                            mainAxisAlignment:
                                                                MainAxisAlignment
                                                                    .spaceBetween,
                                                            children: [
                                                              Container(
                                                                height: height *
                                                                    0.050,
                                                                child:
                                                                    ElevatedButton(
                                                                        style: ElevatedButton
                                                                            .styleFrom(
                                                                          backgroundColor:
                                                                              Colors.blue, // background
                                                                          foregroundColor:
                                                                              Colors.black, // foreground
                                                                          shape:
                                                                              RoundedRectangleBorder(
                                                                            borderRadius:
                                                                                BorderRadius.circular(6), // <-- Radius
                                                                          ),
                                                                        ),
                                                                        onPressed:
                                                                            () {
                                                                          Navigator.of(context)
                                                                              .pop();
                                                                          Navigator.of(context)
                                                                              .pop();
                                                                          saveTransactionToServer(
                                                                              method);
                                                                        },
                                                                        child:
                                                                            Text(
                                                                          "Print Receipt",
                                                                          style: TextStyle(
                                                                              color: Colors.white,
                                                                              fontSize: getadaptiveTextSize(context, 14)),
                                                                        )),
                                                              ),
                                                              Container(
                                                                height: height *
                                                                    0.050,
                                                                child:
                                                                    OutlinedButton(
                                                                        style: ElevatedButton
                                                                            .styleFrom(
                                                                          // background
                                                                          foregroundColor:
                                                                              Colors.black, // foreground
                                                                          shape:
                                                                              RoundedRectangleBorder(
                                                                            borderRadius:
                                                                                BorderRadius.circular(6), // <-- Radius
                                                                          ),
                                                                        ),
                                                                        onPressed:
                                                                            () {
                                                                          Navigator.of(context)
                                                                              .pop();
                                                                          Navigator.pop(
                                                                              context);
                                                                        },
                                                                        child:
                                                                            Text(
                                                                          "Back To Home",
                                                                          style: TextStyle(
                                                                              color: Colors.black,
                                                                              fontSize: getadaptiveTextSize(context, 14)),
                                                                        )),
                                                              ),
                                                            ],
                                                          ),
                                                        )
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
                                    )
                                  ],
                                ),
                              )),
                          Center(
                            child: Padding(
                              padding: EdgeInsets.only(bottom: height * 0.01),
                              child: Text(
                                "Check Payment Application: If a payment notification is received, print a receipt.",
                                style: TextStyle(
                                  color: Colors.red,
                                  fontSize: getadaptiveTextSize(context, 12),
                                ),
                              ),
                            ),
                          ),
                          Container(
                            padding: EdgeInsets.only(bottom: 0),
                            width: width * 0.48,
                            height: height * 0.05,
                            child: OutlinedButton(
                              style: OutlinedButton.styleFrom(
                                backgroundColor: Colors.blue, // background
                                foregroundColor: Colors.black, // foreground
                                shape: RoundedRectangleBorder(
                                  borderRadius:
                                      BorderRadius.circular(6), // <-- Radius
                                ),
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.print_outlined,
                                    size: getadaptiveTextSize(context, 19),
                                    color:
                                        const Color.fromARGB(255, 58, 104, 125),
                                  ),
                                  Text(
                                    'Print Receipt',
                                    style: TextStyle(
                                        color: Colors.black,
                                        fontSize:
                                            getadaptiveTextSize(context, 15)),
                                  ),
                                ],
                              ),
                              onPressed: () {
                                Navigator.pop(context);

                                saveTransactionToServer(method);
                              },
                            ),
                          ),
                          Container(
                            padding: EdgeInsets.all(height * 0.005),
                          ),
                          Container(
                            padding: EdgeInsets.only(bottom: 0),
                            width: width * 0.48,
                            height: height * 0.05,
                            child: OutlinedButton(
                              style: OutlinedButton.styleFrom(
                                foregroundColor: Colors.black, // foreground
                                shape: RoundedRectangleBorder(
                                  borderRadius:
                                      BorderRadius.circular(6), // <-- Radius
                                ),
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.home_outlined,
                                    size: getadaptiveTextSize(context, 19),
                                    color:
                                        const Color.fromARGB(255, 58, 104, 125),
                                  ),
                                  Text(
                                    'Back To Home',
                                    style: TextStyle(
                                        color: Colors.black,
                                        fontSize:
                                            getadaptiveTextSize(context, 15)),
                                  ),
                                ],
                              ),
                              onPressed: () {
                                Navigator.pop(context);
                                setState(() {});
                              },
                            ),
                          ),
                        ],
                      )),
                  actions: [],
                ),
              ),
            );
          } else {
            showDialog<void>(
              context: context,
              barrierDismissible: false,
              builder: (context) => WillPopScope(
                onWillPop: _onWillPopDialouge,
                child: AlertDialog(
                  // title: const Text('Timer Finished'),
                  content: Container(
                    height: height * 0.28,
                    width: width * 0.98,
                    child: Column(
                      children: [
                        Lottie.asset('assets/animations/warning.json',
                            height: MediaQuery.of(context).size.height * 0.17,
                            repeat: true,
                            animate: true),
                        Container(
                          child: Text(
                            "UPI ID Not Found!",
                            style: TextStyle(
                                color: Colors.red,
                                fontSize: getadaptiveTextSize(context, 15)),
                          ),
                        ),
                        Container(
                          padding: EdgeInsets.only(top: height * 0.020),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Container(
                                height: height * 0.050,
                                child: ElevatedButton(
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor:
                                          Colors.blue, // background
                                      foregroundColor:
                                          Colors.black, // foreground
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(
                                            6), // <-- Radius
                                      ),
                                    ),
                                    onPressed: () {
                                      Navigator.of(context).pop();
                                      // saveTransactionToServer(method);
                                      Navigator.push(context, MaterialPageRoute(
                                        builder: (context) {
                                          return const EditBusinessDetails();
                                        },
                                      ));
                                    },
                                    child: Text(
                                      "Add UPI ID",
                                      style: TextStyle(
                                          color: Colors.white,
                                          fontSize:
                                              getadaptiveTextSize(context, 14)),
                                    )),
                              ),
                              Container(
                                height: height * 0.050,
                                child: OutlinedButton(
                                    style: ElevatedButton.styleFrom(
                                      // background
                                      foregroundColor:
                                          Colors.black, // foreground
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(
                                            6), // <-- Radius
                                      ),
                                    ),
                                    onPressed: () {
                                      Navigator.pop(context);
                                    },
                                    child: Text(
                                      "Back To Home",
                                      style: TextStyle(
                                          color: Colors.black,
                                          fontSize:
                                              getadaptiveTextSize(context, 14)),
                                    )),
                              ),
                            ],
                          ),
                        )
                      ],
                    ),
                  ),
                  actions: [],
                ),
              ),
            );
          }
        }
      }
    });
  }

  // sqDemo() {
  // print(dbs.getDBdata());
  // }

  saveTransactionSqlite(String method) async {
    String time = DateFormat('jms').format(DateTime.now()).toString();
    String date = DateFormat('yMMMd').format(DateTime.now()).toString();
    String amount = inrFormat.format(double.parse(total)).toString();
    String dateTime =
        DateFormat('yyyy-MM-dd HH:mm:ss').format(DateTime.now()).toString();
    final prefs = await SharedPreferences.getInstance();

    String userId = prefs.getString("userId") ?? '';

    dbs.saveTransaction(amount, method, time, date, userId, dateTime);

    // try {
    //   showDialog(
    //     context: context,
    //     barrierDismissible: false,
    //     builder: (BuildContext context) {
    //       return Center(
    //         child: Lottie.asset('assets/animations/loader.json',
    //             height: MediaQuery.of(context).size.height * 0.17,
    //             // controller: _controller,
    //             repeat: true,
    //             animate: true),
    //       );
    //     },
    //   );
    // } catch (e) {}
  }

// Future<http.Response>
  void saveTransactionToServer(String method) async {
    String time = DateFormat('jms').format(DateTime.now()).toString();
    String date = DateFormat('yMMMd').format(DateTime.now()).toString();
    String amount = inrFormat.format(double.parse(total)).toString();
    String dateTime =
        DateFormat('yyyy-MM-dd HH:mm:ss').format(DateTime.now()).toString();
    final prefs = await SharedPreferences.getInstance();

    // 'method': method,
    // 'time': time,
    // 'date': date,
    // 'amount': amount,
    // 'user': {
    // 'userId': '${prefs.getInt('userId')}',

    try {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) {
          return Center(
            child: Lottie.asset('assets/animations/loader.json',
                height: MediaQuery.of(context).size.height * 0.17,
                // controller: _controller,
                repeat: true,
                animate: true),
          );
        },
      );

      final response = await http.post(
        Uri.parse(BASE_URL + '/transaction'),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: jsonEncode(<String, dynamic>{
          'method': method,
          'time': time,
          'date': date,
          'amount': amount,
          'user': {
            'userId': '${prefs.getInt('userId')}',
          },
          "dateTime": dateTime
        }),
      );

      Navigator.pop(context);
      if (response.statusCode == 200) {
        // If the server did return a 201 CREATED response,
        // then parse the JSON.
        successful();
      } else {
        // If the server did not return a 201 CREATED response,
        // then throw an exception.
        showDialog<void>(
          context: context,
          barrierDismissible: false,
          builder: (context) => AlertDialog(
            // title: const Text('Error'),

            insetPadding: EdgeInsets.all(0),
            content: Container(
              height: 220,
              padding: EdgeInsets.all(2),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Lottie.asset('assets/animations/warning.json',
                      height: MediaQuery.of(context).size.height * 0.17,
                      // controller: _controller,
                      repeat: true,
                      animate: true),
                  Text(
                    '${response.body.toString()}',
                    style:
                        TextStyle(fontSize: getadaptiveTextSize(context, 15)),
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(
                style: TextButton.styleFrom(),
                child: Text(
                  'Ok',
                  style: TextStyle(fontSize: getadaptiveTextSize(context, 20)),
                ),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
            ],
          ),
        );
        sleep(Duration(seconds: 1));
      }
    } on SocketException catch (e) {
      // Handle network errors
      Navigator.pop(context);
      showDialog<void>(
        context: context,
        builder: (context) => AlertDialog(
          // title: const Text('Error'),
          content: Container(
            height: 220,
            padding: EdgeInsets.all(2),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Lottie.asset('assets/animations/warning.json',
                    height: MediaQuery.of(context).size.height * 0.17,
                    // controller: _controller,
                    repeat: true,
                    animate: true),
                Text(
                  'Network Error',
                  style: TextStyle(fontSize: getadaptiveTextSize(context, 15)),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              child: Text('Ok',
                  style: TextStyle(fontSize: getadaptiveTextSize(context, 15))),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        ),
      );
    } catch (e) {
      Navigator.pop(context);
      showDialog<void>(
        context: context,
        builder: (context) => AlertDialog(
          content: Container(
            height: 220,
            padding: EdgeInsets.all(2),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Lottie.asset('assets/animations/warning.json',
                    height: MediaQuery.of(context).size.height * 0.17,
                    // controller: _controller,
                    repeat: true,
                    animate: true),
                Text(
                  'Server not Responding',
                  style: TextStyle(fontSize: getadaptiveTextSize(context, 15)),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              child: Text(
                'Ok',
                style: TextStyle(fontSize: getadaptiveTextSize(context, 15)),
              ),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        ),
      );
    }
  }

  // save transactions SharedPreferences
  // Future<void> saveTransaction(String method) async {
  //   var prefs = await SharedPreferences.getInstance();

  //   Map<String, dynamic> singleTransaction = {
  //     "key": prefs.getKeys().length + 1,
  //     "amount": '${inrFormat.format(double.parse(total))}',
  //     "Method": method,
  //     "dateTime": DateFormat('yMMMd').format(DateTime.now()),
  //     "time": DateFormat('jms').format(DateTime.now()),
  //     "currentDay": DateFormat('d').format(DateTime.now()),
  //     "currentMonth": DateFormat('MMM').format(DateTime.now()),
  //     "currentYear": DateFormat('y').format(DateTime.now()),
  //   };

  //   prefs.setString(
  //       '${prefs.getKeys().length + 1}', jsonEncode(singleTransaction));
  //   successful();
  // }

  successful() async {
    final prefs = await SharedPreferences.getInstance();
    var recieptSwitch = prefs.getBool("recieptSwitch") ?? false;

    if (recieptSwitch) {
      printReciept();
    }

    showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        insetPadding: EdgeInsets.only(bottom: 20),

        // title: const Center(
        //   child: Text('Payment Successful'),
        // ),
        // content: Text('Faild To store'),
        content: Container(
            padding: EdgeInsets.only(bottom: 0),
            height: height * 0.262,
            width: width * 0.70,
            child: Column(
              children: [
                Lottie.asset('assets/animations/check_animation.json',
                    height: height * 0.10,
                    // controller: _controller,
                    repeat: false,
                    animate: true),
                Container(
                  padding: EdgeInsets.only(bottom: 0),
                  child: Text(
                    'Payment Successful',
                    style: TextStyle(
                      color: Colors.green,
                      fontSize: getadaptiveTextSize(context, 20),
                    ),
                  ),
                ),
                Container(
                  padding: EdgeInsets.only(bottom: 10),
                  child: Text(
                    '${inrFormat.format(double.parse(total))}',
                    style: TextStyle(
                      color: Colors.black,
                      fontSize: getadaptiveTextSize(context, 30),
                    ),
                  ),
                ),
                Container(
                  padding: EdgeInsets.only(top: 5),
                  width: width * 0.48,
                  height: height * 0.05,
                  child: OutlinedButton(
                    style: TextButton.styleFrom(),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.home_outlined,
                          size: getadaptiveTextSize(context, 19),
                          color: const Color.fromARGB(255, 58, 104, 125),
                        ),
                        Text(
                          'Back To Home',
                          style: TextStyle(
                              color: Colors.black,
                              fontSize: getadaptiveTextSize(context, 15)),
                        ),
                      ],
                    ),
                    onPressed: () {
                      evalString = '0';
                      total = '0';
                      Navigator.of(context).pop();
                      setState(() {});
                    },
                  ),
                ),
              ],
            )),

        actions: [
          // Center(
          //   child: Container(
          //     width: width * 0.51,
          //     height: height * 0.05,
          //     child: OutlinedButton(
          //       style: TextButton.styleFrom(),
          //       child: const Center(
          //           child: Row(
          //         children: [
          //           Icon(
          //             Icons.home_filled,
          //             size: 30,
          //           ),
          //           Text(
          //             'Back To Home',
          //             style: TextStyle(
          //               fontSize: 25,
          //             ),
          //           ),
          //         ],
          //       )),
          //       onPressed: () {
          //         evalString = '0';
          //         total = '0';
          //         Navigator.of(context).pop();
          //         setState(() {});
          //       },
          //     ),
          //   ),
          // ),
        ],
      ),
    );
  }

  void successfulOld() {
    printReciept();
    showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        insetPadding: EdgeInsets.only(bottom: 20),

        title: const Center(
          child: Text('Payment Successful'),
        ),
        // content: Text('Faild To store'),
        content: Container(
            padding: EdgeInsets.only(bottom: 0),
            height: height * 0.24,
            width: width * 0.70,
            child: Column(
              children: [
                Lottie.asset('assets/animations/check_animation.json',
                    height: height * 0.17,
                    // controller: _controller,
                    repeat: false,
                    animate: true),
                Container(
                  padding: EdgeInsets.only(bottom: 0),
                  child: Text(
                    '${inrFormat.format(double.parse(total))}',
                    style: TextStyle(
                      color: Colors.green,
                      fontSize: getadaptiveTextSize(context, 30),
                    ),
                  ),
                )
              ],
            )),

        actions: [
          TextButton(
            style: TextButton.styleFrom(
              padding: EdgeInsets.all(0),
            ),
            child: const Center(
              child: Text(
                'Ok',
                style: TextStyle(
                  fontSize: 25,
                ),
              ),
            ),
            onPressed: () {
              evalString = '0';
              total = '0';
              Navigator.of(context).pop();
              setState(() {});
            },
          ),
        ],
      ),
    );
  }

  Parser p = Parser();

  void calculate() {
    if (evalString[evalString.length - 1] != '+') {
      Expression exp = p.parse(evalString);
      ContextModel cm = ContextModel();
      if (exp.evaluate(EvaluationType.REAL, cm) > 100000) {
        showToast("Amount should be below ₹100,000", context: context);
      } else {
        setState(() {
          total = '${exp.evaluate(EvaluationType.REAL, cm)}';
        });
      }
    }
  }

  isValidAmount(String newEvalString) {
    if (newEvalString[newEvalString.length - 1] != '+') {
      Expression exp = p.parse(newEvalString);
      ContextModel cm = ContextModel();
      if (exp.evaluate(EvaluationType.REAL, cm) > 100000) {
        return true;
      } else {
        return false;
      }
    }
  }

  // Adding '+' operator in string
  void evaluation() {
    setState(() {
      if (evalString[evalString.length - 1] != "+") {
        evalString += "+";
      }
      calculate();
    });
  }

  void backSpace() {
    setState(() {
      // evalString.
      if (evalString != null && evalString.length > 0) {
        evalString = evalString.substring(0, evalString.length - 1);
      }
      if (evalString.isEmpty) {
        evalString = '0';
        total = '0';
      }

      calculate();
    });
  }

  amountWarning() {
    showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        // insetPadding: EdgeInsets.only(bottom: 20),
        content: Container(
            padding: EdgeInsets.only(bottom: 0),
            height: height * 0.244,
            width: width * 0.70,
            // color: Colors.amber,
            child: Column(
              children: [
                Padding(
                  padding: EdgeInsets.all(0),
                  child: Lottie.asset('assets/animations/wrong.json',
                      height: height * 0.10,
                      // controller: _controller,
                      repeat: true,
                      animate: true),
                ),
                Container(
                    padding: EdgeInsets.only(bottom: height * 0.020, top: 0),
                    // color: Colors.blue,
                    child: Center(
                      child: Column(
                        children: [
                          Text(
                            'Please enter an amount below',
                            softWrap: true,
                            style: TextStyle(
                              color: Colors.red,
                              fontWeight: FontWeight.w700,
                              fontSize: getadaptiveTextSize(context, 15),
                            ),
                          ),
                          Text(
                            '₹100,000.00',
                            softWrap: true,
                            style: TextStyle(
                              color: Colors.red,
                              fontWeight: FontWeight.w900,
                              fontSize: getadaptiveTextSize(context, 20),
                            ),
                          ),
                        ],
                      ),
                    )),
                Container(
                  padding: EdgeInsets.only(bottom: 0),
                  width: width * 0.48,
                  height: height * 0.05,
                  child: OutlinedButton(
                    style: TextButton.styleFrom(),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.home_outlined,
                          size: getadaptiveTextSize(context, 19),
                          color: const Color.fromARGB(255, 58, 104, 125),
                        ),
                        Text(
                          'Back To Home',
                          style: TextStyle(
                              color: Colors.black,
                              fontSize: getadaptiveTextSize(context, 15)),
                        ),
                      ],
                    ),
                    onPressed: () {
                      Navigator.pop(context);
                      setState(() {});
                    },
                  ),
                ),
              ],
            )),
        actions: [],
      ),
    );
  }

  // add number in evalSting
  void addition(String number) {
    setState(() {
      if (evalString == '0') {
        evalString = number;
      } else {
        if (evalString.length - evalString.lastIndexOf('+') < 6) {
          // evalString += number;

          if (isValidAmount(evalString + number)) {
            amountWarning();
            // showToast("Amount should be below ₹100,000.", context: context);
          } else {
            evalString += number;
          }
        } else {
          showToast("Digits in number can be only 5", context: context);
        }
      }
      // double pos = evalString.length as double;
      // scroll(pos);
      calculate();
    });
  }

  int getLastNumberLength(String str) {
    int lastPlusIndex = str.lastIndexOf("+");
    if (lastPlusIndex == -1) {
      return str.length;
    } else {
      return str.length - lastPlusIndex - 1;
    }
  }

  void clear() {
    setState(() {
      evalString = "0";
      total = '00';
    });
  }

  Future<bool> _onWillPopDialouge() async {
    return false;
  }

  var size, width, height, appBarHeight;
  var btnHeight, btnWidth;

  Future<bool> _onWillPop() async {
    return (await showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: new Text('Are you sure?'),
            content: new Text(
              'Do you want to exit an App',
              style: TextStyle(fontSize: getadaptiveTextSize(context, 18)),
            ),
            actions: <Widget>[
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Container(
                    width: width / 4,
                    height: height * 0.05,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue,
                        foregroundColor: Colors.black, // foreground
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(6), // <-- Radius
                        ),
                      ),
                      onPressed: () =>
                          Navigator.of(context).pop(false), //<-- SEE HERE
                      child: new Text(
                        'No',
                        style: TextStyle(
                            fontSize: getadaptiveTextSize(context, 15)),
                      ),
                    ),
                  ),
                  Container(
                    width: width / 4,
                    height: height * 0.05,
                    child: ElevatedButton(
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.black, // foreground
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(6), // <-- Radius
                        ),
                      ),
                      onPressed: () =>
                          Navigator.of(context).pop(true), // <-- SEE HERE
                      child: new Text(
                        'Yes',
                        style: TextStyle(
                            fontSize: getadaptiveTextSize(context, 15)),
                      ),
                    ),
                  ),
                ],
              )
            ],
          ),
        )) ??
        false;
  }

  @override
  Widget build(BuildContext context) {
    size = MediaQuery.of(context).size;
    width = size.width;
    height = size.height;
    appBarHeight = AppBar().preferredSize.height;
    var heightAll = MediaQuery.of(context).padding.top;

    btnHeight = ((height - 337) / 4) - 28;
    btnWidth = ((width - (width / 4)) / 3) - 6;

    return WillPopScope(
      onWillPop: _onWillPop,
      child: Scaffold(
        appBar: AppBar(
          // Here we take the value from the MyHomePage object that was created by
          // the App.build method, and use it to set our appbar title.
          title: Text(
            widget.title,
            style: TextStyle(color: Colors.white, fontFamily: 'Becham'),
          ),

          backgroundColor: Colors.blue,
          // titleTextStyle: TextStyle(color: Colors.white),

          actions: [
            IconButton(
              icon: const Icon(
                Icons.history,
                color: Colors.white,
              ),
              tooltip: 'Transactions',
              onPressed: () {
                // handle the press
                Navigator.push(context, MaterialPageRoute(
                  builder: (context) {
                    return const TransactionsHistory();
                  },
                ));
              },
            ),
            IconButton(
              icon: const Icon(
                Icons.menu_outlined,
                color: Colors.white,
              ),
              tooltip: 'Menu',
              onPressed: () {
                // handle the press

                Navigator.push(
                  context,
                  PageRouteBuilder(
                    pageBuilder: (context, animation, secondaryAnimation) =>
                        MenuWidget(),
                    transitionsBuilder:
                        (context, animation, secondaryAnimation, child) {
                      var begin = Offset(1.0, 0.0);
                      var end = Offset.zero;
                      var curve = Curves.ease;

                      var tween = Tween(begin: begin, end: end)
                          .chain(CurveTween(curve: curve));

                      return SlideTransition(
                        position: animation.drive(tween),
                        child: child,
                      );
                    },
                  ),
                );

                // Navigator.push(context, MaterialPageRoute(
                //   builder: (context) {
                //     return const MenuWidget();
                //   },
                // ));
              },
            ),
          ],
          centerTitle: false,
        ),
        resizeToAvoidBottomInset: false,
        body: Center(
          child: Column(
            children: [
              Container(
                color: Colors.amber,
                margin: EdgeInsets.only(top: 10),
                // height: 30,
                padding: EdgeInsets.all(15),
                width: width,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Text(
                          "TOTAL AMOUNT ",
                          style: TextStyle(
                              fontSize: getadaptiveTextSize(context, 12),
                              fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),

                    // amount
                    Column(
                      mainAxisAlignment: MainAxisAlignment.end,
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: Wrap(
                            crossAxisAlignment: WrapCrossAlignment.end,
                            children: [
                              Row(
                                children: [
                                  Text(
                                    // '$total',
                                    '${inrFormat.format(double.parse(total))}',
                                    overflow: TextOverflow.fade,
                                    softWrap: true,
                                    style: TextStyle(
                                        fontSize:
                                            getadaptiveTextSize(context, 15),
                                        fontWeight: FontWeight.bold),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ],
                    )
                  ],
                ),
              ),

              // pay bill
              Container(
                height: height * 0.10,
                margin: EdgeInsets.all(10),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    // CASH
                    Container(
                        width: (width / 3) - 15,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.blue, // background
                            foregroundColor: Colors.black, // foreground
                            shape: RoundedRectangleBorder(
                              borderRadius:
                                  BorderRadius.circular(6), // <-- Radius
                            ),
                          ),
                          // style: ButtonStyle(
                          //   backgroundColor:
                          //       MaterialStateProperty.all<Color>(Colors.blue),

                          // ),
                          onPressed: () {
                            payBill("CASH");
                          },
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.money,
                                size: getadaptiveTextSize(context, 20),
                                color: Colors.white,
                              ),
                              Text(
                                'CASH',
                                style: TextStyle(
                                    color: Colors.white,
                                    fontSize: getadaptiveTextSize(context, 15)),
                              ),
                            ],
                          ),
                        )),

                    // UPI/QR
                    Container(
                        width: (width / 3) - 15,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.blue, // background
                            // foreground
                            shape: RoundedRectangleBorder(
                              borderRadius:
                                  BorderRadius.circular(6), // <-- Radius
                            ),
                          ),
                          onPressed: () {
                            payBill("QR/UPI");
                          },
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.qr_code,
                                size: getadaptiveTextSize(context, 20),
                                color: Colors.white,
                              ),
                              Text(
                                'UPI/QR',
                                style: TextStyle(
                                    color: Colors.white,
                                    // fontWeight: FontWeight.w700,
                                    fontSize: getadaptiveTextSize(context, 15)),
                              ),
                            ],
                          ),
                        )),

                    // Container(
                    //     width: (width / 3) - 15,
                    //     child: ElevatedButton(
                    //       style: ButtonStyle(
                    //         backgroundColor:
                    //             MaterialStateProperty.all<Color>(Colors.blue),
                    //       ),
                    //       onPressed: () {
                    //         // payBill("QR/UPI");
                    //       },
                    //       child: Column(
                    //         mainAxisAlignment: MainAxisAlignment.center,
                    //         children: [
                    //           Icon(
                    //             Icons.more,
                    //             size: getadaptiveTextSize(context, 20),
                    //             color: Colors.white,
                    //           ),
                    //           Text(
                    //             'More',
                    //             style: TextStyle(
                    //                 color: Colors.white,
                    //                 fontSize: getadaptiveTextSize(context, 15)),
                    //           ),
                    //         ],
                    //       ),
                    //     )),
                  ],
                ),
              ),

              // // Amount & Calculation
              Container(
                height: height * 0.08,
                margin: EdgeInsets.only(left: 5, right: 5),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8),
                  color: Colors.amber[50],
                  border: Border.all(
                    color: Colors.blueGrey,
                    width: 1,
                  ),
                ),
                padding: EdgeInsets.all(5),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Column(
                      children: [
                        Container(
                          child: Text(
                            "Amount",
                            overflow: TextOverflow.fade,
                            softWrap: true,
                            style: TextStyle(
                                fontSize: getadaptiveTextSize(context, 10)),
                          ),
                        ),
                      ],
                    ),

                    // evaluation
                    Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Container(
                          padding: EdgeInsets.only(right: 10),
                          child: Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                // Wrap(
                                //   direction: Axis.horizontal,
                                //   children: [
                                Container(
                                  width: width - (width / 3),
                                  alignment: Alignment.centerRight,
                                  child: SingleChildScrollView(
                                    scrollDirection: Axis.horizontal,
                                    controller: _controller,
                                    child: Focus(
                                      focusNode: _focusNode,
                                      child: Text(
                                        '$evalString',
                                        overflow: TextOverflow.fade,
                                        style: TextStyle(
                                          color: Color.fromARGB(255, 214, 7, 7),
                                          fontSize:
                                              getadaptiveTextSize(context, 15),
                                        ),
                                      ),
                                    ),

                                    // Text(
                                    //   '$evalString',

                                    //   overflow: TextOverflow.fade,
                                    //   // softWrap: true,
                                    //   style: TextStyle(
                                    //       color: Color.fromARGB(255, 214, 7, 7),
                                    //       fontSize:
                                    //           getadaptiveTextSize(context, 15)),
                                    // ),
                                  ),
                                )
                                //   ],
                                // )
                              ]),
                        )
                      ],
                    ),
                  ],
                ),
              ),

              // buttons
              Center(
                child: Container(
                  height: height * 0.62,
                  padding: EdgeInsets.only(top: height * 0.015),
                  child: Row(
                    children: [
                      Container(
                        width: width - (width / 4),
                        child: Container(
                          width: width,
                          // height: height - 337,

                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // 1-3
                              Container(
                                width: width - (width / 4),
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceAround,
                                  children: [
                                    // button 1
                                    Container(
                                      height: btnHeight,
                                      width: btnWidth,
                                      child: ElevatedButton(
                                        child: Text(
                                          "1",
                                          style: TextStyle(
                                              fontSize: getadaptiveTextSize(
                                                  context, 40)),
                                        ),
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: Color.fromARGB(
                                              255, 236, 233, 232), // background

                                          // backgroundColor: Colors.amber,
                                          foregroundColor: Colors.black,

                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(
                                                12), // <-- Radius
                                          ),
                                        ),
                                        onPressed: () {
                                          addition('1');
                                        },
                                      ),
                                    ),

                                    // button 2
                                    Container(
                                      height: btnHeight,
                                      width: btnWidth,
                                      child: ElevatedButton(
                                        child: Text(
                                          "2",
                                          style: TextStyle(
                                              fontSize: getadaptiveTextSize(
                                                  context, 40)),
                                        ),
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: Color.fromARGB(
                                              255, 236, 233, 232), // background
                                          foregroundColor: Colors.black,
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(
                                                12), // <-- Radius
                                          ), // foreground
                                        ),
                                        onPressed: () {
                                          addition('2');
                                        },
                                      ),
                                    ),

                                    // button 3
                                    Container(
                                      height: btnHeight,
                                      width: btnWidth,
                                      child: ElevatedButton(
                                        child: Text(
                                          "3",
                                          style: TextStyle(
                                              fontSize: getadaptiveTextSize(
                                                  context, 40)),
                                        ),
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: Color.fromARGB(
                                              255, 236, 233, 232), // background
                                          foregroundColor:
                                              Colors.black, // foreground
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(
                                                12), // <-- Radius
                                          ),
                                        ),
                                        onPressed: () {
                                          addition('3');
                                        },
                                      ),
                                    ),
                                  ],
                                ),
                              ),

                              // 4-6
                              Container(
                                width: width - (width / 4),
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceAround,
                                  children: [
                                    // button 4
                                    Container(
                                      height: btnHeight,
                                      width: btnWidth,
                                      child: ElevatedButton(
                                        child: Text(
                                          "4",
                                          style: TextStyle(
                                              fontSize: getadaptiveTextSize(
                                                  context, 40)),
                                        ),
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: Color.fromARGB(
                                              255, 236, 233, 232), // background
                                          foregroundColor:
                                              Colors.black, // foreground
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(
                                                12), // <-- Radius
                                          ),
                                        ),
                                        onPressed: () {
                                          addition('4');
                                        },
                                      ),
                                    ),

                                    // button 5
                                    Container(
                                      height: btnHeight,
                                      width: btnWidth,
                                      child: ElevatedButton(
                                        child: Text(
                                          "5",
                                          style: TextStyle(
                                              fontSize: getadaptiveTextSize(
                                                  context, 40)),
                                        ),
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: Color.fromARGB(
                                              255, 236, 233, 232), // background
                                          foregroundColor:
                                              Colors.black, // foreground
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(
                                                12), // <-- Radius
                                          ),
                                        ),
                                        onPressed: () {
                                          addition('5');
                                        },
                                      ),
                                    ),

                                    // button 6
                                    Container(
                                      height: btnHeight,
                                      width: btnWidth,
                                      child: ElevatedButton(
                                        child: Text(
                                          "6",
                                          style: TextStyle(
                                              fontSize: getadaptiveTextSize(
                                                  context, 40)),
                                        ),
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: Color.fromARGB(
                                              255, 236, 233, 232), // background
                                          foregroundColor:
                                              Colors.black, // foreground
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(
                                                12), // <-- Radius
                                          ),
                                        ),
                                        onPressed: () {
                                          addition('6');
                                        },
                                      ),
                                    ),
                                  ],
                                ),
                              ),

                              // 7-9
                              Container(
                                width: width - (width / 4),
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceAround,
                                  children: [
                                    // button 7
                                    Container(
                                      height: btnHeight,
                                      width: btnWidth,
                                      child: ElevatedButton(
                                        child: Text(
                                          "7",
                                          style: TextStyle(
                                              fontSize: getadaptiveTextSize(
                                                  context, 40)),
                                        ),
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: Color.fromARGB(
                                              255, 236, 233, 232), // background
                                          foregroundColor:
                                              Colors.black, // foreground
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(
                                                12), // <-- Radius
                                          ),
                                        ),
                                        onPressed: () {
                                          addition('7');
                                        },
                                      ),
                                    ),

                                    // button 8
                                    Container(
                                      height: btnHeight,
                                      width: btnWidth,
                                      child: ElevatedButton(
                                        child: Text(
                                          "8",
                                          style: TextStyle(
                                              fontSize: getadaptiveTextSize(
                                                  context, 40)),
                                        ),
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: Color.fromARGB(
                                              255, 236, 233, 232), // background
                                          foregroundColor:
                                              Colors.black, // foreground
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(
                                                12), // <-- Radius
                                          ),
                                        ),
                                        onPressed: () {
                                          addition('8');
                                        },
                                      ),
                                    ),

                                    // button 9
                                    Container(
                                      height: btnHeight,
                                      width: btnWidth,
                                      child: ElevatedButton(
                                        child: Text(
                                          "9",
                                          style: TextStyle(
                                              fontSize: getadaptiveTextSize(
                                                  context, 40)),
                                        ),
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: Color.fromARGB(
                                              255, 236, 233, 232), // background
                                          foregroundColor:
                                              Colors.black, // foreground
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(
                                                12), // <-- Radius
                                          ),
                                        ),
                                        onPressed: () {
                                          addition('9');
                                        },
                                      ),
                                    ),
                                  ],
                                ),
                              ),

                              // clear-0-+
                              Container(
                                width: width - (width / 4),
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceAround,
                                  children: [
                                    // button clear
                                    Container(
                                      height: btnHeight,
                                      width: btnWidth,
                                      child: ElevatedButton(
                                        child: Text(
                                          "C",
                                          style: TextStyle(
                                              fontSize: getadaptiveTextSize(
                                                  context, 20)),
                                        ),
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: Color.fromARGB(
                                              255, 236, 233, 232), // background
                                          foregroundColor:
                                              Colors.black, // foreground
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(
                                                12), // <-- Radius
                                          ),
                                        ),
                                        onPressed: () {
                                          clear();
                                        },
                                      ),
                                    ),

                                    // button 0
                                    Container(
                                      height: btnHeight,
                                      width: btnWidth * 2,
                                      child: ElevatedButton(
                                        child: Text(
                                          "0",
                                          style: TextStyle(
                                              fontSize: getadaptiveTextSize(
                                                  context, 40)),
                                        ),
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: Color.fromARGB(
                                              255, 236, 233, 232), // background
                                          foregroundColor:
                                              Colors.black, // foreground
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(
                                                12), // <-- Radius
                                          ),
                                        ),
                                        onPressed: () {
                                          addition('0');
                                        },
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      Container(
                        width: (width / 4),
                        height: height - 337,
                        child: Container(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            children: [
                              // / back button
                              Container(
                                height: btnHeight * 2 + (btnHeight * 0.050),
                                width: btnWidth,
                                // color: Color.fromARGB(255, 236, 233, 232),
                                child: ElevatedButton(
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Color.fromARGB(
                                        255, 236, 233, 232), // background
                                    foregroundColor: Colors.black, // foreground
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(
                                          12), // <-- Radius
                                    ),
                                  ),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      // Icon(Icons.currency_rupee_rounded, color: Colors.white,),
                                      Icon(
                                        Icons.arrow_back,
                                        color: Colors.black,
                                        size: 50,
                                      ),
                                    ],
                                  ),
                                  onPressed: () {
                                    backSpace();
                                  },
                                ),
                              ),

                              // button add/addition
                              Container(
                                height: btnHeight * 2 + (btnHeight * 0.050),
                                width: btnWidth,
                                // color: Color.fromARGB(255, 236, 233, 232),
                                child: ElevatedButton(
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Color.fromARGB(
                                        255, 236, 233, 232), // background
                                    foregroundColor: Colors.black, // foreground
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(
                                          12), // <-- Radius
                                    ),
                                  ),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      // Icon(Icons.currency_rupee_rounded, color: Colors.white,),
                                      Icon(
                                        Icons.add,
                                        color: Colors.black,
                                        size: 50,
                                      ),
                                    ],
                                  ),
                                  onPressed: () {
                                    // addition('+');
                                    evaluation();
                                  },
                                ),
                              )
                            ],
                          ),
                        ),
                      )
                    ],
                  ),
                ),
              ),

              // Button
            ],
          ),
        ),
      ),
    );
  }
}

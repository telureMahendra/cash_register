import 'dart:convert';
import 'dart:io';

import 'package:cash_register/addBusinessDetails.dart';
import 'package:cash_register/api.dart';
import 'package:cash_register/helper/helper.dart';
import 'package:cash_register/setting.dart';
import 'package:cash_register/success.dart';
import 'package:cash_register/transactions_history.dart';
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:math_expressions/math_expressions.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:flutter_styled_toast/flutter_styled_toast.dart';
import 'package:http/http.dart' as http;
// import 'package:fluttertoast/fluttertoast.dart';

import 'login.dart';

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  // late final AnimationController _controller;

  String total = '0.0';
  int tempNum = 0;
  String evalString = "0";
  late bool isLoggedIn = false;
  late bool isBusinessDetailsFound = false;

  final inrFormat = NumberFormat.currency(
    locale: 'hi_IN',
    name: 'INR',
    symbol: '₹',
    decimalDigits: 2,
  );

  // bool isLoggedIn;

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
                child: const Text('Ok'),
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

    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {});

    // checkLoggedIn();
    checkBusinessDetailsFound();
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

  void payBill(String method) {
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
            title: const Text('Oops😬'),
            content: Text('Enter a amount'),
            actions: [
              TextButton(
                child: const Text('Ok'),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
            ],
          ),
        );
      } else {
        // saveTransaction(method);
        saveTransactionToServer(method);
      }
    });
  }

// Future<http.Response>
  void saveTransactionToServer(String method) async {
    String time = DateFormat('jms').format(DateTime.now()).toString();
    String date = DateFormat('yMMMd').format(DateTime.now()).toString();
    String amount = inrFormat.format(double.parse(total)).toString();
    final prefs = await SharedPreferences.getInstance();

    try {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) {
          return const Center(child: CircularProgressIndicator());
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
          builder: (context) => AlertDialog(
            title: const Text('Error'),
            content: Text('${response.body.toString()}'),
            actions: [
              TextButton(
                child: const Text('Ok'),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
            ],
          ),
        );
      }
    } on SocketException catch (e) {
      // Handle network errors
      Navigator.pop(context);
      showDialog<void>(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Error'),
          content: Text('Network Error'),
          actions: [
            TextButton(
              child: const Text('Ok'),
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
          title: const Text('Error'),
          content: Text('Server Not Responding'),
          actions: [
            TextButton(
              child: const Text('Ok'),
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

  void successful() {
    showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Center(
          child: Text('Payment Successful'),
        ),
        // content: Text('Faild To store'),
        content: Container(
            height: height * 0.25,
            child: Column(
              children: [
                Lottie.asset('assets/animations/check_animation.json',
                    height: height * 0.17,
                    // controller: _controller,
                    repeat: false,
                    animate: true),
                Container(
                  // padding: EdgeInsets.only(top: (height * 0.03)),
                  child: Text(
                    '${inrFormat.format(double.parse(total))}',
                    style: TextStyle(
                        color: Colors.green,
                        fontSize: getadaptiveTextSize(context, 30)),
                  ),
                )
              ],
            )),

        actions: [
          TextButton(
            child: const Center(
              child: Text('Continue'),
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

      setState(() {
        total = '${exp.evaluate(EvaluationType.REAL, cm)}';
        // total = "${oCcy.format(total)}";
      });
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

  // add number in evalSting
  void addition(String number) {
    setState(() {
      if (evalString == '0') {
        evalString = number;
      } else {
        if (evalString.length - evalString.lastIndexOf('+') < 6) {
          evalString += number;
        } else {
          showToast("Digits in number can be only 6", context: context);
        }
      }
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

  var size, width, height, appBarHeight;
  var btnHeight, btnWidth;

  @override
  Widget build(BuildContext context) {
    size = MediaQuery.of(context).size;
    width = size.width;
    height = size.height;
    appBarHeight = AppBar().preferredSize.height;
    var heightAll = MediaQuery.of(context).padding.top;

    btnHeight = ((height - 337) / 4) - 6;
    btnWidth = ((width - (width / 4)) / 3) - 6;

    return Scaffold(
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
              Icons.settings,
              color: Colors.white,
            ),
            tooltip: 'App Settings',
            onPressed: () {
              // handle the press
              Navigator.push(context, MaterialPageRoute(
                builder: (context) {
                  return const SettingWidget();
                },
              ));
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
                            fontSize: getadaptiveTextSize(context, 10)),
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
                                          getadaptiveTextSize(context, 10)),
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
              height: 50,
              margin: EdgeInsets.all(10),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // CASH
                  Container(
                      width: (width / 2) - 15,
                      child: ElevatedButton(
                        style: ButtonStyle(
                          backgroundColor:
                              MaterialStateProperty.all<Color>(Colors.blue),
                        ),
                        onPressed: () {
                          payBill("CASH");
                        },
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.money,
                              size: getadaptiveTextSize(context, 20),
                              color: Colors.white,
                            ),
                            Text(
                              'Cash',
                              style: TextStyle(
                                  color: Colors.white,
                                  fontSize: getadaptiveTextSize(context, 15)),
                            ),
                          ],
                        ),
                      )),

                  // UPI/QR
                  Container(
                      width: (width / 2) - 15,
                      child: ElevatedButton(
                        style: ButtonStyle(
                          backgroundColor:
                              MaterialStateProperty.all<Color>(Colors.blue),
                        ),
                        onPressed: () {
                          payBill("QR/UPI");
                        },
                        child: Row(
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
                                  fontSize: getadaptiveTextSize(context, 15)),
                            ),
                          ],
                        ),
                      )),
                ],
              ),
            ),

            // // Amount & Calculation
            Container(
              height: 100,
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
                  SingleChildScrollView(
                      child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Container(
                        padding: EdgeInsets.only(right: 10),
                        child: Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              Wrap(
                                children: [
                                  Container(
                                    width: width - (width / 3),
                                    alignment: Alignment.topRight,
                                    child: Text(
                                      '$evalString',
                                      overflow: TextOverflow.fade,
                                      softWrap: true,
                                      style: TextStyle(
                                          color: Color.fromARGB(255, 214, 7, 7),
                                          fontSize:
                                              getadaptiveTextSize(context, 15)),
                                    ),
                                  )
                                ],
                              )
                            ]),
                      )
                    ],
                  )),
                ],
              ),
            ),

            // buttons
            Container(
              child: Row(
                children: [
                  Container(
                    width: width - (width / 4),
                    child: Container(
                      width: width,
                      height: height - 337,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // 1-3
                          Container(
                            width: width - (width / 4),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceAround,
                              children: [
                                // button 1
                                Container(
                                  height: btnHeight,
                                  width: btnWidth,
                                  child: ElevatedButton(
                                    child: Text(
                                      "1",
                                      style: TextStyle(
                                          fontSize:
                                              getadaptiveTextSize(context, 40)),
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
                                          fontSize:
                                              getadaptiveTextSize(context, 40)),
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
                                          fontSize:
                                              getadaptiveTextSize(context, 40)),
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
                              mainAxisAlignment: MainAxisAlignment.spaceAround,
                              children: [
                                // button 4
                                Container(
                                  height: btnHeight,
                                  width: btnWidth,
                                  child: ElevatedButton(
                                    child: Text(
                                      "4",
                                      style: TextStyle(
                                          fontSize:
                                              getadaptiveTextSize(context, 40)),
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
                                          fontSize:
                                              getadaptiveTextSize(context, 40)),
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
                                          fontSize:
                                              getadaptiveTextSize(context, 40)),
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
                              mainAxisAlignment: MainAxisAlignment.spaceAround,
                              children: [
                                // button 7
                                Container(
                                  height: btnHeight,
                                  width: btnWidth,
                                  child: ElevatedButton(
                                    child: Text(
                                      "7",
                                      style: TextStyle(
                                          fontSize:
                                              getadaptiveTextSize(context, 40)),
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
                                          fontSize:
                                              getadaptiveTextSize(context, 40)),
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
                                          fontSize:
                                              getadaptiveTextSize(context, 40)),
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
                              mainAxisAlignment: MainAxisAlignment.spaceAround,
                              children: [
                                // button clear
                                Container(
                                  height: btnHeight,
                                  width: btnWidth,
                                  child: ElevatedButton(
                                    child: Text(
                                      "C",
                                      style: TextStyle(
                                          fontSize:
                                              getadaptiveTextSize(context, 20)),
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
                                          fontSize:
                                              getadaptiveTextSize(context, 40)),
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
                            height: btnHeight * 2,
                            width: btnWidth,
                            // color: Color.fromARGB(255, 236, 233, 232),
                            child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Color.fromARGB(
                                    255, 236, 233, 232), // background
                                foregroundColor: Colors.black, // foreground
                                shape: RoundedRectangleBorder(
                                  borderRadius:
                                      BorderRadius.circular(12), // <-- Radius
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
                            height: btnHeight * 2,
                            width: btnWidth,
                            // color: Color.fromARGB(255, 236, 233, 232),
                            child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Color.fromARGB(
                                    255, 236, 233, 232), // background
                                foregroundColor: Colors.black, // foreground
                                shape: RoundedRectangleBorder(
                                  borderRadius:
                                      BorderRadius.circular(12), // <-- Radius
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

            // Button
          ],
        ),
      ),
    );
  }
}

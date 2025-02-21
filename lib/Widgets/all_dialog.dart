import 'package:cash_register/common_utils/assets_path.dart';
import 'package:cash_register/common_utils/common_functions.dart';
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:shared_preferences/shared_preferences.dart';

void showSuccessFailDialog(
    BuildContext context, String animationPath, String message) {
  showDialog<void>(
    context: context,
    builder: (context) => AlertDialog(
      content: Container(
        height: MediaQuery.of(context).size.height * 0.250,
        padding: EdgeInsets.all(2),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Lottie.asset(animationPath,
                height: MediaQuery.of(context).size.height * 0.17,
                // controller: _controller,
                repeat: true,
                animate: true),
            Text(
              message,
              // "No Response Mapped\nResponse Code: 89",
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: getAdaptiveTextSize(context, 15),
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          child: Text(
            'Ok',
            style: TextStyle(fontSize: getAdaptiveTextSize(context, 15)),
          ),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
      ],
    ),
  );
}

showSuccessfulPaymentDialog(BuildContext context, String amount,
    bool isFromProductsScreen, bool isFromQrCode) async {
  Size size = MediaQuery.of(context).size;
  double width = size.width;
  double height = size.height;
  final prefs = await SharedPreferences.getInstance();
  var recieptSwitch = prefs.getBool("recieptSwitch") ?? false;

  if (recieptSwitch) {
    // printhelper.printThermalReciept(
    //     method, printhelper.sourceCalculator, evalString);
  }

  showDialog<void>(
    context: context,
    barrierDismissible: false,
    builder: (context) => AlertDialog(
      insetPadding: EdgeInsets.only(bottom: 20),
      content: Container(
        padding: EdgeInsets.only(bottom: 0),
        height: height * 0.3,
        width: width * 0.70,
        child: Column(
          children: [
            Lottie.asset('assets/animations/check_animation.json',
                height: height * 0.10, repeat: false, animate: true),
            Container(
              padding: EdgeInsets.only(bottom: 0),
              child: Text(
                'Payment Successful',
                style: TextStyle(
                  color: Colors.green,
                  fontSize: getAdaptiveTextSize(context, 20),
                ),
              ),
            ),
            Container(
              padding: EdgeInsets.only(bottom: 10),
              child: Text(
                inrFormat.format(double.parse(amount)),
                // amount,
                style: TextStyle(
                  color: Colors.black,
                  fontSize: getAdaptiveTextSize(context, 30),
                ),
              ),
            ),
            Container(
              padding: EdgeInsets.only(top: 5),
              width: width * 0.49,
              height: height * 0.05,
              child: OutlinedButton(
                style: TextButton.styleFrom(),
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
                  print("from product screen $isFromProductsScreen");
                  if (isFromProductsScreen) {
                    // Navigator.of(context).pop();
                    // deleteAllProducts(
                    //     context, isFromProductsScreen, isFromQrCode);

                    clearCart();

                    while (Navigator.canPop(context)) {
                      Navigator.pop(context);
                    }
                    // if (isFromQrCode) {
                    //   clearCart(context);
                    // }
                  } else {
                    Navigator.of(context).pop();
                    while (Navigator.canPop(context)) {
                      Navigator.pop(context);
                    }
                  }
                },
              ),
            ),
          ],
        ),
      ),
    ),
  );
}

void showLoader(BuildContext context) {
  showDialog<void>(
    context: context,
    barrierDismissible: false,
    builder: (BuildContext context) {
      return Center(
        child: Lottie.asset(loaderAnimationPath,
            height: MediaQuery.of(context).size.height * 0.17,
            // controller: _controller,
            repeat: true,
            animate: true),
      );
    },
  );
}

// PopScope<Object?>(
//               canPop: false,
//               onPopInvokedWithResult: (bool didPop, Object? result) async {
//                 if (didPop) {
//                   return;
//                 }
//                 final bool shouldPop = await showBackDialog(context) ?? false;
//                 if (context.mounted && shouldPop) {
//                   Navigator.pop(context);
//                 }
//               },
//               child: TextButton(
//                 onPressed: () async {
//                   final bool shouldPop = await showBackDialog(context) ?? false;
//                   if (context.mounted && shouldPop) {
//                     Navigator.pop(context);
//                   }
//                 },
//                 child: const Text('Go back'),
//               ),
//             ),

Future<bool> showExitConfirmationDialog(BuildContext context) async {
  return (await showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Text('Confirm Exit'),
          content: Text('Do you want to exit the app?'),
          actions: <Widget>[
            TextButton(
              onPressed: () => Navigator.of(context).pop(false), // No action
              child: Text('No'),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(true), // Yes action
              child: Text('Yes'),
            ),
          ],
        ),
      )) ??
      false;
}

Future<bool?> showBackDialog(BuildContext context) async {
  double height = MediaQuery.of(context).size.height;
  double width = MediaQuery.of(context).size.width;
  return showDialog<bool>(
    context: context,
    builder: (context) => AlertDialog(
      title: new Text('Are you sure?'),
      content: new Text(
        'Do you want to exit an App',
        style: TextStyle(fontSize: getAdaptiveTextSize(context, 18)),
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
                    // Navigator.of(context).pop(false), //<-- SEE HERE
                    Navigator.pop(context, false),
                child: new Text(
                  'No',
                  style: TextStyle(fontSize: getAdaptiveTextSize(context, 15)),
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
                onPressed: () => Navigator.of(context).pop(true),
                // Navigator.of(context).pop(true), // <-- SEE HERE
                child: Text(
                  'Yes',
                  style: TextStyle(fontSize: getAdaptiveTextSize(context, 15)),
                ),
              ),
            ),
          ],
        )
      ],
    ),
  );
}
// Future<bool?> _showBackDialog12() {
//   return showDialog<bool>(
//     context: context,
//     builder: (BuildContext context) {
//       return AlertDialog(
//         title: const Text('Are you sure?'),
//         content: const Text(
//           'Are you sure you want to leave this page?',
//         ),
//         actions: <Widget>[
//           TextButton(
//             style: TextButton.styleFrom(
//               textStyle: Theme.of(context).textTheme.labelLarge,
//             ),
//             child: const Text('Nevermind'),
//             onPressed: () {
//               Navigator.pop(context, false);
//             },
//           ),
//           TextButton(
//             style: TextButton.styleFrom(
//               textStyle: Theme.of(context).textTheme.labelLarge,
//             ),
//             child: const Text('Leave'),
//             onPressed: () {
//               Navigator.pop(context, true);
//             },
//           ),
//         ],
//       );
//     },
//   );
// }

// showQrCodeDialog(BuildContext context) async {
//   final prefs = await SharedPreferences.getInstance();
//   double height = MediaQuery.of(context).size.height;
//   double width = MediaQuery.of(context).size.width;
//   showDialog<void>(
//     context: context,
//     barrierDismissible: false,
//     builder: (context) => WillPopScope(
//       onWillPop: onWillPopDialougeFunction(),
//       child: AlertDialog(
//         // insetPadding: EdgeInsets.only(bottom: 20),
//         content: Container(
//             padding: EdgeInsets.only(bottom: 0),
//             height: height * 0.79,
//             width: width,
//             // color: Colors.amber,
//             child: Column(
//               children: [
//                 Container(
//                     // padding: EdgeInsets.only(
//                     //     bottom: height * 0.020, top: 0),
//                     // color: Colors.blue,
//                     child: Center(
//                   child: Column(
//                     children: [
//                       // UPIPaymentQRCode(
//                       //   upiDetails: upiDetails,
//                       //   size: 200,
//                       // ),
//                       Container(
//                         // padding: EdgeInsets.only(
//                         //     top: height * 0.005,
//                         //     bottom: height * 0.005),
//                         child: Text(
//                           "Complete Your Payment",
//                           style: TextStyle(
//                               color: Colors.black,
//                               fontSize: getadaptiveTextSize(context, 13)),
//                         ),
//                       ),
//                       Container(
//                         padding: EdgeInsets.only(
//                             top: height * 0.005, bottom: height * 0.005),
//                         child: Text(
//                           '${inrFormat.format(double.parse(total))}',
//                           style: TextStyle(
//                               color: Colors.green,
//                               fontWeight: FontWeight.w900,
//                               fontSize: getadaptiveTextSize(context, 30)),
//                         ),
//                       ),
//                       Container(
//                         padding: EdgeInsets.only(
//                             top: height * 0.005, bottom: height * 0.005),
//                         child: Text(
//                           '${prefs.getString("businessName")}',
//                           style: TextStyle(
//                               color: Colors.black,
//                               fontWeight: FontWeight.w600,
//                               fontSize: getadaptiveTextSize(context, 20)),
//                         ),
//                       ),
//                       Container(
//                         padding: EdgeInsets.only(bottom: height * 0.005),
//                         child: Text(
//                           'Scan and pay using UPI app',
//                           style: TextStyle(
//                               color: Colors.black,
//                               fontSize: getadaptiveTextSize(context, 15)),
//                         ),
//                       ),
//                       Code(
//                         height: height * 0.25,
//                         data:
//                             "upi://pay?pa=${prefs.getString("upiID")}&pn=${prefs.getString("businessName")}&mc=0000&tn=Bill%20Payment&am=${double.parse(total)}&cu=INR",
//                         // "upi://pay?pa=9561051485@axl&pn=Mahendra%20Telure&mc=0000&mode=02&purpose=00&am=10",
//                         codeType: CodeType.qrCode(),
//                       ),
//                       Container(
//                         padding: EdgeInsets.only(
//                             top: height * 0.005, bottom: height * 0.005),
//                         child: Text(
//                           'UPI ID: ${prefs.getString("upiID")}',
//                           style: TextStyle(
//                               color: Colors.black,
//                               fontSize: getadaptiveTextSize(context, 15)),
//                         ),
//                       ),
//                       Center(
//                         child: Container(
//                             padding: EdgeInsets.all(height * 0.005),
//                             child: Row(
//                               mainAxisAlignment: MainAxisAlignment.center,
//                               children: [
//                                 Image.asset(
//                                   "assets/images/bhim_tra.png",
//                                   height: height * 0.02,
//                                 ),
//                                 Image.asset(
//                                   "assets/images/upi_tra.png",
//                                   height: height * 0.02,
//                                 ),
//                               ],
//                             )),
//                       ),
//                       Center(
//                         child: Container(
//                           child: TimerCountdown(
//                             format:
//                                 // CountDownTimerFormat.secondsOnly,
//                                 CountDownTimerFormat.minutesSeconds,
//                             endTime: DateTime.now().add(
//                               Duration(
//                                   minutes: 0, seconds: 5, microseconds: 20),
//                             ),
//                             timeTextStyle: TextStyle(
//                                 fontWeight: FontWeight.w800,
//                                 fontSize: getadaptiveTextSize(context, 20)),
//                             onEnd: () {
//                               // print("Timer finished");
//                               showDialog<void>(
//                                 context: context,
//                                 barrierDismissible: false,
//                                 builder: (context) => WillPopScope(
//                                   onWillPop: _onWillPopDialouge,
//                                   child: AlertDialog(
//                                     // title: const Text('Timer Finished'),
//                                     content: Container(
//                                       height: height * 0.28,
//                                       width: width * 0.98,
//                                       child: Column(
//                                         children: [
//                                           Lottie.asset(
//                                               'assets/animations/warning.json',
//                                               height: MediaQuery.of(context)
//                                                       .size
//                                                       .height *
//                                                   0.17,
//                                               repeat: true,
//                                               animate: true),
//                                           Container(
//                                             child: Text(
//                                               "Transaction Timeout!",
//                                               style: TextStyle(
//                                                   color: Colors.red,
//                                                   fontSize: getadaptiveTextSize(
//                                                       context, 15)),
//                                             ),
//                                           ),
//                                           Container(
//                                             padding: EdgeInsets.only(
//                                                 top: height * 0.020),
//                                             child: Row(
//                                               mainAxisAlignment:
//                                                   MainAxisAlignment
//                                                       .spaceBetween,
//                                               children: [
//                                                 Container(
//                                                   height: height * 0.050,
//                                                   child: ElevatedButton(
//                                                       style: ElevatedButton
//                                                           .styleFrom(
//                                                         backgroundColor: Colors
//                                                             .blue, // background
//                                                         foregroundColor: Colors
//                                                             .black, // foreground
//                                                         padding:
//                                                             EdgeInsets.all(8),
//                                                         shape:
//                                                             RoundedRectangleBorder(
//                                                           borderRadius:
//                                                               BorderRadius.circular(
//                                                                   6), // <-- Radius
//                                                         ),
//                                                       ),
//                                                       onPressed: () {
//                                                         Navigator.of(context)
//                                                             .pop();
//                                                         Navigator.of(context)
//                                                             .pop();
//                                                         // Navigator
//                                                         //     .popUntil(
//                                                         //         context);
//                                                         saveTransactionToServer(
//                                                             method,
//                                                             total,
//                                                             printhelper
//                                                                 .sourceCalculator);
//                                                       },
//                                                       child: Text(
//                                                         "Print Receipt",
//                                                         style: TextStyle(
//                                                             color: Colors.white,
//                                                             fontSize:
//                                                                 getadaptiveTextSize(
//                                                                     context,
//                                                                     14)),
//                                                       )),
//                                                 ),
//                                                 Container(
//                                                   height: height * 0.050,
//                                                   child: OutlinedButton(
//                                                       style: OutlinedButton
//                                                           .styleFrom(
//                                                         // background
//                                                         foregroundColor: Colors
//                                                             .black, // foreground
//                                                         padding:
//                                                             EdgeInsets.all(8),
//                                                         shape:
//                                                             RoundedRectangleBorder(
//                                                           borderRadius:
//                                                               BorderRadius.circular(
//                                                                   6), // <-- Radius
//                                                         ),
//                                                       ),
//                                                       onPressed: () {
//                                                         Navigator.of(context)
//                                                             .pop();
//                                                         Navigator.pop(context);
//                                                       },
//                                                       child: Text(
//                                                         "Back To Home",
//                                                         style: TextStyle(
//                                                             color: Colors.black,
//                                                             fontSize:
//                                                                 getadaptiveTextSize(
//                                                                     context,
//                                                                     14)),
//                                                       )),
//                                                 ),
//                                               ],
//                                             ),
//                                           )
//                                         ],
//                                       ),
//                                     ),
//                                     actions: [],
//                                   ),
//                                 ),
//                               );
//                             },
//                           ),
//                         ),
//                       )
//                     ],
//                   ),
//                 )),
//                 Center(
//                   child: Padding(
//                     padding: EdgeInsets.only(bottom: height * 0.01),
//                     child: Text(
//                       "Check Payment Application: If a payment notification is received, print a receipt.",
//                       style: TextStyle(
//                         color: Colors.red,
//                         fontSize: getadaptiveTextSize(context, 12),
//                       ),
//                     ),
//                   ),
//                 ),
//                 Container(
//                   padding: EdgeInsets.only(bottom: 0),
//                   width: width * 0.50,
//                   height: height * 0.05,
//                   child: OutlinedButton(
//                     style: OutlinedButton.styleFrom(
//                       backgroundColor: Colors.blue, // background
//                       foregroundColor: Colors.black, // foreground
//                       shape: RoundedRectangleBorder(
//                         borderRadius: BorderRadius.circular(6), // <-- Radius
//                       ),
//                     ),
//                     child: Row(
//                       mainAxisAlignment: MainAxisAlignment.center,
//                       children: [
//                         Icon(
//                           Icons.print_outlined,
//                           size: getadaptiveTextSize(context, 19),
//                           color: const Color.fromARGB(255, 58, 104, 125),
//                         ),
//                         Text(
//                           'Print Receipt',
//                           style: TextStyle(
//                               color: Colors.black,
//                               fontSize: getadaptiveTextSize(context, 15)),
//                         ),
//                       ],
//                     ),
//                     onPressed: () {
//                       Navigator.pop(context);

//                       saveTransactionToServer(
//                           method, total, printhelper.sourceCalculator);
//                     },
//                   ),
//                 ),
//                 Container(
//                   padding: EdgeInsets.all(height * 0.005),
//                 ),
//                 Container(
//                   padding: EdgeInsets.only(bottom: 0),
//                   width: width * 0.50,
//                   height: height * 0.05,
//                   child: OutlinedButton(
//                     style: OutlinedButton.styleFrom(
//                       foregroundColor: Colors.black, // foreground
//                       shape: RoundedRectangleBorder(
//                         borderRadius: BorderRadius.circular(6), // <-- Radius
//                       ),
//                     ),
//                     child: Row(
//                       mainAxisAlignment: MainAxisAlignment.center,
//                       children: [
//                         Icon(
//                           Icons.home_outlined,
//                           size: getadaptiveTextSize(context, 19),
//                           color: const Color.fromARGB(255, 58, 104, 125),
//                         ),
//                         Text(
//                           'Back To Home',
//                           style: TextStyle(
//                               color: Colors.black,
//                               fontSize: getadaptiveTextSize(context, 15)),
//                         ),
//                       ],
//                     ),
//                     onPressed: () {
//                       Navigator.pop(context);
//                     },
//                   ),
//                 ),
//               ],
//             )),
//         actions: [],
//       ),
//     ),
//   );
// }

// paymentSuccessMessage(BuildContext context, String animationPath, String message){
//   showDialog<void>(
//       context: context,
//       barrierDismissible: false,
//       builder: (context) => AlertDialog(
//         insetPadding: EdgeInsets.only(bottom: 20),
//         content: Container(
//             padding: EdgeInsets.only(bottom: 0),
//             height: height * 0.268,
//             width: width * 0.70,
//             child: Column(
//               children: [
//                 Lottie.asset('assets/animations/check_animation.json',
//                     height: MediaQuery.of(context).size.height * 0.10, repeat: false, animate: true),
//                 Container(
//                   padding: EdgeInsets.only(bottom: 0),
//                   child: Text(
//                     'Payment Successful',
//                     style: TextStyle(
//                       color: Colors.green,
//                       fontSize: getadaptiveTextSize(context, 20),
//                     ),
//                   ),
//                 ),
//                 Container(
//                   padding: EdgeInsets.only(bottom: 10),
//                   child: Text(
//                     '${inrFormat.format(double.parse(total))}',
//                     style: TextStyle(
//                       color: Colors.black,
//                       fontSize: getadaptiveTextSize(context, 30),
//                     ),
//                   ),
//                 ),
//                 Container(
//                   padding: EdgeInsets.only(top: 5),
//                   width: width * 0.49,
//                   height: height * 0.05,
//                   child: OutlinedButton(
//                     style: TextButton.styleFrom(),
//                     child: Row(
//                       mainAxisAlignment: MainAxisAlignment.center,
//                       children: [
//                         Icon(
//                           Icons.home_outlined,
//                           size: getadaptiveTextSize(context, 19),
//                           color: const Color.fromARGB(255, 58, 104, 125),
//                         ),
//                         Text(
//                           'Back To Home',
//                           style: TextStyle(
//                               color: Colors.black,
//                               fontSize: getadaptiveTextSize(context, 15)),
//                         ),
//                       ],
//                     ),
//                     onPressed: () {
//                       evalString = '0';
//                       total = '0';
//                       Navigator.of(context).pop();
//                       setState(() {});
//                     },
//                   ),
//                 ),
//               ],
//             )),
//         actions: [
//           // Center(
//           //   child: Container(
//           //     width: width * 0.51,
//           //     height: height * 0.05,
//           //     child: OutlinedButton(
//           //       style: TextButton.styleFrom(),
//           //       child: const Center(
//           //           child: Row(
//           //         children: [
//           //           Icon(
//           //             Icons.home_filled,
//           //             size: 30,
//           //           ),
//           //           Text(
//           //             'Back To Home',
//           //             style: TextStyle(
//           //               fontSize: 25,
//           //             ),
//           //           ),
//           //         ],
//           //       )),
//           //       onPressed: () {
//           //         evalString = '0';
//           //         total = '0';
//           //         Navigator.of(context).pop();
//           //         setState(() {});
//           //       },
//           //     ),
//           //   ),
//           // ),
//         ],
//       ),
//     );
// }

// import 'package:cash_register/helper/helper.dart';
// import 'package:cash_register/helper/printHelper.dart';
// import 'package:flutter/material.dart';
// import 'package:intl/intl.dart';
// import 'package:lottie/lottie.dart';
// import 'package:shared_preferences/shared_preferences.dart';
// import 'package:http/http.dart' as http;

// class Transacctionhelper extends StatefulWidget {
//   const Transacctionhelper({super.key});

//   @override
//   State<Transacctionhelper> createState() => _TransacctionhelperState();
// }

// class _TransacctionhelperState extends State<Transacctionhelper> {
//   getadaptiveTextSize(BuildContext context, dynamic value) {
//     return (value / 710) * MediaQuery.of(context).size.height;
//   }

//   late Printhelper printhelper = Printhelper();

//   successful(var method) async {
//     final prefs = await SharedPreferences.getInstance();
//     var recieptSwitch = prefs.getBool("recieptSwitch") ?? false;

//     if (recieptSwitch) {
//       // printReciept();
//       // printThermalReciept(method, printhelper.sourceCalculator);
//       // Printhelper.printThermalReciept(
//       //     method, printhelper.sourceCalculator, );
//     }

//     syncTransaction();

//     showDialog<void>(
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
//                     height: height * 0.10, repeat: false, animate: true),
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
//   }

//   void saveTransactionToServer(
//       String method, String amount, String tranSource) async {
//     String time = DateFormat('jms').format(DateTime.now()).toString();
//     String date = DateFormat('yMMMd').format(DateTime.now()).toString();
//     String amount = inrFormat.format(double.parse(amount)).toString();
//     String dateTime =
//         DateFormat('yyyy-MM-dd HH:mm:ss').format(DateTime.now()).toString();
//     final prefs = await SharedPreferences.getInstance();

//     // 'method': method,
//     // 'time': time,
//     // 'date': date,
//     // 'amount': amount,
//     // 'user': {
//     // 'userId': '${prefs.getInt('userId')}',

//     try {
//       showDialog(
//         context: context,
//         barrierDismissible: false,
//         builder: (BuildContext context) {
//           return Center(
//             child: Lottie.asset('assets/animations/loader.json',
//                 height: MediaQuery.of(context).size.height * 0.17,
//                 // controller: _controller,
//                 repeat: true,
//                 animate: true),
//           );
//         },
//       );

//       final response = await http.post(
//         Uri.parse('${Environment.baseUrl}/transaction'),
//         headers: <String, String>{
//           'Content-Type': 'application/json; charset=UTF-8',
//           'userId': '${prefs.getInt('userId')}'
//         },
//         body: jsonEncode(<String, dynamic>{
//           'method': method,
//           'time': time,
//           'date': date,
//           'amount': amount,
//           'userId': '${prefs.getInt('userId')}',
//           "dateTime": dateTime,
//           'tranSource': tranSource,
//           'user': {
//             'userId': '${prefs.getInt('userId')}',
//           }
//         }),
//       );

//       Navigator.pop(context);
//       if (response.statusCode == 200) {
//         // If the server did return a 201 CREATED response,
//         // then parse the JSON.
//         successful(method);
//       } else {
//         // If the server did not return a 201 CREATED response,
//         // then throw an exception.
//         showDialog<void>(
//           context: context,
//           barrierDismissible: false,
//           builder: (context) => AlertDialog(
//             // title: const Text('Error'),

//             insetPadding: EdgeInsets.all(0),
//             content: Container(
//               height: 220,
//               padding: EdgeInsets.all(2),
//               child: Column(
//                 mainAxisSize: MainAxisSize.min,
//                 children: [
//                   Lottie.asset('assets/animations/warning.json',
//                       height: MediaQuery.of(context).size.height * 0.17,
//                       // controller: _controller,
//                       repeat: true,
//                       animate: true),
//                   Text(
//                     '${response.body.toString()}',
//                     style:
//                         TextStyle(fontSize: getadaptiveTextSize(context, 15)),
//                   ),
//                 ],
//               ),
//             ),
//             actions: [
//               TextButton(
//                 style: TextButton.styleFrom(),
//                 child: Text(
//                   'Ok',
//                   style: TextStyle(fontSize: getadaptiveTextSize(context, 20)),
//                 ),
//                 onPressed: () {
//                   Navigator.of(context).pop();
//                 },
//               ),
//             ],
//           ),
//         );
//         sleep(Duration(seconds: 1));
//       }
//     } on SocketException catch (e) {
//       // Handle network errors
//       Navigator.pop(context);
//       showDialog<void>(
//         context: context,
//         builder: (context) => AlertDialog(
//           // title: const Text('Error'),
//           content: Container(
//             height: 220,
//             padding: EdgeInsets.all(2),
//             child: Column(
//               mainAxisSize: MainAxisSize.min,
//               children: [
//                 Lottie.asset('assets/animations/warning.json',
//                     height: MediaQuery.of(context).size.height * 0.17,
//                     // controller: _controller,
//                     repeat: true,
//                     animate: true),
//                 Text(
//                   'Network Error',
//                   style: TextStyle(fontSize: getadaptiveTextSize(context, 15)),
//                 ),
//               ],
//             ),
//           ),
//           actions: [
//             TextButton(
//               child: Text('Ok',
//                   style: TextStyle(fontSize: getadaptiveTextSize(context, 15))),
//               onPressed: () {
//                 Navigator.of(context).pop();
//               },
//             ),
//           ],
//         ),
//       );
//     } catch (e) {
//       Navigator.pop(context);
//       showDialog<void>(
//         context: context,
//         builder: (context) => AlertDialog(
//           content: Container(
//             height: 220,
//             padding: EdgeInsets.all(2),
//             child: Column(
//               mainAxisSize: MainAxisSize.min,
//               children: [
//                 Lottie.asset('assets/animations/warning.json',
//                     height: MediaQuery.of(context).size.height * 0.17,
//                     // controller: _controller,
//                     repeat: true,
//                     animate: true),
//                 Text(
//                   'Server not Responding',
//                   style: TextStyle(fontSize: getadaptiveTextSize(context, 15)),
//                 ),
//               ],
//             ),
//           ),
//           actions: [
//             TextButton(
//               child: Text(
//                 'Ok',
//                 style: TextStyle(fontSize: getadaptiveTextSize(context, 15)),
//               ),
//               onPressed: () {
//                 Navigator.of(context).pop();
//               },
//             ),
//           ],
//         ),
//       );
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return const Placeholder();
//   }
// }

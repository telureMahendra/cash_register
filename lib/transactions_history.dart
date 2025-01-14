import 'dart:convert';

import 'package:cash_register/helper/helper.dart';
import 'package:cash_register/helper/transaction_helper.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:lottie/lottie.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:intl/intl.dart';

import 'package:http/http.dart' as http;

class TransactionsHistory extends StatefulWidget {
  const TransactionsHistory({super.key});

  @override
  State<TransactionsHistory> createState() => _TransactionsHistoryState();
}

class _TransactionsHistoryState extends State<TransactionsHistory> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      // getTransactions();
    });
  }

  // Future<void> getTransactions() async {
  //   print(DateFormat().format(DateTime.now()));
  //   SharedPreferences.getInstance().then((data) {
  //     data.getKeys().forEach((key) {
  //       String encodedTransaction = data.getString(key) ?? '';
  //       print(key);

  //       if (encodedTransaction.isNotEmpty) {
  //         Map<String, dynamic> singleTransaction =
  //             jsonDecode(encodedTransaction);

  //         transactionList.add(singleTransaction);
  //       }
  //     });

  //     print(transactionList);
  //     // numbers.reversed.toList()
  //     // transactionList = transactionList.reversed.toList();
  //     // transactionList.sort;

  //     // transactionList.sort((a, b) =>
  //     //     DateTime.parse(a['dateTime']).compareTo(DateTime.parse(b['dateTime'])));

  //     setState(() {});
  //   });
  // }

  getadaptiveTextSize(BuildContext context, dynamic value) {
    return (value / 710) * MediaQuery.of(context).size.height;
  }

  Future<List<TransactionDetails>> fetchTransaction() async {
    final prefs = await SharedPreferences.getInstance();

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

    final response = await http.get(
      Uri.parse('$BASE_URL/transaction'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
        'userId': '${prefs.getInt('userId')}',
      },
    );
    print(response.body.toString());

    // response = utf8.decode(response.bodyBytes);

    if (response.statusCode == 200) {
      Navigator.pop(context);
      return TransactionDetails.fromJsonList(
          json.decode(utf8.decode(response.bodyBytes)));
      // return TransactionDetails.fromJsonList(json.decode(response.body));
    } else {
      //  return  Text('No transaction data');
      Navigator.pop(context);
      // return Text("data");
      alertMessage(response.body.toString());
      throw Exception('Request Failed.');
      // return ;
    }
  }

  alertMessage(msg) {
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
                '${msg}',
                style: TextStyle(fontSize: getadaptiveTextSize(context, 15)),
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
              Navigator.of(context).pop();
            },
          ),
        ],
      ),
    );
  }

  // get transactions stored spreferencess
  // Future<void> getTransactions() async {
  //   SharedPreferences.getInstance().then((data) {
  //     List<String> keys = data.getKeys().toList();

  //     keys.sort((a, b) => int.parse(a).compareTo(int.parse(b)));

  //     keys.forEach((key) {
  //       String encodedTransaction = data.getString(key) ?? '';

  //       if (encodedTransaction.isNotEmpty) {
  //         Map<String, dynamic> singleTransaction =
  //             jsonDecode(encodedTransaction);

  //         transactionList.add(singleTransaction);
  //       }
  //     });

  //     transactionList = transactionList.reversed.toList();
  //     print(transactionList);

  //     setState(() {});
  //   });
  // }

  var size, width, height;

  var transactionList = [];

  @override
  Widget build(BuildContext context) {
    size = MediaQuery.of(context).size;
    width = size.width;
    height = size.height;
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Transactions',
          style: TextStyle(color: Colors.white, fontFamily: 'Becham'),
        ),
        backgroundColor: Colors.blue,
      ),

      // body: Center(
      //   child: ListView.builder(
      //     itemBuilder: (context, index) {
      //       return Center(
      //         child: Card(
      //             elevation: 5,
      //             child: Padding(
      //               padding: const EdgeInsets.all(8.0),
      //               child: Container(
      //                   height: height * 0.15,
      //                   width: width * 0.90,
      //                   child: Row(
      //                     // mainAxisAlignment: MainAxisAlignment.spaceBetween,
      //                     // crossAxisAlignment: CrossAxisAlignment.start,
      //                     children: [
      //                       Container(
      //                         width: width * 0.60,
      //                         child: Column(
      //                           crossAxisAlignment: CrossAxisAlignment.center,
      //                           children: [
      //                             Container(
      //                               width: width - (width / 4),
      //                               // height: 130,
      //                               child: Row(
      //                                 mainAxisAlignment:
      //                                     MainAxisAlignment.spaceBetween,
      //                                 children: [
      //                                   Container(
      //                                     padding: EdgeInsets.only(top: 10),
      //                                     child: Text(
      //                                       '+ ${transactionList[index]["amount"]}',
      //                                       style: TextStyle(
      //                                         fontSize: getadaptiveTextSize(
      //                                             context, 15),
      //                                         color: Colors.green,
      //                                       ),
      //                                     ),
      //                                   ),
      //                                 ],
      //                               ),
      //                             ),
      //                             Container(
      //                               width: width - (width / 4),
      //                               height: height * 0.08,
      //                               padding:
      //                                   EdgeInsets.only(top: 20, left: 26),
      //                               child: Column(
      //                                   mainAxisAlignment:
      //                                       MainAxisAlignment.spaceBetween,
      //                                   crossAxisAlignment:
      //                                       CrossAxisAlignment.start,
      //                                   children: [
      //                                     Text(
      //                                         '${transactionList[index]["dateTime"]}'),
      //                                     Text(
      //                                         '${transactionList[index]["time"]}')
      //                                   ]),
      //                             ),
      //                           ],
      //                         ),
      //                       ),
      //                       Container(

      //                           // width: (width-(width/4)*3),
      //                           width: width * 0.30,
      //                           child: Column(
      //                             mainAxisAlignment:
      //                                 MainAxisAlignment.spaceEvenly,
      //                             children: [
      //                               if (transactionList[index]["Method"] ==
      //                                   "CASH")
      //                                 Icon(
      //                                   Icons.money,
      //                                   size: width * 0.10,
      //                                 ),
      //                               if (transactionList[index]["Method"] !=
      //                                   "CASH")
      //                                 Icon(
      //                                   Icons.qr_code,
      //                                   // size: width * 0.10,
      //                                   size:
      //                                       getadaptiveTextSize(context, 30),
      //                                 ),
      //                               Text(
      //                                 '${transactionList[index]["Method"]}',
      //                                 style: TextStyle(
      //                                     fontSize: getadaptiveTextSize(
      //                                         context, 12)),
      //                               )
      //                             ],
      //                           )),
      //                     ],
      //                   )),
      //             )),
      //       );
      //     },
      //     itemCount: transactionList.length,
      //   ),
      // )

      body: FutureBuilder<List<TransactionDetails>>(
        future: fetchTransaction(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(
              // child: CircularProgressIndicator(),
              child: null,
            );
          } else if (snapshot.hasError) {
            return Center(
              child: Text(
                'Error: ${snapshot.error}',
                style: TextStyle(
                    color: Colors.red,
                    fontSize: getadaptiveTextSize(context, 20)),
              ),
            ); // Handle error
          } else if (snapshot.hasData) {
            return ListView.builder(
              itemCount: snapshot.data!.length,
              itemBuilder: (context, index) {
                final transaction = snapshot.data![index];
                // print(transaction.time);
                // return ListTile(
                //   title: Text(transaction.method),
                //   subtitle: Text('${transaction.date} - ${transaction.time}'),
                //   trailing: Text(transaction.amount),
                // );
                return (Center(
                  child: Card(
                      elevation: 5,
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Container(
                            height: height * 0.15,
                            width: width * 0.90,
                            child: Row(
                              // mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              // crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Container(
                                  width: width * 0.60,
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.center,
                                    children: [
                                      Container(
                                        width: width - (width / 4),
                                        // height: 130,
                                        child: Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          children: [
                                            Container(
                                              padding: EdgeInsets.only(top: 10),
                                              child: Text(
                                                '+ ${transaction.amount.toString()}',
                                                style: TextStyle(
                                                  fontSize: getadaptiveTextSize(
                                                      context, 15),
                                                  color: Colors.green,
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      Container(
                                        width: width - (width / 4),
                                        height: height * 0.08,
                                        padding:
                                            EdgeInsets.only(top: 20, left: 26),
                                        child: Column(
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceBetween,
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                  '${transaction.date.toString()}'),
                                              Text('${transaction.time}')
                                            ]),
                                      ),
                                    ],
                                  ),
                                ),
                                Container(

                                    // width: (width-(width/4)*3),
                                    width: width * 0.30,
                                    child: Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceEvenly,
                                      children: [
                                        if (transaction.method == "CASH")
                                          Icon(
                                            Icons.money,
                                            size: width * 0.10,
                                          ),
                                        if (transaction.method != "CASH")
                                          Icon(
                                            Icons.qr_code,
                                            // size: width * 0.10,
                                            size: getadaptiveTextSize(
                                                context, 30),
                                          ),
                                        Text(
                                          '${transaction.method}',
                                          style: TextStyle(
                                              fontSize: getadaptiveTextSize(
                                                  context, 12)),
                                        )
                                      ],
                                    )),
                              ],
                            )),
                      )),
                ));
              },
            );
          } else if (!snapshot.hasData) {
            return Center(
              child: Text("No Transactions"),
            );
          } else {
            return Text('No transaction data'); // Handle empty data case
          }
        },
      ),
    );
  }
}

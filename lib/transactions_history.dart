import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:cash_register/db/sqfLiteDBService.dart';
import 'package:cash_register/helper/helper.dart';
import 'package:cash_register/helper/transaction_helper.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:internet_connection_checker/internet_connection_checker.dart';
import 'package:lottie/lottie.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:intl/intl.dart';

import 'package:http/http.dart' as http;
import 'package:skeleton_text/skeleton_text.dart';

class TransactionsHistory extends StatefulWidget {
  const TransactionsHistory({super.key});

  @override
  State<TransactionsHistory> createState() => _TransactionsHistoryState();
}

class _TransactionsHistoryState extends State<TransactionsHistory> {
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

  final dbs = DatabaseService.instance;
  List<Map<String, Object?>>? _billData;
  late StreamSubscription _streamSubscription;
  bool isDeviceConnected = false;

  internetConnection() =>
      _streamSubscription = Connectivity().onConnectivityChanged.listen(
        (event) async {
          isDeviceConnected =
              await InternetConnectionChecker.instance.hasConnection;
        },
      );

  Future<List<TransactionDetailsSQL>> _fetchDatao() async {
    print("in fetch method");
    List<Map<String, Object?>>? data = await dbs.getDBdata();
    print('Data from sql ${data}');
    print(TransactionDetailsSQL.fromJsonList(data));
    return TransactionDetailsSQL.fromJsonList(data);
  }

  Future<List> _fetchData() async {
    List<Map<String, Object?>>? data = await dbs.getDBdata();

    print("in fetch method");
    List<TransactionDetailsSQL> transactionList =
        data.map((item) => TransactionDetailsSQL.fromJson(item)).toList();
    return transactionList.reversed.toList();
  }

  static List<dynamic> sortListByDate(List<dynamic> list) {
    // list.sort((a, b) => a.dateTime.compareTo(b.dateTime));
    list.sort((a, b) => b.dateTime.compareTo(a.dateTime));
    return list;
  }

  Future<List<dynamic>> combineData() async {
    if (isDeviceConnected) {
      print("Device connected");
    } else {
      print("device is not connected");
    }

    Future<List> data = _fetchData();
    print("data loaded from the sqlite");
    Future<List> data1 = fetchTransactionServer();
    print("data loaded from the server");

    List<dynamic> list1 = await data;
    List<dynamic> list2 = await data1;

    List<dynamic> combinedList = [...list1, ...list2];

    // return combinedList;
    return sortListByDate(combinedList);
  }

  Future<List> fetchTransactionServer() async {
    final prefs = await SharedPreferences.getInstance();

    List data = [];

    // showDialog(
    //   context: context,
    //   barrierDismissible: false,
    //   builder: (BuildContext context) {
    //     return Center(
    //       child: Lottie.asset('assets/animations/loader.json',
    //           height: MediaQuery.of(context).size.height * 0.17,
    //           // controller: _controller,
    //           repeat: true,
    //           animate: true),
    //     );
    //   },
    // );

    try {
      final response = await http.get(
        Uri.parse('$BASE_URL/transaction/current-day'),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
          'userId': '${prefs.getInt('userId')}',
          'itemCount': "88",
          'pageNumber': "0",
          "date": '${DateFormat('yMMMd').format(DateTime.now()).toString()}'
        },
      ).timeout(
        const Duration(seconds: 10),
        onTimeout: () {
          return http.Response('Error', 408);
        },
      );

      // response = utf8.decode(response.bodyBytes);

      if (response.statusCode == 200) {
        // Navigator.pop(context);
        return TransactionDetails.fromJsonList(
            json.decode(utf8.decode(response.bodyBytes)));
        // return TransactionDetails.fromJsonList(json.decode(response.body));
      } else {
        //  return  Text('No transaction data');
        // Navigator.pop(context);
        // return Text("data");
        alertMessage(response.body.toString());
        throw Exception('Request Failed.');
        // return ;
      }
    } on SocketException catch (e) {
      // Navigator.pop(context);
      return data;
    }
  }

  getadaptiveTextSize(BuildContext context, dynamic value) {
    return (value / 710) * MediaQuery.of(context).size.height;
  }

  Future<List<TransactionDetails>> fetchTransaction() async {
    final prefs = await SharedPreferences.getInstance();

    // showDialog(
    //   context: context,
    //   barrierDismissible: false,
    //   builder: (BuildContext context) {
    //     return Center(
    //       child: Lottie.asset('assets/animations/loader.json',
    //           height: MediaQuery.of(context).size.height * 0.17,
    //           // controller: _controller,
    //           repeat: true,
    //           animate: true),
    //     );
    //   },
    // );

    final response = await http.get(
      Uri.parse('$BASE_URL/transaction'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
        'userId': '${prefs.getInt('userId')}',
      },
    );

    // response = utf8.decode(response.bodyBytes);

    if (response.statusCode == 200) {
      // Navigator.pop(context);
      return TransactionDetails.fromJsonList(
          json.decode(utf8.decode(response.bodyBytes)));
      // return TransactionDetails.fromJsonList(json.decode(response.body));
    } else {
      //  return  Text('No transaction data');
      // Navigator.pop(context);
      // return Text("data");
      alertMessage(response.body.toString());
      throw Exception('Request Failed.');
      // return ;
    }
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {});

    // internetConnection();
    syncStatus();

    // setState(() {});
  }

  @override
  void dispose() {
    // _streamSubscription1.cancel();
    super.dispose();
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

  bool isSynced = false;

  Future<void> syncStatus() async {
    final prefs = await SharedPreferences.getInstance();

    List<TransactionDetailsSQL> unsyncedTransactions =
        await dbs.getUnsyncedTransactions();

    if (unsyncedTransactions.isNotEmpty) {
      prefs.getBool("isSynced") ?? false;
      isSynced = false;
    } else {
      isSynced = true;
      prefs.getBool("isSynced") ?? true;
    }
    setState(() {});
  }

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
          foregroundColor: Colors.white,
        ),
        body: Center(
          child: Container(
            child: Column(
              children: [
                isSynced
                    ? Container(
                        height: height * 0.030,
                        color: Colors.green,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.sync),
                            Text("Transaction Synced")
                          ],
                        ),
                      )
                    : Container(
                        height: height * 0.030,
                        color: Colors.orange,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.sync_problem),
                            Text("Transaction Not Synced")
                          ],
                        ),
                      ),
                Container(
                  child: Expanded(
                    child: FutureBuilder<List>(
                      future: combineData(),
                      // future: combineData(),
                      builder: (context, snapshot) {
                        if (snapshot.connectionState ==
                            ConnectionState.waiting) {
                          return Center(
                            // child: CircularProgressIndicator(),
                            child: buildSkeleton(context),
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
                        } else if (!snapshot.hasData) {
                          return Text("data");
                        } else if (snapshot.hasData) {
                          return ListView.builder(
                            itemCount: snapshot.data!.length,
                            itemBuilder: (context, index) {
                              final transaction = snapshot.data![index];

                              return (Center(
                                child: Card(
                                    elevation: 5,
                                    child: Padding(
                                      padding: const EdgeInsets.all(8.0),
                                      child: Container(
                                          height: height * 0.15,
                                          width: width * 0.90,
                                          child: Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceBetween,
                                            // crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              Container(
                                                width: width * 0.40,
                                                child: Column(
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.center,
                                                  children: [
                                                    Container(
                                                      width:
                                                          width - (width / 4),
                                                      // height: 130,
                                                      child: Row(
                                                        mainAxisAlignment:
                                                            MainAxisAlignment
                                                                .spaceBetween,
                                                        children: [
                                                          Container(
                                                            padding:
                                                                EdgeInsets.only(
                                                                    top: 10),
                                                            child: Text(
                                                              '+ ${transaction.amount.toString()}',
                                                              style: TextStyle(
                                                                fontSize:
                                                                    getadaptiveTextSize(
                                                                        context,
                                                                        15),
                                                                color: Colors
                                                                    .green,
                                                              ),
                                                            ),
                                                          ),
                                                        ],
                                                      ),
                                                    ),
                                                    Container(
                                                      width:
                                                          width - (width / 4),
                                                      height: height * 0.08,
                                                      padding: EdgeInsets.only(
                                                          top: 20, left: 26),
                                                      child: Column(
                                                          mainAxisAlignment:
                                                              MainAxisAlignment
                                                                  .spaceBetween,
                                                          crossAxisAlignment:
                                                              CrossAxisAlignment
                                                                  .start,
                                                          children: [
                                                            Text(
                                                                '${transaction.date.toString()}'),
                                                            Text(
                                                                '${transaction.time}')
                                                          ]),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                              // (transaction.status.toString() ==
                                              //         1)
                                              //     ? changeSyncStatus(true)
                                              //     : changeSyncStatus(false)

                                              Column(
                                                mainAxisAlignment:
                                                    MainAxisAlignment
                                                        .spaceEvenly,
                                                children: [
                                                  (transaction.tranSource
                                                              .toString() ==
                                                          "PRODUCT")
                                                      ? Container(
                                                          child: Icon(
                                                            Icons.shopping_cart,
                                                            color: Colors.grey,
                                                            size:
                                                                getadaptiveTextSize(
                                                                    context,
                                                                    30),
                                                          ),
                                                        )
                                                      : Container(
                                                          child: Icon(
                                                            Icons.calculate,
                                                            color: Colors.grey,
                                                            size:
                                                                getadaptiveTextSize(
                                                                    context,
                                                                    20),
                                                          ),
                                                        ),
                                                  (transaction.status
                                                              .toString() ==
                                                          '1')
                                                      ? Container(
                                                          // child: Icon(
                                                          //   Icons.sync,
                                                          //   color: Colors.green,
                                                          //   size:
                                                          //       getadaptiveTextSize(
                                                          //           context,
                                                          //           30),
                                                          // ),
                                                          )
                                                      : Container(
                                                          // color: Colors.amber,
                                                          child: Icon(
                                                            Icons.sync_problem,
                                                            color: Colors.amber,
                                                            size:
                                                                getadaptiveTextSize(
                                                                    context,
                                                                    30),
                                                          ),
                                                        ),
                                                ],
                                              ),

                                              Container(

                                                  // width: (width-(width/4)*3),
                                                  width: width * 0.30,
                                                  child: Column(
                                                    mainAxisAlignment:
                                                        MainAxisAlignment
                                                            .spaceEvenly,
                                                    children: [
                                                      if (transaction.method ==
                                                          "CASH")
                                                        Icon(
                                                          Icons.money,
                                                          size: width * 0.10,
                                                        ),
                                                      if (transaction.method !=
                                                          "CASH")
                                                        Icon(
                                                          Icons.qr_code,
                                                          // size: width * 0.10,
                                                          size:
                                                              getadaptiveTextSize(
                                                                  context, 30),
                                                        ),
                                                      Text(
                                                        '${transaction.method}',
                                                        style: TextStyle(
                                                            fontSize:
                                                                getadaptiveTextSize(
                                                                    context,
                                                                    12)),
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
                          return Text(
                              'No transaction data'); // Handle empty data case
                        }
                      },
                    ),
                  ),
                )
              ],
            ),
          ),
        ));
  }

  Widget buildSkeleton(BuildContext context) {
    return ListView.builder(
        itemCount: 8,
        itemBuilder: (BuildContext context, int index) {
          return ListTile(
            splashColor: const Color.fromARGB(255, 179, 172, 172),
            title: Container(
              decoration: BoxDecoration(
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey,
                    offset: const Offset(
                      3.0,
                      3.0,
                    ),
                    blurRadius: 5.0,
                    spreadRadius: 1.0,
                  ), //BoxShadow
                  BoxShadow(
                    color: const Color.fromARGB(255, 232, 229, 229),
                    offset: const Offset(0.0, 0.0),
                    blurRadius: 0.0,
                    spreadRadius: 0.0,
                  ), //BoxShadow
                ],
              ),
              padding: EdgeInsets.all(5),
              child: Column(
                children: [
                  Container(
                      alignment: Alignment.topLeft,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          // SkeletonAnimation(
                          //   shimmerColor: Colors.grey,
                          //   borderRadius: BorderRadius.circular(20),
                          //   shimmerDuration: 500,
                          //   child: Container(
                          //     color: const Color.fromARGB(255, 208, 200, 200),
                          //     child: SizedBox(
                          //       height: 80,
                          //       width: 80,
                          //     ),
                          //   ),
                          // ),
                          Container(
                            width: width * 0.30,
                            height: height * 0.085,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                SkeletonAnimation(
                                  shimmerColor: Colors.grey,
                                  borderRadius: BorderRadius.circular(5),
                                  shimmerDuration: 500,
                                  child: Container(
                                    color: const Color.fromARGB(
                                        255, 208, 200, 200),
                                    child: SizedBox(
                                      height: 25,
                                      width: 100,
                                    ),
                                  ),
                                ),
                                SkeletonAnimation(
                                  shimmerColor: Colors.grey,
                                  borderRadius: BorderRadius.circular(5),
                                  shimmerDuration: 500,
                                  child: Container(
                                    color: const Color.fromARGB(
                                        255, 208, 200, 200),
                                    child: SizedBox(
                                      height: 15,
                                      width: 100,
                                    ),
                                  ),
                                ),
                                SkeletonAnimation(
                                  shimmerColor: Colors.grey,
                                  borderRadius: BorderRadius.circular(5),
                                  shimmerDuration: 500,
                                  child: Container(
                                    padding: EdgeInsets.only(left: 10),
                                    color: const Color.fromARGB(
                                        255, 208, 200, 200),
                                    child: SizedBox(
                                      height: 15,
                                      width: 90,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          SkeletonAnimation(
                            shimmerColor: Colors.grey,
                            borderRadius: BorderRadius.circular(5),
                            shimmerDuration: 500,
                            child: Container(
                              color: const Color.fromARGB(255, 208, 200, 200),
                              child: SizedBox(
                                height: 35,
                                width: 35,
                              ),
                            ),
                          ),
                          Container(
                            width: width * 0.15,
                            height: height * 0.11,
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                SkeletonAnimation(
                                  shimmerColor: Colors.grey,
                                  borderRadius: BorderRadius.circular(5),
                                  shimmerDuration: 500,
                                  child: Container(
                                    color: const Color.fromARGB(
                                        255, 208, 200, 200),
                                    child: SizedBox(
                                      height: 40,
                                      width: 40,
                                    ),
                                  ),
                                ),
                                SkeletonAnimation(
                                  shimmerColor: Colors.grey,
                                  borderRadius: BorderRadius.circular(5),
                                  shimmerDuration: 500,
                                  child: Container(
                                    color: const Color.fromARGB(
                                        255, 208, 200, 200),
                                    child: SizedBox(
                                      height: 30,
                                      width: 60,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      )),
                ],
              ),
            ),
          );
        });
  }
}

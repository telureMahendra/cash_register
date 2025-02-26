import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:cash_register/db/sqfLite_db_service.dart';
import 'package:cash_register/helper/helper.dart';
import 'package:cash_register/helper/service/transaction_sync_service.dart';
import 'package:cash_register/model/transaction_helper.dart';
import 'package:cash_register/model/environment.dart';
import 'package:cash_register/modules/transaction_history_module/widgets/transaction_summary_card_widget.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:hive/hive.dart';
import 'package:hive_flutter/adapters.dart';
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

  int totalTransactionCount = 0;
  double totalAmount = 0.0;
  int cashTransactionCount = 0;
  int upiQrTransactionCount = 0;
  double cashAmount = 0.0;
  double upiQrAmount = 0.0;

  final dbs = DatabaseService.instance;
  List<Map<String, Object?>>? _billData;
  late StreamSubscription _streamSubscription;
  bool isDeviceConnected = false;

  final inrFormat = NumberFormat.currency(
    locale: 'hi_IN',
    name: 'INR',
    symbol: '₹',
    decimalDigits: 2,
  );

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

  Future<Box> openTransactionBox() async {
    await Hive.initFlutter();
    return await Hive.openBox('transactions');
  }

  Future<List<dynamic>> combineData() async {
    var box = await openTransactionBox();

    Future<List> data = _fetchData();
    print("data loaded from the sqlite");
    Future<List> data1 = fetchTransactionServer();
    print("data loaded from the server");

    List<dynamic> list1 = await data;
    List<dynamic> list2 = await data1;

    List<dynamic> combinedList = [...list1, ...list2];

    List<dynamic> sortedList = sortListByDate(combinedList);

    // if (box.containsKey('transactions') && box.containsKey('lastUpdateDate')) {
    //   String lastUpdateDate = box.get('lastUpdateDate');

    //   // If the data is for today, return the cached data
    //   if (lastUpdateDate != currentDate) {
    //     await box.delete('transactions');
    //     await box.delete('lastUpdateDate');
    //   }
    // }

    // await box.put('transactions', sortedList);

    if (box.containsKey('transactions')) {
      List<dynamic> cachedData = box.get('transactions');
      return cachedData; // Return cached data
    } else {
      return sortedList; // Return empty if no cached data is available
    }

    // return sortListByDate(combinedList);
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
        Uri.parse('${Environment.baseUrl}/transaction/current-day'),
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

  fetchTransactionsummary() async {
    final prefs = await SharedPreferences.getInstance();

    try {
      final response = await http.get(
        Uri.parse('${Environment.baseUrl}/transaction/summary'),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
          'userId': '${prefs.getInt('userId')}',
          "date": DateFormat('yMMMd').format(DateTime.now()).toString()
        },
      ).timeout(
        const Duration(seconds: 10),
        onTimeout: () {
          return http.Response('Error', 408);
        },
      );

      if (response.statusCode == 200) {
        var data = jsonDecode(response.body);
        setState(() {
          totalAmount = data['totalAmount'];
          totalTransactionCount = data['totalTransactionCount'];

          cashAmount = data['cashAmount'];
          cashTransactionCount = data['cashTransactionCount'];

          upiQrAmount = data['upiQrAmount'];
          upiQrTransactionCount = data['upiQrTransactionCount'];
        });
      } else {
        //  return  Text('No transaction data');
        // Navigator.pop(context);
        return Text("data");
        // alertMessage(response.body.toString());
        // throw Exception('Request Failed.');
        // return ;
      }
    } on SocketException catch (e) {
      // Navigator.pop(context);
      print(e);
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
      Uri.parse('${Environment.baseUrl}/transaction'),
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
    fetchTransactionsummary();

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

  Future<void> syncTransaction() async {
    if (isDeviceConnected) {
      print("working on syncronization");
      TransactionSyncService syncService =
          TransactionSyncService(DatabaseService.instance, databaseHelper: dbs);
      print("network is available");
      await syncService.syncTransactions();
      final prefs = await SharedPreferences.getInstance();
      prefs.setBool("isSynced", true);
      setState(() {});
    } else {
      print("network error in syncronization");
    }
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
          actions: [
            isSynced
                ? IconButton(
                    icon: const Icon(
                      Icons.sync,
                      color: Colors.white,
                    ),
                    tooltip: 'Synced',
                    onPressed: () {},
                  )
                : IconButton(
                    icon: const Icon(
                      Icons.sync_problem_rounded,
                      color: Colors.white,
                    ),
                    tooltip: 'Sync',
                    onPressed: () {
                      syncTransaction();
                    },
                  )
          ],
          title: Text(
            'Transactions',
            style: TextStyle(color: Colors.white, fontFamily: 'Becham'),
          ),
          backgroundColor: Colors.blue,
          foregroundColor: Colors.white,
        ),
        body: Center(
          child: Column(
            children: [
              // isSynced
              //     ? Container(
              //         height: height * 0.030,
              //         // color: Colors.green,
              //         child: Row(
              //           mainAxisAlignment: MainAxisAlignment.center,
              //           children: [
              //             Icon(
              //               Icons.sync,
              //               color: Colors.green,
              //             ),
              //             Text(
              //               "Transaction Synced",
              //               style: TextStyle(color: Colors.green),
              //             )
              //           ],
              //         ),
              //       )
              //     : Container(
              //         height: height * 0.030,
              //         color: Colors.orange,
              //         child: Row(
              //           mainAxisAlignment: MainAxisAlignment.center,
              //           children: [
              //             Icon(Icons.sync_problem),
              //             Text("Transaction Not Synced")
              //           ],
              //         ),
              //       ),
              Container(
                  padding:
                      const EdgeInsets.only(left: 8.0, right: 8.0, top: 8.0),
                  child: Text(
                    "Today's Transaction Summary",
                    style: TextStyle(
                        color: Colors.black,
                        fontSize: getadaptiveTextSize(context, 15)),
                  )),
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Container(
                  // width: width,
                  // padding: EdgeInsets.symmetric(horizontal: 25),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      TransactionSummaryCardWidget(
                          title: "Total",
                          amount: totalAmount,
                          transactionCount: totalTransactionCount),
                      TransactionSummaryCardWidget(
                          title: "UPI/QR",
                          amount: upiQrAmount,
                          transactionCount: upiQrTransactionCount),
                      TransactionSummaryCardWidget(
                          title: "Cash",
                          amount: cashAmount,
                          transactionCount: cashTransactionCount)
                    ],
                  ),
                ),
              ),
              Expanded(
                child: FutureBuilder<List>(
                  future: combineData(),
                  // future: combineData(),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
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
                                  child: SizedBox(
                                      height: height * 0.15,
                                      width: width * 0.90,
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        // crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          SizedBox(
                                            width: width * 0.40,
                                            child: Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.center,
                                              children: [
                                                SizedBox(
                                                  width: width - (width / 4),
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
                                                        Text(transaction.date
                                                            .toString()),
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
                                                MainAxisAlignment.spaceEvenly,
                                            children: [
                                              (transaction.tranSource
                                                          .toString() ==
                                                      "PRODUCT")
                                                  ? Icon(
                                                      Icons.shopping_cart,
                                                      color: Colors.grey,
                                                      size: getadaptiveTextSize(
                                                          context, 30),
                                                    )
                                                  : Icon(
                                                      Icons.calculate,
                                                      color: Colors.grey,
                                                      size: getadaptiveTextSize(
                                                          context, 20),
                                                    ),
                                              (transaction.status.toString() ==
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
                                                  : Icon(
                                                      Icons.sync_problem,
                                                      color: Colors.amber,
                                                      size: getadaptiveTextSize(
                                                          context, 30),
                                                    ),
                                            ],
                                          ),

                                          SizedBox(

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
                                                  if (transaction.method ==
                                                      "CARD")
                                                    Icon(
                                                      Icons.credit_card,
                                                      // size: width * 0.10,
                                                      size: getadaptiveTextSize(
                                                          context, 30),
                                                    ),
                                                  if (transaction.method
                                                      .toString()
                                                      .contains("QR"))
                                                    Icon(
                                                      Icons.qr_code,
                                                      // size: width * 0.10,
                                                      size: getadaptiveTextSize(
                                                          context, 30),
                                                    ),
                                                  Text(
                                                    '${transaction.method}',
                                                    style: TextStyle(
                                                        fontSize:
                                                            getadaptiveTextSize(
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
                      return Text(
                          'No transaction data'); // Handle empty data case
                    }
                  },
                ),
              )
            ],
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
                          SizedBox(
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
                          SizedBox(
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

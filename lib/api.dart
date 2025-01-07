import 'dart:convert';

import 'package:cash_register/helper/transaction_helper.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter/src/widgets/placeholder.dart';
import 'package:http/http.dart' as http;

class ApiFetch extends StatefulWidget {
  const ApiFetch({super.key});

  @override
  State<ApiFetch> createState() => _ApiFetchState();
}

class _ApiFetchState extends State<ApiFetch> {
  var size, width, height;

  @override
  void initState() {
    super.initState();
  }

  Future<List<TransactionDetails>> fetchTransaction() async {
    final response =
        await http.get(Uri.parse('http://10.0.20.79:8080/api/v1/transaction'));

    if (response.statusCode == 200) {
      return TransactionDetails.fromJsonList(json.decode(response.body));
    } else {
      throw Exception('Request Failed.');
    }
  }

  getadaptiveTextSize(BuildContext context, dynamic value) {
    return (value / 710) * MediaQuery.of(context).size.height;
  }

  @override
  Widget build(BuildContext context) {
    size = MediaQuery.of(context).size;
    width = size.width;
    height = size.height;

    return Scaffold(
      appBar: AppBar(
        title: Text("API Fetch"),
        centerTitle: false,
        backgroundColor: Colors.blue,
      ),
      resizeToAvoidBottomInset: false,
      body: FutureBuilder<List<TransactionDetails>>(
        future: fetchTransaction(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(
              child: CircularProgressIndicator(),
            ); // Show loading indicator
          } else if (snapshot.hasError) {
            return Text('Error: ${snapshot.error}'); // Handle error
          } else if (snapshot.hasData) {
            return ListView.builder(
              itemCount: snapshot.data!.length,
              itemBuilder: (context, index) {
                final transaction = snapshot.data![index];
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
                                                '+ ${transaction.amount}',
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
                                              Text('${transaction.date}'),
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
          } else {
            return Text('No data'); // Handle empty data case
          }
        },
      ),
    );
  }
}

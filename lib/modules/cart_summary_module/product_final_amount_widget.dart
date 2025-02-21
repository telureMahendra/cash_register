import 'dart:convert';

import 'package:cash_register/Widgets/all_dialog.dart';
import 'package:cash_register/common_utils/assets_path.dart';
import 'package:cash_register/common_utils/common_functions.dart';
import 'package:cash_register/common_utils/strings.dart';
import 'package:cash_register/db/sqfLite_db_service.dart';
import 'package:cash_register/helper/printe_helper.dart';
import 'package:cash_register/helper/stream_helper.dart';
import 'package:cash_register/model/cart_item.dart';
import 'package:cash_register/modules/cart_summary_module/payment_button_widget.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:math_expressions/math_expressions.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ProductFinalAmountWidget extends StatefulWidget {
  const ProductFinalAmountWidget({super.key});

  @override
  State<ProductFinalAmountWidget> createState() =>
      _ProductFinalAmountWidgetState();
}

class _ProductFinalAmountWidgetState extends State<ProductFinalAmountWidget> {
  String total = '';
  final dbs = DatabaseService.instance;
  Printhelper printHelper = Printhelper();

  // void deleteAllProducts(BuildContext context) {
  //   final dbs = DatabaseService.instance;
  //   // StreamHelper.cartFinalAmounSink.add(await dbs.getCartTotal());
  //   dbs.emptyCart().then((_) async {
  //     StreamHelper.cartCountSink.add(await dbs.getCartCount());

  //     if (context.mounted) {
  //       Navigator.maybePop(context);
  //     }
  //   });
  // }

  @override
  void initState() {
    // TODO: implement initState
    print("device model in final ${getDeviceModelDetails()}");
    super.initState();
  }

  printReciept(String method) async {
    printHelper
        .printProductReciept(method, printHelper.sourceProduct)
        .then((_) async {
      saveTransactionSqlite(
          method, await dbs.getCartTotal(), printHelper.sourceProduct, true);
      // deleteAllProducts(context, true, false);

      // Navigator.pop(context);
    });
  }

  String getDeviceModelDetails() {
    String model = '';
    getDeviceModel().then((value) {
      model = value;
    });
    return model;
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

    saveTransactionSqlite(
        "CASH", await dbs.getCartTotal(), printHelper.sourceProduct, true);
    showSuccessfulPaymentDialog(context, await dbs.getCartTotal(), true, false);
  }

  showQr() {
    showProductQrCodeDialog(
        context, total, "QR/UPI", printHelper.sourceProduct, true);
  }

  payCard() async {
    print("card clicked");
    const platform = MethodChannel('printMethod');
    try {
      final saleRequest = {
        "AMOUNT": await dbs.getCartTotal(),
        // "TIP_AMOUNT": "0",
        "TRAN_TYPE": "SALE",
        "BILL_NUMBER": "abc123",
        "SOURCE_ID": "abcd",
        "PRINT_FLAG": "0",
        "UDF2": "",
        "UDF3": "",
        "UDF4": "",
        "UDF5": "",
      };

      // Invoke the method on Android to start the payment process
      // await platform.invokeMethod('paymentMethod', {"data": saleRequest});
      var response =
          await platform.invokeMethod('paymentMethod', {"data": saleRequest});
      Map<String, dynamic> responseMap = jsonDecode(response);

      printRecieptP300("CARD");

      showSuccessfulPaymentDialog(
          context, await dbs.getCartTotal(), true, false);
    } on PlatformException catch (e) {
      Map<String, dynamic> responseMap = jsonDecode(e.message.toString());

      showSuccessFailDialog(context, invalidAnimationPath,
          '${responseMap["STATUS_CODE"]}-${responseMap["STATUS_MSG"]}');
    }
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    double width = size.width;
    double height = size.height;
    return StreamBuilder(
        stream: StreamHelper.cartFinalAmountStream,
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            if (snapshot.data != null) {
              total = snapshot.data.toString();
              return SizedBox(
                width: width > 500 ? width * 0.80 : width,
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 7),
                  child: Column(
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              children: [
                                Text(
                                  "Total: ",
                                  style: TextStyle(
                                    fontSize: getAdaptiveTextSize(context, 17),
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                Text(
                                  inrFormat.format(
                                      double.parse(snapshot.data.toString())),
                                  style: TextStyle(
                                    fontSize: getAdaptiveTextSize(context, 17),
                                    fontWeight: FontWeight.bold,
                                  ),
                                )
                              ],
                            ),
                            ElevatedButton(
                              onPressed: () {
                                showModalBottomSheet(
                                    context: context,
                                    builder: (context) {
                                      return SizedBox(
                                        width: width,
                                        child: Padding(
                                          padding: const EdgeInsets.symmetric(
                                            vertical: 10.0,
                                            horizontal: 25.0,
                                          ),
                                          child: Column(
                                            mainAxisAlignment:
                                                MainAxisAlignment.start,
                                            crossAxisAlignment:
                                                CrossAxisAlignment.center,
                                            children: [
                                              Text(
                                                "Payment Details",
                                                style: TextStyle(
                                                    fontSize:
                                                        getAdaptiveTextSize(
                                                            context, 15),
                                                    fontWeight:
                                                        FontWeight.bold),
                                              ),
                                              Padding(
                                                padding: EdgeInsets.only(
                                                    bottom: height * 0.015),
                                                child: Row(
                                                  children: List.generate(
                                                    20,
                                                    (index) {
                                                      return Expanded(
                                                        child: Padding(
                                                          padding:
                                                              const EdgeInsets
                                                                  .only(
                                                                  left: 4.0,
                                                                  right: 4.0),
                                                          child: Container(
                                                            height: 2,
                                                            width: 8,
                                                            color: Colors.grey,
                                                          ),
                                                        ),
                                                      );
                                                    },
                                                  ),
                                                ),
                                              ),
                                              Padding(
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                        horizontal: 30),
                                                child: Column(
                                                  children: [
                                                    Row(
                                                      mainAxisAlignment:
                                                          MainAxisAlignment
                                                              .spaceBetween,
                                                      children: [
                                                        Text(
                                                          "Sub Total:",
                                                          style: TextStyle(
                                                            fontSize:
                                                                getAdaptiveTextSize(
                                                                    context,
                                                                    14),
                                                          ),
                                                        ),
                                                        Text(
                                                          inrFormat.format(double
                                                              .parse(snapshot
                                                                  .data
                                                                  .toString())),
                                                          style: TextStyle(
                                                            fontSize:
                                                                getAdaptiveTextSize(
                                                                    context,
                                                                    14),
                                                            fontWeight:
                                                                FontWeight.bold,
                                                          ),
                                                        )
                                                      ],
                                                    ),
                                                    Row(
                                                      mainAxisAlignment:
                                                          MainAxisAlignment
                                                              .spaceBetween,
                                                      children: [
                                                        Text(
                                                          "Tax:",
                                                          style: TextStyle(
                                                            fontSize:
                                                                getAdaptiveTextSize(
                                                                    context,
                                                                    14),
                                                          ),
                                                        ),
                                                        Text(
                                                          "0.00",
                                                          style: TextStyle(
                                                            fontSize:
                                                                getAdaptiveTextSize(
                                                                    context,
                                                                    14),
                                                            fontWeight:
                                                                FontWeight.bold,
                                                          ),
                                                        )
                                                      ],
                                                    ),
                                                    Row(
                                                      mainAxisAlignment:
                                                          MainAxisAlignment
                                                              .spaceBetween,
                                                      children: [
                                                        Text(
                                                          "Discount",
                                                          style: TextStyle(
                                                            fontSize:
                                                                getAdaptiveTextSize(
                                                                    context,
                                                                    14),
                                                          ),
                                                        ),
                                                        Text(
                                                          "0.00",
                                                          style: TextStyle(
                                                            fontSize:
                                                                getAdaptiveTextSize(
                                                                    context,
                                                                    14),
                                                            fontWeight:
                                                                FontWeight.bold,
                                                          ),
                                                        )
                                                      ],
                                                    )
                                                  ],
                                                ),
                                              ),
                                              Padding(
                                                padding:
                                                    const EdgeInsets.all(10.0),
                                                child: Row(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment
                                                          .spaceBetween,
                                                  children: [
                                                    Text(
                                                      "Total:",
                                                      style: TextStyle(
                                                        fontSize:
                                                            getAdaptiveTextSize(
                                                                context, 16),
                                                        fontWeight:
                                                            FontWeight.bold,
                                                      ),
                                                    ),
                                                    Text(
                                                      inrFormat.format(
                                                          double.parse(snapshot
                                                              .data
                                                              .toString())),
                                                      style: TextStyle(
                                                        fontSize:
                                                            getAdaptiveTextSize(
                                                                context, 16),
                                                        fontWeight:
                                                            FontWeight.bold,
                                                      ),
                                                    )
                                                  ],
                                                ),
                                              ),
                                              Card(
                                                elevation: 2,
                                                shadowColor: Colors.black,
                                                color: Colors.white,
                                                child: SizedBox(
                                                    width: width * 0.90,
                                                    // height: height * 0.050,
                                                    child: Padding(
                                                      padding:
                                                          const EdgeInsets.all(
                                                              5.0),
                                                      child: Column(
                                                        children: [
                                                          Text(
                                                            "Payment Method",
                                                            style: TextStyle(
                                                                fontSize:
                                                                    getAdaptiveTextSize(
                                                                        context,
                                                                        18),
                                                                fontWeight:
                                                                    FontWeight
                                                                        .bold),
                                                          ),
                                                          Text(
                                                              "Please choose the one that suits you best."),
                                                          Padding(
                                                            padding: EdgeInsets
                                                                .only(
                                                                    top: height *
                                                                        0.015,
                                                                    bottom:
                                                                        height *
                                                                            0.015),
                                                            child: Row(
                                                              mainAxisAlignment:
                                                                  MainAxisAlignment
                                                                      .spaceAround,
                                                              children: [
                                                                PaymentButtonWidget(
                                                                    iconData: Icons
                                                                        .money,
                                                                    buttonText:
                                                                        cashButtonText,
                                                                    onPressed:
                                                                        () async {
                                                                      if (await getDeviceModel() ==
                                                                          "P3000") {
                                                                        printRecieptP300(
                                                                            "CASH");
                                                                      } else {
                                                                        // Navigator.pop(
                                                                        //     context);
                                                                        printReciept(
                                                                            "CASH");
                                                                      }
                                                                    }),
                                                                PaymentButtonWidget(
                                                                    iconData: Icons
                                                                        .qr_code,
                                                                    buttonText:
                                                                        upiQrCodeButtonText,
                                                                    onPressed:
                                                                        () {
                                                                      showQr();
                                                                    }),
                                                                FutureBuilder<
                                                                    String>(
                                                                  future:
                                                                      getDeviceModel(), // Call your async function here
                                                                  builder: (context,
                                                                      snapshot) {
                                                                    if (snapshot
                                                                            .connectionState ==
                                                                        ConnectionState
                                                                            .waiting) {
                                                                      return Container(); // Show a loading spinner while waiting
                                                                    } else if (snapshot
                                                                        .hasError) {
                                                                      return Container();
                                                                    } else if (snapshot
                                                                        .hasData) {
                                                                      String
                                                                          deviceModel =
                                                                          snapshot.data ??
                                                                              "Unknown Device";
                                                                      if (deviceModel ==
                                                                          "P3000") {
                                                                        return PaymentButtonWidget(
                                                                            iconData: Icons
                                                                                .credit_card,
                                                                            buttonText:
                                                                                cardButtonText,
                                                                            onPressed:
                                                                                () {
                                                                              payCard();
                                                                            });
                                                                      }
                                                                    }

                                                                    return Container();
                                                                  },
                                                                ),
                                                              ],
                                                            ),
                                                          )
                                                        ],
                                                      ),
                                                    )),
                                              )
                                            ],
                                          ),
                                        ),
                                      );
                                    });
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.blue, // background
                                foregroundColor: Colors.black, // foreground
                                shape: RoundedRectangleBorder(
                                  borderRadius:
                                      BorderRadius.circular(6), // <-- Radius
                                ),
                              ),
                              child: SizedBox(
                                height: height * 0.060,
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Icon(
                                      Icons.print,
                                      color: Colors.black,
                                    ),
                                    Text(
                                      "Print",
                                      style: TextStyle(
                                        fontSize:
                                            getAdaptiveTextSize(context, 13),
                                        fontWeight: FontWeight.bold,
                                      ),
                                    )
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }
          }
          return Container();
        });
  }
}

import 'dart:convert';
import 'dart:typed_data';

import 'package:cash_register/helper/printHelper.dart';
import 'package:cash_register/helper/product.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_esc_pos_utils/flutter_esc_pos_utils.dart';
import 'package:intl/intl.dart';
import 'package:lottie/lottie.dart';
import 'package:math_expressions/math_expressions.dart';
import 'package:print_bluetooth_thermal/print_bluetooth_thermal.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:widgets_to_image/widgets_to_image.dart';
import 'package:image/image.dart' as img;
// import 'package:image/image.dart';
import 'dart:typed_data';

import 'products.dart';

class Cartsummary extends StatefulWidget {
  List<CartProduct> cartProducts;
  Cartsummary({super.key, required this.cartProducts});

  @override
  State<Cartsummary> createState() => _CartsummaryState();
}

class _CartsummaryState extends State<Cartsummary> {
  var size, width, height;

  getadaptiveTextSize(BuildContext context, dynamic value) {
    return (value / 710) * MediaQuery.of(context).size.height;
  }

  WidgetsToImageController widgetsToImageController =
      WidgetsToImageController();
  // to save image bytes of widget
  Uint8List? bytes;
  Uint8List? imgBytes;
  String _info = "";
  String _msj = '';

  bool connected = false;
  String _selectSize = "2";
  final _txtText = TextEditingController(text: "Hello developer");
  bool _progress = false;
  String _msjprogress = "";
  var conDeviceMac = '', conDeviceName = '';

  String optionprinttype = "58 mm";
  List<String> options = ["58 mm", "80 mm"];
  final TextEditingController priceEditContoller = TextEditingController();
  Parser p = Parser();
  late Printhelper printhelper = Printhelper();

  @override
  void initState() {
    super.initState();
    getCartProducts();
  }

  List<CartProduct> cartProductsList = [];

  getCartProducts() {
    cartProductsList = widget.cartProducts;
  }

  printThermalReciept() {}

  Future<List<CartProduct>> productList() async {
    await Future.delayed(Duration.zero);
    var products = cartProductsList;
    return products;
  }

  final inrFormat = NumberFormat.currency(
    locale: 'hi_IN',
    name: 'INR',
    symbol: '₹',
    decimalDigits: 2,
  );

  increasQT00Y(index) {
    cartProductsList[index].countNumber++;
    setState(() {});
  }

  decreasQTY(index) {
    if (cartProductsList[index].countNumber > 1) {
      cartProductsList[index].countNumber--;
    } else if (cartProductsList[index].countNumber == 1) {
      cartProductsList.removeAt(index);
    }
    setState(() {});
  }

  Future<bool> _onWillPopDialouge() async {
    return false;
  }

  changeAmount(index) {
    priceEditContoller.text = cartProductsList[index].price;
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
                Container(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      TextButton(
                          onPressed: () {
                            Navigator.pop(context);
                          },
                          child: Icon(
                            Icons.close,
                            size: getadaptiveTextSize(context, 20),
                          ))
                    ],
                  ),
                ),
                Padding(
                  padding:
                      const EdgeInsets.symmetric(vertical: 10, horizontal: 20),
                  child: TextFormField(
                    style: const TextStyle(fontSize: 20),
                    // controller: priceEditContoller,
                    decoration: InputDecoration(
                      prefixIcon: Icon(Icons.money, color: Colors.black54),
                      hintText: 'Product Price',
                      hintStyle:
                          const TextStyle(color: Colors.black45, fontSize: 18),
                      enabledBorder: OutlineInputBorder(
                        borderSide: BorderSide.none,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      border: InputBorder.none,
                      focusedBorder: OutlineInputBorder(
                        borderSide:
                            const BorderSide(color: Colors.blue, width: 2),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      filled: true,
                      fillColor: const Color(0xFFedf0f8),
                      contentPadding: const EdgeInsets.symmetric(
                        vertical: 15,
                        horizontal: 20,
                      ),
                    ),
                    keyboardType: TextInputType.number,
                    // obscureText: _obscureText,
                    // autovalidateMode: AutovalidateMode.onUserInteraction,
                  ),
                ),
                ElevatedButton(
                    onPressed: () {
                      cartProductsList[index].price =
                          priceEditContoller.text.toString();

                      Navigator.pop(context);
                    },
                    child: Text("Update"))
              ],
            ),
          ),
          actions: [],
        ),
      ),
    );
  }

  String calculate(var count, var price) {
    var evalString = count.toString();
    evalString += "*";
    evalString += price;
    Expression exp = p.parse(evalString);
    ContextModel cm = ContextModel();

    return '${exp.evaluate(EvaluationType.REAL, cm)}';
  }

  @override
  Widget build(BuildContext context) {
    print(widget.cartProducts[0].productName);
    size = MediaQuery.of(context).size;
    width = size.width;
    height = size.height;
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Cart Summary',
          style: TextStyle(color: Colors.white, fontFamily: 'Becham'),
        ),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(
              Icons.print,
              color: Colors.white,
            ),
            tooltip: 'Sync',
            onPressed: () {
              // handle the press
              // Workmanager().initialize(
              //   callbackDispatcher,
              //   isInDebugMode: true,
              // );
              // syncTask();
              // syncTransaction();
              printhelper.printProductReciept(
                  "CASH", printhelper.sourceProduct, cartProductsList);
            },
          ),
        ],
      ),
      // floatingActionButton: Padding(
      //   padding: EdgeInsets.only(bottom: height * 0.065),
      //   child: Container(
      //     decoration: BoxDecoration(borderRadius: BorderRadius.circular(50)),
      //     height: 80,
      //     width: 80,
      //     child: FloatingActionButton(
      //       isExtended: true,
      //       backgroundColor: Colors.blueAccent,
      //       onPressed: () async {

      //       },
      //       child: Center(
      //         child: Column(
      //           mainAxisAlignment: MainAxisAlignment.center,
      //           crossAxisAlignment: CrossAxisAlignment.center,
      //           children: [
      //             Stack(
      //               children: [
      //                 Icon(
      //                   Icons.add,
      //                   size: getadaptiveTextSize(context, 50),
      //                   color: Colors.white,
      //                 ),
      //               ],
      //             ),
      //           ],
      //         ),
      //       ),
      //     ),
      //   ),
      // ),
      body: Container(
        child: FutureBuilder<List>(
            future: productList(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return Center(
                  child: CircularProgressIndicator(),
                  // child: null,
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
                      var product = snapshot.data![index];
                      // print(transaction.time);
                      // return ListTile(
                      //   title: Text(product.),
                      //   subtitle: Text('${transaction.date} - ${transaction.time}'),
                      //   trailing: Text(transaction.amount),
                      // );
                      return Card(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        elevation: 4,
                        child: Container(
                          padding: EdgeInsets.only(left: 10, right: 10),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              ClipRRect(
                                borderRadius: const BorderRadius.horizontal(
                                  left: Radius.circular(16),
                                ),
                                child: Image.memory(
                                  Base64Decoder().convert(product.image),
                                  width: width * 0.15,
                                  height: width * 0.15,
                                  fit: BoxFit.fill,
                                ),

                                // Image.network(
                                //   'https://mhtwyat.',
                                //   width: 100,
                                //   height: 100,
                                //   fit: BoxFit.cover,
                                // ),
                              ),
                              Container(
                                width: width * 0.40,
                                // color: Colors.amber,
                                padding: const EdgeInsets.all(16),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      product.productName,
                                      style: const TextStyle(
                                          fontSize: 15,
                                          fontWeight: FontWeight.bold),
                                    ),
                                    const SizedBox(height: 4),
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text(
                                          '${inrFormat.format(double.parse(product.price))}',
                                          style: TextStyle(fontSize: 16),
                                        ),
                                        Container(
                                          width: 30,
                                          height: 30,
                                          child: Center(
                                            child: IconButton(
                                              onPressed: () {
                                                changeAmount(index);
                                              },
                                              style: ElevatedButton.styleFrom(
                                                backgroundColor: Colors.blue,
                                                shape: RoundedRectangleBorder(
                                                  borderRadius:
                                                      BorderRadius.circular(6),
                                                ),
                                              ),
                                              icon: Icon(
                                                Icons.mode_edit_outline,
                                                color: Colors.black,
                                                size: getadaptiveTextSize(
                                                    context, 15),
                                              ),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                              Container(
                                width: width * 0.28,
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    // Text(
                                    //   "QTY",
                                    //   style: const TextStyle(
                                    //       fontSize: 12,
                                    //       fontWeight: FontWeight.bold),
                                    // ),
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.center,
                                      children: [
                                        Container(
                                          width: 35,
                                          height: 35,
                                          child: Center(
                                            child: IconButton(
                                              onPressed: () {
                                                decreasQTY(index);
                                              },
                                              style: ElevatedButton.styleFrom(
                                                backgroundColor: Colors.blue,
                                                shape: RoundedRectangleBorder(
                                                  borderRadius:
                                                      BorderRadius.circular(6),
                                                ),
                                              ),
                                              icon: Icon(
                                                Icons.remove,
                                                color: Colors.black,
                                                size: getadaptiveTextSize(
                                                    context, 18),
                                              ),
                                            ),
                                          ),
                                        ),
                                        Text(
                                          '${product.countNumber}',
                                          style: const TextStyle(
                                              fontSize: 18,
                                              fontWeight: FontWeight.bold),
                                        ),
                                        Container(
                                          width: 35,
                                          height: 35,
                                          child: Center(
                                            child: IconButton(
                                              onPressed: () {
                                                increasQT00Y(index);
                                              },
                                              style: ElevatedButton.styleFrom(
                                                backgroundColor: Colors.blue,
                                                shape: RoundedRectangleBorder(
                                                  borderRadius:
                                                      BorderRadius.circular(6),
                                                ),
                                              ),
                                              icon: Icon(
                                                Icons.add,
                                                color: Colors.black,
                                                size: getadaptiveTextSize(
                                                    context, 18),
                                              ),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                    Container(
                                      child: Text(
                                        '${inrFormat.format(double.parse(calculate(product.countNumber, product.price)))}',
                                        // ' ${calculate(product.countNumber, product.price)}'
                                      ),
                                    )
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    });
              } else if (!snapshot.hasData) {
                return Center(
                  child: Text("No products"),
                );
              } else {
                return Text('No product data'); // Handle empty data case
              }
            }),
      ),
    );
  }

  // Widget cardWidget() {
  //   return Card(
  //     shape: RoundedRectangleBorder(
  //       borderRadius: BorderRadius.circular(16),
  //     ),
  //     elevation: 4,
  //     child: Row(
  //       crossAxisAlignment: CrossAxisAlignment.start,
  //       children: [
  //         ClipRRect(
  //           borderRadius: const BorderRadius.horizontal(
  //             left: Radius.circular(16),
  //           ),
  //           child: Image.network(
  //             'https://mhtwyat.com/wp-content/uploads/2022/02/%D8%A7%D8%AC%D9%85%D9%84-%D8%A7%D9%84%D8%B5%D9%88%D8%B1-%D8%B9%D9%86-%D8%A7%D9%84%D8%B1%D8%B3%D9%88%D9%84-%D8%B5%D9%84%D9%89-%D8%A7%D9%84%D9%84%D9%87-%D8%B9%D9%84%D9%8A%D9%87-%D9%88%D8%B3%D9%84%D9%85-1-1.jpg',
  //             width: 100,
  //             height: 100,
  //             fit: BoxFit.cover,
  //           ),
  //         ),
  //         Container(
  //           padding: const EdgeInsets.all(16),
  //           child: const Column(
  //             crossAxisAlignment: CrossAxisAlignment.start,
  //             children: [
  //               Text(
  //                 "Title",
  //                 style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
  //               ),
  //               SizedBox(height: 4),
  //               Text(
  //                 "Description",
  //                 style: TextStyle(fontSize: 16),
  //               ),
  //             ],
  //           ),
  //         )
  //       ],
  //     ),
  //   );
  // }
}

import 'dart:typed_data';

import 'package:cash_register/Widgets/all_dialog.dart';
import 'package:cash_register/Widgets/cart_item_widget.dart';
import 'package:cash_register/common_utils/common_functions.dart';
import 'package:cash_register/db/sqfLite_db_service.dart';
import 'package:cash_register/helper/printe_helper.dart';
import 'package:cash_register/helper/product.dart';
import 'package:cash_register/helper/stream_helper.dart';
import 'package:cash_register/main.dart';
import 'package:cash_register/model/cart_item.dart';
import 'package:cash_register/modules/cart_summary_module/product_final_amount_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:math_expressions/math_expressions.dart';
import 'package:widgets_to_image/widgets_to_image.dart';
// import 'package:image/image.dart';

class Cartsummary extends StatefulWidget {
  Cartsummary({
    super.key,
  });

  @override
  State<Cartsummary> createState() => _CartsummaryState();
}

class _CartsummaryState extends State<Cartsummary> {
  var size, width, height;

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
  List<CartProduct> cartProducts = [];
  final dbs = DatabaseService.instance;
  @override
  void initState() {
    final dbs = DatabaseService.instance;
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) async {
      // StreamHelper.initCartCountStreamController();
      StreamHelper.cartFinalAmounSink.add(await dbs.getCartTotal());
    });
    super.initState();
  }

  Future<bool> _onWillPopDialouge() async {
    return false;
  }

  changeAmount(index) {
    showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (context) => WillPopScope(
        onWillPop: _onWillPopDialouge,
        child: AlertDialog(
          // title: const Text('Timer Finished'),
          content: Container(
            height: height * 0.35,
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
                            size: getAdaptiveTextSize(context, 20),
                          ))
                    ],
                  ),
                ),
                Padding(
                  padding:
                      const EdgeInsets.symmetric(vertical: 10, horizontal: 20),
                  child: TextFormField(
                    style: const TextStyle(fontSize: 20),
                    controller: priceEditContoller,
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
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Price Should not be empty!';
                      }
                      if (value.length < 6) {
                        return 'Please enter valid price';
                      }

                      return null;
                    },
                    // obscureText: _obscureText,
                    // autovalidateMode: AutovalidateMode.onUserInteraction,
                  ),
                ),
                ElevatedButton(
                    onPressed: () {
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

  printReciept(String method) async {
    printhelper
        .printProductReciept("CASH", printhelper.sourceProduct)
        .then((_) async {
      saveTransactionSqlite(
          method, await dbs.getCartTotal(), printhelper.sourceProduct, true);
      // deleteAllProducts(context, true, false);
      // showSuccessfulPaymentDialog(context, amount, isFromProductsScreen, isFromQrCode)
    });
  }

  @override
  Widget build(BuildContext context) {
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
              Icons.delete,
              color: Colors.white,
            ),
            tooltip: 'Delete all',
            onPressed: () {
              deleteAllProducts(context);
              // handle the press
              // Workmanager().initialize(
              //   callbackDispatcher,
              //   isInDebugMode: true,
              // );
              // syncTask();
              // syncTransaction();
              // printhelper.printProductReciept(
              //     "CASH", printhelper.sourceProduct, cartProductsList);
            },
          ),
          // IconButton(
          //   icon: const Icon(
          //     Icons.print,
          //     color: Colors.white,
          //   ),
          //   tooltip: 'Print',
          //   onPressed: () {
          //     printhelper
          //         .printProductReciept("CASH", printhelper.sourceProduct)
          //         .then((_) async {
          //       deleteAllProducts(context, true);
          //     });
          //   },
          // ),
        ],
      ),
      bottomSheet: Container(
        height: height * 0.09,
        color: const Color.fromARGB(255, 196, 220, 244),
        child: Row(
          children: [
            ProductFinalAmountWidget(),
          ],
        ),
      ),
      body: Padding(
        padding: EdgeInsets.only(bottom: height * 0.09),
        child: FutureBuilder<List<CartItem>>(
          future: getCartProducts(),
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
                      fontSize: getAdaptiveTextSize(context, 20)),
                ),
              ); // Handle error
            } else if (snapshot.hasData) {
              return ListView.builder(
                  itemCount: snapshot.data!.length,
                  itemBuilder: (context, index) {
                    var product = snapshot.data![index];

                    return CartItemWidget(
                      cartItem: product,
                      productId: product.productId,
                    );
                  });
            } else if (!snapshot.hasData) {
              return Center(
                child: Text("No products"),
              );
            } else {
              return Text('No product data'); // Handle empty data case
            }
          },
        ),
      ),
    );
  }
}

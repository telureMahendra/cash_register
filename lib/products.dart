import 'dart:convert';
import 'dart:io';

import 'package:cash_register/addProduct.dart';
import 'package:cash_register/helper/helper.dart';
import 'package:cash_register/helper/product.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:lottie/lottie.dart';
import 'package:http/http.dart' as http;
import 'package:math_expressions/math_expressions.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ProductsList extends StatefulWidget {
  const ProductsList({super.key});

  @override
  State<ProductsList> createState() => _ProductsListState();
}

class _ProductsListState extends State<ProductsList> {
  var size, width, height;

  final TextEditingController searchController = TextEditingController();

  List<ProductDetails> _productList = [];
  List<ProductDetails> _productListSearched = [];

  List<CartProduct> _cartProducts = [];

  bool _isLoading = true;

  var channel = MethodChannel("printMethod");

  Parser p = Parser();

  String calculate(amount) {
    Expression exp = p.parse(amount);
    ContextModel cm = ContextModel();
    return '${exp.evaluate(EvaluationType.REAL, cm)}';
  }

  printReciept() async {
    final prefs = await SharedPreferences.getInstance();
    var amount = '';
    String productString = '';

    for (CartProduct product in _cartProducts) {
      amount += '+${product.price}*${product.countNumber}';
      productString += '${product.productName}.';
      productString += '${product.countNumber}.';
      productString += '${inrFormat.format(double.parse(product.price))}"';
    }

    amount = calculate(amount);

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
      "items": productString
    });

    _cartProducts.removeRange(0, _cartProducts.length);

    for (ProductDetails p in _productListSearched) {
      var index = _productListSearched.indexOf(p);
      _productListSearched[index].isSelected = false;
      _productListSearched[index].countNumber = 0;
    }
    setState(() {});
  }

  @override
  void initState() {
    super.initState();
    _fetchProducts();
  }

  final inrFormat = NumberFormat.currency(
    locale: 'hi_IN',
    name: 'INR',
    symbol: '₹',
    decimalDigits: 2,
  );
// inrFormat.format(double.parse(total))
  getadaptiveTextSize(BuildContext context, dynamic value) {
    return (value / 710) * MediaQuery.of(context).size.height;
  }

  Future<void> _fetchProducts() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      print(prefs.getInt('userId'));
      final response = await http.get(
        Uri.parse('$BASE_URL/product'),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
          'userId': '${prefs.getInt('userId')}'
        },
      );

      if (response.statusCode == 200) {
        print("response 200");
        setState(() {
          _productList = ProductDetails.fromJsonList(jsonDecode(response.body));
          _productListSearched =
              ProductDetails.fromJsonList(jsonDecode(response.body));
          _isLoading = false;
          print(_productListSearched[1].toString());
        });
      } else {
        print('error in status code ${response.body.toString()}');
        setState(() {
          _isLoading = false;
        });
      }
    } on SocketException catch (e) {
      print("SocketException error $e");
    } catch (e) {
      print("error in catch $e");
      setState(() {
        _isLoading = false;
      });
    }
  }

  int findProductIndexById(int productId) {
    for (int i = 0; i < _cartProducts.length; i++) {
      if (_cartProducts[i].id == productId) {
        return i;
      }
    }

    return -1;
  }

  removeProductFromCart(productId) {
    if (findProductIndexById(productId) >= 0) {
      _cartProducts.removeAt(findProductIndexById(productId));
    }
    setState(() {});
  }

  addProductInCart(ProductDetails product) {
    if (findProductIndexById(product.id) >= 0) {
      print("Product fount");
      _cartProducts[findProductIndexById(product.id)].countNumber =
          product.countNumber;
    } else {
      print("Product fount");

      _cartProducts.add(CartProduct(
        id: product.id,
        productName: product.productName,
        countNumber: product.countNumber,
        image: product.image,
        price: product.price,
      ));
    }
  }

  searchProduct(String value) async {
    _productListSearched = await _productList
        .where((product) =>
            product.productName.toLowerCase().contains(value.toString()))
        .toList();
  }

  nonSelectWarning() {
    showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        // insetPadding: EdgeInsets.only(bottom: 20),
        content: Container(
            padding: EdgeInsets.only(bottom: 0),
            height: height * 0.225,
            width: width * 0.70,
            // color: Colors.amber,
            child: Column(
              children: [
                Padding(
                  padding: EdgeInsets.all(0),
                  child: Lottie.asset('assets/animations/warning.json',
                      height: height * 0.10,
                      // controller: _controller,
                      repeat: true,
                      animate: true),
                ),
                Container(
                    padding: EdgeInsets.only(bottom: height * 0.020, top: 0),
                    // color: Colors.blue,
                    child: Center(
                      child: Column(
                        children: [
                          Text(
                            'Please Select Product',
                            softWrap: true,
                            style: TextStyle(
                              color: Colors.red,
                              fontWeight: FontWeight.w700,
                              fontSize: getadaptiveTextSize(context, 15),
                            ),
                          ),
                        ],
                      ),
                    )),
                Container(
                  padding: EdgeInsets.only(top: height * 0.02),
                  width: width * 0.59,
                  height: height * 0.07,
                  child: OutlinedButton(
                    style: TextButton.styleFrom(),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.home_outlined,
                          size: getadaptiveTextSize(context, 19),
                          color: const Color.fromARGB(255, 58, 104, 125),
                        ),
                        Text(
                          'Back To Products',
                          style: TextStyle(
                              color: Colors.black,
                              fontSize: getadaptiveTextSize(context, 15)),
                        ),
                      ],
                    ),
                    onPressed: () {
                      Navigator.pop(context);
                      setState(() {});
                    },
                  ),
                ),
              ],
            )),
        actions: [],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    size = MediaQuery.of(context).size;
    width = size.width;
    height = size.height;
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Checkout',
          style: TextStyle(color: Colors.white, fontFamily: 'Becham'),
        ),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(
              Icons.add_shopping_cart,
              color: Colors.white,
            ),
            tooltip: 'Add Product',
            onPressed: () {
              Navigator.push(context, MaterialPageRoute(
                builder: (context) {
                  return Addproduct();
                },
              ));
            },
          ),
        ],
      ),
      // floatingActionButtonLocation: FloatingActionButtonLocation.endTop,
      floatingActionButton: Padding(
        padding: EdgeInsets.only(bottom: height * 0.065),
        child: Container(
          decoration: BoxDecoration(borderRadius: BorderRadius.circular(50)),
          height: 80,
          width: 80,
          child: FloatingActionButton(
            isExtended: true,
            backgroundColor: Colors.blueAccent,
            onPressed: () {
              if (_cartProducts.isEmpty) {
                nonSelectWarning();
              } else {
                printReciept();
              }
            },
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Stack(children: [
                    Icon(
                      Icons.shopping_cart,
                      size: getadaptiveTextSize(context, 50),
                      color: Colors.white,
                    ),
                    Container(
                      padding: EdgeInsets.only(bottom: 20),
                      height: 70,
                      width: 70,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Text(
                            '${_cartProducts.length}',
                            style: TextStyle(
                                fontSize: getadaptiveTextSize(context, 20),
                                color: Colors.red,
                                fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                    ),
                  ]),
                ],
              ),
            ),
          ),
        ),
      ),
      body: Center(
          child: Container(
        height: height * 0.90,
        child: Column(children: [
          Card(
            elevation: 5,
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Container(
                // height: height * 0.05,
                width: width * 0.90,
                // padding: EdgeInsets.only(right: 20),
                child: Column(
                  // mainAxisAlignment: MainAxisAlignment.start,
                  // crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Container(
                          width: width * 0.90,
                          child: Padding(
                            padding: const EdgeInsets.symmetric(
                                vertical: 10, horizontal: 20),
                            child: TextFormField(
                              // onChanged: searchData(),
                              onChanged: (text) {
                                searchProduct(text);
                                setState(() {});
                              },
                              style: const TextStyle(fontSize: 20),
                              controller: searchController,
                              decoration: InputDecoration(
                                prefixIcon:
                                    Icon(Icons.search, color: Colors.black54),
                                hintText: 'Search Product',
                                hintStyle: const TextStyle(
                                    color: Colors.black45, fontSize: 18),
                                enabledBorder: OutlineInputBorder(
                                  borderSide: BorderSide.none,
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                border: InputBorder.none,
                                focusedBorder: OutlineInputBorder(
                                  borderSide: const BorderSide(
                                      color: Colors.blue, width: 2),
                                  borderRadius: BorderRadius.circular(15),
                                ),
                                filled: true,
                                fillColor: const Color(0xFFedf0f8),
                                contentPadding: const EdgeInsets.symmetric(
                                  vertical: 15,
                                  horizontal: 20,
                                ),
                              ),
                              keyboardType: TextInputType.text,
                              autovalidateMode:
                                  AutovalidateMode.onUserInteraction,
                              validator: (value) {
                                // setState(() {});
                                return null;
                              },
                            ),
                          ),
                          // Text(
                          //   'Total Amount ',
                          //   style: TextStyle(
                          //     fontWeight: FontWeight.bold,
                          //     fontSize: getadaptiveTextSize(context, 18),
                          //   ),
                          // ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
          Container(
            child: Expanded(
              child: _isLoading
                  ? Center(child: Lottie.asset('assets/animations/loader.json'))
                  : RefreshIndicator(
                      onRefresh: () => _fetchProducts(),
                      // strokeWidth: 10,

                      backgroundColor: Colors.white,

                      // onRefresh: () {
                      //   setState(() {
                      //     _productList;
                      //   });
                      // },
                      child: _productListSearched.isEmpty
                          ? RefreshIndicator(
                              onRefresh: () => _fetchProducts(),
                              child: Text("NO products Found!"))
                          : GridView.builder(
                              gridDelegate:
                                  SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: 3,
                                // mainAxisExtent: ,
                                // mainAxisExtent: height * 0.18,
                                crossAxisSpacing: 10,
                                mainAxisSpacing: 0.1,
                              ),
                              itemCount: _productListSearched.length,
                              itemBuilder: (context, index) {
                                return Padding(
                                  padding: const EdgeInsets.all(10),
                                  child: InkWell(
                                    onLongPress: () {
                                      _productListSearched[index].countNumber =
                                          0;

                                      _productListSearched[index].isSelected =
                                          false;

                                      removeProductFromCart(
                                          _productListSearched[index].id);

                                      setState(() {});
                                    },
                                    onTap: () {
                                      _productListSearched[index].countNumber++;

                                      _productListSearched[index].isSelected =
                                          true;

                                      // _cartProducts.add(CartProduct(
                                      //   id: _productListSearched[index].id,
                                      //   productName: _productListSearched[index]
                                      //       .productName,
                                      //   countNumber: _productListSearched[index]
                                      //       .countNumber,
                                      //   price:
                                      //       _productListSearched[index].price,
                                      // ));

                                      addProductInCart(
                                          _productListSearched[index]);

                                      // print(_cartProducts[1].toString());

                                      setState(() {});
                                    },
                                    child: Container(
                                      // height: height * 0.50,

                                      decoration: BoxDecoration(
                                          color: const Color.fromARGB(
                                              255, 255, 255, 255),
                                          borderRadius:
                                              BorderRadius.circular(10),
                                          border: Border.all(width: 1)),
                                      child: Center(
                                        child: Stack(
                                          children: [
                                            Container(
                                              child: Center(
                                                  // child: Image.memory(
                                                  //   Base64Decoder().convert(
                                                  //       _productList[index].image),
                                                  //   fit: BoxFit.fill,
                                                  // ),
                                                  child: ClipRRect(
                                                borderRadius:
                                                    BorderRadius.circular(
                                                        10), // Image border
                                                child: SizedBox.fromSize(
                                                  child: Image.memory(
                                                    Base64Decoder().convert(
                                                        _productListSearched[
                                                                index]
                                                            .image),
                                                    fit: BoxFit.fill,
                                                  ),
                                                ),
                                              )),
                                            ),
                                            Container(
                                              width: double.infinity,
                                              // color: Colors.transparent,
                                              child: Column(
                                                mainAxisAlignment:
                                                    MainAxisAlignment.end,
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.center,
                                                children: [
                                                  Container(
                                                    decoration: BoxDecoration(
                                                      color:
                                                          const Color.fromARGB(
                                                                  255,
                                                                  216,
                                                                  215,
                                                                  215)
                                                              .withOpacity(0.7),
                                                      // color: containerColor,
                                                      borderRadius:
                                                          BorderRadius.only(
                                                              bottomLeft: Radius
                                                                  .circular(10),
                                                              bottomRight:
                                                                  Radius
                                                                      .circular(
                                                                          10)),
                                                    ),
                                                    child: Column(
                                                      children: [
                                                        Container(
                                                          width:
                                                              double.infinity,
                                                          child: Center(
                                                            child: Text(
                                                              _productListSearched[
                                                                      index]
                                                                  .productName,
                                                              textAlign:
                                                                  TextAlign
                                                                      .center,
                                                              style: TextStyle(
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .bold,
                                                                  color: Colors
                                                                      .black,
                                                                  fontSize:
                                                                      getadaptiveTextSize(
                                                                          context,
                                                                          10)),
                                                            ),
                                                          ),
                                                        ),
                                                        Container(
                                                          width:
                                                              double.infinity,
                                                          child: Center(
                                                            child: Text(
                                                              inrFormat.format(
                                                                  double.parse(
                                                                      _productListSearched[
                                                                              index]
                                                                          .price)),
                                                              // _productList[index].price,
                                                              textAlign:
                                                                  TextAlign
                                                                      .center,
                                                              style: TextStyle(
                                                                fontWeight:
                                                                    FontWeight
                                                                        .bold,
                                                                color: Colors
                                                                    .black,
                                                              ),
                                                            ),
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                            _productListSearched[index]
                                                        .isSelected ==
                                                    false
                                                ? Container()
                                                : Container(
                                                    color: const Color.fromARGB(
                                                            255, 216, 215, 215)
                                                        .withOpacity(0.7),
                                                    child: Center(
                                                      child: Text(
                                                        '${_productListSearched[index].countNumber}',
                                                        style: TextStyle(
                                                            fontSize:
                                                                getadaptiveTextSize(
                                                                    context,
                                                                    25)),
                                                      ),
                                                    ),
                                                  )
                                          ],
                                        ),
                                      ),
                                    ),
                                  ),
                                );
                              },
                            ),
                    ),
            ),
          ),
        ]),
      )),
    );
  }
}

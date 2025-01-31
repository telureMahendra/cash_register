import 'dart:convert';
import 'dart:io';

import 'package:add_to_cart_animation/add_to_cart_animation.dart';
import 'package:cash_register/addProduct.dart';
import 'package:cash_register/helper/helper.dart';
import 'package:cash_register/helper/product.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:lottie/lottie.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

class ProductMaster extends StatefulWidget {
  const ProductMaster({super.key});

  @override
  State<ProductMaster> createState() => _ProductMasterState();
}

class _ProductMasterState extends State<ProductMaster> {
  var size, width, height;
  final TextEditingController searchController = TextEditingController();
  List<ProductDetails> _productList = [];
  List<ProductDetails> _productListSearched = [];

  List<CartProduct> cartProducts = [];

  bool _isLoading = true;
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
      ).timeout(
        const Duration(seconds: 5),
        onTimeout: () {
          return http.Response('Error', 408);
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
        print(response.body);
        print('error in status code: ${response.body.toString()}');
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
    for (int i = 0; i < cartProducts.length; i++) {
      if (cartProducts[i].id == productId) {
        return i;
      }
    }

    return -1;
  }

  searchProduct(String value) async {
    _productListSearched = await _productList
        .where((product) =>
            product.productName.toLowerCase().contains(value.toString()))
        .toList();
  }

  final inrFormat = NumberFormat.currency(
    locale: 'hi_IN',
    name: 'INR',
    symbol: '₹',
    decimalDigits: 2,
  );

  @override
  void initState() {
    super.initState();
    _fetchProducts();
  }

  @override
  Widget build(BuildContext context) {
    size = MediaQuery.of(context).size;
    width = size.width;
    height = size.height;
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Product Master',
          style: TextStyle(color: Colors.white, fontFamily: 'Becham'),
        ),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
        // actions: [
        //   IconButton(
        //     icon: const Icon(
        //       Icons.store_outlined,
        //       color: Colors.white,
        //     ),
        //     tooltip: 'Add Product',
        //     onPressed: () {
        //       Navigator.push(context, MaterialPageRoute(
        //         builder: (context) {
        //           return Addproduct();
        //         },
        //       ));
        //     },
        //   ),
        // ],
      ),
      // floatingActionButtonLocation: FloatingActionButtonLocation.endTop,
      floatingActionButton: Padding(
        padding: const EdgeInsets.all(20),
        child: Container(
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: Colors.blue,
          ),
          child: IconButton(
            icon: Icon(
              Icons.add,
              color: Colors.black,
              size: getadaptiveTextSize(context, 30),
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
        ),
      ),

      // body: ListView(
      //   shrinkWrap: true,
      //   children: [
      //     ListTile(
      //       title: Container(
      //         padding: EdgeInsets.all(15),
      //         child: Column(
      //           children: [
      //             Container(
      //                 alignment: Alignment.topLeft,
      //                 child: Row(
      //                   children: [
      //                     Icon(Icons.person_2),
      //                     Text(
      //                       "Name",
      //                       style: TextStyle(
      //                           fontSize: getadaptiveTextSize(context, 15),
      //                           fontWeight: FontWeight.bold),
      //                     ),
      //                   ],
      //                 )),
      //             Container(
      //               padding: EdgeInsets.only(left: width * 0.08),
      //               alignment: Alignment.topLeft,
      //               child: Text('1324'),
      //             )
      //           ],
      //         ),
      //       ),
      //       onTap: () {},
      //     ),
      //     ListTile(
      //       title: Container(
      //         padding: EdgeInsets.all(15),
      //         child: Column(
      //           children: [
      //             Container(
      //                 alignment: Alignment.topLeft,
      //                 child: Row(
      //                   children: [
      //                     Icon(Icons.mark_email_read),
      //                     Text(
      //                       "Email",
      //                       style: TextStyle(
      //                           fontSize: getadaptiveTextSize(context, 15),
      //                           fontWeight: FontWeight.bold),
      //                     ),
      //                   ],
      //                 )),
      //             Container(
      //               padding: EdgeInsets.only(left: width * 0.08),
      //               alignment: Alignment.topLeft,
      //               child: Text('asdfgh'),
      //             )
      //           ],
      //         ),
      //       ),
      //       onTap: () {},
      //     ),
      //     ListTile(
      //       title: Container(
      //         padding: EdgeInsets.all(15),
      //         child: Column(
      //           children: [
      //             Container(
      //                 alignment: Alignment.topLeft,
      //                 child: Row(
      //                   children: [
      //                     Icon(Icons.phone_android),
      //                     Text(
      //                       "Mobile",
      //                       style: TextStyle(
      //                           fontSize: getadaptiveTextSize(context, 15),
      //                           fontWeight: FontWeight.bold),
      //                     ),
      //                   ],
      //                 )),
      //             Container(
      //               padding: EdgeInsets.only(left: width * 0.08),
      //               alignment: Alignment.topLeft,
      //               child: Text('edfghl'),
      //             )
      //           ],
      //         ),
      //       ),
      //       onTap: () {},
      //     ),
      //   ],
      // ),

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
                  ? Center(
                      child: Container(
                          // height: 200,
                          child: Lottie.asset('assets/animations/loader.json',
                              height: 100)))
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
                          : ListView.builder(
                              itemCount: _productListSearched.length,
                              itemBuilder: (BuildContext context, int index) {
                                return ListTile(
                                  splashColor:
                                      const Color.fromARGB(255, 179, 172, 172),
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
                                          color: Colors.white,
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
                                              mainAxisAlignment:
                                                  MainAxisAlignment
                                                      .spaceBetween,
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
                                                              .image,
                                                        ),
                                                        height: 50,
                                                        fit: BoxFit.fill,
                                                      ),
                                                    ),
                                                  )),
                                                ),
                                                Container(
                                                  width: width * 0.30,
                                                  child: Column(
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment
                                                            .start,
                                                    children: [
                                                      Text(
                                                        _productListSearched[
                                                                index]
                                                            .productName,
                                                        style: TextStyle(
                                                            fontSize:
                                                                getadaptiveTextSize(
                                                                    context,
                                                                    15),
                                                            fontWeight:
                                                                FontWeight
                                                                    .bold),
                                                      ),
                                                      Text(
                                                        inrFormat.format(
                                                            double.parse(
                                                                _productListSearched[
                                                                        index]
                                                                    .price)),
                                                        style: TextStyle(
                                                          fontSize:
                                                              getadaptiveTextSize(
                                                                  context, 15),
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                                Container(
                                                  child: Row(
                                                    children: [
                                                      Text(
                                                        "500",
                                                        style: TextStyle(
                                                          fontSize:
                                                              getadaptiveTextSize(
                                                                  context, 12),
                                                        ),
                                                      ),
                                                      Text(
                                                        "gm",
                                                        style: TextStyle(
                                                          fontSize:
                                                              getadaptiveTextSize(
                                                                  context, 12),
                                                        ),
                                                      )
                                                    ],
                                                  ),
                                                ),
                                                Container(
                                                  child: Row(
                                                    mainAxisAlignment:
                                                        MainAxisAlignment
                                                            .spaceEvenly,
                                                    children: [
                                                      IconButton(
                                                        icon: Icon(
                                                          Icons.edit,
                                                          color: Colors.black,
                                                          size:
                                                              getadaptiveTextSize(
                                                                  context, 20),
                                                        ),
                                                        tooltip: 'Edit Product',
                                                        onPressed: () {
                                                          Navigator.push(
                                                              context,
                                                              MaterialPageRoute(
                                                            builder: (context) {
                                                              return Addproduct();
                                                            },
                                                          ));
                                                        },
                                                      ),
                                                      IconButton(
                                                        icon: Icon(
                                                          Icons.delete,
                                                          color: Colors.black,
                                                          size:
                                                              getadaptiveTextSize(
                                                                  context, 30),
                                                        ),
                                                        tooltip:
                                                            'Delete Product',
                                                        onPressed: () {
                                                          Navigator.push(
                                                              context,
                                                              MaterialPageRoute(
                                                            builder: (context) {
                                                              return Addproduct();
                                                            },
                                                          ));
                                                        },
                                                      ),
                                                    ],
                                                  ),
                                                )
                                              ],
                                            )),
                                      ],
                                    ),
                                  ),
                                  onTap: () {},
                                );
                              }),
                    ),
            ),
          ),
        ]),
      )),
    );
  }
}





// ListTile(
//             title: Container(
//               padding: EdgeInsets.all(15),
//               child: Column(
//                 children: [
//                   Container(
//                       alignment: Alignment.topLeft,
//                       child: Row(
//                         children: [
//                           Icon(Icons.phone_android),
//                           Text(
//                             "Mobile",
//                             style: TextStyle(
//                                 fontSize: getadaptiveTextSize(context, 15),
//                                 fontWeight: FontWeight.bold),
//                           ),
//                         ],
//                       )),
//                   Container(
//                     padding: EdgeInsets.only(left: width * 0.08),
//                     alignment: Alignment.topLeft,
//                     child: Text('edfghl'),
//                   )
//                 ],
//               ),
//             ),
//             onTap: () {},
//           );
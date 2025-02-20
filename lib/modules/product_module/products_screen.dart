import 'dart:convert';
import 'dart:io';

import 'package:cash_register/add_product.dart';
import 'package:cash_register/cart_summary.dart';
import 'package:cash_register/common_utils/common_functions.dart';
import 'package:cash_register/db/sqfLite_db_service.dart';

import 'package:cash_register/helper/helper.dart';
import 'package:cash_register/helper/product.dart';
import 'package:cash_register/helper/stream_helper.dart';
import 'package:cash_register/model/cart_item.dart';
import 'package:cash_register/model/environment.dart';
import 'package:cash_register/modules/product_module/widgets/cart_icon_widget.dart';
import 'package:cash_register/modules/product_module/widgets/product_widget.dart';
import 'package:cash_register/product_master.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:lottie/lottie.dart';
import 'package:http/http.dart' as http;
import 'package:math_expressions/math_expressions.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:add_to_cart_animation/add_to_cart_animation.dart';
import 'package:skeleton_text/skeleton_text.dart';

class ProductsList extends StatefulWidget {
  const ProductsList({super.key});

  @override
  State<ProductsList> createState() => ProductsListState();
}

class ProductsListState extends State<ProductsList> {
  var size, width, height;

  final dbs = DatabaseService.instance;

  final TextEditingController searchController = TextEditingController();

  final GlobalKey widgetKey = GlobalKey();
  GlobalKey<CartIconKey> cartKey = GlobalKey<CartIconKey>();
  late Function(GlobalKey) runAddToCartAnimation;
  late Function(GlobalKey) onClick;
  var _cartQuantityItems = 0;

  List<ProductDetails> _productList = [];
  List<ProductDetails> _productListSearched = [];

  List<CartProduct> cartProducts = [];

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

    List<CartItem> data = await getCartProducts();

    for (CartItem product in data) {
      amount += '+${product.price}*${product.countNumber}';
      productString += '${product.productName}.';
      productString += '${product.countNumber}.';
      productString += '${inrFormat.format(double.parse(product.price))}"';
      // var _price = _calculate(product.countNumber, product.price);
      // _total += '+$_price';
      // bytes += PostCode.text(
      //   text:
      //       '${product.productName}${_addSpace(21 - product.productName.length)}${product.countNumber}${_addSpace(21 - 4 - product.countNumber.toString().length - _price.length)}Rs. $_price',
      //   fontSize: FontSize.compressed,
      //   align: AlignPos.center,
      // );
    }

    // for (CartProduct product in cartProducts) {
    //   amount += '+${product.price}*${product.countNumber}';
    //   productString += '${product.productName}.';
    //   productString += '${product.countNumber}.';
    //   productString += '${inrFormat.format(double.parse(product.price))}"';
    // }

    amount = calculate(amount);

    var invProdCounter = prefs.getInt("invProdCounter") ?? 1;
    //   prefs.setInt("invProdCounter", invProdCounter++);

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
      "count": "123",
      "method": "upi"
    });

    prefs.setInt("invProdCounter", invProdCounter++);

    // cartProducts.removeRange(0, cartProducts.length);

    // for (ProductDetails p in _productListSearched) {
    //   var index = _productListSearched.indexOf(p);
    //   _productListSearched[index].isSelected = false;
    //   _productListSearched[index].countNumber = 0;
    // }
    // setState(() {});
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) async {
      StreamHelper.cartCountSink.add(await dbs.getCartCount());
    });
    _fetchProducts();
  }

  @override
  void dispose() {
    super.dispose();
  }

  Future<void> _fetchProducts() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      print(prefs.getInt('userId'));
      final response = await http.get(
        Uri.parse('${Environment.baseUrl}/product'),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
          'userId': '${prefs.getInt('userId')}',
          'itemCount': "88",
          'pageNumber': "0",
        },
      ).timeout(
        const Duration(seconds: 10),
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
        print(response.body.toString());
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
    for (int i = 0; i < cartProducts.length; i++) {
      if (cartProducts[i].id == productId) {
        return i;
      }
    }

    return -1;
  }

  removeProductFromCart(productId) {
    if (findProductIndexById(productId) >= 0) {
      cartProducts.removeAt(findProductIndexById(productId));
    }
    setState(() {});
  }

  addProductTocartSqlite(ProductDetails product) {
    dbs.addProductToCart(product.id, product.price, product.image,
        product.countNumber, product.measurementUnit, product.productName);
  }

  removeProductFromSqlite(int productId) {
    dbs.decreaseProductCount(productId);
  }

  addProductInCart(ProductDetails product) {
    if (findProductIndexById(product.id) >= 0) {
      print("Product fount");
      cartProducts[findProductIndexById(product.id)].countNumber =
          product.countNumber;
    } else {
      print("Product fount");

      cartProducts.add(CartProduct(
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
              Icons.store_outlined,
              color: Colors.white,
            ),
            tooltip: 'Product Master',
            onPressed: () {
              Navigator.push(context, MaterialPageRoute(
                builder: (context) {
                  return ProductMaster();
                },
              ));
            },
          ),
        ],
      ),
      floatingActionButton: CartIconWidget(),
      floatingActionButtonLocation: FloatingActionButtonLocation.endDocked,
      body: Center(
          child: SizedBox(
        height: height * 0.90,
        child: Column(children: [
          Card(
            elevation: 5,
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: SizedBox(
                // height: height * 0.05,
                width: width * 0.90,
                // padding: EdgeInsets.only(right: 20),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        SizedBox(
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
                                return null;
                              },
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
          Expanded(
            child: _isLoading
                ? buildSkeleton(context)
                : RefreshIndicator(
                    onRefresh: () => _fetchProducts(),
                    backgroundColor: Colors.white,
                    child: _productListSearched.isEmpty
                        ? RefreshIndicator(
                            onRefresh: () => _fetchProducts(),
                            child: Text("No products Found!"))
                        : GridView.builder(
                            gridDelegate:
                                SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: width < 500 ? 3 : 4,
                              crossAxisSpacing: 10,
                              mainAxisSpacing: 0.1,
                            ),
                            itemCount: _productListSearched.length,
                            itemBuilder: (context, index) {
                              return ProductWidget(
                                  product: _productListSearched[index]);
                            },
                          ),
                  ),
          ),
        ]),
      )),
    );
  }

  Widget buildSkeleton(BuildContext context) {
    return GridView.builder(
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        crossAxisSpacing: 10,
        mainAxisSpacing: 0.1,
      ),
      itemCount: 15,
      itemBuilder: (context, index) {
        return TextButton(
          onPressed: () {},
          child: Padding(
            padding: const EdgeInsets.all(10),
            child: Container(
              // height: height * 0.50,

              decoration: BoxDecoration(
                  color: const Color.fromARGB(255, 230, 226, 226),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(width: 1)),
              child: Center(
                child: Stack(
                  children: [
                    SkeletonAnimation(
                      shimmerColor: Colors.grey,
                      borderRadius: BorderRadius.circular(20),
                      shimmerDuration: 500,
                      child: SizedBox(
                        height: 90,
                        width: 90,
                      ),
                    ),
                    SizedBox(
                      width: double.infinity,
                      // color: Colors.transparent,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.end,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          SizedBox(
                            height: height * 0.040,
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                SkeletonAnimation(
                                  shimmerColor: Colors.grey,
                                  borderRadius: BorderRadius.circular(20),
                                  shimmerDuration: 500,
                                  child: Container(
                                    color: const Color.fromARGB(
                                        255, 208, 200, 200),
                                    child: SizedBox(
                                      height: 15,
                                      width: 80,
                                    ),
                                  ),
                                ),
                                SkeletonAnimation(
                                  shimmerColor: Colors.grey,
                                  borderRadius: BorderRadius.circular(20),
                                  shimmerDuration: 500,
                                  child: Container(
                                    decoration: BoxDecoration(
                                        color: const Color.fromARGB(
                                            255, 208, 200, 200),
                                        borderRadius: BorderRadius.only(
                                          bottomLeft: Radius.circular(10),
                                          bottomRight: Radius.circular(10),
                                        )),
                                    child: SizedBox(
                                      height: 15,
                                      width: 80,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

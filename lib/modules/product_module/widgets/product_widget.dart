import 'package:cash_register/Widgets/network_image_widget.dart';
import 'package:cash_register/common_utils/common_functions.dart';
import 'package:cash_register/db/sqfLite_db_service.dart';
import 'package:cash_register/helper/product.dart';
import 'package:cash_register/helper/stream_helper.dart';
import 'package:cash_register/model/cart_item.dart';
import 'package:cash_register/model/environment.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class ProductWidget extends StatefulWidget {
  final ProductDetails product;
  const ProductWidget({
    super.key,
    required this.product,
  });

  @override
  State<ProductWidget> createState() => _ProductWidgetState();
}

class _ProductWidgetState extends State<ProductWidget> {
  final dbs = DatabaseService.instance;
  bool isSelected = false;
  int count = 0;

  unselectProduct() {
    dbs.deleteProductFromCart(widget.product.id).then((_) async {
      StreamHelper.cartCountSink.add(await dbs.getCartCount());
      isSelected = false;
      setState(() {});
    });

    print("long press");
  }

  // Future<List> _fetchData() async {
  //   List<Map<String, Object?>>? data = await dbs.getCartList();

  //   print("in fetch method");
  //   List<CartItem> cartList =
  //       data.map((item) => CartItem.fromJson(item)).toList();

  //   // print(cartList.toList().toString());
  //   for (CartItem c in cartList) {
  //     print("product details");
  //     print(c.countNumber);
  //     print(c.image);
  //     print(c.productId);
  //     print(c.productName);
  //     print(c.price);
  //   }

  //   return cartList.reversed.toList();
  // }

  selectProduct() async {
    await dbs.addProductToCart(
      widget.product.id,
      widget.product.price,
      widget.product.image,
      widget.product.countNumber + 1,
      widget.product.measurementUnit,
      widget.product.productName,
    );
    StreamHelper.cartCountSink.add(await dbs.getCartCount());
    updatSelection();
  }

  @override
  void initState() {
    updatSelection();
    super.initState();
  }

  updatSelection() async {
    Map<String, dynamic> product = await findCartProductById(widget.product.id);
    if (product.isNotEmpty) {
      print(product["productId"]);
      isSelected = true;
      count = product["countNumber"];
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        selectProduct();
      },
      onLongPress: () {
        unselectProduct();
      },
      child: Padding(
        padding: const EdgeInsets.all(10),
        child: Container(
          decoration: BoxDecoration(
            color: const Color.fromARGB(255, 255, 255, 255),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(width: 1),
            // image: DecorationImage(
            //   image: NetworkImage(
            //     "${Environment.imageBaseUrl}${widget.product.image}",
            //   ),
            // ),
          ),
          child: Stack(
            children: [
              // Center(
              //     child: ClipRRect(
              //   borderRadius: BorderRadius.circular(10), // Image border
              //   child: SizedBox.fromSize(
              //     child: Image.network(
              //         "${Environment.imageBaseUrl}${widget.product.image}",
              //         fit: BoxFit.fitHeight),
              //   ),
              // )),
              NetworkImageWidget(image: widget.product.image),
              SizedBox(
                width: double.infinity,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Container(
                      decoration: BoxDecoration(
                        color: const Color.fromARGB(255, 216, 215, 215)
                            .withOpacity(0.7),
                        // color: containerColor,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Column(
                        children: [
                          SizedBox(
                            width: double.infinity,
                            child: Center(
                              child: Text(
                                widget.product.productName,
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: Colors.black,
                                    fontSize: getadaptiveTextSize(context, 10)),
                              ),
                            ),
                          ),
                          SizedBox(
                            width: double.infinity,
                            child: Center(
                              child: Text(
                                inrFormat
                                    .format(double.parse(widget.product.price)),
                                // _productList[index].price,
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black,
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
              isSelected == false
                  ? Container()
                  : Container(
                      decoration: BoxDecoration(
                        color: const Color.fromARGB(255, 216, 215, 215)
                            .withOpacity(0.7),
                        // color: containerColor,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Center(
                        child: Text(
                          '$count',
                          style: TextStyle(
                            fontSize: getadaptiveTextSize(context, 25),
                          ),
                        ),
                      ),
                    ),
            ],
          ),
        ),
      ),
    );
  }
}

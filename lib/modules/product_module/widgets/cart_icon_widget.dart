import 'package:add_to_cart_animation/add_to_cart_animation.dart';
import 'package:cash_register/cart_summary.dart';
import 'package:cash_register/common_utils/common_functions.dart';
import 'package:cash_register/db/sqfLite_db_service.dart';
import 'package:cash_register/helper/stream_helper.dart';
import 'package:cash_register/model/cart_item.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class CartIconWidget extends StatefulWidget {
  const CartIconWidget({super.key});

  @override
  State<CartIconWidget> createState() => _CartIconWidgetState();
}

class _CartIconWidgetState extends State<CartIconWidget> {
  List<CartItem> cartItem = [];
  GlobalKey<CartIconKey> cartKey = GlobalKey<CartIconKey>();
  final dbs = DatabaseService.instance;

  // int count = 0;

  @override
  void initState() {
    // TODO: implement initState

    // _fetchData();
    super.initState();
  }

  _fetchData() async {
    List<Map<String, Object?>>? data = await dbs.getCartList();

    print("in fetch method");
    List<CartItem> cartList =
        data.map((item) => CartItem.fromJson(item)).toList();

    // print(cartList.toList().toString());
    for (CartItem c in cartList) {
      print("product details");
      print(c.countNumber);
      print(c.image);
      print(c.productId);
      print(c.productName);
      print(c.price);
    }
    // count = cartList.toList().length;

    // return cartList.toList().length;
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    double width = size.width;
    double height = size.height;
    return StreamBuilder(
      stream: StreamHelper.cartCountStream,
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          if (snapshot.data != null) {
            if (snapshot.data! < 1) {
              return Container();
            }
            return SizedBox(
              // height: 50,
              child: Padding(
                padding: EdgeInsets.only(bottom: 80),
                child: SizedBox(
                  height: 90,
                  width: 90,
                  child: FloatingActionButton(
                    isExtended: true,
                    backgroundColor: Colors.blueAccent,
                    onPressed: () {
                      Navigator.push(context,
                          MaterialPageRoute(builder: (BuildContext context) {
                        return Cartsummary();
                      }));
                    },
                    child: Stack(children: [
                      AddToCartIcon(
                        key: cartKey,
                        // leading: ,

                        icon: Icon(
                          Icons.shopping_cart,
                          size: getadaptiveTextSize(context, 50),
                          color: Colors.white,
                        ),
                        badgeOptions: BadgeOptions(
                          height: 30,
                          width: 30,
                          active: false,
                          backgroundColor: Colors.red,
                          fontSize: getadaptiveTextSize(context, 15),
                        ),
                      ),
                      Container(
                        alignment: Alignment.center,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Text(
                              '${snapshot.data}',
                              style: TextStyle(
                                  fontSize: getadaptiveTextSize(context, 20),
                                  color: Colors.red,
                                  fontWeight: FontWeight.bold),
                            ),
                          ],
                        ),
                      ),
                    ]),
                  ),
                ),
              ),
            );
          }
        }

        return Container();
      },
    );
  }
}

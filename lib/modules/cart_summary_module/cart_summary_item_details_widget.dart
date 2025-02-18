import 'package:cash_register/common_utils/common_functions.dart';
import 'package:cash_register/db/sqfLite_db_service.dart';
import 'package:cash_register/helper/stream_helper.dart';
import 'package:cash_register/model/cart_item.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class CartSummaryItemDetailsWidget extends StatefulWidget {
  final int productId;
  final CartItem cartItem;
  const CartSummaryItemDetailsWidget({
    super.key,
    required this.productId,
    required this.cartItem,
  });

  @override
  State<CartSummaryItemDetailsWidget> createState() =>
      _CartSummaryItemDetailsWidgetState();
}

class _CartSummaryItemDetailsWidgetState
    extends State<CartSummaryItemDetailsWidget> {
  late CartItem cartItem;

  var size, width, height;

  void decreaseProductCount(int productId) {
    final dbs = DatabaseService.instance;
    dbs.decreaseProductCount(productId).then((_) async {
      StreamHelper.cartCountSink.add(await dbs.getCartCount());
      StreamHelper.cartFinalAmounSink.add(await dbs.getCartTotal());
    });
    loadCartProduct();
  }

  void increaseProductCount(int productId) async {
    final dbs = DatabaseService.instance;

    await dbs.increaseProductCount(productId).then((_) async {
      StreamHelper.cartFinalAmounSink.add(await dbs.getCartTotal());
    });
    loadCartProduct();
  }

  void updatPrice() async {
    final dbs = DatabaseService.instance;

    dbs
        .changePrice(widget.productId, priceEditContoller.text.toString())
        .then((_) async {
      StreamHelper.cartFinalAmounSink.add(await dbs.getCartTotal());
    });
  }

  Future<bool> _onWillPopDialouge() async {
    return false;
  }

  final TextEditingController priceEditContoller = TextEditingController();

  changeAmount() {
    priceEditContoller.text = widget.cartItem.price;
    showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (context) => WillPopScope(
        onWillPop: _onWillPopDialouge,
        child: AlertDialog(
          // title: const Text('Timer Finished'),
          content: SizedBox(
            height: height * 0.28,
            width: width * 0.98,
            child: Column(
              children: [
                Row(
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
                    // obscureText: _obscureText,
                    // autovalidateMode: AutovalidateMode.onUserInteraction,
                  ),
                ),
                ElevatedButton(
                    onPressed: () {
                      // cartProductsList[index].price =
                      //     priceEditContoller.text.toString();
                      updatPrice();

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

  void loadCartProduct() async {
    final dbs = DatabaseService.instance;
    Map<String, dynamic> data = await dbs.getCartProductById(widget.productId);
    // TransactionDetailsSQL.fromJsonList(data)
    cartItem = CartItem.fromMap(data);
    setState(() {});
    print(data);
  }

  @override
  void initState() {
    cartItem = widget.cartItem;
    loadCartProduct();

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    size = MediaQuery.of(context).size;
    width = size.width;
    height = size.height;
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Container(
          width: width * 0.40,
          // color: Colors.amber,
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                widget.cartItem.productName,
                style:
                    const TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 4),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    inrFormat.format(double.parse(cartItem.price)),
                    style: TextStyle(fontSize: 16),
                  ),
                  SizedBox(
                    width: 30,
                    height: 30,
                    child: Center(
                      child: IconButton(
                        onPressed: () {
                          changeAmount();
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blue,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(6),
                          ),
                        ),
                        icon: Icon(
                          Icons.mode_edit_outline,
                          color: Colors.black,
                          size: getadaptiveTextSize(context, 15),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        SizedBox(
          width: width * 0.28,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  SizedBox(
                    width: 35,
                    height: 35,
                    child: Center(
                      child: IconButton(
                        onPressed: () {
                          // decreasQTY(index);
                          // decreaseProductCount(cartItem.productId);
                          decreaseProductCount(widget.cartItem.productId);
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blue,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(6),
                          ),
                        ),
                        icon: Icon(
                          Icons.remove,
                          color: Colors.black,
                          size: getadaptiveTextSize(context, 18),
                        ),
                      ),
                    ),
                  ),
                  Text(
                    '${cartItem.countNumber}',
                    style: const TextStyle(
                        fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(
                    width: 35,
                    height: 35,
                    child: Center(
                      child: IconButton(
                        onPressed: () {
                          // increasQT00Y(index);
                          increaseProductCount(widget.cartItem.productId);
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blue,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(6),
                          ),
                        ),
                        icon: Icon(
                          Icons.add,
                          color: Colors.black,
                          size: getadaptiveTextSize(context, 18),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              Text(
                inrFormat.format(double.parse(calculateProductPrice(
                    cartItem.countNumber, cartItem.price))),
                // ' ${calculate(product.countNumber, product.price)}'
              )
            ],
          ),
        ),
      ],
    );
  }
}

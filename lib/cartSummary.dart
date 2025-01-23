import 'package:cash_register/helper/product.dart';
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';

class Cartsummary extends StatefulWidget {
  final List<CartProduct> cartProducts;
  const Cartsummary({super.key, required this.cartProducts});

  @override
  State<Cartsummary> createState() => _CartsummaryState();
}

class _CartsummaryState extends State<Cartsummary> {
  var size, width, height;

  getadaptiveTextSize(BuildContext context, dynamic value) {
    return (value / 710) * MediaQuery.of(context).size.height;
  }

  @override
  Widget build(BuildContext context) {
    size = MediaQuery.of(context).size;
    width = size.width;
    height = size.height;
    return Scaffold(
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
              Navigator.pop(context);
            },
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Stack(
                    children: [
                      Icon(
                        Icons.add,
                        size: getadaptiveTextSize(context, 50),
                        color: Colors.white,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
      body: Container(
        child: Center(
          child: Container(
            height: height * 0.90,
            child: Column(
              children: [
                Container(
                  child: Text("data"),
                ),
                Container(
                  child: Expanded(child: Text("data")),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

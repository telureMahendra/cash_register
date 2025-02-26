import 'package:cash_register/common_utils/common_functions.dart';
import 'package:flutter/material.dart';

class PayButtonWidget extends StatelessWidget {
  final String buttonText;
  final VoidCallback onPressed;

  const PayButtonWidget({
    super.key,
    required this.buttonText,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    double width = size.width;
    return SizedBox(
      width: (width / 3) - 15,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.blue, // background
          foregroundColor: Colors.black, // foreground
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(6), // <-- Radius
          ),
        ),
        onPressed: onPressed,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.money,
              size: getAdaptiveTextSize(context, 20),
              color: Colors.white,
            ),
            Text(
              buttonText,
              style: TextStyle(
                  color: Colors.white,
                  fontSize: getAdaptiveTextSize(context, 15)),
            ),
          ],
        ),
      ),
    );
  }
}

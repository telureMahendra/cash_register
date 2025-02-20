import 'package:cash_register/common_utils/common_functions.dart';
import 'package:flutter/material.dart';

class PaymentButtonWidget extends StatelessWidget {
  final IconData iconData;
  final String buttonText;
  final VoidCallback onPressed;
  const PaymentButtonWidget({
    super.key,
    required this.iconData,
    required this.buttonText,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return OutlinedButton(
      style: OutlinedButton.styleFrom(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(6),
        ),
      ),
      onPressed: onPressed,
      child: SizedBox(
        // height: 50,
        // width: 50,
        child: Padding(
          padding: const EdgeInsets.all(10.0),
          child: Column(
            children: [
              Icon(
                iconData,
                color: Colors.black,
                size: getAdaptiveTextSize(context, 15),
              ),
              Text(
                buttonText,
                style: TextStyle(
                  color: Colors.black,
                  fontSize: getAdaptiveTextSize(context, 15),
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

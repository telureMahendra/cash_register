import 'package:cash_register/common_utils/common_functions.dart';
import 'package:flutter/material.dart';

class CalculatorButtonWidget extends StatelessWidget {
  final String buttonText;
  final VoidCallback onPressed;
  final bool isWidthDouble;
  const CalculatorButtonWidget({
    super.key,
    required this.buttonText,
    required this.onPressed,
    required this.isWidthDouble,
  });

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    double width = size.width;
    double height = size.height;

    double appBarHeight = AppBar().preferredSize.height;
    double btnHeight = (height - 337) / 4 - height * 0.033;
    double btnWidth = (width - (width / 4)) / 3 - (width * 0.030);

    if (height > 1200) {
      btnHeight = (height - 337) / 4 - height * 0.045;
    }

    return SizedBox(
      height: btnHeight,
      width: isWidthDouble ? btnWidth * 2 : btnWidth,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: Color.fromARGB(255, 236, 233, 232), // background
          foregroundColor: Colors.black, // foreground
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12), // Radius
          ),
        ),
        onPressed: onPressed,
        child: Text(
          buttonText,
          style: TextStyle(
            fontSize: getAdaptiveTextSize(context, 40),
          ),
        ),
      ),
    );
  }
}

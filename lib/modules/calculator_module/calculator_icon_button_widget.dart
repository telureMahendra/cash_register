import 'package:flutter/material.dart';

class CalculatorIconButtonWidget extends StatelessWidget {
  final IconData icon;
  final VoidCallback onPressed;
  const CalculatorIconButtonWidget({
    super.key,
    required this.icon,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    double width = size.width;
    double height = size.height;

    double btnHeight = (height - 337) / 4 - height * 0.033;
    double btnWidth = (width - (width / 4)) / 3 - (width * 0.030);
    if (height > 1200) {
      btnHeight = (height - 337) / 4 - height * 0.045;
    }
    return SizedBox(
      height: btnHeight * 2,
      width: btnWidth,
      child: TextButton(
        style: TextButton.styleFrom(
          backgroundColor: Color.fromARGB(255, 236, 233, 232), // background
          foregroundColor: Colors.black, // foreground
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12), // Radius
          ),
        ),
        onPressed: onPressed,
        child: Center(
          child: Icon(
            icon,
            color: Colors.black,
            size: 50,
          ),
        ),
      ),
    );
  }
}

import 'package:cash_register/common_utils/common_functions.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class TransactionSummaryCardWidget extends StatelessWidget {
  final String title;
  final double amount;
  final int transactionCount;
  const TransactionSummaryCardWidget({
    super.key,
    required this.title,
    required this.amount,
    required this.transactionCount,
  });

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    double width = size.width;
    double height = size.height;
    return Card(
      elevation: 5,
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: SizedBox(
          height: height * 0.08,
          // width: (width / 3) - width * 0.065,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: TextStyle(
                  fontSize: getAdaptiveTextSize(context, 10),
                  color: Colors.black,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                // '$totalAmount',
                inrFormat.format(double.parse(amount.toString())),

                style: TextStyle(
                    fontSize: getAdaptiveTextSize(context, 13),
                    color: Colors.green,
                    fontWeight: FontWeight.bold),
              ),
              Text(
                // '$totalAmount',
                '$transactionCount Transactions',

                style: TextStyle(
                  fontSize: getAdaptiveTextSize(context, 13),
                  color: Colors.black87,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

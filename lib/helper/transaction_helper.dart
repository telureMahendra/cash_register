class TransactionDetails {
  final String method;
  final String time;
  final String date;
  final String amount;
  final String transactionId;

  TransactionDetails(
      {required this.method,
      required this.time,
      required this.date,
      required this.amount,
      required this.transactionId});

  factory TransactionDetails.fromJson(Map<String, dynamic> json) {
    return TransactionDetails(
        method: json['method'],
        time: json['time'],
        date: json['date'],
        amount: json['amount'],
        transactionId: json['transactionId']);
  }

  static List<TransactionDetails> fromJsonList(dynamic jsonList) {
    final transactionDetailsList = <TransactionDetails>[];
    if (jsonList == null) return transactionDetailsList;

    if (jsonList is List<dynamic>) {
      for (final json in jsonList) {
        transactionDetailsList.add(
          TransactionDetails.fromJson(json),
        );
      }
    }

    return transactionDetailsList;
  }
}

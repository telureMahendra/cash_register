class TransactionDetails {
  final String method;
  final String time;
  final String date;
  final String amount;
  final String transactionId;
  final String dateTime;
  final int status;
  final int tid;

  TransactionDetails({
    required this.method,
    required this.time,
    required this.date,
    required this.amount,
    required this.transactionId,
    required this.dateTime,
    required this.status,
    required this.tid,
  });

  factory TransactionDetails.fromJson(Map<String, dynamic> json) {
    return TransactionDetails(
        method: json['method'],
        time: json['time'],
        date: json['date'],
        amount: json['amount'],
        transactionId: json['transactionId'],
        dateTime: json['dateTime'],
        status: json['status'],
        tid: json['tid']);
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

class TransactionDetailsSQL {
  final String method;
  final String time;
  final String date;
  final String amount;
  // final String transactionId;
  final int status;

  final String dateTime;
  final int tid;

  TransactionDetailsSQL(
      {required this.method,
      required this.time,
      required this.date,
      required this.amount,
      // required this.transactionId,
      required this.dateTime,
      required this.status,
      required this.tid});

  factory TransactionDetailsSQL.fromJson(Map<String, dynamic> json) {
    return TransactionDetailsSQL(
        method: json['method'],
        time: json['time'],
        date: json['date'],
        amount: json['amount'],
        // transactionId: json['transactionId'],
        dateTime: json['tdatetime'],
        status: json['status'],
        tid: json["tid"]);
  }

  Map<String, dynamic> toJson() {
    return {
      'method': method,
      'time': time,
      'date': date,
      'amount': amount,
      'dateTime': dateTime,
      'status': status,
      'tid': tid,
    };
  }

  factory TransactionDetailsSQL.fromMap(Map<String, dynamic> map) {
    return TransactionDetailsSQL(
        method: map['method'],
        time: map['time'],
        date: map['date'],
        amount: map['amount'],
        dateTime: map['tdatetime'],
        status: map['status'],
        tid: map['tid']);
  }

  Map<String, dynamic> toMap() {
    return {
      'method': method,
      'time': time,
      'date': date,
      'amount': amount,
      'tdatetime': dateTime,
      'tid': tid,
    };
  }

  static List<TransactionDetailsSQL> fromJsonList(dynamic jsonList) {
    final transactionDetailsList = <TransactionDetailsSQL>[];
    if (jsonList == null) return transactionDetailsList;

    if (jsonList is List<dynamic>) {
      for (final json in jsonList) {
        transactionDetailsList.add(
          TransactionDetailsSQL.fromJson(json),
        );
      }
    }

    return transactionDetailsList;
  }
}

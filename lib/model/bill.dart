class BillFields {
  static final List<String> values = [
    amount,
    method,
    date,
    time,
    userId,
    id,
    created_at
  ];

  static final String id = 'id';
  static final String userId = 'userID';
  static final String amount = 'amount';
  static final String method = 'method';
  static final String time = 'time';
  static final String date = 'date';
  static String created_at = 'created_at';
}

class Bill {
  late final int id;
  late final String userId;
  late final String amount;
  late final String method;
  late final String time;
  late final String date;
  late String? created_at;

  Bill(
      {required this.amount,
      required this.method,
      required this.date,
      required this.time,
      required this.userId,
      required this.id,
      required this.created_at});
}

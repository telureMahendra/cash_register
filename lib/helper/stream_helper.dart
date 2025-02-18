import 'dart:async';

abstract class StreamHelper {
  static final StreamController<int> _cartCountStremConntroller =
      StreamController<int>.broadcast();
  static Sink<int> get cartCountSink => _cartCountStremConntroller.sink;
  static Stream<int> get cartCountStream => _cartCountStremConntroller.stream;

  static final StreamController<String> _productAmountSummaryController =
      StreamController<String>.broadcast();

  static Sink<String> get cartFinalAmounSink =>
      _productAmountSummaryController.sink;

  static Stream<String> get cartFinalAmountStream =>
      _productAmountSummaryController.stream;
}

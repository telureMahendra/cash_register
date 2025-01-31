import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:cash_register/addBusinessDetails.dart';
import 'package:cash_register/api.dart';
import 'package:cash_register/cartSummary.dart';
import 'package:cash_register/db/sqfLiteDBService.dart';
import 'package:cash_register/editBusinessDetails.dart';
import 'package:cash_register/helper/helper.dart';
import 'package:cash_register/helper/printHelper.dart';
import 'package:cash_register/helper/service/TransactionSyncService.dart';
import 'package:cash_register/menu.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:cash_register/transactions_history.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_esc_pos_utils/flutter_esc_pos_utils.dart';
import 'package:flutter_timer_countdown/flutter_timer_countdown.dart';
import 'package:lottie/lottie.dart';
import 'package:math_expressions/math_expressions.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:print_bluetooth_thermal/post_code.dart';
// import 'package:print_bluetooth_thermal/post_code.dart' as FontSize;
// package:print_bluetooth_thermal/post_code.dart

import 'package:print_bluetooth_thermal/print_bluetooth_thermal.dart';
// import 'package:print_bluetooth_thermal/print_bluetooth_thermal.dart';
import 'package:qr_bar_code/code/src/code_generate.dart';
import 'package:qr_bar_code/code/src/code_type.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:widgets_to_image/widgets_to_image.dart';
import 'package:workmanager/workmanager.dart';
import 'package:workmanager/src/options.dart' as constraints;
import 'package:flutter_styled_toast/flutter_styled_toast.dart';
import 'package:http/http.dart' as http;
import 'package:image/image.dart' as img;
// import 'package:upi_payment_qrcode_generator/upi_payment_qrcode_generator.dart';
// import 'package:fluttertoast/fluttertoast.dart';
import 'package:qr_bar_code/qr_bar_code.dart';
import 'package:internet_connection_checker/internet_connection_checker.dart';

import 'login.dart';

class Calculator extends StatefulWidget {
  const Calculator({super.key, required this.title});

  final String title;

  @override
  State<Calculator> createState() => _CalculatorState();
}

class _CalculatorState extends State<Calculator> {
  // late final AnimationController _controller;

  final dbs = DatabaseService.instance;
  late Printhelper printhelper = Printhelper();

  String total = '0.0';
  int tempNum = 0;
  String evalString = "0";
  late bool isLoggedIn = false;
  late bool isBusinessDetailsFound = false;
  late bool dataUpdated = false;

  var upiID = '';

  List<Map<String, Object?>>? _billData;

  // final MyConnectivity _connectivity = MyConnectivity.instance;

  Future<void> _fetchData() async {
    List<Map<String, Object?>>? data = await dbs.getDBdata();
    setState(() {
      _billData = data;
    });
  }

  // final upiDetails = UPIDetails(
  //     upiID: "95610051485@ybl", payeeName: "MahendraTelure", amount: 10);

  ScrollController _controller = new ScrollController();

  FocusNode _focusNode = FocusNode();

  void scroll(double position) {
    _controller.jumpTo(position);
  }

  var channel = MethodChannel("printMethod");

  printReciept() async {
    final prefs = await SharedPreferences.getInstance();

    if (evalString[evalString.length - 1] == '+') {
      evalString = evalString.substring(0, evalString.length - 1);
    }

    List<String> amounts = evalString.split("+");
    print(amounts);
    String items = "";
    for (String a in amounts) {
      print(a);
      items += "Item=${inrFormat.format(double.parse(a.toString()))}'";
    }

    bool status;
    status = prefs.getBool('isLogoPrint') ?? false;
    channel.invokeListMethod("printCartReceipt", {
      "shopName": prefs.getString("businessName") ?? '',
      "address": prefs.getString("address") ?? '',
      "shopMobile": prefs.getString('businessMobile') ?? '',
      "shopEmail": prefs.getString('businessEmail') ?? '',
      "amount": '${inrFormat.format(double.parse(total))}',
      "gstNumber": prefs.getString('gstNumber') ?? '',
      "isPrintGST": prefs.getBool('isPrintGST') ?? '',
      "image": status ? prefs.getString('image') ?? '' : '',
      "items": items
    });
  }

  String _info = "";
  String _msj = '';

  bool connected = false;
  // List<BluetoothInfo> items = [];
  // final List<String> _options = [
  //   "permission bluetooth granted",
  //   "bluetooth enabled",
  //   "connection status",
  //   "update info"
  // ];

  String _selectSize = "2";
  final _txtText = TextEditingController(text: "Hello developer");
  bool _progress = false;
  String _msjprogress = "";
  var conDeviceMac = '', conDeviceName = '';

  String optionprinttype = "58 mm";
  List<String> options = ["58 mm", "80 mm"];

  String addSpace(spaceCount) {
    var temp = "";
    for (int i = 0; i < spaceCount; i++) {
      temp += " ";
    }
    return temp;
  }

  // String getRupeeSymbolForPrinter() {
  //   // Determine the character set supported by your printer
  //   // and return the appropriate symbol.
  //   // For example:
  //   // If using CP437 and '§' is a suitable substitute:
  //   if (printerCharacterSet == 'CP437') {
  //     return '§';
  //   } else {
  //     // Handle other character sets or return an empty string if unsupported
  //     return '';
  //   }
  // }

  printThermalReciept(var payMethod, var recSource) async {
    // checkPaired();

    bool connectionStatus = await PrintBluetoothThermal.connectionStatus;

    // bool result = await PrintBluetoothThermal.writeString(
    // printText: PrintTextSize(size: int.parse("5"), text: "hello"));

    String time = DateFormat('jms').format(DateTime.now()).toString();
    String date = DateFormat('yMMMd').format(DateTime.now()).toString();

    if (connectionStatus) {
      print("Device Connected to printer ");

      final prefs = await SharedPreferences.getInstance();
      List<int> bytes = [];
      // Using default profile
      final profile = await CapabilityProfile.load();

      bool isLogoPrint;
      isLogoPrint = prefs.getBool('isLogoPrint') ?? false;

      final generator = Generator(
          optionprinttype == "58 mm" ? PaperSize.mm58 : PaperSize.mm80,
          profile);
      bytes += generator.setGlobalFont(PosFontType.fontA);
      bytes += generator.reset();

      if (isLogoPrint) {
        final Uint8List bytesImg =
            Base64Codec().decode(prefs.getString('image') ?? '');
        img.Image? image = img.decodeImage(bytesImg);

        final resizedImage = img.copyResize(image!,
            width: image.width ~/ 1.3,
            height: image.height ~/ 1.3,
            interpolation: img.Interpolation.nearest);
        final bytesimg = Uint8List.fromList(img.encodeJpg(resizedImage));
        image = img.decodeImage(bytesimg);

        bytes += generator.image(
          image!,
          align: PosAlign.center,
        );

        await PrintBluetoothThermal.writeBytes(bytes);
      }
      await PrintBluetoothThermal.writeString(
        printText: PrintTextSize(
          size: 3,
          text: prefs.getString("businessName") ?? '',
        ),
      );
      // await PrintBluetoothThermal.writeString(
      //   printText: PrintTextSize(
      //     size: 1,
      //     text: ' ',
      //   ),
      // );
      // await PrintBluetoothThermal.writeBytes(generator.feed(0));

      await PrintBluetoothThermal.writeString(
        printText: PrintTextSize(
          size: 1,
          text: '\n${prefs.getString("address") ?? ''}',
        ),
      );

      await PrintBluetoothThermal.writeString(
        printText: PrintTextSize(
          size: 2,
          text: '\nEmail: ${prefs.getString("businessEmail") ?? ''}',
        ),
      );

      await PrintBluetoothThermal.writeString(
        printText: PrintTextSize(
          size: 2,
          text: '\nMobile: ${prefs.getString("businessMobile") ?? ''}',
        ),
      );

      bool isGstPrint = prefs.getBool('isPrintGST') ?? false;
      if (isGstPrint) {
        await PrintBluetoothThermal.writeString(
          printText: PrintTextSize(
            size: 2,
            text: '\nGST: ${prefs.getString("gstNumber") ?? ''}',
          ),
        );
      }

      bytes = [];

      // bytes +=
      //     PostCode.text(text: "Size compressed", fontSize: FontSize.compressed);
      // bytes += PostCode.text(text: "Size normal", fontSize: FontSize.normal);
      // bytes += PostCode.text(text: "Bold", bold: true);
      // bytes += PostCode.text(text: "Inverse", inverse: true);
      // bytes += PostCode.text(text: "AlignPos right", align: AlignPos.right);
      // bytes += PostCode.text(
      //     text: "Size normal center",
      //     bold: true,
      //     fontSize: FontSize.normal,
      //     align: AlignPos.center);

      var invCalCounter = prefs.getInt("invCalCounter") ?? 1;
      var invProdCounter = prefs.getInt("invProdCounter") ?? 1;

      bytes += generator.feed(1);

      if (recSource == "CALCULATOR") {
        bytes += PostCode.text(
          text:
              "Inv No.: cal/${invCalCounter++}${addSpace(25 - payMethod.toString().length - invCalCounter.toString().length)}By: ${payMethod.toString()}",
          fontSize: FontSize.compressed,
          align: AlignPos.center,
        );
        prefs.setInt("invCalCounter", invCalCounter++);
      } else {
        bytes += PostCode.text(
          text:
              "Inv No.: Pro/${invProdCounter++}${addSpace(25 - payMethod.toString().length - invProdCounter.toString().length)}By: ${payMethod}",
          fontSize: FontSize.compressed,
          align: AlignPos.center,
        );
        prefs.setInt("invProdCounter", invProdCounter++);
      }

      bytes += PostCode.text(
        text:
            "Date: ${date}${addSpace(30 - date.length - time.length)}Time: ${time}",
        fontSize: FontSize.compressed,
        align: AlignPos.center,
      );

      bytes += PostCode.text(
        text: "------------------------------------------",
        fontSize: FontSize.compressed,
        align: AlignPos.center,
      );
      bytes += PostCode.text(
        text: "Product${addSpace(20)}Value",
        align: AlignPos.center,
        fontSize: FontSize.normal,
      );
      bytes += PostCode.text(
        text: "------------------------------------------",
        fontSize: FontSize.compressed,
        align: AlignPos.center,
      );

      if (evalString[evalString.length - 1] == '+') {
        evalString = evalString.substring(0, evalString.length - 1);
      }

      List<String> amounts = evalString.split("+");
      int counter = 1;
      // String rupeeSymbol = getRupeeSymbolForPrinter();
      for (String a in amounts) {
        a = inrFormat.format(double.parse(a.toString()));
        bytes += PostCode.text(
          text:
              "Item $counter${addSpace(34 - a.length - counter.toString().length)}Rs. ${a.substring(1)}",
          fontSize: FontSize.compressed,
          align: AlignPos.center,
          bold: false,
        );
        counter++;
      }

      bytes += PostCode.text(
        text: "==========================================",
        fontSize: FontSize.compressed,
        align: AlignPos.center,
      );
      bytes += PostCode.text(
        text:
            "Total${addSpace(24 - total.length - 3)}Rs. ${inrFormat.format(double.parse(total)).substring(1)}",
        fontSize: FontSize.normal,
        bold: true,
        align: AlignPos.center,
      );
      bytes += PostCode.text(
        text: "==========================================",
        fontSize: FontSize.compressed,
        align: AlignPos.center,
      );

      // bytes += PostCode.text(
      //     text:
      //         "Bold\bcccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc",
      //     bold: true);
      // bytes += PostCode.text(
      //     text:
      //         "Inverse\nddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddd",
      //     inverse: true);
      // // bytes += PostCode.text(text: "AlignPos right", align: AlignPos.right);
      // bytes += PostCode.text(
      //     text:
      //         "Double Height\neeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee",
      //     fontSize: FontSize.doubleHeight);
      // bytes += PostCode.text(
      //     text:
      //         "Double Width\nfffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff",
      //     fontSize: FontSize.doubleWidth);
      // bytes += PostCode.text(
      //     text:
      //         "Size big\nggggggggggggggggggggggggggggggggggggggggggggggggggggggggg",
      //     fontSize: FontSize.big);

      bytes += PostCode.text(
        text: "Thank You!",
        fontSize: FontSize.doubleHeight,
        align: AlignPos.center,
      );
      bytes += PostCode.text(
        text: "Note: Goods once sold will not be taken back or exchanged.",
        fontSize: FontSize.compressed,
        align: AlignPos.center,
      );
      bytes += PostCode.text(
        text: "Powerd by: Vizpay Business Solutions Pvt. Ltd.",
        fontSize: FontSize.compressed,
        align: AlignPos.center,
      );

      // bytes += PostCode.enter();

      bytes += generator.feed(3);
      //bytes += generator.cut();
      await PrintBluetoothThermal.writeBytes(bytes);
    }
    print("Device not connected");
  }

  checkPaired() async {
    final prefs = await SharedPreferences.getInstance();
    var resultq = await PrintBluetoothThermal.disconnect;
    String mac = prefs.getString("mac") ?? '';
    print("Mac address is: ${mac}");
    var devices = await PrintBluetoothThermal.pairedBluetooths;
    for (BluetoothInfo b in devices) {
      if (b.macAdress == mac) {
        conDeviceMac = b.macAdress;
        conDeviceName = b.name;
      }
    }
    if (mac.isNotEmpty) {
      connect(conDeviceMac, conDeviceName);
    }
  }

  Future<void> connect(String mac, String name) async {
    await PrintBluetoothThermal.disconnect;
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _progress = true;
      _msjprogress = "Connecting...";
      connected = false;
    });

    final bool result =
        await PrintBluetoothThermal.connect(macPrinterAddress: mac);
    prefs.setString("mac", mac);
    conDeviceMac = mac;
    conDeviceName = name;

    print("state conected $result");
    if (result) connected = true;
    setState(() {
      _progress = false;
    });
  }

  Future<List<int>> testTicket() async {
    List<int> bytes = [];
    // Using default profile
    final profile = await CapabilityProfile.load();
    final generator = Generator(
        optionprinttype == "58 mm" ? PaperSize.mm58 : PaperSize.mm80, profile);
    bytes += generator.setGlobalFont(PosFontType.fontA);
    bytes += generator.reset();

    bytes += generator.text(
      'Text size 50%',
      styles: const PosStyles(
        fontType: PosFontType.fontB,
      ),
    );
    bytes += generator.text(
      'Text size 100%',
      styles: const PosStyles(
        fontType: PosFontType.fontA,
      ),
    );
    bytes += generator.text(
      'Text size 200%',
      styles: const PosStyles(
        height: PosTextSize.size2,
        width: PosTextSize.size2,
      ),
    );

    bytes += generator.feed(2);
    //bytes += generator.cut();
    return bytes;
  }

  Future<void> initPlatformState() async {
    String platformVersion;
    int porcentbatery = 0;
    // Platform messages may fail, so we use a try/catch PlatformException.
    try {
      platformVersion = await PrintBluetoothThermal.platformVersion;
      print("patformversion: $platformVersion");
      porcentbatery = await PrintBluetoothThermal.batteryLevel;
    } on PlatformException {
      platformVersion = 'Failed to get platform version.';
    }

    // If the widget was removed from the tree while the asynchronous platform
    // message was in flight, we want to discard the reply rather than calling
    // setState to update our non-existent appearance.
    if (!mounted) return;

    final bool result = await PrintBluetoothThermal.bluetoothEnabled;
    print("bluetooth enabled: $result");
    if (result) {
      _msj = "Bluetooth enabled, please search and connect";
    } else {
      _msj = "Bluetooth not enabled";
    }

    setState(() {
      _info = "$platformVersion ($porcentbatery% battery)";
    });
  }

  Future<bool> isNetworkAvailable() async {
    var connectivityResult = await (Connectivity().checkConnectivity());
    return connectivityResult != ConnectivityResult.none;
  }

  void callbackDispatcher() {
    Workmanager().executeTask((task, inputData) async {
      if (task == "syncTransactionsTask") {
        if (await isNetworkAvailable()) {
          TransactionSyncService syncService = TransactionSyncService(
              DatabaseService.instance,
              databaseHelper: dbs);
          print("network is available");
          await syncService.syncTransactions();
        }
      }
      // return Future.value(true);
      return Future.value(true);
    });
  }

  Future<void> syncTransaction() async {
    if (isDeviceConnected) {
      print("working on syncronization");
      TransactionSyncService syncService =
          TransactionSyncService(DatabaseService.instance, databaseHelper: dbs);
      print("network is available");
      await syncService.syncTransactions();
      final prefs = await SharedPreferences.getInstance();
      prefs.setBool("isSynced", true);
      setState(() {});
    } else {
      print("network error in syncronization");
    }
  }

  Future<void> syncTask() async {
    final prefs = await SharedPreferences.getInstance();
    var isSynced = prefs.getBool("isSynced") ?? false;

    if (isSynced) {
      prefs.setBool("isSynced", false);
    } else {
      prefs.setBool("isSynced", true);
    }
    setState(() {});

    // print("in sync function");
    // Workmanager()
    //     .registerOneOffTask("syncTransactionsTask", "syncTransactionsTask",
    //         constraints: constraints.Constraints(
    //           networkType: NetworkType.connected,
    //           // requiresBatteryNotLow: true,
    //           // requiresCharging: true,
    //           // requiresDeviceIdle: true,
    //           // requiresStorageNotLow: true
    //         ));
  }

  // Workmanager().registerOneOffTask("syncTransactionOnOff", "syncTransactions",
  //     constraints: constraints.Constraints(
  //         networkType: NetworkType.connected,
  //         requiresBatteryNotLow: true,
  //         requiresCharging: true,
  //         requiresDeviceIdle: true,
  //         requiresStorageNotLow: true));

  //   void initWorkManager() {
  //   Workmanager().initialize(
  //     callbackDispatcher,
  //     isInDebugMode: true,
  //   );
  // }

  final inrFormat = NumberFormat.currency(
    locale: 'hi_IN',
    name: 'INR',
    symbol: '₹',
    decimalDigits: 2,
  );

  Future<void> checkLoggedIn() async {
    final prefs = await SharedPreferences.getInstance();
    // ignore: unused_local_variable
    isLoggedIn = prefs.getBool('isLoggedIn') ?? false;
    // setState(() {});

    if (!isLoggedIn) {
      Navigator.pushReplacement(context,
          MaterialPageRoute(builder: (context) => const LoginScreen()));
    }
  }

  Future<void> checkBusinessDetailsFound() async {
    final prefs = await SharedPreferences.getInstance();

    isBusinessDetailsFound = prefs.getBool('isBusinessDetailsFound') ?? false;

    if (isBusinessDetailsFound == false) {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) {
          return const Center(child: CircularProgressIndicator());
        },
      );
      final response = await http.get(
        Uri.parse('$BASE_URL/business'),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
          'userId': '${prefs.getInt('userId')}',
        },
      );

      if (response.statusCode == 200) {
        String responseString = utf8.decode(response.bodyBytes);
        Map<String, dynamic> jsonData = jsonDecode(responseString);

        prefs.setBool("isBusinessDetailsFound", true);
        prefs.setString('businessName', jsonData['businessName'] ?? '');
        prefs.setString('address', jsonData['address'] ?? '');
        prefs.setString('businessEmail', jsonData['email'] ?? '');
        prefs.setString('businessMobile', jsonData['mobile'] ?? '');
        prefs.setString('gstNumber', jsonData['gstNumber'] ?? '');
        prefs.setString('upiID', jsonData['upiID'] ?? '');
        prefs.setBool("recieptSwitch", true);
        isBusinessDetailsFound = true;
        Navigator.pop(context);
      } else {
        //  return const Text('No transaction data');

        Navigator.pop(context);
        showDialog<void>(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Error'),
            content: Text('${response.body.toString()}'),
            actions: [
              TextButton(
                child: Text(
                  'Ok',
                  style: TextStyle(fontSize: getadaptiveTextSize(context, 15)),
                ),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
            ],
          ),
        );
        // throw Exception('Request Failed.');
      }
    }
    setState(() {});
    if (isBusinessDetailsFound == false) {
      Navigator.pop(context);
      Navigator.pushReplacement(context,
          MaterialPageRoute(builder: (context) => const AddBusinessDetails()));
    }
  }

  late StreamSubscription _streamSubscription;
  bool isDeviceConnected = false;
  internetConnection() =>
      _streamSubscription = Connectivity().onConnectivityChanged.listen(
        (event) async {
          isDeviceConnected =
              await InternetConnectionChecker.instance.hasConnection;
        },
      );

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      _focusNode.requestFocus();
    });

    internetConnection();
    initPlatformState();

    checkLoggedIn();
    checkBusinessDetailsFound();
    checkPaired();

    setState(() {});
  }

  @override
  void dispose() {
    _streamSubscription.cancel();
    super.dispose();
  }

  getadaptiveTextSize(BuildContext context, dynamic value) {
    return (value / 710) * MediaQuery.of(context).size.height;
  }

  Future<void> payBill(
    String method,
  ) async {
    final prefs = await SharedPreferences.getInstance();
    upiID = prefs.getString("upiID") ?? '';

    // if (isDeviceConnected) {

    setState(() {
      // var myInt = int.parse(total);
      // assert(myInt is int);
      // print("int is ${myInt}");

      if ((total == '0') ||
          (total == 0) ||
          total == '0.00' ||
          (total == 0.00) ||
          total == '0.0' ||
          (total == 0.0) ||
          total == '00' ||
          (total == 00)) {
        //

        showDialog<void>(
          context: context,
          builder: (context) => AlertDialog(
            content: Container(
              height: 220,
              padding: EdgeInsets.all(2),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Lottie.asset('assets/animations/warning.json',
                      height: MediaQuery.of(context).size.height * 0.17,
                      // controller: _controller,
                      repeat: true,
                      animate: true),
                  Text(
                    'Please Enter an Amount',
                    style:
                        TextStyle(fontSize: getadaptiveTextSize(context, 15)),
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(
                child: Text(
                  'Ok',
                  style: TextStyle(fontSize: getadaptiveTextSize(context, 15)),
                ),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
            ],
          ),
        );
      } else {
        if (method == 'CASH') {
          saveTransactionSqlite(method, total, printhelper.sourceCalculator);
          // printWidgetToReciept();
        } else {
          // internetConnection();
          if (isDeviceConnected) {
            upiID = prefs.getString("upiID") ?? '';
            if (upiID.toString().isNotEmpty ||
                upiID.trim().isNotEmpty ||
                upiID.toString() != '') {
              showDialog<void>(
                context: context,
                barrierDismissible: false,
                builder: (context) => WillPopScope(
                  onWillPop: _onWillPopDialouge,
                  child: AlertDialog(
                    // insetPadding: EdgeInsets.only(bottom: 20),
                    content: Container(
                        padding: EdgeInsets.only(bottom: 0),
                        height: height * 0.79,
                        width: width,
                        // color: Colors.amber,
                        child: Column(
                          children: [
                            Container(
                                // padding: EdgeInsets.only(
                                //     bottom: height * 0.020, top: 0),
                                // color: Colors.blue,
                                child: Center(
                              child: Column(
                                children: [
                                  // UPIPaymentQRCode(
                                  //   upiDetails: upiDetails,
                                  //   size: 200,
                                  // ),
                                  Container(
                                    // padding: EdgeInsets.only(
                                    //     top: height * 0.005,
                                    //     bottom: height * 0.005),
                                    child: Text(
                                      "Complete Your Payment",
                                      style: TextStyle(
                                          color: Colors.black,
                                          fontSize:
                                              getadaptiveTextSize(context, 13)),
                                    ),
                                  ),
                                  Container(
                                    padding: EdgeInsets.only(
                                        top: height * 0.005,
                                        bottom: height * 0.005),
                                    child: Text(
                                      '${inrFormat.format(double.parse(total))}',
                                      style: TextStyle(
                                          color: Colors.green,
                                          fontWeight: FontWeight.w900,
                                          fontSize:
                                              getadaptiveTextSize(context, 30)),
                                    ),
                                  ),
                                  Container(
                                    padding: EdgeInsets.only(
                                        top: height * 0.005,
                                        bottom: height * 0.005),
                                    child: Text(
                                      '${prefs.getString("businessName")}',
                                      style: TextStyle(
                                          color: Colors.black,
                                          fontWeight: FontWeight.w600,
                                          fontSize:
                                              getadaptiveTextSize(context, 20)),
                                    ),
                                  ),
                                  Container(
                                    padding:
                                        EdgeInsets.only(bottom: height * 0.005),
                                    child: Text(
                                      'Scan and pay using UPI app',
                                      style: TextStyle(
                                          color: Colors.black,
                                          fontSize:
                                              getadaptiveTextSize(context, 15)),
                                    ),
                                  ),
                                  Code(
                                    height: height * 0.25,
                                    data:
                                        "upi://pay?pa=${prefs.getString("upiID")}&pn=${prefs.getString("businessName")}&mc=0000&tn=Bill%20Payment&am=${double.parse(total)}&cu=INR",
                                    // "upi://pay?pa=9561051485@axl&pn=Mahendra%20Telure&mc=0000&mode=02&purpose=00&am=10",
                                    codeType: CodeType.qrCode(),
                                  ),
                                  Container(
                                    padding: EdgeInsets.only(
                                        top: height * 0.005,
                                        bottom: height * 0.005),
                                    child: Text(
                                      'UPI ID: ${prefs.getString("upiID")}',
                                      style: TextStyle(
                                          color: Colors.black,
                                          fontSize:
                                              getadaptiveTextSize(context, 15)),
                                    ),
                                  ),
                                  Center(
                                    child: Container(
                                        padding: EdgeInsets.all(height * 0.005),
                                        child: Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: [
                                            Image.asset(
                                              "assets/images/bhim_tra.png",
                                              height: height * 0.02,
                                            ),
                                            Image.asset(
                                              "assets/images/upi_tra.png",
                                              height: height * 0.02,
                                            ),
                                          ],
                                        )),
                                  ),
                                  Center(
                                    child: Container(
                                      child: TimerCountdown(
                                        format:
                                            // CountDownTimerFormat.secondsOnly,
                                            CountDownTimerFormat.minutesSeconds,
                                        endTime: DateTime.now().add(
                                          Duration(
                                              minutes: 0,
                                              seconds: 5,
                                              microseconds: 20),
                                        ),
                                        timeTextStyle: TextStyle(
                                            fontWeight: FontWeight.w800,
                                            fontSize: getadaptiveTextSize(
                                                context, 20)),
                                        onEnd: () {
                                          // print("Timer finished");
                                          showDialog<void>(
                                            context: context,
                                            barrierDismissible: false,
                                            builder: (context) => WillPopScope(
                                              onWillPop: _onWillPopDialouge,
                                              child: AlertDialog(
                                                // title: const Text('Timer Finished'),
                                                content: Container(
                                                  height: height * 0.28,
                                                  width: width * 0.98,
                                                  child: Column(
                                                    children: [
                                                      Lottie.asset(
                                                          'assets/animations/warning.json',
                                                          height: MediaQuery.of(
                                                                      context)
                                                                  .size
                                                                  .height *
                                                              0.17,
                                                          repeat: true,
                                                          animate: true),
                                                      Container(
                                                        child: Text(
                                                          "Transaction Timeout!",
                                                          style: TextStyle(
                                                              color: Colors.red,
                                                              fontSize:
                                                                  getadaptiveTextSize(
                                                                      context,
                                                                      15)),
                                                        ),
                                                      ),
                                                      Container(
                                                        padding:
                                                            EdgeInsets.only(
                                                                top: height *
                                                                    0.020),
                                                        child: Row(
                                                          mainAxisAlignment:
                                                              MainAxisAlignment
                                                                  .spaceBetween,
                                                          children: [
                                                            Container(
                                                              height: height *
                                                                  0.050,
                                                              child:
                                                                  ElevatedButton(
                                                                      style: ElevatedButton
                                                                          .styleFrom(
                                                                        backgroundColor:
                                                                            Colors.blue, // background
                                                                        foregroundColor:
                                                                            Colors.black, // foreground
                                                                        padding:
                                                                            EdgeInsets.all(8),
                                                                        shape:
                                                                            RoundedRectangleBorder(
                                                                          borderRadius:
                                                                              BorderRadius.circular(6), // <-- Radius
                                                                        ),
                                                                      ),
                                                                      onPressed:
                                                                          () {
                                                                        Navigator.of(context)
                                                                            .pop();
                                                                        Navigator.of(context)
                                                                            .pop();
                                                                        saveTransactionToServer(
                                                                            method,
                                                                            total,
                                                                            printhelper.sourceCalculator);
                                                                      },
                                                                      child:
                                                                          Text(
                                                                        "Print Receipt",
                                                                        style: TextStyle(
                                                                            color:
                                                                                Colors.white,
                                                                            fontSize: getadaptiveTextSize(context, 14)),
                                                                      )),
                                                            ),
                                                            Container(
                                                              height: height *
                                                                  0.050,
                                                              child:
                                                                  OutlinedButton(
                                                                      style: OutlinedButton
                                                                          .styleFrom(
                                                                        // background
                                                                        foregroundColor:
                                                                            Colors.black, // foreground
                                                                        padding:
                                                                            EdgeInsets.all(8),
                                                                        shape:
                                                                            RoundedRectangleBorder(
                                                                          borderRadius:
                                                                              BorderRadius.circular(6), // <-- Radius
                                                                        ),
                                                                      ),
                                                                      onPressed:
                                                                          () {
                                                                        Navigator.of(context)
                                                                            .pop();
                                                                        Navigator.pop(
                                                                            context);
                                                                      },
                                                                      child:
                                                                          Text(
                                                                        "Back To Home",
                                                                        style: TextStyle(
                                                                            color:
                                                                                Colors.black,
                                                                            fontSize: getadaptiveTextSize(context, 14)),
                                                                      )),
                                                            ),
                                                          ],
                                                        ),
                                                      )
                                                    ],
                                                  ),
                                                ),
                                                actions: [],
                                              ),
                                            ),
                                          );
                                        },
                                      ),
                                    ),
                                  )
                                ],
                              ),
                            )),
                            Center(
                              child: Padding(
                                padding: EdgeInsets.only(bottom: height * 0.01),
                                child: Text(
                                  "Check Payment Application: If a payment notification is received, print a receipt.",
                                  style: TextStyle(
                                    color: Colors.red,
                                    fontSize: getadaptiveTextSize(context, 12),
                                  ),
                                ),
                              ),
                            ),
                            Container(
                              padding: EdgeInsets.only(bottom: 0),
                              width: width * 0.50,
                              height: height * 0.05,
                              child: OutlinedButton(
                                style: OutlinedButton.styleFrom(
                                  backgroundColor: Colors.blue, // background
                                  foregroundColor: Colors.black, // foreground
                                  shape: RoundedRectangleBorder(
                                    borderRadius:
                                        BorderRadius.circular(6), // <-- Radius
                                  ),
                                ),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(
                                      Icons.print_outlined,
                                      size: getadaptiveTextSize(context, 19),
                                      color: const Color.fromARGB(
                                          255, 58, 104, 125),
                                    ),
                                    Text(
                                      'Print Receipt',
                                      style: TextStyle(
                                          color: Colors.black,
                                          fontSize:
                                              getadaptiveTextSize(context, 15)),
                                    ),
                                  ],
                                ),
                                onPressed: () {
                                  Navigator.pop(context);

                                  saveTransactionToServer(method, total,
                                      printhelper.sourceCalculator);
                                },
                              ),
                            ),
                            Container(
                              padding: EdgeInsets.all(height * 0.005),
                            ),
                            Container(
                              padding: EdgeInsets.only(bottom: 0),
                              width: width * 0.50,
                              height: height * 0.05,
                              child: OutlinedButton(
                                style: OutlinedButton.styleFrom(
                                  foregroundColor: Colors.black, // foreground
                                  shape: RoundedRectangleBorder(
                                    borderRadius:
                                        BorderRadius.circular(6), // <-- Radius
                                  ),
                                ),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(
                                      Icons.home_outlined,
                                      size: getadaptiveTextSize(context, 19),
                                      color: const Color.fromARGB(
                                          255, 58, 104, 125),
                                    ),
                                    Text(
                                      'Back To Home',
                                      style: TextStyle(
                                          color: Colors.black,
                                          fontSize:
                                              getadaptiveTextSize(context, 15)),
                                    ),
                                  ],
                                ),
                                onPressed: () {
                                  Navigator.pop(context);
                                  setState(() {});
                                },
                              ),
                            ),
                          ],
                        )),
                    actions: [],
                  ),
                ),
              );
            } else {
              showDialog<void>(
                context: context,
                barrierDismissible: false,
                builder: (context) => WillPopScope(
                  onWillPop: _onWillPopDialouge,
                  child: AlertDialog(
                    // title: const Text('Timer Finished'),
                    content: Container(
                      height: height * 0.28,
                      width: width * 0.98,
                      child: Column(
                        children: [
                          Lottie.asset('assets/animations/warning.json',
                              height: MediaQuery.of(context).size.height * 0.17,
                              repeat: true,
                              animate: true),
                          Container(
                            child: Text(
                              "UPI ID Not Found!",
                              style: TextStyle(
                                  color: Colors.red,
                                  fontSize: getadaptiveTextSize(context, 15)),
                            ),
                          ),
                          Container(
                            padding: EdgeInsets.only(top: height * 0.020),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Container(
                                  height: height * 0.050,
                                  child: ElevatedButton(
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor:
                                            Colors.blue, // background
                                        foregroundColor:
                                            Colors.black, // foreground
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(
                                              6), // <-- Radius
                                        ),
                                      ),
                                      onPressed: () {
                                        Navigator.of(context).pop();
                                        // saveTransactionToServer(method);
                                        Navigator.push(context,
                                            MaterialPageRoute(
                                          builder: (context) {
                                            return const EditBusinessDetails();
                                          },
                                        ));
                                      },
                                      child: Text(
                                        "Add UPI ID",
                                        style: TextStyle(
                                            color: Colors.white,
                                            fontSize: getadaptiveTextSize(
                                                context, 14)),
                                      )),
                                ),
                                Container(
                                  height: height * 0.050,
                                  child: OutlinedButton(
                                      style: ElevatedButton.styleFrom(
                                        // background
                                        foregroundColor:
                                            Colors.black, // foreground
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(
                                              6), // <-- Radius
                                        ),
                                      ),
                                      onPressed: () {
                                        Navigator.pop(context);
                                      },
                                      child: Text(
                                        "Back To Home",
                                        style: TextStyle(
                                            color: Colors.black,
                                            fontSize: getadaptiveTextSize(
                                                context, 14)),
                                      )),
                                ),
                              ],
                            ),
                          )
                        ],
                      ),
                    ),
                    actions: [],
                  ),
                ),
              );
            }
          } else {
            showDialog<void>(
              context: context,
              builder: (context) => AlertDialog(
                content: Container(
                  height: 220,
                  padding: EdgeInsets.all(2),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Lottie.asset('assets/animations/networkError.json',
                          height: MediaQuery.of(context).size.height * 0.17,
                          // controller: _controller,
                          repeat: true,
                          animate: true),
                      Text(
                        'Network Error',
                        style: TextStyle(
                            fontSize: getadaptiveTextSize(context, 15)),
                      ),
                    ],
                  ),
                ),
                actions: [
                  TextButton(
                    child: Text(
                      'Ok',
                      style:
                          TextStyle(fontSize: getadaptiveTextSize(context, 15)),
                    ),
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                  ),
                ],
              ),
            );
          }
        }
      }
    });
  }

  // sqDemo() {
  // print(dbs.getDBdata());
  // }

  saveTransactionSqlite(String method, String amount, String tranSource) async {
    String time = DateFormat('jms').format(DateTime.now()).toString();
    String date = DateFormat('yMMMd').format(DateTime.now()).toString();
    String amount = inrFormat.format(double.parse(total)).toString();
    String dateTime =
        DateFormat('yyyy-MM-dd HH:mm:ss').format(DateTime.now()).toString();
    final prefs = await SharedPreferences.getInstance();

    int userId = prefs.getInt("userId")!;

    var tran_source = "CALCULATOR";

    dbs.saveTransaction(
        amount, method, time, date, userId, dateTime, 0, tran_source);
    print("Date stored");
    successful(method);

    // try {
    //   showDialog(
    //     context: context,
    //     barrierDismissible: false,
    //     builder: (BuildContext context) {
    //       return Center(
    //         child: Lottie.asset('assets/animations/loader.json',
    //             height: MediaQuery.of(context).size.height * 0.17,
    //             // controller: _controller,
    //             repeat: true,
    //             animate: true),
    //       );
    //     },
    //   );
    // } catch (e) {}
  }

// Future<http.Response>
  void saveTransactionToServer(
      String method, String amount, String tranSource) async {
    String time = DateFormat('jms').format(DateTime.now()).toString();
    String date = DateFormat('yMMMd').format(DateTime.now()).toString();
    String amount = inrFormat.format(double.parse(total)).toString();
    String dateTime =
        DateFormat('yyyy-MM-dd HH:mm:ss').format(DateTime.now()).toString();
    final prefs = await SharedPreferences.getInstance();

    // 'method': method,
    // 'time': time,
    // 'date': date,
    // 'amount': amount,
    // 'user': {
    // 'userId': '${prefs.getInt('userId')}',

    try {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) {
          return Center(
            child: Lottie.asset('assets/animations/loader.json',
                height: MediaQuery.of(context).size.height * 0.17,
                // controller: _controller,
                repeat: true,
                animate: true),
          );
        },
      );

      final response = await http.post(
        Uri.parse(BASE_URL + '/transaction'),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
          'userId': '${prefs.getInt('userId')}'
        },
        body: jsonEncode(<String, dynamic>{
          'method': method,
          'time': time,
          'date': date,
          'amount': amount,
          'userId': '${prefs.getInt('userId')}',
          "dateTime": dateTime,
          'tranSource': tranSource,
          'user': {
            'userId': '${prefs.getInt('userId')}',
          }
        }),
      );

      Navigator.pop(context);
      if (response.statusCode == 200) {
        // If the server did return a 201 CREATED response,
        // then parse the JSON.
        successful(method);
      } else {
        // If the server did not return a 201 CREATED response,
        // then throw an exception.
        showDialog<void>(
          context: context,
          barrierDismissible: false,
          builder: (context) => AlertDialog(
            // title: const Text('Error'),

            insetPadding: EdgeInsets.all(0),
            content: Container(
              height: 220,
              padding: EdgeInsets.all(2),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Lottie.asset('assets/animations/warning.json',
                      height: MediaQuery.of(context).size.height * 0.17,
                      // controller: _controller,
                      repeat: true,
                      animate: true),
                  Text(
                    '${response.body.toString()}',
                    style:
                        TextStyle(fontSize: getadaptiveTextSize(context, 15)),
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(
                style: TextButton.styleFrom(),
                child: Text(
                  'Ok',
                  style: TextStyle(fontSize: getadaptiveTextSize(context, 20)),
                ),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
            ],
          ),
        );
        sleep(Duration(seconds: 1));
      }
    } on SocketException catch (e) {
      // Handle network errors
      Navigator.pop(context);
      showDialog<void>(
        context: context,
        builder: (context) => AlertDialog(
          // title: const Text('Error'),
          content: Container(
            height: 220,
            padding: EdgeInsets.all(2),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Lottie.asset('assets/animations/warning.json',
                    height: MediaQuery.of(context).size.height * 0.17,
                    // controller: _controller,
                    repeat: true,
                    animate: true),
                Text(
                  'Network Error',
                  style: TextStyle(fontSize: getadaptiveTextSize(context, 15)),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              child: Text('Ok',
                  style: TextStyle(fontSize: getadaptiveTextSize(context, 15))),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        ),
      );
    } catch (e) {
      Navigator.pop(context);
      showDialog<void>(
        context: context,
        builder: (context) => AlertDialog(
          content: Container(
            height: 220,
            padding: EdgeInsets.all(2),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Lottie.asset('assets/animations/warning.json',
                    height: MediaQuery.of(context).size.height * 0.17,
                    // controller: _controller,
                    repeat: true,
                    animate: true),
                Text(
                  'Server not Responding',
                  style: TextStyle(fontSize: getadaptiveTextSize(context, 15)),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              child: Text(
                'Ok',
                style: TextStyle(fontSize: getadaptiveTextSize(context, 15)),
              ),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        ),
      );
    }
  }

  // save transactions SharedPreferences
  // Future<void> saveTransaction(String method) async {
  //   var prefs = await SharedPreferences.getInstance();

  //   Map<String, dynamic> singleTransaction = {
  //     "key": prefs.getKeys().length + 1,
  //     "amount": '${inrFormat.format(double.parse(total))}',
  //     "Method": method,
  //     "dateTime": DateFormat('yMMMd').format(DateTime.now()),
  //     "time": DateFormat('jms').format(DateTime.now()),
  //     "currentDay": DateFormat('d').format(DateTime.now()),
  //     "currentMonth": DateFormat('MMM').format(DateTime.now()),
  //     "currentYear": DateFormat('y').format(DateTime.now()),
  //   };

  //   prefs.setString(
  //       '${prefs.getKeys().length + 1}', jsonEncode(singleTransaction));
  //   successful();
  // }

  successful(var method) async {
    final prefs = await SharedPreferences.getInstance();
    var recieptSwitch = prefs.getBool("recieptSwitch") ?? false;

    if (recieptSwitch) {
      // printReciept();
      // printThermalReciept(method, printhelper.sourceCalculator);
      printhelper.printThermalReciept(
          method, printhelper.sourceCalculator, evalString);
    }

    syncTransaction();

    showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        insetPadding: EdgeInsets.only(bottom: 20),

        // title: const Center(
        //   child: Text('Payment Successful'),
        // ),
        // content: Text('Faild To store'),
        content: Container(
            padding: EdgeInsets.only(bottom: 0),
            height: height * 0.268,
            width: width * 0.70,
            child: Column(
              children: [
                Lottie.asset('assets/animations/check_animation.json',
                    height: height * 0.10,
                    // controller: _controller,
                    repeat: false,
                    animate: true),
                Container(
                  padding: EdgeInsets.only(bottom: 0),
                  child: Text(
                    'Payment Successful',
                    style: TextStyle(
                      color: Colors.green,
                      fontSize: getadaptiveTextSize(context, 20),
                    ),
                  ),
                ),
                Container(
                  padding: EdgeInsets.only(bottom: 10),
                  child: Text(
                    '${inrFormat.format(double.parse(total))}',
                    style: TextStyle(
                      color: Colors.black,
                      fontSize: getadaptiveTextSize(context, 30),
                    ),
                  ),
                ),
                Container(
                  padding: EdgeInsets.only(top: 5),
                  width: width * 0.49,
                  height: height * 0.05,
                  child: OutlinedButton(
                    style: TextButton.styleFrom(),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.home_outlined,
                          size: getadaptiveTextSize(context, 19),
                          color: const Color.fromARGB(255, 58, 104, 125),
                        ),
                        Text(
                          'Back To Home',
                          style: TextStyle(
                              color: Colors.black,
                              fontSize: getadaptiveTextSize(context, 15)),
                        ),
                      ],
                    ),
                    onPressed: () {
                      evalString = '0';
                      total = '0';
                      Navigator.of(context).pop();
                      setState(() {});
                    },
                  ),
                ),
              ],
            )),

        actions: [
          // Center(
          //   child: Container(
          //     width: width * 0.51,
          //     height: height * 0.05,
          //     child: OutlinedButton(
          //       style: TextButton.styleFrom(),
          //       child: const Center(
          //           child: Row(
          //         children: [
          //           Icon(
          //             Icons.home_filled,
          //             size: 30,
          //           ),
          //           Text(
          //             'Back To Home',
          //             style: TextStyle(
          //               fontSize: 25,
          //             ),
          //           ),
          //         ],
          //       )),
          //       onPressed: () {
          //         evalString = '0';
          //         total = '0';
          //         Navigator.of(context).pop();
          //         setState(() {});
          //       },
          //     ),
          //   ),
          // ),
        ],
      ),
    );
  }

  void successfulOld() {
    // calling method channel function
    printReciept();

    // showing Successful Message
    showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        insetPadding: EdgeInsets.only(bottom: 20),

        title: const Center(
          child: Text('Payment Successful'),
        ),
        // content: Text('Faild To store'),
        content: Container(
            padding: EdgeInsets.only(bottom: 0),
            height: height * 0.24,
            width: width * 0.70,
            child: Column(
              children: [
                Lottie.asset('assets/animations/check_animation.json',
                    height: height * 0.17,
                    // controller: _controller,
                    repeat: false,
                    animate: true),
                Container(
                  padding: EdgeInsets.only(bottom: 0),
                  child: Text(
                    '${inrFormat.format(double.parse(total))}',
                    style: TextStyle(
                      color: Colors.green,
                      fontSize: getadaptiveTextSize(context, 30),
                    ),
                  ),
                )
              ],
            )),

        actions: [
          TextButton(
            style: TextButton.styleFrom(
              padding: EdgeInsets.all(0),
            ),
            child: const Center(
              child: Text(
                'Ok',
                style: TextStyle(
                  fontSize: 25,
                ),
              ),
            ),
            onPressed: () {
              evalString = '0';
              total = '0';
              Navigator.of(context).pop();
              setState(() {});
            },
          ),
        ],
      ),
    );
  }

  Parser p = Parser();

  void calculate() {
    if (evalString[evalString.length - 1] != '+') {
      Expression exp = p.parse(evalString);
      ContextModel cm = ContextModel();
      if (exp.evaluate(EvaluationType.REAL, cm) > 100000) {
        showToast("Amount should be below ₹100,000", context: context);
      } else {
        setState(() {
          total = '${exp.evaluate(EvaluationType.REAL, cm)}';
        });
      }
    }
  }

  isValidAmount(String newEvalString) {
    if (newEvalString[newEvalString.length - 1] != '+') {
      Expression exp = p.parse(newEvalString);
      ContextModel cm = ContextModel();
      if (exp.evaluate(EvaluationType.REAL, cm) > 100000) {
        return true;
      } else {
        return false;
      }
    }
  }

  // Adding '+' operator in string
  void evaluation() {
    setState(() {
      if (evalString[evalString.length - 1] != "+") {
        evalString += "+";
      }
      calculate();
    });
  }

  void backSpace() {
    setState(() {
      // evalString.
      if (evalString != null && evalString.length > 0) {
        evalString = evalString.substring(0, evalString.length - 1);
      }
      if (evalString.isEmpty) {
        evalString = '0';
        total = '0';
      }

      calculate();
    });
  }

  amountWarning() {
    showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        // insetPadding: EdgeInsets.only(bottom: 20),
        content: Container(
            padding: EdgeInsets.only(bottom: 0),
            height: height * 0.244,
            width: width * 0.70,
            // color: Colors.amber,
            child: Column(
              children: [
                Padding(
                  padding: EdgeInsets.all(0),
                  child: Lottie.asset('assets/animations/wrong.json',
                      height: height * 0.10,
                      // controller: _controller,
                      repeat: true,
                      animate: true),
                ),
                Container(
                    padding: EdgeInsets.only(bottom: height * 0.020, top: 0),
                    // color: Colors.blue,
                    child: Center(
                      child: Column(
                        children: [
                          Text(
                            'Please enter an amount below',
                            softWrap: true,
                            style: TextStyle(
                              color: Colors.red,
                              fontWeight: FontWeight.w700,
                              fontSize: getadaptiveTextSize(context, 15),
                            ),
                          ),
                          Text(
                            '₹100,000.00',
                            softWrap: true,
                            style: TextStyle(
                              color: Colors.red,
                              fontWeight: FontWeight.w900,
                              fontSize: getadaptiveTextSize(context, 20),
                            ),
                          ),
                        ],
                      ),
                    )),
                Container(
                  padding: EdgeInsets.only(bottom: 0),
                  width: width * 0.50,
                  height: height * 0.05,
                  child: OutlinedButton(
                    style: TextButton.styleFrom(),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.home_outlined,
                          size: getadaptiveTextSize(context, 19),
                          color: const Color.fromARGB(255, 58, 104, 125),
                        ),
                        Text(
                          'Back To Home',
                          style: TextStyle(
                              color: Colors.black,
                              fontSize: getadaptiveTextSize(context, 15)),
                        ),
                      ],
                    ),
                    onPressed: () {
                      Navigator.pop(context);
                      setState(() {});
                    },
                  ),
                ),
              ],
            )),
        actions: [],
      ),
    );
  }

  // add number in evalSting
  void addition(String number) {
    setState(() {
      if (evalString == '0') {
        evalString = number;
      } else {
        if (evalString.length - evalString.lastIndexOf('+') < 6) {
          // evalString += number;

          if (isValidAmount(evalString + number)) {
            amountWarning();
            // showToast("Amount should be below ₹100,000.", context: context);
          } else {
            evalString += number;
          }
        } else {
          showToast("Digits in number can be only 5", context: context);
        }
      }
      // double pos = evalString.length as double;
      // scroll(pos);
      calculate();
    });
  }

  int getLastNumberLength(String str) {
    int lastPlusIndex = str.lastIndexOf("+");
    if (lastPlusIndex == -1) {
      return str.length;
    } else {
      return str.length - lastPlusIndex - 1;
    }
  }

  void clear() {
    setState(() {
      evalString = "0";
      total = '00';
    });
  }

  Future<bool> _onWillPopDialouge() async {
    return false;
  }

  var size, width, height, appBarHeight;
  var btnHeight, btnWidth;

  Future<bool> _onWillPop() async {
    return (await showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: new Text('Are you sure?'),
            content: new Text(
              'Do you want to exit an App',
              style: TextStyle(fontSize: getadaptiveTextSize(context, 18)),
            ),
            actions: <Widget>[
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Container(
                    width: width / 4,
                    height: height * 0.05,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue,
                        foregroundColor: Colors.black, // foreground
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(6), // <-- Radius
                        ),
                      ),
                      onPressed: () =>
                          Navigator.of(context).pop(false), //<-- SEE HERE
                      child: new Text(
                        'No',
                        style: TextStyle(
                            fontSize: getadaptiveTextSize(context, 15)),
                      ),
                    ),
                  ),
                  Container(
                    width: width / 4,
                    height: height * 0.05,
                    child: ElevatedButton(
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.black, // foreground
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(6), // <-- Radius
                        ),
                      ),
                      onPressed: () =>
                          Navigator.of(context).pop(true), // <-- SEE HERE
                      child: new Text(
                        'Yes',
                        style: TextStyle(
                            fontSize: getadaptiveTextSize(context, 15)),
                      ),
                    ),
                  ),
                ],
              )
            ],
          ),
        )) ??
        false;
  }

  @override
  Widget build(BuildContext context) {
    size = MediaQuery.of(context).size;
    width = size.width;
    height = size.height;
    appBarHeight = AppBar().preferredSize.height;
    var heightAll = MediaQuery.of(context).padding.top;

    // works on realme 5 pro
    btnHeight = ((height - 337) / 4) - height * 0.033;

    // for terminal
    // btnHeight = ((height - 337) / 4) - height * 0.045;
    btnWidth = ((width - (width / 4)) / 3) - (width * 0.030);

    return WillPopScope(
      onWillPop: _onWillPop,
      child: SafeArea(
        top: false,
        child: Scaffold(
          appBar: AppBar(
            // Here we take the value from the MyHomePage object that was created by
            // the App.build method, and use it to set our appbar title.
            title: Text(
              widget.title,
              style: TextStyle(color: Colors.white, fontFamily: 'Becham'),
            ),

            backgroundColor: Colors.blue,
            // titleTextStyle: TextStyle(color: Colors.white),

            actions: [
              IconButton(
                icon: const Icon(
                  Icons.sync,
                  color: Colors.white,
                ),
                tooltip: 'Sync',
                onPressed: () {
                  // handle the press
                  // Workmanager().initialize(
                  //   callbackDispatcher,
                  //   isInDebugMode: true,
                  // );
                  // syncTask();
                  syncTransaction();
                },
              ),
              IconButton(
                icon: const Icon(
                  Icons.history,
                  color: Colors.white,
                ),
                tooltip: 'Transactions',
                onPressed: () {
                  // handle the press
                  Navigator.push(context, MaterialPageRoute(
                    builder: (context) {
                      return const TransactionsHistory();
                    },
                  ));
                },
              ),
              IconButton(
                icon: const Icon(
                  Icons.menu_outlined,
                  color: Colors.white,
                ),
                tooltip: 'Menu',
                onPressed: () {
                  // handle the press

                  Navigator.push(
                    context,
                    PageRouteBuilder(
                      pageBuilder: (context, animation, secondaryAnimation) =>
                          MenuWidget(),
                      transitionsBuilder:
                          (context, animation, secondaryAnimation, child) {
                        var begin = Offset(1.0, 0.0);
                        var end = Offset.zero;
                        var curve = Curves.ease;

                        var tween = Tween(begin: begin, end: end)
                            .chain(CurveTween(curve: curve));

                        return SlideTransition(
                          position: animation.drive(tween),
                          child: child,
                        );
                      },
                    ),
                  );

                  // Navigator.push(context, MaterialPageRoute(
                  //   builder: (context) {
                  //     return const MenuWidget();
                  //   },
                  // ));
                },
              ),
            ],
            centerTitle: false,
          ),
          resizeToAvoidBottomInset: false,
          body: Center(
            child: Column(
              children: [
                Container(
                  color: Colors.amber,
                  margin: EdgeInsets.only(top: 10),
                  // height: 30,
                  padding: EdgeInsets.all(15),
                  width: width,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Text(
                            "TOTAL AMOUNT ",
                            style: TextStyle(
                                fontSize: getadaptiveTextSize(context, 12),
                                fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),

                      // amount
                      Column(
                        mainAxisAlignment: MainAxisAlignment.end,
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          SingleChildScrollView(
                            scrollDirection: Axis.horizontal,
                            child: Wrap(
                              crossAxisAlignment: WrapCrossAlignment.end,
                              children: [
                                Row(
                                  children: [
                                    Text(
                                      // '$total',
                                      '${inrFormat.format(double.parse(total))}',
                                      overflow: TextOverflow.fade,
                                      softWrap: true,
                                      style: TextStyle(
                                          fontSize:
                                              getadaptiveTextSize(context, 15),
                                          fontWeight: FontWeight.bold),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ],
                      )
                    ],
                  ),
                ),

                // pay bill
                Container(
                  height: height * 0.10,
                  margin: EdgeInsets.all(10),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      // CASH
                      Container(
                          width: (width / 3) - 15,
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.blue, // background
                              foregroundColor: Colors.black, // foreground
                              shape: RoundedRectangleBorder(
                                borderRadius:
                                    BorderRadius.circular(6), // <-- Radius
                              ),
                            ),
                            // style: ButtonStyle(
                            //   backgroundColor:
                            //       MaterialStateProperty.all<Color>(Colors.blue),

                            // ),
                            onPressed: () {
                              payBill("CASH");
                            },
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.money,
                                  size: getadaptiveTextSize(context, 20),
                                  color: Colors.white,
                                ),
                                Text(
                                  'CASH',
                                  style: TextStyle(
                                      color: Colors.white,
                                      fontSize:
                                          getadaptiveTextSize(context, 15)),
                                ),
                              ],
                            ),
                          )),

                      // UPI/QR
                      Container(
                          width: (width / 3) - 15,
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.blue, // background

                              shape: RoundedRectangleBorder(
                                borderRadius:
                                    BorderRadius.circular(6), // <-- Radius
                              ),
                            ),
                            onPressed: () {
                              payBill("QR/UPI");
                            },
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.qr_code,
                                  size: getadaptiveTextSize(context, 20),
                                  color: Colors.white,
                                ),
                                Text(
                                  'UPI/QR',
                                  style: TextStyle(
                                      color: Colors.white,
                                      // fontWeight: FontWeight.w700,
                                      fontSize:
                                          getadaptiveTextSize(context, 15)),
                                ),
                              ],
                            ),
                          )),

                      // Container(
                      //     width: (width / 3) - 15,
                      //     child: ElevatedButton(
                      //       style: ButtonStyle(
                      //         backgroundColor:
                      //             MaterialStateProperty.all<Color>(Colors.blue),
                      //       ),
                      //       onPressed: () {
                      //         // payBill("QR/UPI");
                      //       },
                      //       child: Column(
                      //         mainAxisAlignment: MainAxisAlignment.center,
                      //         children: [
                      //           Icon(
                      //             Icons.more,
                      //             size: getadaptiveTextSize(context, 20),
                      //             color: Colors.white,
                      //           ),
                      //           Text(
                      //             'More',
                      //             style: TextStyle(
                      //                 color: Colors.white,
                      //                 fontSize: getadaptiveTextSize(context, 15)),
                      //           ),
                      //         ],
                      //       ),
                      //     )),
                    ],
                  ),
                ),

                // // Amount & Calculation
                Container(
                  height: height * 0.08,
                  margin: EdgeInsets.only(left: 5, right: 5),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(8),
                    color: Colors.amber[50],
                    border: Border.all(
                      color: Colors.blueGrey,
                      width: 1,
                    ),
                  ),
                  padding: EdgeInsets.all(5),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Column(
                        children: [
                          Container(
                            child: Text(
                              "Amount",
                              overflow: TextOverflow.fade,
                              softWrap: true,
                              style: TextStyle(
                                  fontSize: getadaptiveTextSize(context, 10)),
                            ),
                          ),
                        ],
                      ),

                      // evaluation
                      Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Container(
                            padding: EdgeInsets.only(right: 10),
                            child: Row(
                                mainAxisAlignment: MainAxisAlignment.end,
                                children: [
                                  // Wrap(
                                  //   direction: Axis.horizontal,
                                  //   children: [
                                  Container(
                                    width: width - (width / 3),
                                    alignment: Alignment.centerRight,
                                    child: SingleChildScrollView(
                                      scrollDirection: Axis.horizontal,
                                      controller: _controller,
                                      child: Focus(
                                        focusNode: _focusNode,
                                        child: Text(
                                          '$evalString',
                                          overflow: TextOverflow.fade,
                                          style: TextStyle(
                                            color:
                                                Color.fromARGB(255, 214, 7, 7),
                                            fontSize: getadaptiveTextSize(
                                                context, 15),
                                          ),
                                        ),
                                      ),

                                      // Text(
                                      //   '$evalString',

                                      //   overflow: TextOverflow.fade,
                                      //   // softWrap: true,
                                      //   style: TextStyle(
                                      //       color: Color.fromARGB(255, 214, 7, 7),
                                      //       fontSize:
                                      //           getadaptiveTextSize(context, 15)),
                                      // ),
                                    ),
                                  )
                                  //   ],
                                  // )
                                ]),
                          )
                        ],
                      ),
                    ],
                  ),
                ),

                // buttons
                Center(
                  child: Container(
                    // terminal p3000
                    // height: height * 0.580,

                    // realme 5 pro
                    height: height * 0.52,
                    width: width * 0.95,
                    // color: Colors.amber,
                    padding: EdgeInsets.only(
                      top: height * 0.008,
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          width: width - (width / 4) - width * 0.050,
                          // width: (width / 4) - width * 0.050,
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // 1-3
                              Container(
                                width: (width - (width / 4)),
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceAround,
                                  children: [
                                    // button 1
                                    Container(
                                      height: btnHeight,
                                      width: btnWidth,
                                      child: ElevatedButton(
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: Color.fromARGB(
                                              255, 236, 233, 232), // background

                                          // backgroundColor: Colors.amber,
                                          foregroundColor: Colors.black,

                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(
                                                12), // <-- Radius
                                          ),
                                        ),
                                        onPressed: () {
                                          addition('1');
                                        },
                                        child: Text(
                                          "1",
                                          style: TextStyle(
                                              fontSize: getadaptiveTextSize(
                                                  context, 40)),
                                        ),
                                      ),
                                    ),

                                    // button 2
                                    Container(
                                      height: btnHeight,
                                      width: btnWidth,
                                      child: ElevatedButton(
                                        child: Text(
                                          "2",
                                          style: TextStyle(
                                              fontSize: getadaptiveTextSize(
                                                  context, 40)),
                                        ),
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: Color.fromARGB(
                                              255, 236, 233, 232), // background
                                          foregroundColor: Colors.black,
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(
                                                12), // <-- Radius
                                          ), // foreground
                                        ),
                                        onPressed: () {
                                          addition('2');
                                        },
                                      ),
                                    ),

                                    // button 3
                                    Container(
                                      height: btnHeight,
                                      width: btnWidth,
                                      child: ElevatedButton(
                                        child: Text(
                                          "3",
                                          style: TextStyle(
                                              fontSize: getadaptiveTextSize(
                                                  context, 40)),
                                        ),
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: Color.fromARGB(
                                              255, 236, 233, 232), // background
                                          foregroundColor:
                                              Colors.black, // foreground
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(
                                                12), // <-- Radius
                                          ),
                                        ),
                                        onPressed: () {
                                          addition('3');
                                        },
                                      ),
                                    ),
                                  ],
                                ),
                              ),

                              // 4-6
                              Container(
                                width: width - (width / 4),
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceAround,
                                  children: [
                                    // button 4
                                    Container(
                                      height: btnHeight,
                                      width: btnWidth,
                                      child: ElevatedButton(
                                        child: Text(
                                          "4",
                                          style: TextStyle(
                                              fontSize: getadaptiveTextSize(
                                                  context, 40)),
                                        ),
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: Color.fromARGB(
                                              255, 236, 233, 232), // background
                                          foregroundColor:
                                              Colors.black, // foreground
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(
                                                12), // <-- Radius
                                          ),
                                        ),
                                        onPressed: () {
                                          addition('4');
                                        },
                                      ),
                                    ),

                                    // button 5
                                    Container(
                                      height: btnHeight,
                                      width: btnWidth,
                                      child: ElevatedButton(
                                        child: Text(
                                          "5",
                                          style: TextStyle(
                                              fontSize: getadaptiveTextSize(
                                                  context, 40)),
                                        ),
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: Color.fromARGB(
                                              255, 236, 233, 232), // background
                                          foregroundColor:
                                              Colors.black, // foreground
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(
                                                12), // <-- Radius
                                          ),
                                        ),
                                        onPressed: () {
                                          addition('5');
                                        },
                                      ),
                                    ),

                                    // button 6
                                    Container(
                                      height: btnHeight,
                                      width: btnWidth,
                                      child: ElevatedButton(
                                        child: Text(
                                          "6",
                                          style: TextStyle(
                                              fontSize: getadaptiveTextSize(
                                                  context, 40)),
                                        ),
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: Color.fromARGB(
                                              255, 236, 233, 232), // background
                                          foregroundColor:
                                              Colors.black, // foreground
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(
                                                12), // <-- Radius
                                          ),
                                        ),
                                        onPressed: () {
                                          addition('6');
                                        },
                                      ),
                                    ),
                                  ],
                                ),
                              ),

                              // 7-9
                              Container(
                                width: width - (width / 4),
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceAround,
                                  children: [
                                    // button 7
                                    Container(
                                      height: btnHeight,
                                      width: btnWidth,
                                      child: ElevatedButton(
                                        child: Text(
                                          "7",
                                          style: TextStyle(
                                              fontSize: getadaptiveTextSize(
                                                  context, 40)),
                                        ),
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: Color.fromARGB(
                                              255, 236, 233, 232), // background
                                          foregroundColor:
                                              Colors.black, // foreground
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(
                                                12), // <-- Radius
                                          ),
                                        ),
                                        onPressed: () {
                                          addition('7');
                                        },
                                      ),
                                    ),

                                    // button 8
                                    Container(
                                      height: btnHeight,
                                      width: btnWidth,
                                      child: ElevatedButton(
                                        child: Text(
                                          "8",
                                          style: TextStyle(
                                              fontSize: getadaptiveTextSize(
                                                  context, 40)),
                                        ),
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: Color.fromARGB(
                                              255, 236, 233, 232), // background
                                          foregroundColor:
                                              Colors.black, // foreground
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(
                                                12), // <-- Radius
                                          ),
                                        ),
                                        onPressed: () {
                                          addition('8');
                                        },
                                      ),
                                    ),

                                    // button 9
                                    Container(
                                      height: btnHeight,
                                      width: btnWidth,
                                      child: ElevatedButton(
                                        child: Text(
                                          "9",
                                          style: TextStyle(
                                              fontSize: getadaptiveTextSize(
                                                  context, 40)),
                                        ),
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: Color.fromARGB(
                                              255, 236, 233, 232), // background
                                          foregroundColor:
                                              Colors.black, // foreground
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(
                                                12), // <-- Radius
                                          ),
                                        ),
                                        onPressed: () {
                                          addition('9');
                                        },
                                      ),
                                    ),
                                  ],
                                ),
                              ),

                              // clear-0-+
                              Container(
                                width: width - (width / 4),
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceAround,
                                  children: [
                                    // button clear
                                    Container(
                                      height: btnHeight,
                                      width: btnWidth,
                                      child: ElevatedButton(
                                        child: Text(
                                          "C",
                                          style: TextStyle(
                                              fontSize: getadaptiveTextSize(
                                                  context, 20)),
                                        ),
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: Color.fromARGB(
                                              255, 236, 233, 232), // background
                                          foregroundColor:
                                              Colors.black, // foreground
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(
                                                12), // <-- Radius
                                          ),
                                        ),
                                        onPressed: () {
                                          clear();
                                        },
                                      ),
                                    ),

                                    // button 0
                                    Container(
                                      height: btnHeight,
                                      width: btnWidth * 2,
                                      child: ElevatedButton(
                                        child: Text(
                                          "0",
                                          style: TextStyle(
                                              fontSize: getadaptiveTextSize(
                                                  context, 40)),
                                        ),
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: Color.fromARGB(
                                              255, 236, 233, 232), // background
                                          foregroundColor:
                                              Colors.black, // foreground
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(
                                                12), // <-- Radius
                                          ),
                                        ),
                                        onPressed: () {
                                          addition('0');
                                        },
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                        Container(
                          width: (width / 4) - width * 0.010,
                          height: height - 337,
                          child: Container(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.spaceAround,
                              children: [
                                // / back button
                                Container(
                                  height: btnHeight * 2 + (btnHeight * 0.090),
                                  width: btnWidth - btnWidth * 0.00005,
                                  // color: Color.fromARGB(255, 236, 233, 232),
                                  child: TextButton(
                                    style: TextButton.styleFrom(
                                      backgroundColor: Color.fromARGB(
                                          255, 236, 233, 232), // background
                                      foregroundColor:
                                          Colors.black, // foreground
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(
                                            12), // <-- Radius
                                      ),
                                    ),
                                    child: Center(
                                      child: Icon(
                                        Icons.arrow_back,
                                        color: Colors.black,
                                        size: 50,
                                      ),
                                    ),
                                    onPressed: () {
                                      backSpace();
                                    },
                                  ),
                                ),

                                // button add/addition
                                Container(
                                  height: btnHeight * 2 + (btnHeight * 0.090),
                                  width: btnWidth,
                                  // color: Color.fromARGB(255, 236, 233, 232),
                                  child: TextButton(
                                    style: TextButton.styleFrom(
                                      backgroundColor: Color.fromARGB(
                                          255, 236, 233, 232), // background
                                      foregroundColor:
                                          Colors.black, // foreground
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(
                                            12), // <-- Radius
                                      ),
                                    ),
                                    child: Icon(
                                      Icons.add,
                                      color: Colors.black,
                                      size: 50,
                                    ),
                                    onPressed: () {
                                      // addition('+');
                                      evaluation();
                                    },
                                  ),
                                )
                              ],
                            ),
                          ),
                        )
                      ],
                    ),
                  ),
                ),

                // Button
              ],
            ),
          ),
        ),
      ),
    );
  }
}

import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_esc_pos_utils/flutter_esc_pos_utils.dart';
import 'package:print_bluetooth_thermal/post_code.dart';
import 'package:print_bluetooth_thermal/print_bluetooth_thermal.dart';
import 'package:image/image.dart' as img;
import 'package:print_bluetooth_thermal/print_bluetooth_thermal_windows.dart';
import 'package:flutter_esc_pos_utils/flutter_esc_pos_utils.dart' as qrsize;
import 'package:shared_preferences/shared_preferences.dart';

class Connectprinter extends StatefulWidget {
  const Connectprinter({super.key});

  @override
  State<Connectprinter> createState() => _ConnectprinterState();
}

class _ConnectprinterState extends State<Connectprinter> {
  var size, width, height;
  var conDeviceMac = '', conDeviceName = '';
  String _info = "";
  String _msj = '';
  bool connected = false;
  List<BluetoothInfo> items = [];
  final List<String> _options = [
    "permission bluetooth granted",
    "bluetooth enabled",
    "connection status",
    "update info"
  ];

  String _selectSize = "2";
  final _txtText = TextEditingController(text: "Hello developer");
  bool _progress = false;
  String _msjprogress = "";

  String optionprinttype = "58 mm";
  List<String> options = ["58 mm", "80 mm"];

  @override
  void initState() {
    // TODO: implement initState
    initPlatformState();
    checkPaired();
    super.initState();
  }

  checkPaired() async {
    final prefs = await SharedPreferences.getInstance();
    var resultq = await PrintBluetoothThermal.disconnect;
    String mac = prefs.getString("mac") ?? '';
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

  @override
  Widget build(BuildContext context) {
    size = MediaQuery.of(context).size;
    width = size.width;
    height = size.height;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Connect Printer'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
        centerTitle: false,
        actions: [
          PopupMenuButton(
            elevation: 3.2,
            //initialValue: _options[1],
            onCanceled: () {
              print('You have not chossed anything');
            },
            tooltip: 'Menu',
            onSelected: (Object select) async {
              String sel = select as String;
              if (sel == "permission bluetooth granted") {
                bool status =
                    await PrintBluetoothThermal.isPermissionBluetoothGranted;
                setState(() {
                  _info = "permission bluetooth granted: $status";
                });
                //open setting permision if not granted permision
              } else if (sel == "bluetooth enabled") {
                bool state = await PrintBluetoothThermal.bluetoothEnabled;
                setState(() {
                  _info = "Bluetooth enabled: $state";
                });
              } else if (sel == "update info") {
                initPlatformState();
              } else if (sel == "connection status") {
                final bool result =
                    await PrintBluetoothThermal.connectionStatus;
                connected = result;
                setState(() {
                  _info = "connection status: $result";
                });
              }
            },
            itemBuilder: (BuildContext context) {
              return _options.map((String option) {
                return PopupMenuItem(
                  value: option,
                  child: Text(option),
                );
              }).toList();
            },
          )
        ],
      ),
      body: SingleChildScrollView(
        scrollDirection: Axis.vertical,
        child: Container(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            spacing: 3,
            children: [
              Text('info: $_info\n '),
              Text(_msj),
              if (!connected)
                Text(
                    'If your device not listed here, go to bluetooth settings and pair the printer'),
              // Row(
              //   children: [
              //     const Text("Type print"),
              //     const SizedBox(width: 10),
              //     DropdownButton<String>(
              //       value: optionprinttype,
              //       items: options.map((String option) {
              //         return DropdownMenuItem<String>(
              //           value: option,
              //           child: Text(option),
              //         );
              //       }).toList(),
              //       onChanged: (String? newValue) {
              //         setState(() {
              //           optionprinttype = newValue!;
              //         });
              //       },
              //     ),
              //   ],
              // ),
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Container(
                  width: width * 0.90,
                  padding: EdgeInsets.all(10),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                        child: ElevatedButton(
                          onPressed: () {
                            disconnect();
                            getBluetoots();
                          },
                          child: Row(
                            children: [
                              Visibility(
                                visible: _progress,
                                child: const SizedBox(
                                  width: 25,
                                  height: 25,
                                  child: CircularProgressIndicator.adaptive(
                                      strokeWidth: 1,
                                      backgroundColor: Colors.blue),
                                ),
                              ),
                              const SizedBox(width: 5),
                              Text(_progress ? _msjprogress : "Search"),
                            ],
                          ),
                        ),
                      ),
                      Container(
                        child: ElevatedButton(
                          onPressed: connected ? disconnect : null,
                          child: const Text("Disconnect"),
                        ),
                      ),
                      Container(
                        child: ElevatedButton(
                          onPressed: connected ? printTest : null,
                          child: const Text("Test"),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              connected
                  ? Container(
                      child: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Connected Device",
                          style: TextStyle(
                              fontSize: 20, fontWeight: FontWeight.bold),
                        ),
                        ListTile(
                          title: Text('Name: ${conDeviceName}'),
                          subtitle: Text("macAddress: ${conDeviceMac}"),
                        ),
                      ],
                    ))
                  : items.isEmpty
                      ? Container()
                      : Container(
                          height: height * 0.70,
                          decoration: BoxDecoration(
                            borderRadius:
                                const BorderRadius.all(Radius.circular(10)),
                            color: Colors.grey.withAlpha(50),
                          ),
                          child: ListView.builder(
                            itemCount: items.isNotEmpty ? items.length : 0,
                            itemBuilder: (context, index) {
                              return ListTile(
                                onTap: () {
                                  String mac = items[index].macAdress;
                                  String name = items[index].name;

                                  connect(mac, name);
                                },
                                title: Text('Name: ${items[index].name}'),
                                subtitle: Text(
                                    "macAddress: ${items[index].macAdress}"),
                              );
                            },
                          )),
              const SizedBox(height: 10),
              // Container(
              //   padding: const EdgeInsets.all(10),
              //   decoration: BoxDecoration(
              //     borderRadius: const BorderRadius.all(Radius.circular(10)),
              //     color: Colors.grey.withAlpha(50),
              //   ),
              //   child: Column(children: [
              //     const Text(
              //         "Text size without the library without external packets, print images still it should not use a library"),
              //     const SizedBox(height: 10),
              //     Row(
              //       children: [
              //         Expanded(
              //           child: TextField(
              //             controller: _txtText,
              //             decoration: const InputDecoration(
              //               border: OutlineInputBorder(),
              //               labelText: "Text",
              //             ),
              //           ),
              //         ),
              //         const SizedBox(width: 5),
              //         DropdownButton<String>(
              //           hint: const Text('Size'),
              //           value: _selectSize,
              //           items: <String>['1', '2', '3', '4', '5']
              //               .map((String value) {
              //             return DropdownMenuItem<String>(
              //               value: value,
              //               child: Text(value),
              //             );
              //           }).toList(),
              //           onChanged: (String? select) {
              //             setState(() {
              //               _selectSize = select.toString();
              //             });
              //           },
              //         )
              //       ],
              //     ),
              //     ElevatedButton(
              //       onPressed: connected ? printWithoutPackage : null,
              //       child: const Text("Print"),
              //     ),
              //   ]),
              // ),
              const SizedBox(height: 10),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> initPlatformState() async {
    String platformVersion;
    int porcentbatery = 0;
    // Platform messages may fail, so we use a try/catch PlatformException.
    try {
      platformVersion = await PrintBluetoothThermal.platformVersion;
      //print("patformversion: $platformVersion");
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

  Future<void> getBluetoots() async {
    setState(() {
      _progress = true;
      _msjprogress = "Wait";
      items = [];
    });
    final List<BluetoothInfo> listResult =
        await PrintBluetoothThermal.pairedBluetooths;

    /*await Future.forEach(listResult, (BluetoothInfo bluetooth) {
      String name = bluetooth.name;
      String mac = bluetooth.macAdress;
    });*/

    setState(() {
      _progress = false;
    });

    if (listResult.length == 0) {
      _msj =
          "There are no bluetoohs linked, go to settings and link the printer";
    } else {
      _msj = "Touch an item in the list to connect";
    }

    setState(() {
      items = listResult;
    });
  }

  Future<void> connect(String mac, String name) async {
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

  Future<void> disconnect() async {
    final bool status = await PrintBluetoothThermal.disconnect;
    final prefs = await SharedPreferences.getInstance();
    prefs.setString("mac", '');
    setState(() {
      connected = false;
    });
    print("status disconnect $status");
  }

  Future<void> printTest() async {
    /*if (kDebugMode) {
      bool result = await PrintBluetoothThermalWindows.writeBytes(bytes: "Hello \n".codeUnits);
      return;
    }*/

    bool conexionStatus = await PrintBluetoothThermal.connectionStatus;
    //print("connection status: $conexionStatus");
    if (conexionStatus) {
      bool result = false;
      if (Platform.isWindows) {
        List<int> ticket = await testWindows();
        result = await PrintBluetoothThermalWindows.writeBytes(bytes: ticket);
      } else {
        List<int> ticket = await testTicket();
        result = await PrintBluetoothThermal.writeBytes(ticket);
      }
      print("print test result:  $result");
    } else {
      print("print test conexionStatus: $conexionStatus");
      setState(() {
        disconnect();
      });
      //throw Exception("Not device connected");
    }
  }

  Future<void> printString() async {
    bool conexionStatus = await PrintBluetoothThermal.connectionStatus;
    if (conexionStatus) {
      String enter = '\n';
      await PrintBluetoothThermal.writeBytes(enter.codeUnits);
      //size of 1-5
      String text = "Hello";
      await PrintBluetoothThermal.writeString(
          printText: PrintTextSize(size: 1, text: text));
      await PrintBluetoothThermal.writeString(
          printText: PrintTextSize(size: 2, text: "$text size 2"));
      await PrintBluetoothThermal.writeString(
          printText: PrintTextSize(size: 3, text: "$text size 3"));
    } else {
      //desconectado
      print("desconectado bluetooth $conexionStatus");
    }
  }

  Future<List<int>> testTicket() async {
    List<int> bytes = [];
    // Using default profile
    final profile = await CapabilityProfile.load();

    // final generator = Generator(
    //     optionprinttype == "58 mm" ? PaperSize.mm58 : PaperSize.mm80, profile);
    final generator = Generator(
        optionprinttype == "58 mm" ? PaperSize.mm58 : PaperSize.mm80, profile);
    bytes += generator.setGlobalFont(PosFontType.fontA);
    bytes += generator.reset();
    // bytes += generator.image();

    // final Uint8List bytesImg = Base64Codec().decode(imgData);
    // img.Image? image = img.decodeImage(bytesImg);

    final ByteData data = await rootBundle.load('assets/images/logo.png');
    final Uint8List bytesImg = data.buffer.asUint8List();
    img.Image? image = img.decodeImage(bytesImg);

    // if (Platform.isIOS) {
    // Resizes the image to half its original size and reduces the quality to 80%
    final resizedImage = img.copyResize(image!,
        width: image.width ~/ 1.3,
        height: image.height ~/ 1.3,
        interpolation: img.Interpolation.nearest);
    final bytesimg = Uint8List.fromList(img.encodeJpg(resizedImage));
    image = img.decodeImage(bytesimg);
    // }

    //Using `ESC *`
    // bytes += generator.image(
    //   image!,
    //   align: PosAlign.center,
    // );

    // bytes += generator.text(
    //     'Regular: aA bB cC dD eE fF gG hH iI jJ kK lL mM nN oO pP qQ rR sS tT uU vV wW xX yY zZ');
    // bytes += generator.text('Special 1: ñÑ àÀ èÈ éÉ üÜ çÇ ôÔ',
    //     styles: const PosStyles(codeTable: 'CP1252'));
    // bytes += generator.text('Special 2: blåbærgrød',
    //     styles: const PosStyles(codeTable: 'CP1252'));

    // bytes += generator.text('Bold text', styles: const PosStyles(bold: true));
    // bytes += generator.text('Reverse text',
    //     styles: const PosStyles(fontType: PosFontType.fontA));
    // bytes += generator.text('Underlined text',
    //     styles: const PosStyles(underline: true), linesAfter: 1);
    // bytes += generator.text('Align left',
    //     styles: const PosStyles(align: PosAlign.left));
    // bytes += generator.text('Align center',
    //     styles: const PosStyles(align: PosAlign.center));
    // bytes += generator.text('Align right',
    //     styles: const PosStyles(align: PosAlign.right), linesAfter: 1);

    // bytes += generator.row([
    //   PosColumn(
    //     text: 'col3',
    //     width: 3,
    //     styles: const PosStyles(align: PosAlign.center, underline: true),
    //   ),
    //   PosColumn(
    //     text: 'col6',
    //     width: 6,
    //     styles: const PosStyles(align: PosAlign.center, underline: true),
    //   ),
    //   PosColumn(
    //     text: 'col3',
    //     width: 3,
    //     styles: const PosStyles(align: PosAlign.center, underline: true),
    //   ),
    // ]);

    bytes += PostCode.text(
      text: "Printer Test",
      fontSize: FontSize.big,
      align: AlignPos.center,
    );

    bytes += PostCode.text(
      text: "Powerd By: vizpay business solution pvt1234567890123456789",
      fontSize: FontSize.normal,
      align: AlignPos.center,
    );

    //barcode

    final List<int> barData = [1, 2, 3, 4, 5, 6, 7, 8, 9, 0, 4];
    bytes += generator.barcode(Barcode.upcA(barData));

    //QR code
    bytes +=
        generator.qrcode('https://www.vizpay.in/', size: qrsize.QRSize.size8);

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

  Future<List<int>> testWindows() async {
    List<int> bytes = [];

    bytes += PostCode.text(
        text:
            "compressed-\naaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa",
        fontSize: FontSize.compressed);
    bytes += PostCode.text(
        text:
            "Size normal\nbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb",
        fontSize: FontSize.normal);
    bytes += PostCode.text(
        text:
            "Bold\bcccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc",
        bold: true);
    bytes += PostCode.text(
        text:
            "Inverse\nddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddd",
        inverse: true);
    // bytes += PostCode.text(text: "AlignPos right", align: AlignPos.right);
    bytes += PostCode.text(
        text:
            "Double Height\neeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee",
        fontSize: FontSize.doubleHeight);
    bytes += PostCode.text(
        text:
            "Double Width\nfffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff",
        fontSize: FontSize.doubleWidth);
    bytes += PostCode.text(
        text:
            "Size big\nggggggggggggggggggggggggggggggggggggggggggggggggggggggggg",
        fontSize: FontSize.big);
    bytes += PostCode.enter();

    //List of rows
    bytes += PostCode.row(
        texts: ["PRODUCT", "VALUE"],
        proportions: [60, 40],
        fontSize: FontSize.compressed);
    for (int i = 0; i < 3; i++) {
      bytes += PostCode.row(
          texts: ["Item $i", "$i,00"],
          proportions: [60, 40],
          fontSize: FontSize.compressed);
    }

    bytes += PostCode.line();

    bytes += PostCode.barcode(barcodeData: "123456789");
    bytes += PostCode.qr("123456789");

    bytes += PostCode.enter(nEnter: 5);

    return bytes;
  }

  Future<void> printWithoutPackage() async {
    //impresion sin paquete solo de PrintBluetoothTermal
    bool connectionStatus = await PrintBluetoothThermal.connectionStatus;
    if (connectionStatus) {
      String text = "${_txtText.text}\n";
      bool result = await PrintBluetoothThermal.writeString(
          printText: PrintTextSize(size: int.parse(_selectSize), text: text));
      print("status print result: $result");
      setState(() {
        _msj = "printed status: $result";
      });
    } else {
      //no conectado, reconecte
      setState(() {
        _msj = "no connected device";
      });
      print("no conectado");
    }
  }

  String imgData =
      "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";
}

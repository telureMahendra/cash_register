// import 'package:bluetooth_print_plus/bluetooth_print_plus.dart';
// import 'package:cash_register/helper/service/command_tool_Blue_plus.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter/services.dart';
// import 'package:widgets_to_image/widgets_to_image.dart';

// enum CmdType { Tsc, Cpcl, Esc }

// class FunctionPage extends StatefulWidget {
//   final BluetoothDevice device;

//   const FunctionPage(this.device, {super.key});

//   @override
//   State<FunctionPage> createState() => _FunctionPageState();
// }

// class _FunctionPageState extends State<FunctionPage> {
//   CmdType cmdType = CmdType.Tsc;

//   @override
//   void deactivate() {
//     // TODO: implement deactivate
//     super.deactivate();
//     _disconnect();
//   }

//   void _disconnect() async {
//     await BluetoothPrintPlus.disconnect();
//   }

//   WidgetsToImageController widgetsToImageController =
//       WidgetsToImageController();
//   Uint8List? bytes;

//   @override
//   Widget build(BuildContext context) {
//     // TODO: implement build
//     return Scaffold(
//       appBar: AppBar(
//         title: Text(widget.device.name ?? ""),
//       ),
//       body: Column(
//         children: [
//           // buildRadioGroupRowWidget(),
//           const SizedBox(
//             height: 20,
//           ),

//           WidgetsToImage(
//             controller: widgetsToImageController,
//             child: cardWidget(),
//           ),

//           OutlinedButton(
//               onPressed: () async {
//                 final bytes = await widgetsToImageController.capture();
//                 setState(() {
//                   this.bytes = bytes;
//                 });
//               },
//               child: Text("Generate Image")),
//           Row(
//             mainAxisAlignment: MainAxisAlignment.spaceAround,
//             children: [
//               OutlinedButton(
//                   onPressed: () async {
//                     // final ByteData bytes =
//                     //     await rootBundle.load("assets/images/business.png");
//                     // final Uint8List image = bytes.buffer.asUint8List();
//                     Uint8List? cmd;
//                     cmd = await CommandTool.escImageCmd(bytes!);
//                     // switch (cmdType) {
//                     //   case CmdType.Tsc:
//                     //     cmd = await CommandTool.tscImageCmd(image);
//                     //     break;
//                     //   case CmdType.Cpcl:
//                     //     cmd = await CommandTool.cpclImageCmd(image);
//                     //     break;
//                     //   case CmdType.Esc:
//                     //     cmd = await CommandTool.escImageCmd(image);
//                     //     break;
//                     // }
//                     // await BluetoothPrintPlus.
//                     await BluetoothPrintPlus.write(cmd);
//                   },
//                   child: Text("image")),
//             ],
//           ),
//           Row(
//             mainAxisAlignment: MainAxisAlignment.spaceAround,
//             children: [
//               OutlinedButton(
//                   onPressed: () async {
//                     Uint8List? cmd;
//                     cmd = await CommandTool.printSize1();
//                     await BluetoothPrintPlus.write(cmd);

//                     Uint8List? cmd1;
//                     cmd1 = await CommandTool.printSize7();
//                     await BluetoothPrintPlus.write(cmd1);
//                     // switch (cmdType) {
//                     //   case CmdType.Tsc:
//                     //     cmd = await CommandTool.tscTemplateCmd();
//                     //     break;
//                     //   case CmdType.Cpcl:
//                     //     cmd = await CommandTool.cpclTemplateCmd();
//                     //     break;
//                     //   case CmdType.Esc:
//                     //     cmd = await CommandTool.escTemplateCmd();
//                     //     break;
//                     // }

//                     // print("getCommand $cmd");
//                   },
//                   child: Text("text/QR_code/barcode")),
//             ],
//           ),
//           Row(
//             mainAxisAlignment: MainAxisAlignment.spaceAround,
//             children: [
//               OutlinedButton(
//                   onPressed: () async {
//                     await BluetoothPrintPlus.disconnect();
//                     Navigator.pop(context);
//                     // switch (cmdType) {
//                     //   case CmdType.Tsc:
//                     //     cmd = await CommandTool.tscTemplateCmd();
//                     //     break;
//                     //   case CmdType.Cpcl:
//                     //     cmd = await CommandTool.cpclTemplateCmd();
//                     //     break;
//                     //   case CmdType.Esc:
//                     //     cmd = await CommandTool.escTemplateCmd();
//                     //     break;
//                     // }

//                     // print("getCommand $cmd");
//                   },
//                   child: Text("Disconnect")),
//             ],
//           ),
//           if (bytes != null)
//             Container(
//               height: 100,
//               width: 100,
//               child: buildImage(bytes!),
//             )
//         ],
//       ),
//     );
//   }

//   Row buildRadioGroupRowWidget() {
//     return Row(children: [
//       const Text("command type"),
//       ...CmdType.values
//           .map((e) => Row(
//                 mainAxisSize: MainAxisSize.min,
//                 children: [
//                   Radio(
//                     value: e,
//                     groupValue: cmdType,
//                     onChanged: (v) {
//                       setState(() {
//                         cmdType = e;
//                       });
//                     },
//                   ),
//                   Text(e.toString().split(".").last)
//                 ],
//               ))
//           .toList()
//     ]);
//   }

//   Widget buildImage(Uint8List bytes) => Image.memory(bytes);

//   Widget cardWidget() {
//     return Card(
//       shape: RoundedRectangleBorder(
//         borderRadius: BorderRadius.circular(16),
//       ),
//       elevation: 4,
//       child: Row(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           ClipRRect(
//             borderRadius: const BorderRadius.horizontal(
//               left: Radius.circular(16),
//             ),
//             child: Image.network(
//               'https://mhtwyat.com/wp-content/uploads/2022/02/%D8%A7%D8%AC%D9%85%D9%84-%D8%A7%D9%84%D8%B5%D9%88%D8%B1-%D8%B9%D9%86-%D8%A7%D9%84%D8%B1%D8%B3%D9%88%D9%84-%D8%B5%D9%84%D9%89-%D8%A7%D9%84%D9%84%D9%87-%D8%B9%D9%84%D9%8A%D9%87-%D9%88%D8%B3%D9%84%D9%85-1-1.jpg',
//               width: 100,
//               height: 100,
//               fit: BoxFit.cover,
//             ),
//           ),
//           Container(
//             padding: const EdgeInsets.all(16),
//             child: const Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 Text(
//                   "Title",
//                   style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
//                 ),
//                 SizedBox(height: 4),
//                 Text(
//                   "Description",
//                   style: TextStyle(fontSize: 16),
//                 ),
//               ],
//             ),
//           )
//         ],
//       ),
//     );
//   }
// }

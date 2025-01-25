import 'package:bluetooth_print_plus/bluetooth_print_plus.dart';
import 'package:cash_register/helper/service/command_tool.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

enum CmdType { Tsc, Cpcl, Esc }

class FunctionPage extends StatefulWidget {
  final BluetoothDevice device;

  const FunctionPage(this.device, {super.key});

  @override
  State<FunctionPage> createState() => _FunctionPageState();
}

class _FunctionPageState extends State<FunctionPage> {
  CmdType cmdType = CmdType.Tsc;

  @override
  void deactivate() {
    // TODO: implement deactivate
    super.deactivate();
    _disconnect();
  }

  void _disconnect() async {
    await BluetoothPrintPlus.disconnect();
  }

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.device.name ?? ""),
      ),
      body: Column(
        children: [
          // buildRadioGroupRowWidget(),
          const SizedBox(
            height: 20,
          ),

          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              OutlinedButton(
                  onPressed: () async {
                    final ByteData bytes =
                        await rootBundle.load("assets/images/logo.png");
                    final Uint8List image = bytes.buffer.asUint8List();
                    Uint8List? cmd;
                    cmd = await CommandTool.escImageCmd(image);
                    // switch (cmdType) {
                    //   case CmdType.Tsc:
                    //     cmd = await CommandTool.tscImageCmd(image);
                    //     break;
                    //   case CmdType.Cpcl:
                    //     cmd = await CommandTool.cpclImageCmd(image);
                    //     break;
                    //   case CmdType.Esc:
                    //     cmd = await CommandTool.escImageCmd(image);
                    //     break;
                    // }
                    await BluetoothPrintPlus.write(cmd);
                  },
                  child: Text("image")),
            ],
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              OutlinedButton(
                  onPressed: () async {
                    Uint8List? cmd;
                    cmd = await CommandTool.printSize1();
                    await BluetoothPrintPlus.write(cmd);

                    Uint8List? cmd1;
                    cmd1 = await CommandTool.printSize7();
                    await BluetoothPrintPlus.write(cmd1);
                    // switch (cmdType) {
                    //   case CmdType.Tsc:
                    //     cmd = await CommandTool.tscTemplateCmd();
                    //     break;
                    //   case CmdType.Cpcl:
                    //     cmd = await CommandTool.cpclTemplateCmd();
                    //     break;
                    //   case CmdType.Esc:
                    //     cmd = await CommandTool.escTemplateCmd();
                    //     break;
                    // }

                    // print("getCommand $cmd");
                  },
                  child: Text("text/QR_code/barcode")),
            ],
          )
        ],
      ),
    );
  }

  Row buildRadioGroupRowWidget() {
    return Row(children: [
      const Text("command type"),
      ...CmdType.values
          .map((e) => Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Radio(
                    value: e,
                    groupValue: cmdType,
                    onChanged: (v) {
                      setState(() {
                        cmdType = e;
                      });
                    },
                  ),
                  Text(e.toString().split(".").last)
                ],
              ))
          .toList()
    ]);
  }
}

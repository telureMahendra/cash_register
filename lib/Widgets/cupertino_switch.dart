import 'dart:convert';

import 'package:cash_register/Widgets/logo_widget.dart';
import 'package:cash_register/common_utils/common_functions.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class CupertinoSwitchWidget extends StatefulWidget {
  final String btnName;
  final String switchKeyName;
  final bool isLogoShow;
  const CupertinoSwitchWidget(
      {super.key,
      required this.switchKeyName,
      required this.btnName,
      required this.isLogoShow});

  @override
  State<CupertinoSwitchWidget> createState() => _CupertinoSwitchWidgetState();
}

class _CupertinoSwitchWidgetState extends State<CupertinoSwitchWidget> {
  var size, width, height;
  bool btnValue = true;
  bool isLogoPrint = false;

  @override
  void initState() {
    // WidgetsBinding.instance.addPostFrameCallback((timeStamp) {});
    print("initstate invoked");
    super.initState();
    getStatus();
  }

  getStatus() async {
    final prefs = await SharedPreferences.getInstance();
    btnValue = prefs.getBool(widget.switchKeyName) ?? false;
    isLogoPrint = prefs.getBool(widget.switchKeyName) ?? false;
    print("getstatus invoked");

    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    size = MediaQuery.of(context).size;
    width = size.width;
    height = size.height;
    if (kDebugMode) {
      print("build invoked");
    }
    return ListTile(
      title: Container(
        padding: EdgeInsets.only(top: 5, bottom: 5, left: 15, right: 15),
        child: Column(
          children: [
            Container(
              alignment: Alignment.topLeft,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    widget.btnName,
                    style: TextStyle(
                        fontSize: getadaptiveTextSize(context, 15),
                        fontWeight: FontWeight.bold),
                  ),
                  CupertinoSwitch(
                    value: btnValue,
                    onChanged: (value) async {
                      final prefs = await SharedPreferences.getInstance();
                      prefs.setBool(widget.switchKeyName, value);
                      btnValue = value;
                      setState(() {});
                    },
                  ),
                  // if (widget.isLogoShow)
                  //   FutureBuilder(
                  //       future: loadImage(),
                  //       builder: (context, snapshot) {
                  //         if (snapshot.connectionState == ConnectionState.waiting) {
                  //           return Center(
                  //             child: CircularProgressIndicator(),
                  //             // child: buildSkeleton(context),
                  //           );
                  //         } else if (snapshot.hasError) {
                  //           return Center(
                  //             child: Text(
                  //               'Error: ${snapshot.error}',
                  //               style: TextStyle(
                  //                   color: Colors.red,
                  //                   fontSize: getadaptiveTextSize(context, 20)),
                  //             ),
                  //           ); // Handle error
                  //         } else if (snapshot.data == null) {
                  //           // Todo : snapshot.data.isEmpty handel
                  //           return Container();
                  //         } else if (snapshot.hasData) {
                  //           return Image.memory(
                  //             Base64Decoder().convert(snapshot.data!),
                  //             fit: BoxFit.fitWidth,
                  //             width: width * 0.22,

                  //             // height:
                  //             //     width * 0.22,
                  //           );
                  //         } else {
                  //           return Text('no image'); // Handle empty data case
                  //         }
                  //       }),
                ],
              ),
            ),
            if (widget.isLogoShow && btnValue) LogoWidget()
          ],
        ),
      ),
    );
  }
}

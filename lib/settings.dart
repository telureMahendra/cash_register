import 'package:cash_register/Widgets/cupertino_switch.dart';
import 'package:cash_register/common_utils/common_functions.dart';
import 'package:cash_register/common_utils/strings.dart';

import 'package:flutter/material.dart';

class SettingsWidget extends StatefulWidget {
  const SettingsWidget({super.key});

  @override
  State<SettingsWidget> createState() => _SettingsWidgetState();
}

class _SettingsWidgetState extends State<SettingsWidget> {
  var size, width, height;
  String image = '';

  @override
  void initState() {
    super.initState();
    loadImage();
  }

  late bool recieptSwitch = true;
  late bool isPrintGST = false;
  late bool isLogoPrint = false;

  @override
  Widget build(BuildContext context) {
    size = MediaQuery.of(context).size;
    width = size.width;
    height = size.height;
    return Scaffold(
        appBar: AppBar(
          title: Text(
            "Settings",
            style: TextStyle(color: Colors.white, fontFamily: 'Becham'),
          ),
          backgroundColor: Colors.blue,
          foregroundColor: Colors.white,
          centerTitle: false,
        ),
        resizeToAvoidBottomInset: false,
        body: Container(
          child: Column(
            children: [
              Expanded(
                child: SizedBox(
                  height: 200.0,
                  child: ListView(
                    shrinkWrap: true,
                    children: [
                      Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SizedBox(height: 16),
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Text(
                              "Print Settings",
                              style: Theme.of(context)
                                  .textTheme
                                  .headlineMedium
                                  ?.copyWith(fontSize: 16),
                            ),
                          ),
                          Container(
                            width: double.infinity,
                            color: Colors.white,
                            child: Column(
                              children: [
                                CupertinoSwitchWidget(
                                  btnName: printRecieptSwithText,
                                  switchKeyName: printRecieptSwitchKeyName,
                                  isLogoShow: false,
                                ),
                                CupertinoSwitchWidget(
                                  btnName: printGstSwitchText,
                                  switchKeyName: printGstSwitchKeyName,
                                  isLogoShow: false,
                                ),
                                CupertinoSwitchWidget(
                                  btnName: printLogoSwitchText,
                                  switchKeyName: printLogoSwitchKeyName,
                                  isLogoShow: true,
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),

                      // business profile start here
                      Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SizedBox(height: 16),
                          Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    "Profile Settings",
                                    style: Theme.of(context)
                                        .textTheme
                                        // .headline1
                                        .headlineMedium
                                        ?.copyWith(fontSize: 16),
                                  ),
                                ],
                              )),
                          Container(
                            width: double.infinity,
                            color: Colors.white,
                            child: Column(
                              children: [
                                // ListTile(
                                //   title: Container(
                                //     padding: EdgeInsets.all(15),
                                //     child: Container(
                                //         alignment: Alignment.topLeft,
                                //         child: Row(
                                //           children: [
                                //             Text(
                                //               "Businness Name",
                                //               style: TextStyle(
                                //                   fontSize: getadaptiveTextSize(
                                //                       context, 15),
                                //                   fontWeight: FontWeight.bold),
                                //             ),
                                //           ],
                                //         )),
                                //   ),
                                //   onTap: () {},
                                // ),
                                // ListTile(
                                //   title: Container(
                                //     padding: EdgeInsets.only(
                                //         top: 5, bottom: 5, left: 15, right: 15),
                                //     child: Container(
                                //         alignment: Alignment.topLeft,
                                //         child: Row(
                                //           mainAxisAlignment:
                                //               MainAxisAlignment.spaceBetween,
                                //           children: [
                                //             Text(
                                //               "Print Logo",
                                //               style: TextStyle(
                                //                   fontSize: getadaptiveTextSize(
                                //                       context, 15),
                                //                   fontWeight: FontWeight.bold),
                                //             ),
                                //             CupertinoSwitch(
                                //               value: isLogoPrint,
                                //               onChanged: (value) {
                                //                 setState(() {
                                //                   changePrintLogo(value);
                                //                   // recieptSwitch = value;
                                //                 });
                                //               },
                                //             ),
                                //           ],
                                //         )),
                                //   ),
                                //   onTap: () {},
                                // ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      // business profile ends here
                    ],
                  ),
                ),
              ),
            ],
          ),
        ));
  }
}

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_styled_toast/flutter_styled_toast.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SettingsWidget extends StatefulWidget {
  const SettingsWidget({super.key});

  @override
  State<SettingsWidget> createState() => _SettingsWidgetState();
}

class _SettingsWidgetState extends State<SettingsWidget> {
  var size, width, height;

  @override
  void initState() {
    super.initState();

    getStatus();
    setState(() {});
  }

  late bool recieptSwitch = true;
  late bool isPrintGST = false;
  late bool printLogo = false;

  // bool logoswitch = false;

  getStatus() async {
    final prefs = await SharedPreferences.getInstance();
    recieptSwitch = prefs.getBool('recieptSwitch') ?? false;
    isPrintGST = prefs.getBool('isPrintGST') ?? false;
    printLogo = prefs.getBool('printLogo') ?? false;
    setState(() {});
  }

  changePrintLogo(status) async {
    final prefs = await SharedPreferences.getInstance();
    printLogo = status;
    prefs.setBool('printLogo', printLogo);
    setState(() {});
  }

  changeGSTStatus(status) async {
    final prefs = await SharedPreferences.getInstance();
    isPrintGST = status;
    prefs.setBool('isPrintGST', isPrintGST);
    setState(() {});

    // final prefs = await SharedPreferences.getInstance();
    // recieptSwitch = status;
    // prefs.setBool('recieptSwitch', recieptSwitch);
    // setState(() {});
  }

  changePrintStatus(status) async {
    final prefs = await SharedPreferences.getInstance();
    recieptSwitch = status;
    prefs.setBool('recieptSwitch', recieptSwitch);
    setState(() {});
  }

  getadaptiveTextSize(BuildContext context, dynamic value) {
    return (value / 710) * MediaQuery.of(context).size.height;
  }

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
                                ListTile(
                                  title: Container(
                                    padding: EdgeInsets.only(
                                        top: 5, bottom: 5, left: 15, right: 15),
                                    child: Container(
                                        alignment: Alignment.topLeft,
                                        child: Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          children: [
                                            Text(
                                              "Print Reciept",
                                              style: TextStyle(
                                                  fontSize: getadaptiveTextSize(
                                                      context, 15),
                                                  fontWeight: FontWeight.bold),
                                            ),
                                            CupertinoSwitch(
                                              value: recieptSwitch,
                                              onChanged: (value) {
                                                setState(() {
                                                  changePrintStatus(value);
                                                  // recieptSwitch = value;
                                                });
                                              },
                                            ),
                                          ],
                                        )),
                                  ),
                                  onTap: () {},
                                ),
                                ListTile(
                                  title: Container(
                                    padding: EdgeInsets.only(
                                        top: 5, bottom: 5, left: 15, right: 15),
                                    child: Container(
                                        alignment: Alignment.topLeft,
                                        child: Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          children: [
                                            Text(
                                              "Print GST Number",
                                              style: TextStyle(
                                                  fontSize: getadaptiveTextSize(
                                                      context, 15),
                                                  fontWeight: FontWeight.bold),
                                            ),
                                            CupertinoSwitch(
                                              value: isPrintGST,
                                              onChanged: (value) {
                                                setState(() {
                                                  changeGSTStatus(value);
                                                  // showToast(
                                                  //     "Available for only prime members",
                                                  //     context: context);
                                                  // logoswitch = value;
                                                });
                                              },
                                            ),
                                          ],
                                        )),
                                  ),
                                  onTap: () {},
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
                                ListTile(
                                  title: Container(
                                    padding: EdgeInsets.only(
                                        top: 5, bottom: 5, left: 15, right: 15),
                                    child: Container(
                                        alignment: Alignment.topLeft,
                                        child: Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          children: [
                                            Text(
                                              "Print Logo",
                                              style: TextStyle(
                                                  fontSize: getadaptiveTextSize(
                                                      context, 15),
                                                  fontWeight: FontWeight.bold),
                                            ),
                                            CupertinoSwitch(
                                              value: printLogo,
                                              onChanged: (value) {
                                                setState(() {
                                                  changePrintLogo(value);
                                                  // recieptSwitch = value;
                                                });
                                              },
                                            ),
                                          ],
                                        )),
                                  ),
                                  onTap: () {},
                                ),
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

import 'package:cash_register/ConnectPrinter_print_bluetooth_thermal.dart';
import 'package:cash_register/helper/ConnectPrinter_Blue_plus.dart';
import 'package:cash_register/login.dart';

import 'package:cash_register/profile.dart';
import 'package:cash_register/settings.dart';
import 'package:cash_register/imageCrop.dart';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter/src/widgets/placeholder.dart';
import 'package:flutter_styled_toast/flutter_styled_toast.dart';

import 'package:shared_preferences/shared_preferences.dart';
// import 'package:url_launcher/url_launcher.dart';

class MenuWidget extends StatefulWidget {
  const MenuWidget({super.key});

  @override
  State<MenuWidget> createState() => _MenuWidgetState();
}

class _MenuWidgetState extends State<MenuWidget> {
  var size, width, height;
  var username = '';

  var userId;

  Future<void> getData() async {
    final prefs = await SharedPreferences.getInstance();
    username = prefs.getString("username").toString();
    userId = prefs.getInt('userId');
    setState(() {});
  }

  Future<void> userLogout(BuildContext context) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => const LoginScreen(),
      ),
    );
  }

  @override
  void initState() {
    getData();
    super.initState();
  }

  // Future<void> _launchURL(url) async {
  //   //you can also just use "void" or nothing at all - they all seem to work in this case
  //   if (!await launchUrl(url)) {
  //     throw Exception('Could not launch $url');
  //   }
  // }

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
            "Menu",
            style: TextStyle(color: Colors.white, fontFamily: 'Becham'),
          ),
          backgroundColor: Colors.blue,
          foregroundColor: Colors.white,
          centerTitle: false,
        ),
        resizeToAvoidBottomInset: false,
        body: Center(
            child: Container(
          child: Column(
            children: [
              Card(
                  elevation: 5,
                  child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Container(
                          // height: height * 0.05,
                          width: width * 0.90,
                          // padding: EdgeInsets.only(right: 20),
                          child: Column(
                            // mainAxisAlignment: MainAxisAlignment.start,
                            // crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.start,
                                children: [
                                  Stack(
                                    children: [
                                      Container(
                                        // child: Image.asset(
                                        //     'assets/images/vizpay_logo.jpeg'),
                                        height: width * 0.22,
                                        width: width * 0.22,

                                        child: Center(
                                          child: Text(
                                            username != null &&
                                                    username.isNotEmpty
                                                ? username[0]
                                                : '0',
                                            style: TextStyle(
                                                fontWeight: FontWeight.bold,
                                                fontSize: getadaptiveTextSize(
                                                    context, 50)),
                                          ),
                                        ),
                                        decoration: BoxDecoration(
                                          borderRadius:
                                              BorderRadius.circular(50),
                                          color: Colors.amber,
                                          border: Border.all(
                                            color: Color.fromARGB(255, 0, 0, 0),
                                            width: 1,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  Container(
                                    padding:
                                        EdgeInsets.only(left: height * 0.015),
                                    // width: width * 0.35,
                                    child: Text(
                                      '${username} ',
                                      style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize:
                                              getadaptiveTextSize(context, 18)),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          )))),
              Container(
                child: Expanded(
                  child: SingleChildScrollView(
                      child: Column(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                        Card(
                          elevation: 5,
                          child: InkWell(
                              child: Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Container(
                                      height: height * 0.05,
                                      width: width * 0.90,
                                      child: Row(
                                        children: [
                                          TextButton(
                                            child: Row(
                                              children: [
                                                Icon(Icons.person_2_outlined,
                                                    color: Colors.black),
                                                Text("My Profile",
                                                    style: TextStyle(
                                                        color: Colors.black))
                                              ],
                                            ),
                                            onPressed: () {
                                              Navigator.push(context,
                                                  MaterialPageRoute(
                                                builder: (context) {
                                                  return ProfileScreen();
                                                },
                                              ));
                                            },
                                          )
                                        ],
                                      ))),
                              onTap: () {
                                Navigator.push(context, MaterialPageRoute(
                                  builder: (context) {
                                    return ProfileScreen();
                                  },
                                ));
                              }),
                        ),
                        Card(
                          elevation: 5,
                          child: InkWell(
                              child: Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Container(
                                      height: height * 0.05,
                                      width: width * 0.90,
                                      child: Row(
                                        children: [
                                          TextButton(
                                            child: Row(
                                              children: [
                                                Icon(Icons.print_outlined,
                                                    color: Colors.black),
                                                Text("Printer Configuration",
                                                    style: TextStyle(
                                                        color: Colors.black))
                                              ],
                                            ),
                                            onPressed: () async {
                                              Navigator.push(context,
                                                  MaterialPageRoute(
                                                builder: (context) {
                                                  return Connectprinter();
                                                },
                                              ));
                                            },
                                          )
                                        ],
                                      ))),
                              onTap: () {
                                Navigator.push(context, MaterialPageRoute(
                                  builder: (context) {
                                    return Connectprinter();
                                  },
                                ));
                              }),
                        ),
                        Card(
                          elevation: 5,
                          child: InkWell(
                              child: Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Container(
                                      height: height * 0.05,
                                      width: width * 0.90,
                                      child: Row(
                                        children: [
                                          TextButton(
                                            child: Row(
                                              children: [
                                                Icon(Icons.settings_outlined,
                                                    color: Colors.black),
                                                Text("Settings",
                                                    style: TextStyle(
                                                        color: Colors.black))
                                              ],
                                            ),
                                            onPressed: () {
                                              Navigator.push(context,
                                                  MaterialPageRoute(
                                                builder: (context) {
                                                  return SettingsWidget();
                                                },
                                              ));
                                            },
                                          )
                                        ],
                                      ))),
                              onTap: () {
                                Navigator.push(context, MaterialPageRoute(
                                  builder: (context) {
                                    return SettingsWidget();
                                  },
                                ));
                              }),
                        ),
                        Card(
                          elevation: 5,
                          child: InkWell(
                              child: Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Container(
                                      height: height * 0.05,
                                      width: width * 0.90,
                                      child: Row(
                                        children: [
                                          TextButton(
                                            child: Row(
                                              children: [
                                                Icon(Icons.privacy_tip_outlined,
                                                    color: Colors.black),
                                                Text("Privacy Policy",
                                                    style: TextStyle(
                                                        color: Colors.black))
                                              ],
                                            ),
                                            onPressed: () {},
                                          )
                                        ],
                                      ))),
                              onTap: () {
                                // _launchURL(Uri.https('google.com', ''));
                                showToast("Under Construction!",
                                    context: context);
                              }),
                        ),
                        Card(
                          elevation: 5,
                          child: InkWell(
                              child: Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Container(
                                      height: height * 0.05,
                                      width: width * 0.90,
                                      child: Row(
                                        children: [
                                          TextButton(
                                            child: Row(
                                              children: [
                                                Icon(Icons.list,
                                                    color: Colors.black),
                                                Text("Term And Conditions",
                                                    style: TextStyle(
                                                        color: Colors.black))
                                              ],
                                            ),
                                            onPressed: () {},
                                          )
                                        ],
                                      ))),
                              onTap: () {
                                showToast("Under Construction!",
                                    context: context);
                              }),
                        ),
                        Card(
                          elevation: 5,
                          child: InkWell(
                              child: Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Container(
                                      height: height * 0.05,
                                      width: width * 0.90,
                                      child: Row(
                                        children: [
                                          TextButton(
                                            child: Row(
                                              children: [
                                                Icon(Icons.share_outlined,
                                                    color: Colors.black),
                                                Text("Share With Your Friends",
                                                    style: TextStyle(
                                                        color: Colors.black))
                                              ],
                                            ),
                                            onPressed: () {},
                                          )
                                        ],
                                      ))),
                              onTap: () {
                                showToast("Under Construction!",
                                    context: context);
                              }),
                        ),
                        Card(
                          elevation: 5,
                          child: InkWell(
                              child: Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Container(
                                      height: height * 0.05,
                                      width: width * 0.90,
                                      child: Row(
                                        children: [
                                          TextButton(
                                            child: Row(
                                              children: [
                                                Icon(
                                                    Icons.contact_page_outlined,
                                                    color: Colors.black),
                                                Text("Contact Us",
                                                    style: TextStyle(
                                                        color: Colors.black))
                                              ],
                                            ),
                                            onPressed: () {},
                                          )
                                        ],
                                      ))),
                              onTap: () {
                                showToast("Under Construction!",
                                    context: context);
                              }),
                        ),
                        Card(
                          elevation: 5,
                          child: InkWell(
                              child: Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Container(
                                      height: height * 0.05,
                                      width: width * 0.90,
                                      child: Row(
                                        children: [
                                          TextButton(
                                            child: Row(
                                              children: [
                                                Icon(Icons.help_outline,
                                                    color: Colors.black),
                                                Text("Help",
                                                    style: TextStyle(
                                                        color: Colors.black))
                                              ],
                                            ),
                                            onPressed: () {},
                                          )
                                        ],
                                      ))),
                              onTap: () {
                                showToast("Under Construction!",
                                    context: context);
                              }),
                        ),
                        Card(
                          elevation: 5,
                          child: InkWell(
                              child: Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Container(
                                      height: height * 0.05,
                                      width: width * 0.90,
                                      child: Row(
                                        children: [
                                          TextButton(
                                            child: Row(
                                              children: [
                                                Icon(
                                                  Icons.flag_outlined,
                                                  color: Colors.black,
                                                ),
                                                Text(
                                                  "Report a Problem",
                                                  style: TextStyle(
                                                      color: Colors.black),
                                                )
                                              ],
                                            ),
                                            onPressed: () {},
                                          )
                                        ],
                                      ))),
                              onTap: () {
                                showToast("Under Construction!",
                                    context: context);
                              }),
                        ),
                        Card(
                          elevation: 5,
                          child: InkWell(
                              child: Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Container(
                                      height: height * 0.05,
                                      width: width * 0.90,
                                      child: Row(
                                        children: [
                                          TextButton(
                                            child: Row(
                                              children: [
                                                Icon(Icons.info_outline,
                                                    color: Colors.black),
                                                Text("About Us",
                                                    style: TextStyle(
                                                        color: Colors.black))
                                              ],
                                            ),
                                            onPressed: () {},
                                          )
                                        ],
                                      ))),
                              onTap: () {
                                showToast("Under Construction!",
                                    context: context);
                              }),
                        ),
                        Card(
                          elevation: 5,
                          child: InkWell(
                              child: Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Container(
                                      height: height * 0.05,
                                      width: width * 0.90,
                                      child: Row(
                                        children: [
                                          TextButton(
                                            child: Row(
                                              children: [
                                                Icon(Icons.rate_review_outlined,
                                                    color: Colors.black),
                                                Text("Rate This App",
                                                    style: TextStyle(
                                                        color: Colors.black))
                                              ],
                                            ),
                                            onPressed: () {},
                                          )
                                        ],
                                      ))),
                              onTap: () {
                                showToast("Under Construction!",
                                    context: context);
                              }),
                        ),
                        Card(
                          elevation: 5,
                          child: InkWell(
                              child: Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Container(
                                      height: height * 0.05,
                                      width: width * 0.90,
                                      child: Row(
                                        children: [
                                          TextButton(
                                            child: Row(
                                              children: [
                                                Icon(Icons.logout,
                                                    color: Colors.black),
                                                Text("Logout",
                                                    style: TextStyle(
                                                        color: Colors.black))
                                              ],
                                            ),
                                            onPressed: () {
                                              userLogout(context);
                                            },
                                          )
                                        ],
                                      ))),
                              onTap: () {
                                // showToast("Under Construction!", context: context);
                                userLogout(context);
                              }),
                        ),
                        Padding(
                            padding: EdgeInsets.only(bottom: height * 0.075))
                      ])),
                ),
              ),
            ],
          ),
        )));
  }
}

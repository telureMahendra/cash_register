import 'package:cash_register/login.dart';
import 'package:cash_register/printTest.dart';
import 'package:cash_register/profile.dart';

import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter/src/widgets/placeholder.dart';
import 'package:flutter_styled_toast/flutter_styled_toast.dart';

import 'package:shared_preferences/shared_preferences.dart';
// import 'package:url_launcher/url_launcher.dart';

class SettingWidget extends StatefulWidget {
  const SettingWidget({super.key});

  @override
  State<SettingWidget> createState() => _SettingWidgetState();
}

class _SettingWidgetState extends State<SettingWidget> {
  var size, width, height;

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

  // Future<void> _launchURL(url) async {
  //   //you can also just use "void" or nothing at all - they all seem to work in this case
  //   if (!await launchUrl(url)) {
  //     throw Exception('Could not launch $url');
  //   }
  // }

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
          centerTitle: false,
        ),
        resizeToAvoidBottomInset: false,
        body: Center(
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
                                          style: TextStyle(color: Colors.black))
                                    ],
                                  ),
                                  onPressed: () {
                                    Navigator.push(context, MaterialPageRoute(
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
                                          style: TextStyle(color: Colors.black))
                                    ],
                                  ),
                                  onPressed: () async {
                                    // userLogout(context);
                                    Navigator.push(context, MaterialPageRoute(
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
                          return PrintTestScreen();
                        },
                      ));
                      showToast("Under Construction!", context: context);
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
                                          style: TextStyle(color: Colors.black))
                                    ],
                                  ),
                                  onPressed: () {},
                                )
                              ],
                            ))),
                    onTap: () {
                      // _launchURL(Uri.https('google.com', ''));
                      showToast("Under Construction!", context: context);
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
                                      Icon(Icons.list, color: Colors.black),
                                      Text("Term And Conditions",
                                          style: TextStyle(color: Colors.black))
                                    ],
                                  ),
                                  onPressed: () {},
                                )
                              ],
                            ))),
                    onTap: () {
                      showToast("Under Construction!", context: context);
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
                                          style: TextStyle(color: Colors.black))
                                    ],
                                  ),
                                  onPressed: () {},
                                )
                              ],
                            ))),
                    onTap: () {
                      showToast("Under Construction!", context: context);
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
                                      Icon(Icons.contact_page_outlined,
                                          color: Colors.black),
                                      Text("Contact Us",
                                          style: TextStyle(color: Colors.black))
                                    ],
                                  ),
                                  onPressed: () {},
                                )
                              ],
                            ))),
                    onTap: () {
                      showToast("Under Construction!", context: context);
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
                                          style: TextStyle(color: Colors.black))
                                    ],
                                  ),
                                  onPressed: () {},
                                )
                              ],
                            ))),
                    onTap: () {
                      showToast("Under Construction!", context: context);
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
                                        style: TextStyle(color: Colors.black),
                                      )
                                    ],
                                  ),
                                  onPressed: () {},
                                )
                              ],
                            ))),
                    onTap: () {
                      showToast("Under Construction!", context: context);
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
                                          style: TextStyle(color: Colors.black))
                                    ],
                                  ),
                                  onPressed: () {},
                                )
                              ],
                            ))),
                    onTap: () {
                      showToast("Under Construction!", context: context);
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
                                          style: TextStyle(color: Colors.black))
                                    ],
                                  ),
                                  onPressed: () {},
                                )
                              ],
                            ))),
                    onTap: () {
                      showToast("Under Construction!", context: context);
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
                                      Icon(Icons.logout, color: Colors.black),
                                      Text("Logout",
                                          style: TextStyle(color: Colors.black))
                                    ],
                                  ),
                                  onPressed: () {
                                    userLogout(context);
                                  },
                                )
                              ],
                            ))),
                    onTap: () {
                      showToast("Under Construction!", context: context);
                    }),
              ),
              Padding(padding: EdgeInsets.only(bottom: 20))
            ]))));
  }
}

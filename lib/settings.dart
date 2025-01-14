import 'dart:convert';
import 'dart:io';

import 'package:cash_register/editProfile.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_styled_toast/flutter_styled_toast.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SettingsWidget extends StatefulWidget {
  const SettingsWidget({super.key});

  @override
  State<SettingsWidget> createState() => _SettingsWidgetState();
}

class _SettingsWidgetState extends State<SettingsWidget> {
  var size, width, height;
  var image;

  @override
  void initState() {
    super.initState();
    loadImage();
    getStatus();
    setState(() {});
  }

  late bool recieptSwitch = true;
  late bool isPrintGST = false;
  late bool isLogoPrint = false;
  // late bool isLogoPrint =false;
  // prefs.getBool('isLogoPrint')

  // bool logoswitch = false;
  File? galleryFile;
  final picker = ImagePicker();

  void _showPicker({
    required BuildContext context,
  }) {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return SafeArea(
          child: Wrap(
            children: <Widget>[
              ListTile(
                leading: const Icon(Icons.photo_library),
                title: const Text('Photo Library'),
                onTap: () {
                  getImage(ImageSource.gallery);
                  Navigator.of(context).pop();
                },
              ),
              ListTile(
                leading: const Icon(Icons.photo_camera),
                title: const Text('Camera'),
                onTap: () {
                  getImage(ImageSource.camera);
                  Navigator.of(context).pop();
                },
              ),
            ],
          ),
        );
      },
    );
  }

  Future getImage(
    ImageSource img,
  ) async {
    final pickedFile = await picker.pickImage(source: img);
    XFile? xfilePick = pickedFile;
    setState(
      () {
        if (xfilePick != null) {
          galleryFile = File(pickedFile!.path);
          storeImage();
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Nothing is selected')));
        }
      },
    );
  }

  String convertIntoBase64(File file) {
    List<int> imageBytes = file.readAsBytesSync();
    String base64File = base64Encode(imageBytes);
    return base64File;
  }

  storeImage() async {
    final prefs = await SharedPreferences.getInstance();
    prefs.setString("image", convertIntoBase64(galleryFile!));
    loadImage();
  }

  loadImage() async {
    final prefs = await SharedPreferences.getInstance();
    image = prefs.getString("image").toString();
    setState(() {});
  }

  getStatus() async {
    final prefs = await SharedPreferences.getInstance();
    recieptSwitch = prefs.getBool('recieptSwitch') ?? false;
    isPrintGST = prefs.getBool('isPrintGST') ?? false;
    isLogoPrint = prefs.getBool('isLogoPrint') ?? false;
    setState(() {});
  }

  changePrintLogo(status) async {
    final prefs = await SharedPreferences.getInstance();
    var logo = prefs.getString('image')!;

    if (logo.isNotEmpty) {
      isLogoPrint = status;
      prefs.setBool('isLogoPrint', isLogoPrint);
      setState(() {});
    } else {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => const EditProfile(),
        ),
      );
    }
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
                                ListTile(
                                  title: Container(
                                    padding: EdgeInsets.only(
                                        top: 5, bottom: 5, left: 15, right: 15),
                                    child: Container(
                                        alignment: Alignment.topLeft,
                                        child: Column(
                                          children: [
                                            Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment
                                                      .spaceBetween,
                                              children: [
                                                Text(
                                                  "Print Logo",
                                                  style: TextStyle(
                                                      fontSize:
                                                          getadaptiveTextSize(
                                                              context, 15),
                                                      fontWeight:
                                                          FontWeight.bold),
                                                ),
                                                CupertinoSwitch(
                                                  value: isLogoPrint,
                                                  onChanged: (value) {
                                                    setState(() {
                                                      changePrintLogo(value);
                                                      // recieptSwitch = value;
                                                    });
                                                  },
                                                ),
                                              ],
                                            ),
                                            if (isLogoPrint)
                                              Container(
                                                child: Row(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment
                                                          .spaceEvenly,
                                                  children: [
                                                    Container(
                                                      child: Stack(
                                                        children: [
                                                          Container(
                                                            padding:
                                                                EdgeInsets.all(
                                                                    10),
                                                            // child: Image.asset(
                                                            //     'assets/images/vizpay_logo.jpeg'),
                                                            // height:
                                                            //     width * 0.22,
                                                            // width: width * 0.22,

                                                            // ignore: sort_child_properties_last
                                                            child: image == null
                                                                ? const Center(
                                                                    child: Text(
                                                                        'Issue while Loading image!!'))
                                                                : Image.memory(
                                                                    Base64Decoder()
                                                                        .convert(
                                                                            image),
                                                                    fit: BoxFit
                                                                        .fitWidth,
                                                                    width:
                                                                        width *
                                                                            0.22,

                                                                    // height:
                                                                    //     width * 0.22,
                                                                  ),

                                                            // Center(child: Image.file(galleryFile!)),
                                                            // CircleAvatar(
                                                            //     radius: 50,
                                                            //     backgroundColor:
                                                            //         Colors
                                                            //             .amber,
                                                            //     child:
                                                            //         Padding(
                                                            //       padding: const EdgeInsets
                                                            //           .all(
                                                            //           0), // Border radius
                                                            //       child:
                                                            //           ClipOval(
                                                            //         child: Image
                                                            //             .memory(
                                                            //           Base64Decoder()
                                                            //               .convert(image),
                                                            //           fit: BoxFit
                                                            //               .fitWidth,
                                                            //           // width:
                                                            //           //     width * 0.22,
                                                            //           // height:
                                                            //           //     width * 0.22,
                                                            //         ),
                                                            //       ),
                                                            //     ),
                                                            //   ),
                                                            // Center(child: Image.file(galleryFile!)),
                                                            // Center(
                                                            // child: Image.memory(
                                                            //   Base64Decoder().convert(image),
                                                            //   fit: BoxFit.fill,
                                                            // ),
                                                            //   ),
                                                            decoration:
                                                                BoxDecoration(
                                                              borderRadius:
                                                                  BorderRadius
                                                                      .circular(
                                                                          15),
                                                              // color:
                                                              //     Colors.amber,

                                                              border:
                                                                  Border.all(
                                                                color: Color
                                                                    .fromARGB(
                                                                        255,
                                                                        0,
                                                                        0,
                                                                        0),
                                                                width: 1,
                                                              ),
                                                            ),
                                                          ),
                                                        ],
                                                      ),
                                                    ),
                                                    Container(
                                                      child: Container(
                                                        // height: width * 0.22,
                                                        // width: width * 0.22,
                                                        // padding: EdgeInsets.only(top: 20),

                                                        child: Column(
                                                          mainAxisAlignment:
                                                              MainAxisAlignment
                                                                  .end,
                                                          children: [
                                                            TextButton(
                                                              onPressed: () {
                                                                _showPicker(
                                                                    context:
                                                                        context);
                                                              },
                                                              child: Icon(
                                                                Icons
                                                                    .add_a_photo_rounded,
                                                                color: Colors
                                                                    .black,
                                                                size: 40,
                                                              ),
                                                            )
                                                            // Icon(
                                                            //   Icons.mode_edit,
                                                            //   color: Colors.blueAccent,
                                                            //   size: 40,
                                                            // ),
                                                          ],
                                                        ),
                                                      ),
                                                    )
                                                  ],
                                                ),
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

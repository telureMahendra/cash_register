import 'dart:convert';
import 'dart:io';

import 'package:cash_register/editBusinessDetails.dart';
import 'package:cash_register/editProfile.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  var size, width, height;
  var username = '';

  var userId, email, mobile;
  var businessName,
      address,
      businessEmail,
      businessMobile,
      gstNumber,
      upiID,
      image;

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

  @override
  initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {});
    getData();
    loadImage();
    setState(() {});
  }

  Future<void> getData() async {
    final prefs = await SharedPreferences.getInstance();
    username = prefs.getString("username").toString();
    userId = prefs.getInt('userId');
    email = prefs.getString('email');
    mobile = prefs.getString('mobile');
    businessName = prefs.getString("businessName");
    address = prefs.getString("address");
    businessEmail = prefs.getString("businessEmail");
    businessMobile = prefs.getString("businessMobile");
    gstNumber = prefs.getString("gstNumber") ?? '';
    upiID = prefs.getString("upiID") ?? '';

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
          'Profile',
          style: TextStyle(color: Colors.white, fontFamily: 'Becham'),
        ),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
      ),
      body: Center(
          child: Container(
        height: height * 0.90,
        child: Column(children: [
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
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
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
                                        username != null && username.isNotEmpty
                                            ? username[0]
                                            : '0',
                                        style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: getadaptiveTextSize(
                                                context, 50)),
                                      ),
                                    ),
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(50),
                                      color: Colors.amber,
                                      border: Border.all(
                                        color: Color.fromARGB(255, 0, 0, 0),
                                        width: 1,
                                      ),
                                    ),
                                  ),
                                  // Container(
                                  //   // child: Image.asset(
                                  //   //     'assets/images/vizpay_logo.jpeg'),
                                  //   height: width * 0.22,
                                  //   width: width * 0.22,

                                  //   // ignore: sort_child_properties_last
                                  //   child: image == null
                                  //       ? const Center(
                                  //           child: Text(
                                  //               'Issue while Loading image!!'))
                                  //       :
                                  //       // Center(child: Image.file(galleryFile!)),
                                  //       CircleAvatar(
                                  //           radius: 50,
                                  //           backgroundColor: Colors.amber,
                                  //           child: Padding(
                                  //             padding: const EdgeInsets.all(
                                  //                 0), // Border radius
                                  //             child: ClipOval(
                                  //               child: Image.memory(
                                  //                 Base64Decoder()
                                  //                     .convert(image),
                                  //                 fit: BoxFit.fitWidth,
                                  //                 width: width * 0.22,
                                  //                 height: width * 0.22,
                                  //               ),
                                  //             ),
                                  //           ),
                                  //         ),
                                  //   // Center(child: Image.file(galleryFile!)),
                                  //   // Center(
                                  //   // child: Image.memory(
                                  //   //   Base64Decoder().convert(image),
                                  //   //   fit: BoxFit.fill,
                                  //   // ),
                                  //   //   ),
                                  //   decoration: BoxDecoration(
                                  //     borderRadius: BorderRadius.circular(50),
                                  //     color: Colors.amber,
                                  //     border: Border.all(
                                  //       color: Color.fromARGB(255, 0, 0, 0),
                                  //       width: 1,
                                  //     ),
                                  //   ),
                                  // ),
                                  // Container(
                                  //   height: width * 0.22,
                                  //   width: width * 0.22,
                                  //   // padding: EdgeInsets.only(top: 20),

                                  //   child: Column(
                                  //     mainAxisAlignment: MainAxisAlignment.end,
                                  //     children: [
                                  //       TextButton(
                                  //         onPressed: () {
                                  //           _showPicker(context: context);
                                  //         },
                                  //         child: Icon(
                                  //           Icons.add_a_photo_rounded,
                                  //           color: Colors.black,
                                  //           size: 40,
                                  //         ),
                                  //       )
                                  //       // Icon(
                                  //       //   Icons.mode_edit,
                                  //       //   color: Colors.blueAccent,
                                  //       //   size: 40,
                                  //       // ),
                                  //     ],
                                  //   ),
                                  // )
                                ],
                              ),
                              Container(
                                // padding: EdgeInsets.only(left: height * 0.015),
                                width: width * 0.35,
                                child: Text(
                                  '${username} ',
                                  style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize:
                                          getadaptiveTextSize(context, 18)),
                                ),
                              ),
                              Container(
                                  alignment: Alignment.centerRight,
                                  padding: EdgeInsets.all(10),
                                  // width: width * 0.29,
                                  child: ElevatedButton(
                                      onPressed: () {
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (context) =>
                                                const EditProfile(),
                                          ),
                                        );
                                      },
                                      style: ElevatedButton.styleFrom(
                                        padding: const EdgeInsets.only(
                                            left: 5, right: 5),
                                      ),
                                      child: Row(
                                        children: [
                                          Icon(Icons.edit),
                                          Text("Edit Profile")
                                        ],
                                      ))),
                            ],
                          ),
                        ],
                      )))),
          Container(
            child: Expanded(
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
                            "Personal Profile",
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
                                  padding: EdgeInsets.all(15),
                                  child: Column(
                                    children: [
                                      Container(
                                          alignment: Alignment.topLeft,
                                          child: Row(
                                            children: [
                                              Icon(Icons.person_2),
                                              Text(
                                                "Name",
                                                style: TextStyle(
                                                    fontSize:
                                                        getadaptiveTextSize(
                                                            context, 15),
                                                    fontWeight:
                                                        FontWeight.bold),
                                              ),
                                            ],
                                          )),
                                      Container(
                                        padding:
                                            EdgeInsets.only(left: width * 0.08),
                                        alignment: Alignment.topLeft,
                                        child: Text('${username}'),
                                      )
                                    ],
                                  ),
                                ),
                                onTap: () {},
                              ),
                              ListTile(
                                title: Container(
                                  padding: EdgeInsets.all(15),
                                  child: Column(
                                    children: [
                                      Container(
                                          alignment: Alignment.topLeft,
                                          child: Row(
                                            children: [
                                              Icon(Icons.mark_email_read),
                                              Text(
                                                "Email",
                                                style: TextStyle(
                                                    fontSize:
                                                        getadaptiveTextSize(
                                                            context, 15),
                                                    fontWeight:
                                                        FontWeight.bold),
                                              ),
                                            ],
                                          )),
                                      Container(
                                        padding:
                                            EdgeInsets.only(left: width * 0.08),
                                        alignment: Alignment.topLeft,
                                        child: Text('${email}'),
                                      )
                                    ],
                                  ),
                                ),
                                onTap: () {},
                              ),
                              ListTile(
                                title: Container(
                                  padding: EdgeInsets.all(15),
                                  child: Column(
                                    children: [
                                      Container(
                                          alignment: Alignment.topLeft,
                                          child: Row(
                                            children: [
                                              Icon(Icons.phone_android),
                                              Text(
                                                "Mobile",
                                                style: TextStyle(
                                                    fontSize:
                                                        getadaptiveTextSize(
                                                            context, 15),
                                                    fontWeight:
                                                        FontWeight.bold),
                                              ),
                                            ],
                                          )),
                                      Container(
                                        padding:
                                            EdgeInsets.only(left: width * 0.08),
                                        alignment: Alignment.topLeft,
                                        child: Text('${mobile}'),
                                      )
                                    ],
                                  ),
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
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  "Business Profile",
                                  style: Theme.of(context)
                                      .textTheme
                                      // .headline1
                                      .headlineMedium
                                      ?.copyWith(fontSize: 16),
                                ),
                                ElevatedButton(
                                    onPressed: () {
                                      Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                              builder: (context) =>
                                                  const EditBusinessDetails()));
                                    },
                                    child: Row(
                                      children: [
                                        Icon(Icons.edit),
                                        Text("Edit")
                                      ],
                                    ))
                              ],
                            )),
                        Container(
                          width: double.infinity,
                          color: Colors.white,
                          child: Column(
                            children: [
                              ListTile(
                                title: Container(
                                  padding: EdgeInsets.all(15),
                                  child: Column(
                                    children: [
                                      Container(
                                          alignment: Alignment.topLeft,
                                          child: Row(
                                            children: [
                                              Icon(Icons.business_center),
                                              Text(
                                                "Businness Name",
                                                style: TextStyle(
                                                    fontSize:
                                                        getadaptiveTextSize(
                                                            context, 15),
                                                    fontWeight:
                                                        FontWeight.bold),
                                              ),
                                            ],
                                          )),
                                      Container(
                                        padding:
                                            EdgeInsets.only(left: width * 0.08),
                                        alignment: Alignment.topLeft,
                                        child: Text('${businessName}'),
                                      )
                                    ],
                                  ),
                                ),
                                onTap: () {},
                              ),
                              ListTile(
                                title: Container(
                                  padding: EdgeInsets.all(15),
                                  child: Column(
                                    children: [
                                      Container(
                                          alignment: Alignment.topLeft,
                                          child: Row(
                                            children: [
                                              Icon(Icons.account_balance),
                                              Text(
                                                "UPI ID",
                                                style: TextStyle(
                                                    fontSize:
                                                        getadaptiveTextSize(
                                                            context, 15),
                                                    fontWeight:
                                                        FontWeight.bold),
                                              ),
                                            ],
                                          )),
                                      Container(
                                        padding:
                                            EdgeInsets.only(left: width * 0.08),
                                        alignment: Alignment.topLeft,
                                        child: Text('${upiID}'),
                                      )
                                    ],
                                  ),
                                ),
                                onTap: () {},
                              ),
                              if (gstNumber != null ||
                                  gstNumber.toString().isNotEmpty ||
                                  gstNumber.toString() != '')
                                ListTile(
                                  title: Container(
                                    padding: EdgeInsets.all(15),
                                    child: Column(
                                      children: [
                                        Container(
                                            alignment: Alignment.topLeft,
                                            child: Row(
                                              children: [
                                                Icon(Icons.percent),
                                                Text(
                                                  "GST Number",
                                                  style: TextStyle(
                                                      fontSize:
                                                          getadaptiveTextSize(
                                                              context, 15),
                                                      fontWeight:
                                                          FontWeight.bold),
                                                ),
                                              ],
                                            )),
                                        Container(
                                          padding: EdgeInsets.only(
                                              left: width * 0.08),
                                          alignment: Alignment.topLeft,
                                          child: Text('${gstNumber}'),
                                        )
                                      ],
                                    ),
                                  ),
                                  onTap: () {},
                                ),
                              ListTile(
                                title: Container(
                                  padding: EdgeInsets.all(15),
                                  child: Column(
                                    children: [
                                      Container(
                                          alignment: Alignment.topLeft,
                                          child: Row(
                                            children: [
                                              Icon(Icons.location_city),
                                              Text(
                                                "Address",
                                                style: TextStyle(
                                                    fontSize:
                                                        getadaptiveTextSize(
                                                            context, 15),
                                                    fontWeight:
                                                        FontWeight.bold),
                                              ),
                                            ],
                                          )),
                                      Container(
                                        padding:
                                            EdgeInsets.only(left: width * 0.08),
                                        alignment: Alignment.topLeft,
                                        child: Text('${address}'),
                                      )
                                    ],
                                  ),
                                ),
                                onTap: () {},
                              ),
                              ListTile(
                                title: Container(
                                  padding: EdgeInsets.all(15),
                                  child: Column(
                                    children: [
                                      Container(
                                          alignment: Alignment.topLeft,
                                          child: Row(
                                            children: [
                                              Icon(Icons.local_phone),
                                              Text(
                                                "Mobile",
                                                style: TextStyle(
                                                    fontSize:
                                                        getadaptiveTextSize(
                                                            context, 15),
                                                    fontWeight:
                                                        FontWeight.bold),
                                              ),
                                            ],
                                          )),
                                      Container(
                                        padding:
                                            EdgeInsets.only(left: width * 0.08),
                                        alignment: Alignment.topLeft,
                                        child: Text('${businessMobile}'),
                                      )
                                    ],
                                  ),
                                ),
                                onTap: () {},
                              ),
                              ListTile(
                                title: Container(
                                  padding: EdgeInsets.all(15),
                                  child: Column(
                                    children: [
                                      Container(
                                          alignment: Alignment.topLeft,
                                          child: Row(
                                            children: [
                                              Icon(Icons.alternate_email),
                                              Text(
                                                "Email",
                                                style: TextStyle(
                                                    fontSize:
                                                        getadaptiveTextSize(
                                                            context, 15),
                                                    fontWeight:
                                                        FontWeight.bold),
                                              ),
                                            ],
                                          )),
                                      Container(
                                        padding:
                                            EdgeInsets.only(left: width * 0.08),
                                        alignment: Alignment.topLeft,
                                        child: Text('${businessEmail}'),
                                      )
                                    ],
                                  ),
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
          )
        ]),
      )),

      // ),
    );
  }
}

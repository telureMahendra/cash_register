// import 'dart:convert';
// import 'dart:ffi';
import 'dart:io';

import 'package:cash_register/Widgets/profile_list_tile_widget.dart';
import 'package:cash_register/Widgets/username_card_widget.dart';
import 'package:cash_register/common_utils/common_functions.dart';
import 'package:cash_register/common_utils/strings.dart';
import 'package:cash_register/edit_business_details.dart';
import 'package:cash_register/edit_profile.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  // var width, height;
  String username = '';

  var userId, image;
  String email = '',
      mobile = '',
      businessName = '',
      address = '',
      businessEmail = '',
      businessMobile = '',
      gstNumber = '',
      upiID = '';

  File? galleryFile;
  final picker = ImagePicker();

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

  storeImage() async {
    final prefs = await SharedPreferences.getInstance();
    prefs.setString("image", convertIntoBase64(galleryFile!));
    image = loadImage();
  }

  @override
  initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {});
    getData();
    image = loadImage();
    setState(() {});
  }

  Future<void> getData() async {
    final prefs = await SharedPreferences.getInstance();
    username = prefs.getString("username")!;
    userId = prefs.getInt('userId');
    email = prefs.getString('email')!;
    mobile = prefs.getString('mobile')!;
    businessName = prefs.getString("businessName")!;
    address = prefs.getString("address")!;
    businessEmail = prefs.getString("businessEmail")!;
    businessMobile = prefs.getString("businessMobile")!;
    gstNumber = prefs.getString("gstNumber")!;
    upiID = prefs.getString("upiID")!;
  }

  getadaptiveTextSize(BuildContext context, dynamic value) {
    return (value / 710) * MediaQuery.of(context).size.height;
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    double width = size.width;
    double height = size.height;
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Profile',
          style: TextStyle(color: Colors.white, fontFamily: 'Becham'),
        ),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
      ),
      body: Column(
        children: [
          // Card(
          //   elevation: 5,
          //   child: Padding(
          //     padding: const EdgeInsets.all(8.0),
          //     child: Container(
          //       // height: height * 0.05,
          //       width: width * 0.90,
          //       // padding: EdgeInsets.only(right: 20),
          //       child: Row(
          //         mainAxisAlignment: MainAxisAlignment.spaceBetween,
          //         children: [
          //           Container(
          //             // child: Image.asset(
          //             //     'assets/images/vizpay_logo.jpeg'),
          //             height: width * 0.22,
          //             width: width * 0.22,
          //             alignment: Alignment.center,
          //             child: Text(
          //               username != null && username.isNotEmpty
          //                   ? username[0]
          //                   : '0',
          //               style: TextStyle(
          //                   fontWeight: FontWeight.bold,
          //                   fontSize: getadaptiveTextSize(context, 50)),
          //             ),
          //             decoration: BoxDecoration(
          //               borderRadius: BorderRadius.circular(50),
          //               color: Colors.amber,
          //               border: Border.all(
          //                 color: Color.fromARGB(255, 0, 0, 0),
          //                 width: 1,
          //               ),
          //             ),
          //           ),
          //           Container(
          //             // padding: EdgeInsets.only(left: height * 0.015),
          //             width: width * 0.35,
          //             child: Text(
          //               '$username ',
          //               style: TextStyle(
          //                   fontWeight: FontWeight.bold,
          //                   fontSize: getadaptiveTextSize(context, 18)),
          //             ),
          //           ),
          //           Container(
          //             alignment: Alignment.centerRight,
          //             padding: EdgeInsets.all(10),
          //             // width: width * 0.29,
          //             child: ElevatedButton(
          //               onPressed: () {
          //                 Navigator.push(
          //                   context,
          //                   MaterialPageRoute(
          //                     builder: (context) => const EditProfile(),
          //                   ),
          //                 );
          //               },
          //               style: ElevatedButton.styleFrom(
          //                 padding: const EdgeInsets.only(left: 5, right: 5),
          //               ),
          //               child: Row(
          //                 children: [Icon(Icons.edit), Text("Edit Profile")],
          //               ),
          //             ),
          //           ),
          //         ],
          //       ),
          //     ),
          //   ),
          // ),
          UsernameCardWidget(isEditShow: true),
          Expanded(
            child: SingleChildScrollView(
              // shrinkWrap: true,
              child: Column(
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
                  ProfileListTileWidget(
                    title: "Name",
                    description: usernameKey,
                    icon: Icons.person_2,
                  ),
                  ProfileListTileWidget(
                    title: "Email",
                    description: emailKey,
                    icon: Icons.mark_email_read,
                  ),
                  ProfileListTileWidget(
                    title: "Mobile",
                    description: mobileKey,
                    icon: Icons.phone_android,
                  ),

                  // business profile start here
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
                              children: [Icon(Icons.edit), Text("Edit")],
                            ))
                      ],
                    ),
                  ),

                  ProfileListTileWidget(
                    title: "Businness Name",
                    description: businessNameKey,
                    icon: Icons.business_center,
                  ),
                  ProfileListTileWidget(
                    title: "UPI ID",
                    description: upiIDKey,
                    icon: Icons.account_balance,
                  ),

                  ProfileListTileWidget(
                    title: "GST Number",
                    description: gstNumberKey,
                    icon: Icons.percent,
                  ),
                  ProfileListTileWidget(
                    title: "Business Address",
                    description: addressKey,
                    icon: Icons.location_city,
                  ),
                  ProfileListTileWidget(
                    title: "Business Mobile",
                    description: businessMobileKey,
                    icon: Icons.local_phone,
                  ),
                  ProfileListTileWidget(
                    title: "Business Email",
                    description: businessEmailKey,
                    icon: Icons.alternate_email,
                  ),

                  // business profile ends here
                ],
              ),
            ),
          )
        ],
      ),

      // ),
    );
  }
}

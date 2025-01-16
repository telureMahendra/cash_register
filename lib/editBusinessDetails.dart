import 'dart:convert';
import 'dart:io';

import 'package:carousel_slider/carousel_options.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:cash_register/Widgets/button.dart';
import 'package:cash_register/Widgets/text_field.dart';
import 'package:cash_register/helper/helper.dart';
import 'package:cash_register/my_home_page.dart';
import 'package:cash_register/profile.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter/src/widgets/placeholder.dart';

import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class EditBusinessDetails extends StatefulWidget {
  const EditBusinessDetails({super.key});

  @override
  State<EditBusinessDetails> createState() => _EditBusinessDetailsState();
}

class _EditBusinessDetailsState extends State<EditBusinessDetails> {
  var size, width, height;

  final TextEditingController businessNameController = TextEditingController();
  final TextEditingController addressController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController mobileController = TextEditingController();
  final TextEditingController gstNumberController = TextEditingController();
  final TextEditingController upiIDController = TextEditingController();

  GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    loadControllers();
    super.initState();
  }

  Future<void> loadControllers() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    businessNameController.text = prefs.getString("businessName") ?? '';
    addressController.text = prefs.getString('address') ?? '';
    emailController.text = prefs.getString('businessEmail') ?? '';
    mobileController.text = prefs.getString('businessMobile') ?? '';
    gstNumberController.text = prefs.getString('gstNumber') ?? '';
    upiIDController.text = prefs.getString('upiID') ?? '';
    setState(() {});
  }

  Future<void> updateBusinessDetails() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();

    if (_formKey.currentState!.validate()) {
      try {
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (BuildContext context) {
            return const Center(child: CircularProgressIndicator());
          },
        );

        final response = await http.put(
          Uri.parse(BASE_URL + '/business'),
          headers: <String, String>{
            'Content-Type': 'application/json; charset=UTF-8',
            'userId': '${prefs.getInt('userId')}',
          },
          body: jsonEncode(<String, dynamic>{
            'businessName': businessNameController.text.toString(),
            'address': addressController.text.toString(),
            'mobile': mobileController.text.toString(),
            'email': emailController.text.toString(),
            'gstNumber': gstNumberController.text.toString(),
            'upiID': upiIDController.text.toString()
          }),
        );

        Navigator.pop(context);
        if (response.statusCode == 202) {
          // If the server did return a 201 ACCEPTED response,
          // then parse the JSON.
          prefs.setBool("isBusinessDetailsFound", true);
          await prefs.setString(
              'businessName', businessNameController.text.toString());
          await prefs.setString('address', addressController.text.toString());
          await prefs.setString(
              'businessEmail', emailController.text.toString());
          await prefs.setString(
              'businessMobile', mobileController.text.toString());
          await prefs.setString(
              'gstNumber', gstNumberController.text.toString());
          await prefs.setString('upiID', upiIDController.text.toString());

          showDialog<void>(
              context: context,
              builder: (context) => AlertDialog(
                    title: const Text('Success'),
                    content: Text(response.body.toString()),
                    actions: [
                      TextButton(
                        child: const Text('Ok'),
                        onPressed: () {
                          Navigator.of(context).pop();
                          Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const ProfileScreen(),
                            ),
                          );
                        },
                      ),
                    ],
                  ));

          // Navigator.pushReplacement(
          //   context,
          //   MaterialPageRoute(
          //     builder: (context) => const MyHomePage(title: "Bill Register"),
          //   ),
          // );
        } else {
          // If the server did not return a 201 CREATED response,
          // then throw an exception.
          showDialog<void>(
            context: context,
            builder: (context) => AlertDialog(
              title: const Text('Error'),
              content: Text(response.body.toString()),
              actions: [
                TextButton(
                  child: const Text('Ok'),
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                ),
              ],
            ),
          );
        }
      } on SocketException catch (e) {
        // Handle network errors
        Navigator.pop(context);
        showDialog<void>(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Error'),
            content: Text('Network Error'),
            actions: [
              TextButton(
                child: const Text('Ok'),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
            ],
          ),
        );
      } catch (e) {
        Navigator.pop(context);
        showDialog<void>(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Error'),
            content: Text('Server Not Responding'),
            actions: [
              TextButton(
                child: const Text('Ok'),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
            ],
          ),
        );
      }
    }
  }

  helpUPI() async {
    await showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Steps to Find UPI ID'),
        content: SizedBox(
          height: height * 0.20,
          width: width,
          child: ListView(
            children: [
              Container(
                // height: height * 0.70,
                // width: width * 0.70,
                child: CarouselSlider(
                  items: [
                    //1st Image of Slider
                    Container(
                      // margin: EdgeInsets.all(6.0),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(8.0),
                        image: DecorationImage(
                          // image: NetworkImage("ADD IMAGE URL HERE"),
                          image: AssetImage(
                              "assets/images/find-upi-id-on-google-pay.png"),
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),

                    // 2nd Image of Slider
                    Container(
                      // margin: EdgeInsets.all(6.0),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(8.0),
                        image: DecorationImage(
                          // image: NetworkImage("ADD IMAGE URL HERE"),
                          image: AssetImage(
                              "assets/images/find-upi-id-on-bhim.png"),
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),

                    Container(
                      // margin: EdgeInsets.all(6.0),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(8.0),
                        image: DecorationImage(
                          // image: NetworkImage("ADD IMAGE URL HERE"),
                          image: AssetImage(
                              "assets/images/find-upi-id-on-paytm.png"),
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                    Container(
                      // margin: EdgeInsets.all(6.0),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(8.0),
                        image: DecorationImage(
                          // image: NetworkImage("ADD IMAGE URL HERE"),
                          image: AssetImage(
                              "assets/images/find-upi-id-on-phone-pe.png"),
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                  ],

                  //Slider Container properties
                  options: CarouselOptions(
                    height: 180.0,
                    enlargeCenterPage: true,
                    autoPlay: true,
                    aspectRatio: 16 / 9,
                    autoPlayCurve: Curves.fastOutSlowIn,
                    enableInfiniteScroll: true,
                    autoPlayAnimationDuration: Duration(milliseconds: 800),
                    viewportFraction: 0.8,
                  ),
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            child: Text(
              'Ok',
              style: TextStyle(fontSize: 20),
            ),
            onPressed: () {
              Navigator.of(context).pop();
            },
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    size = MediaQuery.of(context).size;
    width = size.width;
    height = size.height;
    return Scaffold(
        // resizeToAvoidBottomInset: false,
        appBar: AppBar(
          title: Text(
            "Update Business Details",
            style: TextStyle(color: Colors.white, fontFamily: 'Becham'),
          ),
          backgroundColor: Colors.blue,
          centerTitle: false,
        ),
        backgroundColor: Colors.white,
        body: Container(
          child: SingleChildScrollView(
            child: SafeArea(
                child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  SizedBox(
                    height: height / 2.7,
                    child: Image.asset('assets/images/business.png'),
                  ),
                  TextFieldInput(
                    icon: Icons.business_center,
                    textEditingController: businessNameController,
                    hintText: 'Business Name',
                    textInputType: TextInputType.text,
                    length: 30,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter business name';
                      }
                      if (value.length < 5) {
                        return 'Business name should have atleast 5 characters';
                      }
                      return null;
                    },
                  ),
                  // TextFieldInput(
                  //   icon: Icons.account_balance,
                  //   textEditingController: upiIDController,
                  //   hintText: 'Enter UPI ID',
                  //   textInputType: TextInputType.text,
                  //   length: 50,
                  //   validator: (value) {
                  //     if (value == null || value.isEmpty) {
                  //       return 'Please enter UPI ID';
                  //     }
                  //     final RegExp upiRegExp =
                  //         RegExp(r"^[a-zA-Z0-9.\-_]{2,256}@[a-zA-Z]{2,64}");
                  //     if (!upiRegExp.hasMatch(value)) {
                  //       return 'Please enter a valid UPI ID';
                  //     }
                  //     return null;
                  //   },
                  // ),
                  // TextFieldInput(
                  //   icon: Icons.percent,
                  //   textEditingController: gstNumberController,
                  //   hintText: 'GST Number(Optional)',
                  //   textInputType: TextInputType.text,
                  //   length: 30,
                  //   validator: (value) {
                  //     return null;
                  //   },
                  // ),
                  TextFieldInput(
                    icon: Icons.percent,
                    textEditingController: gstNumberController,
                    hintText: 'GST Number(Optional)',
                    textInputType: TextInputType.text,
                    length: 30,
                    validator: (value) {
                      return null;
                    },
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(
                        vertical: 10, horizontal: 20),
                    child: TextFormField(
                      maxLength: 30,
                      style: const TextStyle(fontSize: 20),
                      controller: upiIDController,
                      decoration: InputDecoration(
                        prefixIcon:
                            Icon(Icons.account_balance, color: Colors.black54),
                        hintText: 'Enter UPI ID',
                        hintStyle: const TextStyle(
                            color: Colors.black45, fontSize: 18),
                        enabledBorder: OutlineInputBorder(
                          borderSide: BorderSide.none,
                          borderRadius: BorderRadius.circular(30),
                        ),
                        border: InputBorder.none,
                        focusedBorder: OutlineInputBorder(
                          borderSide:
                              const BorderSide(color: Colors.blue, width: 2),
                          borderRadius: BorderRadius.circular(30),
                        ),
                        filled: true,
                        fillColor: const Color(0xFFedf0f8),
                        contentPadding: const EdgeInsets.symmetric(
                          vertical: 15,
                          horizontal: 20,
                        ),
                        suffixIcon: IconButton(
                          icon: Icon(
                            Icons.help,
                            color: Colors.black54,
                          ),
                          onPressed: () {
                            setState(() {
                              helpUPI();
                            });
                          },
                        ),
                      ),
                      keyboardType: TextInputType.text,
                      // obscureText: _obscureText,
                      autovalidateMode: AutovalidateMode.onUserInteraction,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter UPI ID';
                        }
                        final RegExp upiRegExp =
                            RegExp(r"^[a-zA-Z0-9.\-_]{2,256}@[a-zA-Z]{3,64}");
                        if (!upiRegExp.hasMatch(value)) {
                          return 'Please enter a valid UPI ID';
                        }
                        return null;
                      },
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(
                        vertical: 10, horizontal: 20),
                    child: Container(
                      width: width,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Example UPI ID: username@bankname',
                                style: TextStyle(
                                  fontSize: 15,
                                  color: Colors.black45,
                                ),
                              ),
                              Container(
                                width: width * 0.90,
                                child: Text(
                                  'Please note: Ensure you have entered a valid UPI ID. Incorrect UPI IDs may lead to payment issues, such as payments being received by someone else. We are not responsible for any issues arising from incorrect UPI ID entries.',
                                  style: TextStyle(
                                    fontSize: 16,
                                    color: Colors.black54,
                                  ),
                                ),
                              )
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                  TextFieldInput(
                    icon: Icons.place_rounded,
                    textEditingController: addressController,
                    hintText: 'Adress',
                    textInputType: TextInputType.text,
                    length: 100,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter address';
                      }
                      if (value.length < 5) {
                        return 'Please enter valid address';
                      }
                      return null;
                    },
                  ),
                  TextFieldInput(
                    icon: Icons.call,
                    textEditingController: mobileController,
                    hintText: 'Enter your number',
                    textInputType: TextInputType.number,
                    length: 10,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter your number';
                      }
                      if (value.length != 10) {
                        return 'Phone number must be 10 digits';
                      }
                      // Add more email validation logic here if needed
                      return null;
                    },
                  ),
                  TextFieldInput(
                    icon: Icons.email,
                    textEditingController: emailController,
                    hintText: 'Enter your email',
                    textInputType: TextInputType.text,
                    length: 50,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter your email';
                      }
                      final RegExp emailRegExp = RegExp(
                          r"^[a-zA-Z0-9.!#$%&'*+/=?^_`{|}~-]+@[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,253}[a-zA-Z0-9])?(?:\.[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,253}[a-zA-Z0-9])?)*$");
                      if (!emailRegExp.hasMatch(value)) {
                        return 'Please enter a valid email address';
                      }
                      // Add more email validation logic here if needed
                      return null;
                    },
                  ),
                  MyButtons(
                      onTap: updateBusinessDetails, text: "Update Details"),
                  const SizedBox(height: 10),
                ],
              ),
            )),
          ),
        ));
  }
}

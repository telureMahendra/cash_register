import 'dart:convert';
import 'dart:io';

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
                  TextFieldInput(
                    icon: Icons.place_rounded,
                    textEditingController: addressController,
                    hintText: 'Adress',
                    textInputType: TextInputType.text,
                    length: 30,
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

import 'dart:convert';
import 'dart:io';

import 'package:carousel_slider/carousel_options.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:cash_register/Widgets/all_dialog.dart';
import 'package:cash_register/Widgets/button.dart';
import 'package:cash_register/Widgets/drop_down_selector_widget.dart';
import 'package:cash_register/Widgets/dropdown_input.dart';
import 'package:cash_register/Widgets/searchable_dropdown_widget.dart';
import 'package:cash_register/Widgets/text_field.dart';
import 'package:cash_register/common_utils/assets_path.dart';
import 'package:cash_register/common_utils/common_functions.dart';
import 'package:cash_register/common_utils/strings.dart';
import 'package:cash_register/helper/helper.dart';
import 'package:cash_register/calculator.dart';
import 'package:cash_register/home_page.dart';
import 'package:cash_register/model/environment.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class AddBusinessDetails extends StatefulWidget {
  const AddBusinessDetails({super.key});

  @override
  State<AddBusinessDetails> createState() => _AddBusinessDetailsState();
}

class _AddBusinessDetailsState extends State<AddBusinessDetails> {
  var size, width, height;

  final TextEditingController businessNameController = TextEditingController();
  final TextEditingController addressController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController mobileController = TextEditingController();
  final TextEditingController gstNumberController = TextEditingController();
  final TextEditingController upiIDController = TextEditingController();
  final TextEditingController cinNumberController = TextEditingController();
  final TextEditingController panNumberController = TextEditingController();

  GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  late bool isBusinessDetailsFound = false;

  String businessCategory = '';

  @override
  void initState() {
    // checkBusinessDetailsFound();
    super.initState();
  }

  Future<void> checkBusinessDetailsFound() async {
    final prefs = await SharedPreferences.getInstance();

    isBusinessDetailsFound = prefs.getBool('isBusinessDetailsFound') ?? false;

    if (isBusinessDetailsFound == false) {
      try {
        final response = await http.get(
          Uri.parse('${Environment.baseUrl}/business'),
          headers: <String, String>{
            'Content-Type': 'application/json; charset=UTF-8',
            'userId': '${prefs.getInt(userIdKey)}',
          },
        );

        if (response.statusCode == 200) {
          String responseString = utf8.decode(response.bodyBytes);
          Map<String, dynamic> jsonData = jsonDecode(responseString);

          prefs.setBool(isBusinessDetailsFoundKey, true);
          prefs.setString(businessNameKey, jsonData[businessNameKey] ?? '');
          prefs.setString(addressKey, jsonData[addressKey] ?? '');
          prefs.setString(businessEmailKey, jsonData[businessEmailKey] ?? '');
          prefs.setString(businessMobileKey, jsonData[businessMobileKey] ?? '');
          prefs.setString(gstNumberKey, jsonData[gstNumberKey] ?? '');
          prefs.setString(upiIDKey, jsonData[upiIDKey] ?? '');
          // 'username', jsonData['username'] ?? ''
          // return TransactionDetails.fromJsonList(json.decode(response.body));
          if (context.mounted) {
            Navigator.pop(context);

            showSuccessFailDialog(
                context, successAnimationPath, textDetailsAddedSuccessfully);
          }
          // showDialog<void>(
          //   context: context,
          //   builder: (context) => AlertDialog(
          //     title: const Text('Success'),
          //     content: Text('Details added Successfully'),
          //     actions: [
          //       TextButton(
          //         child: const Text('Ok'),
          //         onPressed: () {
          //           Navigator.of(context).pop();
          //         },
          //       ),
          //     ],
          //   ),
          // );
        } else {
          if (mounted) {
            print('${response.body.toString()} in add business');
          }

          // throw Exception('Request Failed.');
        }
      } on SocketException {
        // Handle network errors
        if (context.mounted) {
          Navigator.pop(context);

          showSuccessFailDialog(
              context, warningAnimationPath, networkErrorMessage);
        }

        // showDialog<void>(
        //   context: context,
        //   builder: (context) => AlertDialog(
        //     title: const Text('Error'),
        //     content: Text('Network Error'),
        //     actions: [
        //       TextButton(
        //         child: const Text('Ok'),
        //         onPressed: () {
        //           Navigator.of(context).pop();
        //         },
        //       ),
        //     ],
        //   ),
        // );
      } catch (e) {
        if (context.mounted) {
          Navigator.pop(context);

          showSuccessFailDialog(
              context, warningAnimationPath, serverNotRespondingMessage);
        }
        // Navigator.pop(context);
        // showDialog<void>(
        //   context: context,
        //   builder: (context) => AlertDialog(
        //     title: const Text('Error'),
        //     content: Text('Server Not Responding'),
        //     actions: [
        //       TextButton(
        //         child: const Text('Ok'),
        //         onPressed: () {
        //           Navigator.of(context).pop();
        //         },
        //       ),
        //     ],
        //   ),
        // );
      }
    }
  }

  Future<void> addBusinessDetails() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();

    if (_formKey.currentState!.validate()) {
      try {
        // showDialog(
        //   context: context,
        //   barrierDismissible: false,
        //   builder: (BuildContext context) {
        //     return const Center(child: CircularProgressIndicator());
        //   },
        // );

        if (context.mounted) {
          showLoader(context);
        }

        final response = await http.post(
          Uri.parse('${Environment.baseUrl}/business'),
          headers: <String, String>{
            'Content-Type': 'application/json; charset=UTF-8',
            'userId': '${prefs.getInt(userIdKey)}',
          },
          body: jsonEncode(<String, dynamic>{
            'businessName': businessNameController.text.toString(),
            'address': addressController.text.toString(),
            'mobile': mobileController.text.toString(),
            'email': emailController.text.toString(),
            'gstNumber': gstNumberController.text.toString(),
            'upiID': gstNumberController.text.toString()
          }),
        );

        Navigator.pop(context);
        if (response.statusCode == 201) {
          // If the server did return a 201 CREATED response,
          // then parse the JSON.
          prefs.setBool(isBusinessDetailsFoundKey, true);
          await prefs.setString(
              businessNameKey, businessNameController.text.toString());
          await prefs.setString(addressKey, addressController.text.toString());
          await prefs.setString(
              businessEmailKey, emailController.text.toString());
          await prefs.setString(
              businessMobileKey, mobileController.text.toString());
          await prefs.setString(upiIDKey, upiIDController.text.toString());

          // Navigator.pop(context);

          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => const Homepage(),
            ),
          );
          //  Navigator.of(context).pushAndRemoveUntil(
          //                                 MaterialPageRoute(
          //                                     builder: (context) => MyHomePage()),
          //                                     (route) => false
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
      } on SocketException {
        // Handle network errors
        if (context.mounted) {
          Navigator.pop(context);

          showSuccessFailDialog(
              context, warningAnimationPath, networkErrorMessage);
        }
        // Navigator.pop(context);
        // showDialog<void>(
        //   context: context,
        //   builder: (context) => AlertDialog(
        //     title: const Text('Error'),
        //     content: Text('Network Error'),
        //     actions: [
        //       TextButton(
        //         child: const Text('Ok'),
        //         onPressed: () {
        //           Navigator.of(context).pop();
        //         },
        //       ),
        //     ],
        //   ),
        // );
      } catch (e) {
        if (context.mounted) {
          Navigator.pop(context);

          showSuccessFailDialog(
              context, warningAnimationPath, serverNotRespondingMessage);
        }

        // Navigator.pop(context);
        // showDialog<void>(
        //   context: context,
        //   builder: (context) => AlertDialog(
        //     title: const Text('Error'),
        //     content: Text('Server Not Responding'),
        //     actions: [
        //       TextButton(
        //         child: const Text('Ok'),
        //         onPressed: () {
        //           Navigator.of(context).pop();
        //         },
        //       ),
        //     ],
        //   ),
        // );
      }
    }
  }

  helpUPI() async {
    await showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text(textStepsToFindUpiId),
        content: SizedBox(
          height: height * 0.20,
          width: width,
          // child: ListView(
          //   children: [

          //   ],
          // ),
          child: CarouselSlider(
            items: [
              //1st Image of Slider
              Container(
                // margin: EdgeInsets.all(6.0),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8.0),
                  image: DecorationImage(
                    // image: NetworkImage("ADD IMAGE URL HERE"),
                    image: AssetImage(findUpiIdGooglePayPath),
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
                    image: AssetImage(findUpiIdBhimPath),
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
                    image: AssetImage(findUpiIdpaytmPath),
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
                    image: AssetImage(findUpiIdPhoePayPath),
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
        actions: [
          TextButton(
            child: Text(
              textOk,
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

  List<String> list = ["item 1", "item 2", "item 3", "item 4"];

  @override
  Widget build(BuildContext context) {
    size = MediaQuery.of(context).size;
    width = size.width;
    height = size.height;
    return Scaffold(
        // resizeToAvoidBottomInset: false,
        appBar: AppBar(
          title: Text(textBusinessDetails),
          centerTitle: false,
          backgroundColor: Colors.blue,
          foregroundColor: Colors.white,
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
                    child: Image.asset(businessImagePath),
                  ),
                  // DropDownSelectorWidget(
                  //     hintText: "Select Business Category",
                  //     list: list,
                  //     listValue: ""),

                  DropdownInput(
                    hintText: "Select a Business Category",
                    icon: Icons.list,
                    items: [
                      "department store",
                      "Specialty stores",
                      "Clothing",
                      "Furniture",
                      'Book Store',
                      'Art Craft',
                      "Beauty Stores",
                      'Food',
                      'Super Market',
                      "Automobile Parts",
                      "Boutiques",
                      "Hardware Store",
                      "Catalog retailing",
                      "E-Commerce store",
                      "retailers",
                      "florist",
                      "vegetable Market Shop",
                      "Electronics",
                    ],
                    // selectedItem:
                    // 'USA', // Optional: if you want to preselect an item
                    onChanged: (selectedValue) {
                      businessCategory = selectedValue!;
                      print('Selected value: $businessCategory');
                    },
                  ),

                  TextFieldInput(
                    icon: Icons.business_center,
                    textEditingController: businessNameController,
                    hintText: textBusinessName,
                    textInputType: TextInputType.text,
                    length: 30,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return textPleaseEnterBusinessName;
                      }
                      if (value.length < 5) {
                        return textBusinessNameShouldHaveAtleastFiveCharacters;
                      }
                      return null;
                    },
                  ),
                  // Padding(
                  //   padding: const EdgeInab sets.symmetric(
                  //       vertical: 10, horizontal: 20),
                  //   child: Container(
                  //     width: width,
                  //     child: Row(
                  //       mainAxisAlignment: MainAxisAlignment.start,
                  //       children: [
                  //         Column(
                  //           crossAxisAlignment: CrossAxisAlignment.start,
                  //           children: [
                  //             Text(
                  //               'Example UPI ID: username@bankname',
                  //               style: TextStyle(
                  //                 fontSize: 15,
                  //                 color: Colors.black45,
                  //               ),
                  //             ),
                  //             Container(
                  //               width: width * 0.90,
                  //               child: Text(
                  //                 'Please note: Ensure you have entered a valid UPI ID. Incorrect UPI IDs may lead to payment issues, such as payments being received by someone else. We are not responsible for any issues arising from incorrect UPI ID entries.',
                  //                 style: TextStyle(
                  //                   fontSize: 16,
                  //                   color: Colors.black54,
                  //                 ),
                  //               ),
                  //             )
                  //           ],
                  //         ),
                  //       ],
                  //     ),
                  //   ),
                  // ),
                  // TextFieldInput(
                  //   icon: Icons.percent,
                  //   textEditingController: gstNumberController,
                  //   hintText: 'GST Number(Optional)',
                  //   textInputType: TextInputType.text,
                  //   length: 15,
                  //   validator: (value) {
                  //     // if (value != null || (value!.isNotEmpty)) {
                  //     //   if (value!.length != 15) {
                  //     //     return 'GST Number must be valid';
                  //     //   }
                  //     // }
                  //     return null;
                  //   },
                  // ),
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
                        hintText: textEnterUpiId,
                        hintStyle: const TextStyle(
                            color: Colors.black45, fontSize: 18),
                        enabledBorder: OutlineInputBorder(
                          borderSide: BorderSide.none,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        border: InputBorder.none,
                        focusedBorder: OutlineInputBorder(
                          borderSide:
                              const BorderSide(color: Colors.blue, width: 2),
                          borderRadius: BorderRadius.circular(10),
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
                            helpUPI();
                          },
                        ),
                      ),
                      keyboardType: TextInputType.text,
                      // obscureText: _obscureText,
                      autovalidateMode: AutovalidateMode.onUserInteraction,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return textPleaseEnterUpiId;
                        }
                        final RegExp upiRegExp =
                            RegExp(r"^[a-zA-Z0-9.\-_]{2,256}@[a-zA-Z]{3,64}");
                        if (!upiRegExp.hasMatch(value)) {
                          return textPleaseEnterValidUpiId;
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
                                textExampleUpiIdUsernameAtBankname,
                                style: TextStyle(
                                  fontSize: 15,
                                  color: Colors.black45,
                                ),
                              ),
                              SizedBox(
                                width: width * 0.85,
                                child: Text(
                                  textAddUpiNote,
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
                    icon: Icons.percent,
                    textEditingController: gstNumberController,
                    hintText: textGSTNumberOptional,
                    textInputType: TextInputType.text,
                    length: 15,
                    validator: (value) {
                      return null;
                    },
                  ),
                  TextFieldInput(
                    icon: Icons.card_travel,
                    textEditingController: cinNumberController,
                    hintText: textCINNumberOptional,
                    textInputType: TextInputType.text,
                    length: 21,
                    validator: (value) {
                      return null;
                    },
                  ),
                  TextFieldInput(
                    icon: Icons.card_membership,
                    textEditingController: panNumberController,
                    hintText: textPANNumberOptional,
                    textInputType: TextInputType.text,
                    length: 10,
                    validator: (value) {
                      return null;
                    },
                  ),
                  TextFieldInput(
                    icon: Icons.place_rounded,
                    textEditingController: addressController,
                    hintText: textAdress,
                    textInputType: TextInputType.text,
                    length: 100,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return textPleaseEnterAddress;
                      }
                      if (value.length < 5) {
                        return textPleaseEnterValidAddress;
                      }
                      return null;
                    },
                  ),
                  TextFieldInput(
                    icon: Icons.call,
                    textEditingController: mobileController,
                    hintText: textEnterYourNumber,
                    textInputType: TextInputType.number,
                    length: 10,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return textPleaseEnterYourNumber;
                      }
                      if (value.length != 10) {
                        return textPhoneNumberMustBeTenDigits;
                      }
                      // Add more email validation logic here if needed
                      return null;
                    },
                  ),
                  TextFieldInput(
                    icon: Icons.email,
                    textEditingController: emailController,
                    hintText: textEnterYourEmail,
                    textInputType: TextInputType.text,
                    length: 50,
                    validator: (value) {
                      return validateEmail(value);
                    },
                  ),
                  MyButtons(onTap: addBusinessDetails, text: textAddDetails),
                  const SizedBox(height: 10),
                ],
              ),
            )),
          ),
        ));
  }
}

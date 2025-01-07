import 'dart:convert';
import 'dart:io';

import 'package:cash_register/Widgets/button.dart';
import 'package:cash_register/Widgets/text_field.dart';
import 'package:cash_register/helper/helper.dart';
import 'package:cash_register/profile.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter/src/widgets/placeholder.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class EditProfile extends StatefulWidget {
  const EditProfile({super.key});

  @override
  State<EditProfile> createState() => _EditProfileState();
}

class _EditProfileState extends State<EditProfile> {
  final TextEditingController nameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController numberController = TextEditingController();
  GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  bool _obscureText = true;

  @override
  void dispose() {
    super.dispose();
    emailController.dispose();
    passwordController.dispose();
    nameController.dispose();
    numberController.dispose();
  }

  @override
  void initState() {
    super.initState();
    loadUserDetails();
  }

  Future<void> loadUserDetails() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();

    //   await prefs.setInt('userId', jsonData['userId'] ?? '');
    // await prefs.setString('username', jsonData['username'] ?? '');
    // await prefs.setString('email', jsonData['email'] ?? '');
    // await prefs.setString('mobile', jsonData['mobile'] ?? '');
    // await prefs.setString('password', jsonData['password'] ?? '');
    emailController.text = prefs.getString('email') ?? '';
    passwordController.text = prefs.getString('password') ?? '';
    numberController.text = prefs.getString('mobile') ?? '';
    nameController.text = prefs.getString('username') ?? '';
  }

  void updateUserDetails() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();

    if (_formKey.currentState!.validate()) {
      print('Form is valid');

      try {
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (BuildContext context) {
            return const Center(child: CircularProgressIndicator());
          },
        );

        final response = await http.put(
          Uri.parse(BASE_URL + '/update'),
          headers: <String, String>{
            'Content-Type': 'application/json; charset=UTF-8',
            'userId': '${prefs.getInt('userId')}',
          },
          body: jsonEncode(<String, dynamic>{
            'username': nameController.text.toString(),
            'email': emailController.text.toString(),
            'password': passwordController.text.toString(),
            'mobile': numberController.text.toString(),
          }),
        );

        Navigator.pop(context);
        if (response.statusCode == 202) {
          // If the server did return a 201 CREATED response,
          // then parse the JSON.
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
        } else {
          // If the server did not return a 201 CREATED response,

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
    } else {
      print('Form is not valid');
    }

    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    double height = MediaQuery.of(context).size.height;
    return Scaffold(
        // resizeToAvoidBottomInset: false,
        appBar: AppBar(
          title: Text(
            "Update personal details",
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
                  height: height / 2.8,
                  child: Image.asset('assets/images/signup.jpeg'),
                ),
                TextFieldInput(
                  icon: Icons.person,
                  textEditingController: nameController,
                  hintText: 'Enter your name',
                  textInputType: TextInputType.text,
                  length: 30,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter your name';
                    }
                    // Add more email validation logic here if needed
                    // return null;
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
                    } else if (!value.contains('@') || !value.contains('.')) {
                      return 'Please enter a valid email address';
                    }
                    // Add more email validation logic here if needed
                    return null;
                  },
                ),
                TextFieldInput(
                  icon: Icons.call,
                  textEditingController: numberController,
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
                // TextFieldInput(
                //   icon: Icons.lock,
                //   textEditingController: passwordController,
                //   hintText: 'Enter your passord',
                //   textInputType: TextInputType.text,
                //   isPass: true,
                //   length: 30,
                //   validator: (value) {
                //     if (value == null || value.isEmpty) {
                //       return 'Please enter your password';
                //     }
                //     if (value.length < 8) {
                //       return 'Password must be at least 8 characters long';
                //     }
                //     if (!RegExp(
                //             r'^(?=.*[a-z])(?=.*[A-Z])(?=.*\d)(?=.*[@#$!%*?&])[A-Za-z\d@#$!%*?&]')
                //         .hasMatch(value)) {
                //       return 'Password must contain at least one uppercase, one lowercase, one number, and one special character';
                //     }
                //     // Add more email validation logic here if needed
                //     return null;
                //   },

                // ),

                Padding(
                  padding:
                      const EdgeInsets.symmetric(vertical: 10, horizontal: 20),
                  child: TextFormField(
                    maxLength: 30,
                    style: const TextStyle(fontSize: 20),
                    controller: passwordController,
                    decoration: InputDecoration(
                      prefixIcon: Icon(Icons.lock, color: Colors.black54),
                      hintText: 'Enter your passord',
                      hintStyle:
                          const TextStyle(color: Colors.black45, fontSize: 18),
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
                          _obscureText
                              ? Icons.visibility_off
                              : Icons.visibility,
                          color: Colors.black54,
                        ),
                        onPressed: () {
                          setState(() {
                            _obscureText = !_obscureText;
                          });
                        },
                      ),
                    ),
                    keyboardType: TextInputType.text,
                    obscureText: _obscureText,
                    autovalidateMode: AutovalidateMode.onUserInteraction,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter your password';
                      }
                      if (value.length < 8) {
                        return 'Password must be at least 8 characters long';
                      }
                      if (!RegExp(
                              r'^(?=.*[a-z])(?=.*[A-Z])(?=.*\d)(?=.*[@#$!%*?&])[A-Za-z\d@#$!%*?&]')
                          .hasMatch(value)) {
                        return 'Password must contain at least one uppercase, one lowercase, one number, and one special character';
                      }
                      return null;
                    },
                  ),
                ),

                MyButtons(onTap: updateUserDetails, text: "Update Profile"),
                const SizedBox(height: 10),

                Padding(padding: EdgeInsets.only(bottom: height * 0.05))
              ],
            ),
          )),
        )));
  }
}

import 'dart:convert';
import 'dart:io';

import 'package:cash_register/helper/helper.dart';
import 'package:cash_register/my_home_page.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'Widgets/button.dart';
import 'Widgets/text_field.dart';
import 'package:http/http.dart' as http;

import 'signup.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<LoginScreen> {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  bool _obscureText = true;

  @override
  void dispose() {
    super.dispose();
    emailController.dispose();
    passwordController.dispose();
  }

  Future<void> saveLoginStatus(bool isLoggedIn) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isLoggedIn', isLoggedIn);
    setState(() {});
  }

// email and passowrd auth part

  // Future<void> login() async {
  //   final response = await http.post(
  //     Uri.parse(BASE_URL),
  //     headers: <String, String>{
  //       'Content-Type': 'application/json; charset=UTF-8',
  //     },
  //     body: jsonEncode(<String, String>{
  //       'email': emailController.text.toString(),
  //       'password': passwordController.text.toString()
  //     }),
  //   );

  //   if (response.statusCode == 200) {
  //     // If the server did return a 201 CREATED response,
  //     // then parse the JSON.
  //     saveLoginStatus(true);
  //     Navigator.pushReplacement(
  //         context,
  //         MaterialPageRoute(
  //             builder: (context) => const MyHomePage(
  //                   title: 'Bill Register',
  //                 )));
  //   } else {}
  // }

  void loginUser() async {
    if (_formKey.currentState!.validate()) {
      try {
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (BuildContext context) {
            return const Center(child: CircularProgressIndicator());
          },
        );

        final response = await http.post(
          Uri.parse(BASE_URL + '/user/login'),
          headers: <String, String>{
            'Content-Type': 'application/json; charset=UTF-8',
          },
          body: jsonEncode(<String, String>{
            'username': emailController.text.toString(),
            'password': passwordController.text.toString()
          }),
        );

        Navigator.pop(context);
        if (response.statusCode == 200) {
          final SharedPreferences prefs = await SharedPreferences.getInstance();

          String responseString = utf8.decode(response.bodyBytes);
          Map<String, dynamic> jsonData = jsonDecode(responseString);

          await prefs.setInt('userId', jsonData['userId'] ?? '');
          await prefs.setString('username', jsonData['username'] ?? '');
          await prefs.setString('email', jsonData['email'] ?? '');
          await prefs.setString('mobile', jsonData['mobile'] ?? '');
          await prefs.setString('password', jsonData['password'] ?? '');

          saveLoginStatus(true);
          Navigator.pop(context);
          Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                  builder: (context) => const MyHomePage(
                        title: 'Bill Register',
                      )));
        } else {
          // If the server did not return a 202 CREATED response,
          // then throw an exception.
          showDialog<void>(
            context: context,
            builder: (context) => AlertDialog(
              title: const Text('Error'),
              content: Text('${response.body.toString()}'),
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

      // setState(() {
      //   if (emailController.text.toString().toLowerCase() == "test@gmail.com" &&
      //       passwordController.text.toString() == 'Test@123') {
      //     saveLoginStatus(true);
      //     Navigator.pushReplacement(
      //         context,
      //         MaterialPageRoute(
      //             builder: (context) => const MyHomePage(
      //                   title: 'Bill Register',
      //                 )));
      //   }
      // });
    } else {
      print('Form is not valid');
    }
  }

  @override
  Widget build(BuildContext context) {
    double height = MediaQuery.of(context).size.height;
    return Scaffold(
        // resizeToAvoidBottomInset: false,
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
                    child: Image.asset('assets/images/login.jpeg'),
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
                  // TextFieldInput(
                  //   icon: Icons.lock,
                  //   textEditingController: passwordController,
                  //   hintText: 'Enter your passord',
                  //   textInputType: TextInputType.text,
                  //   length: 30,
                  //   isPass: _obscureText,
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
                  //     return null;
                  //   },
                  // ),
                  Padding(
                    padding: const EdgeInsets.symmetric(
                        vertical: 10, horizontal: 20),
                    child: TextFormField(
                      maxLength: 30,
                      style: const TextStyle(fontSize: 20),
                      controller: passwordController,
                      decoration: InputDecoration(
                        prefixIcon: Icon(Icons.lock, color: Colors.black54),
                        hintText: 'Enter your passord',
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
                  MyButtons(onTap: loginUser, text: "Log In"),
                  const SizedBox(height: 10),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text("Dont have an account?"),
                      GestureDetector(
                        onTap: () {
                          Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const SignUp(),
                            ),
                          );
                        },
                        child: const Text(
                          " Signup",
                          style: TextStyle(
                              fontWeight: FontWeight.bold, color: Colors.blue),
                        ),
                      )
                    ],
                  )
                ],
              ),
            )),
          ),
        ));
  }
}

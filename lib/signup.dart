import 'dart:convert';
import 'dart:io';

import 'package:cash_register/helper/helper.dart';
import 'package:cash_register/login.dart';
import 'package:cash_register/Calculator.dart';

import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter/src/widgets/placeholder.dart';
import 'package:lottie/lottie.dart';

import 'Widgets/button.dart';

import 'Widgets/text_field.dart';
import 'package:http/http.dart' as http;

class SignUp extends StatefulWidget {
  const SignUp({super.key});

  @override
  State<SignUp> createState() => _SignUpState();
}

class _SignUpState extends State<SignUp> {
  final TextEditingController nameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController numberController = TextEditingController();
  GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  bool _obscureText = true;

  TextFontSize fs = TextFontSize();

  @override
  void dispose() {
    super.dispose();
    emailController.dispose();
    passwordController.dispose();
    nameController.dispose();
    numberController.dispose();
  }

  void signupUser() async {
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

        final response = await http.post(
          Uri.parse(BASE_URL + '/adduser'),
          headers: <String, String>{
            'Content-Type': 'application/json; charset=UTF-8',
          },
          body: jsonEncode(<String, dynamic>{
            'username': nameController.text.toString(),
            'email': emailController.text.toString(),
            'password': passwordController.text.toString(),
            'mobile': numberController.text.toString(),
          }),
        );

        Navigator.pop(context);
        if (response.statusCode == 201) {
          // If the server did return a 201 CREATED response,
          // then parse the JSON.
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => const LoginScreen(),
            ),
          );
        } else {
          // If the server did not return a 201 CREATED response,

          showDialog<void>(
            context: context,
            barrierDismissible: false,
            builder: (context) => AlertDialog(
              // title: const Text('Error'),

              insetPadding: EdgeInsets.all(0),
              content: Container(
                height: 220,
                padding: EdgeInsets.all(2),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Lottie.asset('assets/animations/warning.json',
                        height: MediaQuery.of(context).size.height * 0.17,
                        // controller: _controller,
                        repeat: true,
                        animate: true),
                    Text(
                      '${response.body.toString()}',
                      style: TextStyle(
                          fontSize: fs.getadaptiveTextSize(context, 15)),
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  style: TextButton.styleFrom(),
                  child: Text(
                    'Ok',
                    style: TextStyle(
                        fontSize: fs.getadaptiveTextSize(context, 20)),
                  ),
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                ),
              ],
            ),
          );
          sleep(Duration(seconds: 1));

          // showDialog<void>(
          //   context: context,
          //   builder: (context) => AlertDialog(
          //     title: const Text('Error'),
          //     content: Text(response.body.toString()),
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
      } on SocketException catch (e) {
        // Handle network errors
        Navigator.pop(context);
        showDialog<void>(
          context: context,
          builder: (context) => AlertDialog(
            // title: const Text('Error'),
            content: Container(
              height: 220,
              padding: EdgeInsets.all(2),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Lottie.asset('assets/animations/warning.json',
                      height: MediaQuery.of(context).size.height * 0.17,
                      // controller: _controller,
                      repeat: true,
                      animate: true),
                  Text(
                    'Network Error',
                    style: TextStyle(
                        fontSize: fs.getadaptiveTextSize(context, 15)),
                  ),
                ],
              ),
            ),
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
            content: Container(
              height: 220,
              padding: EdgeInsets.all(2),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Lottie.asset('assets/animations/warning.json',
                      height: MediaQuery.of(context).size.height * 0.17,
                      // controller: _controller,
                      repeat: true,
                      animate: true),
                  Text(
                    'Server not Responding',
                    style: TextStyle(
                        fontSize: fs.getadaptiveTextSize(context, 15)),
                  ),
                ],
              ),
            ),
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
              padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 20),
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
                    borderRadius: BorderRadius.circular(10),
                  ),
                  border: InputBorder.none,
                  focusedBorder: OutlineInputBorder(
                    borderSide: const BorderSide(color: Colors.blue, width: 2),
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
                      _obscureText ? Icons.visibility_off : Icons.visibility,
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

            MyButtons(onTap: signupUser, text: "Sign Up"),
            const SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text("Already have an account?"),
                GestureDetector(
                  onTap: () {
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const LoginScreen(),
                      ),
                    );
                  },
                  child: const Text(
                    " Login",
                    style: TextStyle(
                        fontWeight: FontWeight.bold, color: Colors.blue),
                  ),
                )
              ],
            ),
            Padding(padding: EdgeInsets.only(bottom: height * 0.05))
          ],
        ),
      )),
    )));
  }
}

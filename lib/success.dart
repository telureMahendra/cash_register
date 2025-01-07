import 'package:animated_splash_screen/animated_splash_screen.dart';
import 'package:cash_register/my_home_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter/src/widgets/placeholder.dart';
import 'package:lottie/lottie.dart';

class success extends StatefulWidget {
  const success({super.key});

  @override
  State<success> createState() => _successState();
}

class _successState extends State<success> {
  @override
  Widget build(BuildContext context) {
    return AnimatedSplashScreen(
      splash: 
        Center(
            child: Lottie.asset("assets/animations/success.json"),
          ),
      
      nextScreen: const MyHomePage(title: 'Bill Calculator'),
      duration: 2300,
      splashIconSize: 700,
      
      );
  }
}
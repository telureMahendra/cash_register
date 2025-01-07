import 'package:cash_register/splash_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final prefs = await SharedPreferences.getInstance();
  final bool isLoggedIn = prefs.getBool('isLoggedIn') ?? false;

  SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
  WidgetsFlutterBinding.ensureInitialized();
  // runApp(const MyApp());
  runApp(MyApp(isLoggedIn: isLoggedIn));
}

class MyApp extends StatelessWidget {
  final bool isLoggedIn; // Store login status

  const MyApp({super.key, required this.isLoggedIn});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Bill Calculator',
      theme: ThemeData(
        fontFamily: 'Becham',
        textTheme:
            Theme.of(context).textTheme.apply(fontFamily: 'Bold Sans Serif'),
        primarySwatch: Colors.blue,
      ),
      home: splashScreen(
        loginStatus: isLoggedIn,
      ),
    );
  }
}

import 'dart:io';

import 'package:cash_register/Widgets/all_dialog.dart';
import 'package:cash_register/calculator.dart';
import 'package:cash_register/common_utils/common_functions.dart';
import 'package:cash_register/menu.dart';
import 'package:cash_register/modules/product_module/products_screen.dart';
import 'package:cash_register/profile.dart';
import 'package:cash_register/transactions_history.dart';
import 'package:curved_navigation_bar/curved_navigation_bar.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Homepage extends StatefulWidget {
  const Homepage({super.key, this.screenIndex});
  final dynamic screenIndex;

  @override
  State<Homepage> createState() => _HomepageState();
}

class _HomepageState extends State<Homepage> {
  var size, width, height;
  var isCalculatorEnabled = true, isProductEnabled = true;

  @override
  void initState() {
    super.initState();
    // checkEnabledFeatures();
  }

  checkEnabledFeatures() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    isCalculatorEnabled = prefs.getBool("isCalculatorEnabled") ?? true;
    isProductEnabled = prefs.getBool("isProductEnabled") ?? true;
  }

  Future<bool> showExitConfirmationDialog(BuildContext context) async {
    return (await showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: Text('Confirm Exit'),
            content: Text('Do you want to exit the app?'),
            actions: <Widget>[
              TextButton(
                onPressed: () => Navigator.of(context).pop(false), // No action
                child: Text('No'),
              ),
              TextButton(
                onPressed: () => Navigator.of(context).pop(true), // Yes action
                child: Text('Yes'),
              ),
            ],
          ),
        )) ??
        false;
  }

  int index = 1;
  final GlobalKey<CurvedNavigationBarState> _bottomNavigationKey = GlobalKey();

  final screens = [
    ProductsList(),
    Calculator(title: "Bill Calculator"),
    TransactionsHistory(),
    MenuWidget()
  ];
  // var size = getadaptiveTextSize(context, 30);

  @override
  Widget build(BuildContext context) {
    // checkEnabledFeatures();
    // index = widget.screenIndex == null ? 1 : widget.screenIndex;
    var icons = <Widget>[
      if (isProductEnabled)
        Icon(Icons.inventory_outlined,
            size: getAdaptiveTextSize(context, 30), color: Colors.white),
      if (isCalculatorEnabled)
        Icon(Icons.calculate_outlined,
            size: getAdaptiveTextSize(context, 30), color: Colors.white),
      Icon(Icons.history,
          size: getAdaptiveTextSize(context, 30), color: Colors.white),
      Icon(Icons.person_2_outlined,
          size: getAdaptiveTextSize(context, 30), color: Colors.white),
    ];
    size = MediaQuery.of(context).size;
    width = size.width;
    height = size.height;
    return Container(
      height: MediaQuery.of(context).size.height,
      color: Colors.blue,
      child: SafeArea(
        top: false,
        bottom: false,
        child: PopScope(
          onPopInvokedWithResult: (route, result) async {
            if (result == null) {
              if (context.mounted) {
                // Guard the State.context
                final shouldExit = await showExitConfirmationDialog(context);
                if (shouldExit && context.mounted) {
                  Navigator.of(context).maybePop();
                }
              }
            }
          },
          child: Scaffold(
            extendBody: true,
            bottomNavigationBar: CurvedNavigationBar(
              key: _bottomNavigationKey,
              color: Colors.blue,
              buttonBackgroundColor: Colors.blue,
              height: 74,
              animationDuration: Duration(milliseconds: 500),
              animationCurve: Curves.easeInOut,
              backgroundColor: Colors.transparent,
              index: index,
              items: icons,
              onTap: (index) {
                setState(() {
                  this.index = index;
                });
              },
            ),
            body: AnimatedSwitcher(
              duration: Duration(milliseconds: 500),
              transitionBuilder: (Widget child, Animation<double> animation) {
                return SlideTransition(
                  position: Tween<Offset>(
                    begin: const Offset(1.0, 0.0), // Slide in from the right
                    end: Offset.zero,
                  ).animate(animation),
                  child: child,
                );
              },
              child: screens[index],
            ),
          ),
        ),
      ),
    );
  }
}

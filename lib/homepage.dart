import 'package:cash_register/Calculator.dart';
import 'package:cash_register/menu.dart';
import 'package:cash_register/products.dart';
import 'package:cash_register/profile.dart';
import 'package:cash_register/transactions_history.dart';
import 'package:curved_navigation_bar/curved_navigation_bar.dart';
import 'package:flutter/material.dart';
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

  getadaptiveTextSize(BuildContext context, dynamic value) {
    return (value / 710) * MediaQuery.of(context).size.height;
  }

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

  Future<bool> _onWillPop() async {
    return (await showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: new Text('Are you sure?'),
            content: new Text(
              'Do you want to exit an App',
              style: TextStyle(fontSize: getadaptiveTextSize(context, 18)),
            ),
            actions: <Widget>[
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Container(
                    width: width / 4,
                    height: height * 0.05,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue,
                        foregroundColor: Colors.black, // foreground
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(6), // <-- Radius
                        ),
                      ),
                      onPressed: () =>
                          Navigator.of(context).pop(false), //<-- SEE HERE
                      child: new Text(
                        'No',
                        style: TextStyle(
                            fontSize: getadaptiveTextSize(context, 15)),
                      ),
                    ),
                  ),
                  Container(
                    width: width / 4,
                    height: height * 0.05,
                    child: ElevatedButton(
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.black, // foreground
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(6), // <-- Radius
                        ),
                      ),
                      onPressed: () =>
                          Navigator.of(context).pop(true), // <-- SEE HERE
                      child: new Text(
                        'Yes',
                        style: TextStyle(
                            fontSize: getadaptiveTextSize(context, 15)),
                      ),
                    ),
                  ),
                ],
              )
            ],
          ),
        )) ??
        false;
  }

  int index = 1;
  GlobalKey<CurvedNavigationBarState> _bottomNavigationKey = GlobalKey();

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
            size: getadaptiveTextSize(context, 30), color: Colors.white),
      if (isCalculatorEnabled)
        Icon(Icons.calculate_outlined,
            size: getadaptiveTextSize(context, 30), color: Colors.white),
      Icon(Icons.history,
          size: getadaptiveTextSize(context, 30), color: Colors.white),
      Icon(Icons.person_2_outlined,
          size: getadaptiveTextSize(context, 30), color: Colors.white),
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
          child: WillPopScope(
            onWillPop: _onWillPop,
            child: ClipRect(
              child: Scaffold(
                  extendBody: true,
                  bottomNavigationBar: CurvedNavigationBar(
                    key: _bottomNavigationKey,
                    color: Colors.blue,
                    buttonBackgroundColor: Colors.blue,
                    height: height * 0.070,
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
                    transitionBuilder:
                        (Widget child, Animation<double> animation) {
                      return SlideTransition(
                        position: Tween<Offset>(
                          begin:
                              const Offset(1.0, 0.0), // Slide in from the right
                          end: Offset.zero,
                        ).animate(animation),
                        child: child,
                      );
                    },
                    child: screens[index],
                  )),
            ),
          )),
    );
  }
}

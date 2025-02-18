import 'package:cash_register/common_utils/common_functions.dart';
import 'package:cash_register/common_utils/strings.dart';
import 'package:cash_register/edit_profile.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class UsernameCardWidget extends StatefulWidget {
  final bool isEditShow;

  const UsernameCardWidget({
    super.key,
    required this.isEditShow,
  });

  @override
  State<UsernameCardWidget> createState() => _UsernameCardWidgetState();
}

class _UsernameCardWidgetState extends State<UsernameCardWidget> {
  String username = '';

  @override
  void initState() {
    // TODO: implement initState
    getData();
    super.initState();
  }

  getData() async {
    final prefs = await SharedPreferences.getInstance();
    username = prefs.getString(usernameKey) ?? '';
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    double width = size.width;
    double height = size.height;
    return Card(
      elevation: 5,
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Container(
          // height: height * 0.05,
          width: width * 0.90,
          // padding: EdgeInsets.only(right: 20),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                // child: Image.asset(
                //     'assets/images/vizpay_logo.jpeg'),
                height: width * 0.22,
                width: width * 0.22,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(50),
                  color: Colors.amber,
                  border: Border.all(
                    color: Color.fromARGB(255, 0, 0, 0),
                    width: 1,
                  ),
                ),
                child: Text(
                  username != null && username.isNotEmpty ? username[0] : '0',
                  style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: getadaptiveTextSize(context, 50)),
                ),
              ),
              widget.isEditShow == true
                  ? SizedBox(
                      // padding: EdgeInsets.only(left: height * 0.015),
                      width: width * 0.35,
                      child: Text(
                        '$username ',
                        style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: getadaptiveTextSize(context, 18)),
                      ),
                    )
                  : SizedBox(
                      // padding: EdgeInsets.only(left: height * 0.015),
                      // width: width * 0.35,
                      child: Text(
                        '$username ',
                        style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: getadaptiveTextSize(context, 18)),
                      ),
                    ),
              widget.isEditShow == true
                  ? Container(
                      alignment: Alignment.centerRight,
                      padding: EdgeInsets.all(10),
                      // width: width * 0.29,
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const EditProfile(),
                            ),
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.only(left: 5, right: 5),
                        ),
                        child: Row(
                          children: [Icon(Icons.edit), Text("Edit Profile")],
                        ),
                      ),
                    )
                  : Container(
                      width: width * 0.20,
                    ),
            ],
          ),
        ),
      ),
    );
  }
}

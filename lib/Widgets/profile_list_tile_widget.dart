import 'package:cash_register/common_utils/common_functions.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ProfileListTileWidget extends StatefulWidget {
  final String title;
  final String description;
  final IconData icon;
  const ProfileListTileWidget({
    super.key,
    required this.title,
    required this.description,
    required this.icon,
  });

  @override
  State<ProfileListTileWidget> createState() => _ProfileListTileWidgetState();
}

class _ProfileListTileWidgetState extends State<ProfileListTileWidget> {
  String description = '';

  // @override
  // Future<void> initState() async {
  //   final prefs = await SharedPreferences.getInstance();
  //   description = prefs.getString(description) ?? '';
  //   super.initState();
  // }

  @override
  void initState() {
    // TODO: implement initState
    loadDate();
    super.initState();
  }

  loadDate() async {
    final prefs = await SharedPreferences.getInstance();
    description = prefs.getString(widget.description) ?? '';
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    double width = size.width;
    double height = size.height;
    if (widget.description?.isEmpty ?? true) {
      return Container();
    }
    return ListTile(
      tileColor: Colors.white,
      title: Container(
        padding: EdgeInsets.all(15),
        child: Column(
          children: [
            Container(
                alignment: Alignment.topLeft,
                child: Row(
                  children: [
                    Icon(widget.icon),
                    Text(
                      widget.title,
                      style: TextStyle(
                          fontSize: getAdaptiveTextSize(context, 15),
                          fontWeight: FontWeight.bold),
                    ),
                  ],
                )),
            Container(
              padding: EdgeInsets.only(left: width * 0.08),
              alignment: Alignment.topLeft,
              child: Text(description),
            )
          ],
        ),
      ),
    );
  }
}

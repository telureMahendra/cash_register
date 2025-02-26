import 'package:flutter/material.dart';

class ListItemWidget extends StatelessWidget {
  final IconData icon;
  final String text;
  final VoidCallback onPressed;
  const ListItemWidget({
    super.key,
    required this.icon,
    required this.text,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    double width = size.width;
    double height = size.height;
    return Card(
      elevation: 5,
      child: InkWell(
        child: Padding(
            padding:
                EdgeInsets.only(top: 8.0, right: 8.0, bottom: 8.0, left: 8.0),
            child: Container(
                padding: EdgeInsets.only(left: 16),
                height: height * 0.05,
                width: width * 0.90,
                child: Row(
                  children: [
                    Icon(Icons.settings_outlined, color: Colors.black),
                    Text(text, style: TextStyle(color: Colors.black))
                  ],
                ))),
        onTap: () {
          // Navigator.push(context, MaterialPageRoute(
          //   builder: (context) {
          //     return SettingsWidget();
          //   },
          // ));
        },
      ),
    );
  }
}

import 'dart:convert';

import 'package:cash_register/common_utils/assets_path.dart';
import 'package:cash_register/common_utils/common_functions.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class LogoWidget extends StatefulWidget {
  const LogoWidget({super.key});

  @override
  State<LogoWidget> createState() => _LogoWidgetState();
}

class _LogoWidgetState extends State<LogoWidget> {
  var size, width, height;
  @override
  Widget build(BuildContext context) {
    size = MediaQuery.of(context).size;
    width = size.width;
    height = size.height;
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        Stack(
          children: [
            Container(
              padding: EdgeInsets.all(10),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(15),
                border: Border.all(
                  color: Color.fromARGB(255, 0, 0, 0),
                  width: 1,
                ),
              ),
              // child: Image.memory(Base64Decoder().convert(""),
              //     fit: BoxFit.fitWidth, width: width * 0.22),
              child: FutureBuilder(
                future: loadImage(),
                // future: combineData(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return Center(
                      child: CircularProgressIndicator(),
                    );
                  } else if (snapshot.hasError) {
                    return Image.asset(noImagePath,
                        fit: BoxFit.fitWidth,
                        width: width * 0.22); // Handle error
                  } else if (!snapshot.hasData) {
                    return Image.asset(noImagePath,
                        fit: BoxFit.fitWidth, width: width * 0.22);
                  } else if (snapshot.data == null) {
                    return Image.asset(noImagePath,
                        fit: BoxFit.fitWidth, width: width * 0.22);
                  } else if (snapshot.data!.isEmpty) {
                    return Image.asset(noImagePath,
                        fit: BoxFit.fitWidth, width: width * 0.22);
                  } else if (snapshot.hasData) {
                    return Image.memory(base64Decode(snapshot.data!),
                        fit: BoxFit.fitWidth, width: width * 0.22);
                  }

                  return Container();
                },
              ),
            ),
          ],
        ),
        Column(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            TextButton(
              onPressed: () {
                showPicker(context: context);
              },
              child: Icon(
                Icons.add_a_photo_rounded,
                color: Colors.black,
                size: 40,
              ),
            )
            // Icon(
            //   Icons.mode_edit,
            //   color: Colors.blueAccent,
            //   size: 40,
            // ),
          ],
        )
      ],
    );
  }
}

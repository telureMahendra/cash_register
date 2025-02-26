import 'package:flutter/material.dart';

class DropDownSelectorWidget extends StatefulWidget {
  final String hintText;
  final IconData? icon;
  final List<String> list;
  String listValue;
  final Function onChanged;

  DropDownSelectorWidget({
    super.key,
    required this.hintText,
    this.icon,
    required this.list,
    required this.listValue,
    required this.onChanged,
  });

  @override
  State<DropDownSelectorWidget> createState() => _DropDownSelectorWidgetState();
}

class _DropDownSelectorWidgetState extends State<DropDownSelectorWidget> {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 20),
      child: DropdownButton(
        dropdownColor: const Color(0xFFedf0f8),
        iconEnabledColor: const Color(0xFFedf0f8),
        focusColor: const Color(0xFFedf0f8),
        borderRadius: BorderRadius.all(Radius.circular(10)),
        value: widget.listValue.isEmpty ? null : widget.listValue,
        hint: Text(widget.hintText),
        onChanged: (String? newValue) {
          setState(() {
            widget.listValue = newValue!;
          });
        },
        // validator: widget.validator,
        items: widget.list.map<DropdownMenuItem<String>>((String value) {
          return DropdownMenuItem<String>(
            value: value,
            child: Text(value),
          );
        }).toList(),
      ),
    );

    // Container(
    //                   width: width / 2 - width * 0.078,
    //                   child: DropdownButtonFormField<String>(
    //                     dropdownColor: const Color(0xFFedf0f8),
    //                     iconEnabledColor: const Color(0xFFedf0f8),
    //                     focusColor: const Color(0xFFedf0f8),
    //                     borderRadius: BorderRadius.all(Radius.circular(10)),
    //                     value: categoryValue.isEmpty ? null : categoryValue,
    //                     hint: Text('Select an Category'),
    //                     onChanged: (String? newValue) {
    //                       setState(() {
    //                         categoryValue = newValue!;
    //                       });
    //                     },
    //                     validator: (String? value) {
    //                       if (value == null || value.isEmpty) {
    //                         return 'Please select Categoy';
    //                       }
    //                       return null;
    //                     },
    //                     items: categoryList
    //                         .map<DropdownMenuItem<String>>((String value) {
    //                       return DropdownMenuItem<String>(
    //                         value: value,
    //                         child: Text(value),
    //                       );
    //                     }).toList(),
    //                   ),
    //                 ),
  }
}

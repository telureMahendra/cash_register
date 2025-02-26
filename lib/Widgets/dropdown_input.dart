import 'package:flutter/material.dart';

class DropdownInput extends StatelessWidget {
  final String hintText;
  final IconData? icon;
  final List<String> items;
  final String? selectedItem;
  final ValueChanged<String?>? onChanged;

  const DropdownInput({
    super.key,
    required this.hintText,
    this.icon,
    required this.items,
    this.selectedItem,
    this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 20),
      child: DropdownButtonFormField<String>(
        value: selectedItem,
        decoration: InputDecoration(
          prefixIcon: Icon(icon, color: Colors.black54),
          hintText: hintText,
          hintStyle: const TextStyle(color: Colors.black45, fontSize: 18),
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
          maintainHintHeight: true,
        ),
        onChanged: onChanged,
        items: items.map<DropdownMenuItem<String>>(
          (item) {
            return DropdownMenuItem<String>(
              value: item,
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    Text(item),
                    Divider(
                      color: Colors.black12,
                      thickness: 0.5,
                    ),
                  ],
                ),
              ),
            );
          },
        ).toList(),
        menuMaxHeight: 400,
      ),
    );
  }
}

import 'package:flutter/material.dart';

const String BASE_URL = 'http://10.0.20.79:8080/api/v1';

class FontSize {
  getadaptiveTextSize(BuildContext context, dynamic value) {
    return (value / 710) * MediaQuery.of(context).size.height;
  }
}

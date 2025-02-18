import 'package:flutter/material.dart';

// production
// const String BASE_URL = 'http://viz-prod-docker-old.vizpay.in:8080/api/v1';
// const String IMAGE_BASE_URL = 'http://viz-prod-docker-old.vizpay.in:8080';

// staging
// const String BASE_URL = 'http://10.0.30.250:8080/api/v1';
// const String IMAGE_BASE_URL = 'http://10.0.30.250:8080';

// development
// const String BASE_URL = 'http://10.0.20.79:8080/api/v1';
// const String IMAGE_BASE_URL = 'http://10.0.20.79:8080';

class TextFontSize {
  getadaptiveTextSize(BuildContext context, dynamic value) {
    return (value / 710) * MediaQuery.of(context).size.height;
  }
}

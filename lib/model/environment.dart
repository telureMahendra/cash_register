import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class Environment {
  static String get fileName {
    if (kReleaseMode) {
      // print("environment is production");
      return '.env.production';
    }
    if (kProfileMode) {
      // print("environment is staging");
      return '.env.staging';
    }
    // print("environment is development");
    return '.env.development';
  }

  static String get baseUrl {
    return dotenv.env['BASE_URL'] ?? "BASE_URL not specified";
  }

  static String get imageBaseUrl {
    return dotenv.env['IMAGE_BASE_URL'] ?? "IMAGE_BASE_URL not specified";
  }
}

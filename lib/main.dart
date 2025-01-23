import 'package:cash_register/db/sqfLiteDBService.dart';
import 'package:cash_register/helper/service/TransactionSyncService.dart';
import 'package:cash_register/splash_screen.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:workmanager/workmanager.dart';
import 'package:workmanager/src/options.dart' as constraints;

var dbs;

void callbackDispatcher() {
  Workmanager().executeTask((task, inputData) async {
    print("object");
    switch (task) {
      case ScheduledTask.taskName:
        ScheduledTask.control();
        print("sync In main "); // calls your control code
        break;
    }

    // return Future.value(true);
    return Future.value(true);
  });
}

void requestPermissions() async {
  bool reqSuc = false;

  List<Permission> permissions = [
    Permission.location,
    Permission.camera,
    Permission.mediaLibrary,
    Permission.locationAlways
  ];

  for (Permission permission in permissions) {
    if (await permission.isGranted) {
      if (kDebugMode) {
        // logger.i("Permission: $permission already granted");
      }
      reqSuc = true;
      continue;
    } else if (await permission.isDenied) {
      PermissionStatus permissionsStatus = await permission.request();
      if (permissionsStatus.isGranted) {
        if (kDebugMode) {
          // logger.i("Permission: $permission already granted");
        }
        reqSuc = true;
      } else if (permissionsStatus.isPermanentlyDenied) {
        if (kDebugMode) {
          // logger.i("Permission: $permission is permanently denied");
        }
        reqSuc = false;
      }
    }
  }
  if (reqSuc == false) {
    openAppSettings();
  }
}

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final prefs = await SharedPreferences.getInstance();
  final bool isLoggedIn = prefs.getBool('isLoggedIn') ?? false;
  dbs = DatabaseService.instance;

  SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
  WidgetsFlutterBinding.ensureInitialized();
  // runApp(const MyApp());

  Workmanager().initialize(
    callbackDispatcher,
    isInDebugMode: true,
  );
  // requestPermissions();
  runApp(MyApp(isLoggedIn: isLoggedIn));
}

Future<bool> isNetworkAvailable() async {
  var connectivityResult = await (Connectivity().checkConnectivity());
  return connectivityResult != ConnectivityResult.none;
}

class ScheduledTask {
  static const String taskName = "syncTransactionsTask";
  static Future<void> control() async {
    if (await isNetworkAvailable()) {
      TransactionSyncService syncService =
          TransactionSyncService(DatabaseService.instance, databaseHelper: dbs);
      print("network is available");
      await syncService.syncTransactions();
    }
  }
}

class MyApp extends StatelessWidget {
  final bool isLoggedIn; // Store login status

  const MyApp({super.key, required this.isLoggedIn});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Bill Calculator',
      theme: ThemeData(
        fontFamily: 'Becham',
        textTheme:
            Theme.of(context).textTheme.apply(fontFamily: 'Bold Sans Serif'),
        primarySwatch: Colors.blue,
      ),
      home: splashScreen(
        loginStatus: isLoggedIn,
      ),
    );
  }
}

import 'dart:convert';
import 'dart:ffi';
import 'dart:io';
import 'dart:ui';
import 'package:cash_register/db/sqfLite_db_service.dart';
import 'package:cash_register/helper/helper.dart';
import 'package:cash_register/model/transaction_helper.dart';
import 'package:cash_register/model/environment.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class TransactionSyncService {
  final DatabaseService databaseHelper;

  TransactionSyncService(DatabaseService instance,
      {required this.databaseHelper});

  Future<bool> isNetworkAvailable() async {
    var connectivityResult = await (Connectivity().checkConnectivity());
    return connectivityResult != ConnectivityResult.none;
  }

  Future<void> syncTransactions() async {
    List<TransactionDetailsSQL> unsyncedTransactions =
        await databaseHelper.getUnsyncedTransactions();

    final prefs = await SharedPreferences.getInstance();

    // print(unsyncedTransactions.isEmpty);
    if (await isNetworkAvailable()) {
      if (unsyncedTransactions.isNotEmpty) {
        try {
          final url = Uri.parse('${Environment.baseUrl}/transactionList');
          final response = await http.post(url,
              headers: <String, String>{
                'Content-Type': 'application/json; charset=UTF-8',
                'userId': '${prefs.getInt('userId')}'
              },
              body: jsonEncode(
                  unsyncedTransactions.map((tx) => tx.toJson()).toList()));
          // body: jsonEncode(unsyncedTransactions));
          // body: unsyncedTransactions);

          if (response.statusCode == 200 || response.statusCode == 201) {
            var data = response.body.substring(1, response.body.length - 1);
            print("Data from Server $data");

            List<String> numbs = data.split(',');
            for (var d in numbs) {
              print("Data from Server $d");
              await databaseHelper.updateTransactionSyncStatus(
                  int.parse(d), true);
            }

            // await databaseHelper.updateTransactionSyncStatus(data, true);
          } else {
            // Handle API call failure (e.g., log error, retry later)
            print('API call failed with status code: ${response.statusCode}');
          }
        } on SocketException catch (e) {
          print('network error: $e');
        } catch (e) {
          // Handle exceptions (e.g., network errors, API errors)
          print('Error during synchronization: $e');
        }
      }
    }
  }
}

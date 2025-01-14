import 'dart:math';

import 'package:cash_register/db/bill_db.dart';
import 'package:cash_register/model/bill.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DatabaseService {
  static final DatabaseService instance = DatabaseService._init();

  static Database? _database;

  DatabaseService._init();

  Future<Database?> get database async {
    if (_database != null) return _database;

    _database = await _initDB();
    return _database;
  }

  Future<String> get fullPath async {
    const name = 'bill.db';
    final path = await getDatabasesPath();
    return join(path, name);
  }

  Future<Database?> _initDB() async {
    final path = await fullPath;
    var database = await openDatabase(path,
        version: 1, onCreate: create, singleInstance: true);
    return database;
  }

  Future<void> create(Database database, int version) async =>
      await BillDB().createTable(database);

  Future<void> saveTransaction(String amount, String method, String time,
      String date, String userId, String dateTime) async {
    final db = await database;
    await db!.insert('bills', {
      "amount": amount,
      "method": method,
      "time": time,
      "date": date,
      "userId": userId,
      "datetime": dateTime
    });
  }

  Future<List<Map<String, Object?>>> getDBdata() async {
    final db = await database;

    List<Map<String, Object?>> list = await db!.rawQuery('SELECT * FROM bills');
    // print(list);

    return list;
  }
}

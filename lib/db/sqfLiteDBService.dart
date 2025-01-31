import 'dart:math';

import 'package:cash_register/db/bill_db.dart';
import 'package:cash_register/helper/transaction_helper.dart';
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

  Future<List<TransactionDetailsSQL>> getUnsyncedTransactions() async {
    final db = await database;
    final List<Map<String, dynamic>> maps =
        await db!.query('bills', where: 'status = 0');
    return List.generate(maps.length, (i) {
      return TransactionDetailsSQL.fromMap(maps[i]);
    });
  }

  Future<void> updateTransactionSyncStatus(int id, bool isSynced) async {
    final db = await database;
    // await db!.update('bills', {'status': isSynced ? 1 : 0},
    //     where: 'tid = ?', whereArgs: [id]);
    await db!.delete('bills', where: 'tid = ?', whereArgs: [id]);
  }

  Future<void> create(Database database, int version) async =>
      await BillDB().createTable(database);

  Future<void> saveTransaction(
      String amount,
      String method,
      String time,
      String date,
      int userId,
      String dateTime,
      int flag,
      String tran_source) async {
    final db = await database;
    createTable();

    final path = await getDatabasesPath();
    print('path for db is: $path');
    // db?.execute(
    // db!.execute("DROP TABLE bills;");
    // deleteData()
    // createTable();

    await db!.insert('bills', {
      "amount": amount,
      "method": method,
      "time": time,
      "date": date,
      "userId": userId,
      "tdatetime": dateTime,
      "status": flag,
      "tranSource": tran_source,
    });
    print("data stored dbservice");
  }

  deletable() async {
    final db = await database;
    db!.execute("DROP TABLE bills;");
  }

  deleteData() async {
    final db = await database;
    db!.execute("DELETE FROM bills;");
  }

  createTable() async {
    final db = await database;
    db!.execute("""CREATE TABLE IF NOT EXISTS bills(
    "tid" INTEGER NOT NULL,
    "amount" TEXT NOT NULL,
    "method" TEXT,
    "time" TEXT,
    "date" TEXT,
    "userId" INTEGER
    "created_at" DATETIME DEFAULT CURRENT_TIMESTAMP,
    "tdatetime" TEXT,
    "status" INTEGER,
    "tranSource" TEXT,
    PRIMARY KEY("TID" AUTOINCREMENT)
    ); """);
    print("Table created");
  }

  Future<List<Map<String, Object?>>> getDBdata() async {
    final db = await database;
    await _initDB();
    createTable();

    List<Map<String, Object?>> list =
        await db!.rawQuery('SELECT * FROM bills ORDER BY date(tdatetime) ASC ');

    print("data list ${list}");
    return list;
  }
}

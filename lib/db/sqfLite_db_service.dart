import 'dart:math';

import 'package:cash_register/common_utils/strings.dart';
import 'package:cash_register/db/bill_db.dart';
import 'package:cash_register/main.dart';
import 'package:cash_register/model/cart_item.dart';
import 'package:cash_register/model/transaction_helper.dart';
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

  Future<List<Map<String, dynamic>>> getCartList() async {
    final db = await database;

    var result = await db!.query(dbTableCart);
    return result;
  }

  emptyCart() async {
    final db = await database;
    await db!.execute("DELETE FROM $dbTableCart;");
  }

  Future<void> deleteProductFromCart(int productId) async {
    final db = await database;
    await db!.delete(
      dbTableCart,
      where: 'productId = ?',
      whereArgs: [productId],
    );
  }

  Future<int> getCartCount() async {
    final db = await database;
    var result = await db!.query(dbTableCart);
    return result.length;
  }

  Future<String> getCartTotal() async {
    final db = await database;
    List<Map<String, dynamic>> cartItems = await db!.query(dbTableCart);

    double total = 0.0;

    for (var item in cartItems) {
      double price = double.tryParse(item['price'] ?? '0.0') ?? 0.0;
      int countNumber = item['countNumber'] ?? 0;

      total += price * countNumber;
    }

    return total.toStringAsFixed(2);
  }

  Future<Map<String, dynamic>> getCartProductById(int productId) async {
    final db = await database;
    var existingProduct = await db!.query(
      dbTableCart,
      where: 'productId = ?',
      whereArgs: [productId],
    );
    if (existingProduct.isNotEmpty) {
      return existingProduct.first;
    }
    return {};
  }

  Future<void> changePrice(int productId, String price) async {
    final db = await database;
    createCartTable();

    var existingProduct = await db!.query(
      dbTableCart,
      where: 'productId = ?',
      whereArgs: [productId],
    );
    if (existingProduct.isNotEmpty) {
      print('Product found in the cart.');

      await db.update(
        dbTableCart,
        {
          "price": price,
        },
        where: 'productId = ?',
        whereArgs: [productId],
      );
    } else {
      print('Product not found in the cart.');
    }
  }

  Future<void> decreaseProductCount(int productId) async {
    final db = await database;
    createCartTable();

    var existingProduct = await db!.query(
      dbTableCart,
      where: 'productId = ?',
      whereArgs: [productId],
    );
    if (existingProduct.isNotEmpty) {
      print('Product found in the cart.');
      int currentCount = existingProduct.first['countNumber'] as int? ?? 0;

      if (currentCount > 1) {
        int newCount = currentCount - 1;

        await db.update(
          dbTableCart,
          {
            "countNumber": newCount,
          },
          where: 'productId = ?',
          whereArgs: [productId],
        );
      } else {
        await db.delete(
          dbTableCart,
          where: 'productId = ?',
          whereArgs: [productId],
        );
      }
    } else {
      print('Product not found in the cart.');
    }
  }

  Future<void> increaseProductCount(int productId) async {
    final db = await database;
    createCartTable();

    var existingProduct = await db!.query(
      dbTableCart,
      where: 'productId = ?',
      whereArgs: [productId],
    );

    if (existingProduct.isNotEmpty) {
      print('Product found in the cart.');
      int currentCount =
          await existingProduct.first['countNumber'] as int? ?? 0;

      if (currentCount >= 1) {
        int newCount = currentCount + 1;

        await db.update(
          dbTableCart,
          {
            "countNumber": newCount,
          },
          where: 'productId = ?',
          whereArgs: [productId],
        );
      }
    } else {
      print('Product not found in the cart.');
    }
  }

  Future<void> addProductToCart(int productId, String price, String image,
      int countNumber, String unit, String productName) async {
    final db = await database;
    createCartTable();

    print("productc count $countNumber");
    var existingProduct = await db!.query(
      dbTableCart,
      where: 'productId = ?',
      whereArgs: [productId],
    );

    if (existingProduct.isNotEmpty) {
      print("product found");
      int currentCount = existingProduct.first['countNumber'] as int? ?? 0;
      print("product current count $currentCount");
      int newCount = currentCount + 1;
      print("product new count $newCount");

      await db.update(
        dbTableCart,
        {
          "countNumber": newCount,
        },
        where: 'productId = ?',
        whereArgs: [productId],
      );
    } else {
      print("product not found");
      await db.insert(dbTableCart, {
        "productId": productId,
        "price": price,
        "image": image,
        "countNumber": countNumber,
        "unit": unit,
        "productName": productName,
      });
    }
  }

  createCartTable() async {
    final db = await database;

    await db!.execute("""CREATE TABLE IF NOT EXISTS $dbTableCart(
    "productId" INTEGER NOT NULL,
    "price" TEXT NOT NULL,
    "image" TEXT NOT NULL,
    "countNumber" INTEGER NOT NULL,
    "unit" TEXT NOT NULL ,
    "productName" TEXT NOT NULL )""");
    print("Table created");
  }

  Future<bool> saveTransaction(
      String amount,
      String method,
      String time,
      String date,
      int userId,
      String dateTime,
      int flag,
      String tran_source) async {
    final db = await database;
    createBillTable();

    final path = await getDatabasesPath();
    print('path for db is: $path');

    // db?.execute(
    // db!.execute("DROP TABLE bills;");
    // deleteData()
    // createTable();

    var status = await db!.insert(dbTableBills, {
      "amount": amount,
      "method": method,
      "time": time,
      "date": date,
      "userId": userId,
      "tdatetime": dateTime,
      "status": flag,
      "tranSource": tran_source,
    });
    if (status == 1) {
      print("data stored dbservice");
      return true;
    }
    return false;
  }

  deletable() async {
    final db = await database;
    db!.execute("DROP TABLE $dbTableBills;");
  }

  deleteData() async {
    final db = await database;
    db!.execute("DELETE FROM $dbTableBills;");
  }

  createBillTable() async {
    final db = await database;
    db!.execute("""CREATE TABLE IF NOT EXISTS $dbTableBills(
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

// Future<List<Map<String, dynamic>>> getCartList() async {
  Future<List<Map<String, Object?>>> getDBdata() async {
    final db = await database;
    await _initDB();
    createBillTable();

    List<Map<String, Object?>> list =
        await db!.rawQuery('SELECT * FROM bills ORDER BY date(tdatetime) ASC ');

    print("data list ${list}");
    return list;
  }
}

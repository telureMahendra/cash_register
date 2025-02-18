import 'package:cash_register/common_utils/strings.dart';
import 'package:sqflite/sqflite.dart';

class BillDB {
  Future<void> createTable(Database database) async {
    await database.execute("""CREATE TABLE IF NOT EXISTS $dbTableCart(
    "productId" INTEGER NOT NULL,
    "price" TEXT NOT NULL,
    "image" TEXT NOT NULL,
    "countNumber" INTEGER NOT NULL,
    "unit" TEXT NOT NULL ,
    "productName" TEXT NOT NULL )""");

    await database.execute("""CREATE TABLE IF NOT EXISTS $dbTableBills(
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
  }
}

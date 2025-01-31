import 'package:sqflite/sqflite.dart';

class BillDB {
  final tableName = 'bills';

  Future<void> createTable(Database database) async {
    await database.execute("""CREATE TABLE IF NOT EXISTS  $tableName(
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

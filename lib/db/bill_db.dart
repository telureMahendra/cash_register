import 'package:sqflite/sqflite.dart';

class BillDB {
  final tableName = 'bills';

  Future<void> createTable(Database database) async {
    await database.execute("""CREATE TABLE IF NOT EXISTS  $tableName(
    "id" INTEGER NOT NULL,
    "amount" TEXT NOT NULL,
    "method" TEXT,
    "time" TEXT,
    "date" TEXT,
    "userId" TEXT
    "created_at" DATETIME DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY("ID" AUTOINCREMENT)
    ); """);

    // await database.delete(tableName);
  }
}

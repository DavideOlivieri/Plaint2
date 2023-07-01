
import 'package:planit2/models/Event_model.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DatabaseHelper {
  static const int _version = 3;
  static const String _dbName = "Planit2.db";
  
  static Future<Database> _getDB() async {
    return openDatabase(join(await getDatabasesPath(), _dbName),
    onCreate: (db, version) async =>
        await db.execute("CREATE TABLE Event(id INTEGER PRIMARY KEY AUTOINCREMENT, data TEXT NOT NULL, titolo TEXT NOT NULL, descrizione TEXT NOT NULL);"),
        version: _version
    );
  }

  static Future<int> addEvent(Event event) async {
    final db = await _getDB();
    return await db.insert("Event", event.toJson(),
    conflictAlgorithm: ConflictAlgorithm.replace);
  }

   static Future<int> deleteEvent(Event event) async {
     final db = await _getDB();
     return await db.delete("Event",
     where: 'id = ?',
     whereArgs: [event.id],
     );
   }

  Future<List<Map<String, dynamic>>> getEventsByDate(String date) async {
    final db = await _getDB();
    return await db.query(
      'Event',
      where: 'data = ?',
      whereArgs: [date],
    );
  }

}
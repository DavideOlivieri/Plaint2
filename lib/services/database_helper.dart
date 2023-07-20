
import 'package:planit2/models/Event_model.dart';
import 'package:planit2/models/Calendar_model.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DatabaseHelper {
  static const int version = 15;
  static const String _dbName = "Planit2.db";
  
  static Future<Database> _getDB() async {
    return openDatabase(join(await getDatabasesPath(), _dbName),
      version: version,
    onCreate: (db, version) async {
        await db.execute("CREATE TABLE Event(id INTEGER PRIMARY KEY AUTOINCREMENT, data TEXT NOT NULL, titolo TEXT NOT NULL, descrizione TEXT, orario_inizio TEXT, orario_fine TEXT, id_calendario INTEGER);");
        await db.execute("CREATE TABLE Calendar(id INTEGER PRIMARY KEY AUTOINCREMENT, titolo TEXT NOT NULL);");

    },
    );
  }

  static Future<int> addCalendar(Calendar calendar) async {
    final db = await _getDB();
    return await db.insert("Calendar", calendar.toJson(),
        conflictAlgorithm: ConflictAlgorithm.replace);
  }

  static Future<int> deleteCalendar(int id_calendario) async {
    final db = await _getDB();
    return await db.delete(
      'Calendar',
      where: 'id = ?',
      whereArgs: [id_calendario],
    );
  }

  Future<List<Map<String, dynamic>>> getAllCalendars() async {
    final db = await _getDB();
    final List<Map<String, dynamic>> result = await db.query("Calendar");
    return result;
  }

  // FUNZIONI PER EVENTO

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

  Future<List<Map<String, dynamic>>> getEventsByDateAndCalendarId(String date, int id_calendario) async {
    final db = await _getDB();
    return await db.query(
      'Event',
      where: 'data = ? AND id_calendario = ?',
      whereArgs: [date, id_calendario],
      orderBy: 'orario_inizio',
    );
  }

}
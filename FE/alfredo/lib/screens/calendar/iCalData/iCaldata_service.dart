import 'package:alfredo/screens/calendar/iCalData/iCaldata.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

class ICalDBService {
  static Database? _curiCalDB;

  Future<Database> get curiCalDB async {
    if (_curiCalDB != null) return _curiCalDB!;

    _curiCalDB = await initDatabase();
    return _curiCalDB!;
  }

  Future<Database> initDatabase() async {
    String path = join(await getDatabasesPath(), "current_iCalData.db");

    return await openDatabase(path, version: 1, onCreate: (db, version) async {
      await db.execute('''
        CREATE TABLE iCaldatas(
          uid TEXT PRIMARY KEY NOT NULL,
          dtstart TEXT,
          dtend TEXT,
          created TEXT NOT NULL,
          summary TEXT NOT NULL,
          location TEXT,
          description TEXT
        )
      ''');
    });
  }

  Future<bool> insertICal(ICalData iCalData) async {
    Database db = _curiCalDB!;

    try {
      db.insert(
        'iCaldatas',
        iCalData.toMap(),
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
      return true;
    } catch (err) {
      return false;
    }
  }
}

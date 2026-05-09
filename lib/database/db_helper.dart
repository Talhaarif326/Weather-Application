import 'dart:convert';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DbHelper {
  static final DbHelper instance = DbHelper._internal();
  static Database? _db;
  DbHelper._internal();

  Future<Database> get database async {
    if (_db != null) return _db!;
    _db = await _initDb();
    return _db!;
  }

  Future<Database> _initDb() async {
    final path = join(await getDatabasesPath(), 'weather_app.db');
    return await openDatabase(
      path,
      version: 1,
      onCreate: (db, version) async {
        await db.execute(
          '''CREATE TABLE users (id INTEGER PRIMARY KEY AUTOINCREMENT, name TEXT NOT NULL)''',
        );
        await db.execute(
          '''CREATE TABLE locations (id INTEGER PRIMARY KEY AUTOINCREMENT, city_name TEXT NOT NULL, lat REAL NOT NULL, lon REAL NOT NULL, is_current INTEGER DEFAULT 0)''',
        );
        await db.execute(
          '''CREATE TABLE weather_cache (id INTEGER PRIMARY KEY AUTOINCREMENT, location_id INTEGER NOT NULL, json_data TEXT NOT NULL, last_updated INTEGER NOT NULL, FOREIGN KEY (location_id) REFERENCES locations(id) ON DELETE CASCADE)''',
        );
      },
    );
  }

  Future<void> saveUser(String name) async {
    final db = await database;
    await db.delete('users');
    await db.insert('users', {'name': name});
  }

  Future<String?> getUser() async {
    final db = await database;
    final result = await db.query('users', limit: 1);
    if (result.isEmpty) return null;
    return result.first['name'] as String;
  }

  Future<int> saveLocation({
    required String cityName,
    required double lat,
    required double lon,
    bool isCurrent = false,
  }) async {
    final db = await database;
    final existing = await db.query(
      'locations',
      where: 'city_name = ?',
      whereArgs: [cityName],
    );
    if (existing.isNotEmpty) return existing.first['id'] as int;
    return await db.insert('locations', {
      'city_name': cityName,
      'lat': lat,
      'lon': lon,
      'is_current': isCurrent ? 1 : 0,
    });
  }

  Future<List<Map<String, dynamic>>> getSavedLocations() async {
    final db = await database;
    return await db.query(
      'locations',
      where: 'is_current = ?',
      whereArgs: [0],
    );
  }

  Future<void> deleteLocation(int id) async {
    final db = await database;
    await db.delete('locations', where: 'id = ?', whereArgs: [id]);
    await db.delete(
      'weather_cache',
      where: 'location_id = ?',
      whereArgs: [id],
    );
  }

  Future<void> cacheWeather({
    required int locationId,
    required Map<String, dynamic> data,
  }) async {
    final db = await database;
    final existing = await db.query(
      'weather_cache',
      where: 'location_id = ?',
      whereArgs: [locationId],
    );
    final now = DateTime.now().millisecondsSinceEpoch;
    if (existing.isEmpty) {
      await db.insert('weather_cache', {
        'location_id': locationId,
        'json_data': jsonEncode(data),
        'last_updated': now,
      });
    } else {
      await db.update(
        'weather_cache',
        {'json_data': jsonEncode(data), 'last_updated': now},
        where: 'location_id = ?',
        whereArgs: [locationId],
      );
    }
  }

  Future<Map<String, dynamic>?> getCachedWeather(
    int locationId,
  ) async {
    final db = await database;
    final result = await db.query(
      'weather_cache',
      where: 'location_id = ?',
      whereArgs: [locationId],
    );
    if (result.isEmpty) return null;
    return {
      'data': jsonDecode(result.first['json_data'] as String),
      'last_updated': result.first['last_updated'] as int,
    };
  }

  Future<int> getCurrentLocationId() async {
    final db = await database;
    final result = await db.query(
      'locations',
      where: 'is_current = ?',
      whereArgs: [1],
    );
    if (result.isNotEmpty) return result.first['id'] as int;
    return await db.insert('locations', {
      'city_name': 'Current Location',
      'lat': 0,
      'lon': 0,
      'is_current': 1,
    });
  }

  Future<void> updateCurrentLocation({
    required String cityName,
    required double lat,
    required double lon,
  }) async {
    final db = await database;
    await db.update(
      'locations',
      {'city_name': cityName, 'lat': lat, 'lon': lon},
      where: 'is_current = ?',
      whereArgs: [1],
    );
  }

  Future<void> clearAll() async {
    final db = await database;
    await db.delete('users');
    await db.delete('weather_cache');
    await db.delete('locations');
  }
}

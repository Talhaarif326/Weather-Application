import 'dart:convert';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

/// Singleton SQLite database helper for the Weather app.
/// Manages three tables: users, locations, and weather_cache.
/// Access via [DbHelper.instance] — never instantiate directly.
class DbHelper {
  static final DbHelper instance = DbHelper._internal();
  static Database? _db;
  DbHelper._internal();

  /// Returns the open database instance, initializing it on first access.
  /// Subsequent calls return the cached [_db] directly.
  Future<Database> get database async {
    if (_db != null) return _db!;
    _db = await _initDb();
    return _db!;
  }

  /// Opens (or creates) the SQLite database at the platform's default path.
  /// Creates three tables on first run:
  /// - [users] — stores the logged-in user's name (one row max)
  /// - [locations] — stores saved cities and the current GPS location
  /// - [weather_cache] — stores the last API response per location
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

  /// Saves the user's name to the [users] table.
  /// Deletes any existing row first so only one user row exists at a time.
  Future<void> saveUser(String name) async {
    final db = await database;
    await db.delete('users');
    await db.insert('users', {'name': name});
  }

  /// Returns the saved user's name, or null if no user has been saved yet.
  Future<String?> getUser() async {
    final db = await database;
    final result = await db.query('users', limit: 1);
    if (result.isEmpty) return null;
    return result.first['name'] as String;
  }

  /// Saves a city to the [locations] table and returns its row ID.
  /// If a location with the same [cityName] already exists, returns
  /// the existing row's ID without inserting a duplicate.
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

  /// Returns all manually saved locations (is_current = 0).
  /// Excludes the current GPS location row so it doesn't appear
  /// in the Manage Locations list in Settings.
  Future<List<Map<String, dynamic>>> getSavedLocations() async {
    final db = await database;
    return await db.query(
      'locations',
      where: 'is_current = ?',
      whereArgs: [0],
    );
  }

  /// Deletes a saved location and its associated weather cache by [id].
  /// The CASCADE foreign key handles the cache deletion automatically,
  /// but we delete explicitly here for clarity and safety.
  Future<void> deleteLocation(int id) async {
    final db = await database;
    await db.delete('locations', where: 'id = ?', whereArgs: [id]);
    await db.delete(
      'weather_cache',
      where: 'location_id = ?',
      whereArgs: [id],
    );
  }

  /// Inserts or updates the cached weather response for a given [locationId].
  /// If no cache row exists for this location, inserts a new one.
  /// If one already exists, updates it with the latest data and timestamp.
  /// [data] should contain both 'cityName' and 'apiResponse' keys.
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

  /// Returns the cached weather data for a given [locationId], or null
  /// if no cache exists. The returned map contains:
  /// - 'data': the decoded API response + city name
  /// - 'last_updated': the Unix timestamp of when it was cached
  Future<Map<String, dynamic>?> getCachedWeather(int locationId) async {
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

  /// Returns the row ID of the current GPS location row (is_current = 1).
  /// If no such row exists yet (first app launch), creates one with
  /// placeholder coordinates and returns its new ID.
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

  /// Updates the current GPS location row with the latest resolved
  /// city name and coordinates after a successful location fetch.
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

  /// Wipes all data from the database — users, locations, and weather cache.
  /// Called when the user logs out from the Settings screen.
  Future<void> clearAll() async {
    final db = await database;
    await db.delete('users');
    await db.delete('weather_cache');
    await db.delete('locations');
  }
}
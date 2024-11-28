import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class MyDatabaseClass {
  late Database _db;

  // Initialize the database
  Future<void> init() async {
    var dbPath = await getDatabasesPath();
    String path = join(dbPath, 'events.db');
    _db = await openDatabase(path, version: 1, onCreate: (db, version) async {
      await db.execute('''
        CREATE TABLE events (
          ID INTEGER PRIMARY KEY AUTOINCREMENT,
          name TEXT,
          category TEXT,
          date TEXT,
          location TEXT,
          description TEXT,
          status TEXT
        )
      ''');
      await db.execute('''
        CREATE TABLE gifts (
          ID INTEGER PRIMARY KEY AUTOINCREMENT,
          name TEXT,
          category TEXT,
          description TEXT,
          price REAL,
          isPledged INTEGER
        )
      ''');
      await db.execute('''
        CREATE TABLE users (
          ID INTEGER PRIMARY KEY AUTOINCREMENT,
          email TEXT UNIQUE,
          password TEXT
        )
      ''');
    });
  }

  // Get all events from the database
  Future<List<Map<String, dynamic>>> getAllEvents() async {
    return await _db.query('events');
  }

  // Add a new event to the database
  Future<void> addEvent(String name, String date, String location, String description, String category, int userID) async {
    await _db.insert('events', {
      'name': name,
      'category': category,
      'date': date,
      'location': location,
      'description': description,
      'status': 'Upcoming',  // Assuming default status is 'Upcoming'
    });
  }

  // Update an existing event in the database
  Future<void> updateEvent(int eventID, String name, String date, String location, String description, String category) async {
    await _db.update(
      'events',
      {
        'name': name,
        'category': category,
        'date': date,
        'location': location,
        'description': description,
        'status': 'Upcoming',  // Update status as well, or keep it unchanged
      },
      where: 'ID = ?',
      whereArgs: [eventID],
    );
  }

  // Delete an event from the database
  Future<void> deleteEvent(int eventID) async {
    await _db.delete('events', where: 'ID = ?', whereArgs: [eventID]);
  }

  // Get all gifts from the database
  Future<List<Map<String, dynamic>>> getAllGifts() async {
    return await _db.query('gifts');
  }

  // Add a new gift to the database
  Future<void> addGift(String name, String category, String description, double price) async {
    await _db.insert('gifts', {
      'name': name,
      'category': category,
      'description': description,
      'price': price,
    });
  }

  // Update an existing gift in the database
  Future<void> updateGift(int id, String name, String category, String description, double price, bool isPledged) async {
    await _db.update(
      'gifts',
      {
        'name': name,
        'category': category,
        'description': description,
        'price': price,
        'isPledged': isPledged ? 1 : 0,
      },
      where: 'ID = ?',
      whereArgs: [id],
    );
  }

  // Delete a gift from the database
  Future<void> deleteGift(int id) async {
    await _db.delete('gifts', where: 'ID = ?', whereArgs: [id]);
  }
  // Add a new User to the database
  Future<void> addUser(String email, String password) async {
    await _db.insert('users', {
      'email': email,
      'password': password,
    });
  }
// Get all Users from the database
  Future<Map<String, dynamic>?> getUser(String email) async {
    final result = await _db.query('users', where: 'email = ?', whereArgs: [email]);
    return result.isNotEmpty ? result.first : null;
  }

}

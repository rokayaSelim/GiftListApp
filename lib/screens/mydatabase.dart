import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class MyDatabaseClass {
  static Database? _db;

  // Singleton pattern for database access
  Future<Database?> get database async {
    if (_db == null) {
      _db = await init();
    }
    return _db;
  }

  static const int _version = 1;

  // Initialize the database
  Future<Database> init() async {
    String dbPath = await getDatabasesPath();
    String path = join(dbPath, 'my_database.db');

    return await openDatabase(
      path,
      version: _version,
      onCreate: (db, version) async {
        // Create events table
        await db.execute('''
          CREATE TABLE IF NOT EXISTS events (
            ID INTEGER PRIMARY KEY AUTOINCREMENT,
            name TEXT NOT NULL,
            category TEXT,
            date TEXT,
            location TEXT,
            description TEXT,
            status TEXT
          )
        ''');

        // Create gifts table
        await db.execute('''
          CREATE TABLE IF NOT EXISTS gifts (
            ID INTEGER PRIMARY KEY AUTOINCREMENT,
            name TEXT NOT NULL,
            category TEXT,
            description TEXT,
            price REAL,
            isPledged INTEGER
          )
        ''');

        // Create users table
        await db.execute('''
          CREATE TABLE IF NOT EXISTS users (
            ID INTEGER PRIMARY KEY AUTOINCREMENT,
            email TEXT NOT NULL UNIQUE,
            password TEXT NOT NULL,
            username TEXT NOT NULL
          )
        ''');

        print("Database created and tables initialized.");
      },
    );
  }

  // Insert a user into the database
  Future<void> addUser(String email, String password, String username) async {
    Database? db = await database;
    await db!.insert('users', {
      'username': username,
      'email': email,
      'password': password,
    });
  }

  // Fetch all users from the database
  Future<List<Map<String, dynamic>>> getAllUsers() async {
    Database? db = await database;
    return await db!.query('users');
  }

  // Retrieve a user by email
  Future<Map<String, dynamic>?> getUserByEmail(String email) async {
    Database? db = await database;
    final result = await db!.query(
      'users',
      where: 'email = ?',
      whereArgs: [email],
    );
    return result.isNotEmpty ? result.first : null;
  }

  // Update user information
  Future<void> updateUser(int id, String email, String username, String password) async {
    Database? db = await database;
    await db!.update(
      'users',
      {
        'email': email,
        'username': username,
        'password': password,
      },
      where: 'ID = ?',
      whereArgs: [id],
    );
  }

  // Delete a user by ID
  Future<void> deleteUser(int id) async {
    Database? db = await database;
    await db!.delete(
      'users',
      where: 'ID = ?',
      whereArgs: [id],
    );
  }

  // Get all events from the database
  Future<List<Map<String, dynamic>>> getAllEvents() async {
    Database? db = await database;
    return await db!.query('events');
  }

  // Add a new event to the database
  Future<void> addEvent(String name, String date, String location, String description, String category, int userID) async {
    Database? db = await database;
    await db!.insert('events', {
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
    Database? db = await database;
    await db!.update(
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
    Database? db = await database;
    await db!.delete('events', where: 'ID = ?', whereArgs: [eventID]);
  }

  // Get all gifts from the database
  Future<List<Map<String, dynamic>>> getAllGifts() async {
    Database? db = await database;
    return await db!.query('gifts');
  }

  // Add a new gift to the database
  Future<void> addGift(String name, String category, String description, double price) async {
    Database? db = await database;
    await db!.insert('gifts', {
      'name': name,
      'category': category,
      'description': description,
      'price': price,
    });
  }

  // Update an existing gift in the database
  Future<void> updateGift(int id, String name, String category, String description, double price, bool isPledged) async {
    Database? db = await database;
    await db!.update(
      'gifts',
      {
        'name': name,
        'category': category,
        'description': description,
        'price': price,
        'isPledged': isPledged ? 1 : 0, // Converting boolean to integer
      },
      where: 'ID = ?',
      whereArgs: [id],
    );
  }

  // Delete a gift from the database
  Future<void> deleteGift(int id) async {
    Database? db = await database;
    await db!.delete('gifts', where: 'ID = ?', whereArgs: [id]);
  }

  // Clear the database
  Future<void> deleteDatabaseFile() async {
    String dbPath = await getDatabasesPath();
    String path = join(dbPath, 'my_database.db');

    bool exists = await databaseExists(path);
    if (exists) {
      await deleteDatabase(path);
      print("Database deleted successfully.");
    } else {
      print("No database found to delete.");
    }
  }
}

import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class MyDatabaseClass {
  static Database? _mydb;

  // Singleton pattern for database access
  Future<Database?> get database async {
    if (_mydb == null) {
      _mydb = await init();
    }
    return _mydb;
  }

  static const int _version = 1;

  // Initialize the database
  Future<Database> init() async {
    String mydbPath = await getDatabasesPath();
    String path = join(mydbPath, 'my_databases.db');

    return await openDatabase(
      path,
      version: _version,
      onCreate: (mydb, version) async {
        // Create events table
        await mydb.execute('''
          CREATE TABLE IF NOT EXISTS events (
            ID INTEGER PRIMARY KEY AUTOINCREMENT,
            name TEXT NOT NULL,
            category TEXT,
            date TEXT,
            location TEXT,
            description TEXT,
            status TEXT,
            userId INTEGER NOT NULL,
            FOREIGN KEY(userId) REFERENCES users(ID)
          )
        ''');

        // Create gifts table
        await mydb.execute('''
          CREATE TABLE IF NOT EXISTS gifts (
            ID INTEGER PRIMARY KEY AUTOINCREMENT,
            name TEXT NOT NULL,
            category TEXT,
            description TEXT,
            price REAL,
            isPledged INTEGER DEFAULT 0,
            eventId INTEGER NOT NULL,
            FOREIGN KEY(eventId) REFERENCES events(ID)
          )
        ''');

        // Create users table
        await mydb.execute('''
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
    Database? mydb = await database;
    await mydb!.insert('users', {
      'username': username,
      'email': email,
      'password': password,
    });
  }

  // Fetch all users from the database
  Future<List<Map<String, dynamic>>> getAllUsers() async {
    Database? mydb = await database;
    return await mydb!.query('users');
  }

  // Retrieve a user by email
  Future<Map<String, dynamic>?> getUserByEmail(String email) async {
    Database? mydb = await database;
    final result = await mydb!.query(
      'users',
      where: 'email = ?',
      whereArgs: [email],
    );
    return result.isNotEmpty ? result.first : null;
  }

  // Update user information
  Future<void> updateUser(int id, String email, String username, String password) async {
    Database? mydb = await database;
    await mydb!.update(
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
    Database? mydb = await database;
    await mydb!.delete(
      'users',
      where: 'ID = ?',
      whereArgs: [id],
    );
  }

  // Get all events from the database
  Future<List<Map<String, dynamic>>> getAllEvents() async {
    Database? mydb = await database;
    return await mydb!.query('events');
  }

  // Add a new event to the database
  Future<void> addEvent(String name, String date, String location, String description, String category, int userId) async {
    Database? mydb = await database;
    await mydb!.insert('events', {
      'name': name,
      'category': category,
      'date': date,
      'location': location,
      'description': description,
      'status': 'Upcoming', // Assuming default status is 'Upcoming'
      'userId': userId,
    });
  }

  Future<List<Map<String, dynamic>>> getGiftsForEvent(int eventId) async {
    Database? mydb = await database;
    return await mydb!.query('gifts', where: 'eventId = ?', whereArgs: [eventId]);
  }

  // Update an existing event in the database
  Future<void> updateEvent(int eventID, String name, String date, String location, String description, String category) async {
    Database? mydb = await database;
    await mydb!.update(
      'events',
      {
        'name': name,
        'category': category,
        'date': date,
        'location': location,
        'description': description,
      },
      where: 'ID = ?',
      whereArgs: [eventID],
    );
  }

  // Delete an event from the database
  Future<void> deleteEvent(int eventID) async {
    Database? mydb = await database;
    await mydb!.delete('events', where: 'ID = ?', whereArgs: [eventID]);
  }

  // Get all gifts from the database
  Future<List<Map<String, dynamic>>> getAllGifts() async {
    Database? mydb = await database;
    return await mydb!.query('gifts');
  }

  // Add a new gift to the database
  Future<void> addGift(String name, String category, String description, double price, int eventId) async {
    Database? mydb = await database;
    await mydb!.insert('gifts', {
      'name': name,
      'category': category,
      'description': description,
      'price': price,
      'eventId': eventId,
    });
  }

  // Update an existing gift in the database
  Future<void> updateGift(int id, String name, String category, String description, double price, bool isPledged) async {
    Database? mydb = await database;
    await mydb!.update(
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
    Database? mydb = await database;
    await mydb!.delete('gifts', where: 'ID = ?', whereArgs: [id]);
  }

  // Clear the database
  Future<void> deleteDatabaseFile() async {
    String mydbPath = await getDatabasesPath();
    String path = join(mydbPath, 'my_databases.db');

    bool exists = await databaseExists(path);
    if (exists) {
      await deleteDatabase(path);
      print("Database deleted successfully.");
    } else {
      print("No database found to delete.");
    }
  }
}

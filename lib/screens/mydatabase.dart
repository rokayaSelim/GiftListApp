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
            PledgedBy INTEGER NULL,
            imagePath TEXT,
            FOREIGN KEY(eventId) REFERENCES events(ID)
            FOREIGN KEY(PledgedBy) REFERENCES users(ID)
          )
        ''');

        // Create users table
        await mydb.execute('''
          CREATE TABLE IF NOT EXISTS users (
            ID INTEGER PRIMARY KEY AUTOINCREMENT,
            email TEXT NOT NULL UNIQUE,
            password TEXT NOT NULL,
            username TEXT NOT NULL,
            phoneNumber TEXT NOT NULL
          )
        ''');
        await mydb.execute('''
          CREATE TABLE IF NOT EXISTS friends (
            ID INTEGER PRIMARY KEY AUTOINCREMENT,
            userId INTEGER NOT NULL,
            FOREIGN KEY(userId) REFERENCES users(ID)
          )
        ''');

        print("Database created and tables initialized.");
      },
    );
  }
// Add a friend relationship in the database
  Future<void> addFriend(int userId, int friendId) async {
    Database? mydb = await database;
    await mydb!.insert('friends', {
      'userId': userId,
      'ID': friendId,
    });
  }

  // Remove a friend relationship from the database
  Future<void> removeFriend(int userId, int friendId) async {
    Database? mydb = await database;
    await mydb!.delete(
      'friends',
      where: 'userId = ? AND ID = ?',
      whereArgs: [userId, friendId],
    );
  }
  Future<List<Map<String, dynamic>>> getPledgedGiftsByUserId(int userId) async {
    Database? mydb = await database;
    return await mydb!.query(
      'gifts',
      where: 'isPledged = 1 AND PledgedBy = ?',
      whereArgs: [userId],
    );
  }
  // Fetch added friends for a specific user
  Future<List<Map<String, dynamic>>> getFriends(int userId) async {
    Database? mydb = await database;
    final result = await mydb!.rawQuery('''
    SELECT u.ID, u.username, u.email
    FROM friends f
    INNER JOIN users u ON f.ID = u.ID
    WHERE f.userId = ?
  ''', [userId]);

    return result;
  }

  // Insert a user into the database
  Future<void> addUser(String email, String password, String username,String number) async {
    Database? mydb = await database;
    await mydb!.insert('users', {
      'username': username,
      'email': email,
      'password': password,
      'phoneNumber': number,
    });
  }

  // Fetch all users from the database
  Future<List<Map<String, dynamic>>> getAllUsers() async {
    Database? mydb = await database;
    return await mydb!.query('users');
  }

  // Retrieve a user by ID
  Future<Map<String, dynamic>?> getUserById(int userId) async {
    Database? mydb = await database;
    final result = await mydb!.query(
      'users',
      where: 'ID = ?',
      whereArgs: [userId],
    );
    return result.isNotEmpty ? result.first : null;
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
  Future<void> updateUserName(int userId, String newUserName) async {
    Database? mydb = await database;

    // Update query to modify username based on email
    await mydb!.update(
      'users',
      {
        'username': newUserName,
      },
      where: 'ID = ?',
      whereArgs: [userId],
    );
    print("Username updated successfully for $userId.");
  }
  Future<void> updateUserPhone(int userId, String newUserPhone) async {
    Database? mydb = await database;

    // Update query to modify username based on email
    await mydb!.update(
      'users',
      {
        'phoneNumber': newUserPhone,
      },
      where: 'ID = ?',
      whereArgs: [userId],
    );
    print("Username updated successfully for $userId.");
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
  Future<List<Map<String, dynamic>>> getEventsByUserId(int userId) async {
    Database? mydb = await database;
    return await mydb!.query(
      'events',
      where: 'userId = ?',
      whereArgs: [userId],
    );
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
  Future<void> updateGift(int id, String name, String category, String description, double price, bool isPledged, {int? userId}) async {
    Database? mydb = await database;
    await mydb!.update(
      'gifts',
      {
        'name': name,
        'category': category,
        'description': description,
        'price': price,
        'isPledged': isPledged ? 1 : 0,
        'PledgedBy': userId,
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
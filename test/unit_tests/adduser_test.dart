import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart'; // Import sqflite_common_ffi
import 'package:proj_20p4322/screens/mydatabase.dart'; // Adjust the path to your DatabaseHelper file

void main() {
  group('DatabaseHelper Unit Tests', () {
    late MyDatabaseClass dbHelper;
    late SharedPreferences sharedPreferences;
    int? testUserId; // Store the ID of the user inserted during the test

    setUp(() async {
      // Initialize sqflite_common_ffi for in-memory SQLite database
      sqfliteFfiInit();
      databaseFactory = databaseFactoryFfi;

      // Initialize the DatabaseHelper for database interactions
      dbHelper = MyDatabaseClass();

      // Set up SharedPreferences with mocked initial values
      SharedPreferences.setMockInitialValues({});
      sharedPreferences = await SharedPreferences.getInstance();
      // Clean up any existing user with the same email to avoid UNIQUE constraint violation
      final existingUser = await dbHelper.getUserByEmail('testuser@example.com');
      if (existingUser != null) {
        await dbHelper.deleteUserByEmail('testuser@example.com');
      }
    });

    test('Should add a user to the database and retrieve it', () async {
      // Arrange
      final email = 'testuser@example.com';
      final password = 'TestPassword123!';
      final username = 'TestUser';
      final phoneNumber = '1234567890';

      // Act
      await dbHelper.addUser(email, password, username, phoneNumber);

      // Retrieve the user by email (assuming a method exists to get a user by email)
      final retrievedUser = await dbHelper.getUserByEmail(email);


      // Assert
      expect(retrievedUser, isNotNull);
      expect(retrievedUser!['email'], equals(email));
      expect(retrievedUser['username'], equals(username));
      expect(retrievedUser['phoneNumber'], equals(phoneNumber));
    });

    test('Should save userId in SharedPreferences and retrieve it', () async {
      // Arrange
      final userId = 123;

      // Act
      await sharedPreferences.setInt('userId', userId);
      final retrievedUserId = sharedPreferences.getInt('userId');

      // Assert
      expect(retrievedUserId, equals(userId));
    });

    tearDown(() async {
      // Clean up any users added during the test (if necessary)
      if (testUserId != null) {
        await dbHelper.deleteUser(testUserId);
        print('Test user with ID $testUserId deleted.');
      }
    });
  });
}

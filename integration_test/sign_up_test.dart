// integration_test/sign_up_test.dart
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:proj_20p4322/main.dart'; // Update with your app entry point
import 'package:firebase_auth/firebase_auth.dart';
import 'package:proj_20p4322/screens/HomePage.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets("Sign up user test", (tester) async {

    WidgetsFlutterBinding.ensureInitialized();
    await Firebase.initializeApp();
    // Pump the widget tree to the SignUpPage
    await tester.pumpWidget(HedieatyApp());  // Replace with your app's entry point if different

    // Wait for the SignUpPage to be loaded
    await tester.pumpAndSettle();

    // Find the form fields and buttons
    final usernameField = find.byType(TextFormField).at(0);
    final emailField = find.byType(TextFormField).at(1);
    final passwordField = find.byType(TextFormField).at(2);
    final confirmPasswordField = find.byType(TextFormField).at(3);
   // final phoneNumberField = find.byType(TextFormField).at(4);
    final signUpButton = find.byType(ElevatedButton);
    //final signInLink = find.byType(TextButton);

    // Verify the sign-up form is displayed
    expect(usernameField, findsOneWidget);
    expect(emailField, findsOneWidget);
    expect(passwordField, findsOneWidget);
    expect(confirmPasswordField, findsOneWidget);
   // expect(phoneNumberField, findsOneWidget);
    expect(signUpButton, findsOneWidget);
    //expect(signInLink, findsOneWidget);

    // Enter data in the text fields
    await tester.enterText(usernameField, "TestUser");
    await tester.testTextInput.receiveAction(TextInputAction.done);
    await tester.enterText(emailField, "testusermnoqp@example.com");
    await tester.testTextInput.receiveAction(TextInputAction.done);
    await tester.enterText(passwordField, "TestPassword123!");
    await tester.testTextInput.receiveAction(TextInputAction.done);
    await tester.enterText(confirmPasswordField, "TestPassword123!");
    await tester.testTextInput.receiveAction(TextInputAction.done);

    // Tap on the Sign Up button

    await tester.ensureVisible(signUpButton);
    await tester.tap(signUpButton);
    await tester.pumpAndSettle(Duration(seconds: 15));
    // Wait for the sign-up process to complete
    // Verify that the user is signed up successfully and redirected to the next page
    // You can check for specific widgets or actions that occur after sign-up (e.g., HomePage being displayed).
    expect(find.text("Friends"), findsOneWidget);
    expect(find.text("Create Event/List"), findsOneWidget);
    //expect(find.byKey(Key('signUpButton')), findsOneWidget);
    //await tester.pumpAndSettle(); // Ensure the UI settles after the tap
    //expect(find.text('Sign-up successful!'), findsOneWidget);
  });

  testWidgets("Sign up failure due to mismatched passwords", (tester) async {
    WidgetsFlutterBinding.ensureInitialized();
    await Firebase.initializeApp();

    await tester.pumpWidget(HedieatyApp());

    await tester.pumpAndSettle();

    final usernameField = find.byType(TextFormField).at(0);
    final emailField = find.byType(TextFormField).at(1);
    final passwordField = find.byType(TextFormField).at(2);
    final confirmPasswordField = find.byType(TextFormField).at(3);
    final signUpButton = find.byType(ElevatedButton);

    await tester.enterText(usernameField, "TestUser");
    await tester.enterText(emailField, "testusermnoqp@example.com");
    await tester.enterText(passwordField, "TestPassword123!");
    await tester.enterText(confirmPasswordField, "DifferentPassword123!");

    await tester.tap(signUpButton);
    await tester.pumpAndSettle();

    // Check if the error message is shown for mismatched passwords
    expect(find.text("Passwords do not match."), findsOneWidget);
  });
  testWidgets("Sign up failure due to already used email", (tester) async {
    await tester.pumpWidget(HedieatyApp());

    await tester.pumpAndSettle();

    final usernameField = find.byType(TextFormField).at(0);
    final emailField = find.byType(TextFormField).at(1);
    final passwordField = find.byType(TextFormField).at(2);
    final confirmPasswordField = find.byType(TextFormField).at(3);
    final signUpButton = find.byType(ElevatedButton);

    // Assuming "testuser@example.com" is already registered in Firebase
    await tester.enterText(usernameField, "TestUser");
    await tester.enterText(emailField, "testusermnoqp@example.com");
    await tester.enterText(passwordField, "TestPassword123!");
    await tester.enterText(confirmPasswordField, "TestPassword123!");

    await tester.tap(signUpButton);
    await tester.pumpAndSettle(Duration(seconds: 10));

    // Verify that the error message for email already in use is shown
    expect(find.text("The email is already registered."), findsOneWidget);
  });
}

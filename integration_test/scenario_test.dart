// integration_test/sign_up_test.dart
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:proj_20p4322/main.dart'; // Update with your app entry point

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets("Scenario user test", (tester) async {

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
    await tester.enterText(emailField, "TestssssssUserssssss@example.com");
    await tester.testTextInput.receiveAction(TextInputAction.done);
    await tester.enterText(passwordField, "TestPassword123!");
    await tester.testTextInput.receiveAction(TextInputAction.done);
    await tester.enterText(confirmPasswordField, "TestPassword123!");
    await tester.testTextInput.receiveAction(TextInputAction.done);

    // Tap on the Sign Up button

    await tester.ensureVisible(signUpButton);
    await tester.tap(signUpButton);
    await tester.pumpAndSettle(Duration(seconds: 20));
    // Wait for the sign-up process to complete
    // Verify that the user is signed up successfully and redirected to the next page
    // You can check for specific widgets or actions that occur after sign-up (e.g., HomePage being displayed).
    expect(find.text("Friends"), findsOneWidget);
    expect(find.text("Create Event/List"), findsOneWidget);
    //expect(find.byKey(Key('signUpButton')), findsOneWidget);
    //await tester.pumpAndSettle(); // Ensure the UI settles after the tap
    //expect(find.text('Sign-up successful!'), findsOneWidget);
    // Find and tap on the "Create Event/List" button
    final createEventButton = find.widgetWithText(FloatingActionButton, "Create Event/List");
    expect(createEventButton, findsOneWidget);

    await tester.tap(createEventButton);
    await tester.pumpAndSettle(Duration(seconds: 5));

    expect(find.text("Search"), findsOneWidget);

    // Tap the "Create Event/List" button
    final createAddEventButton = find.widgetWithIcon(IconButton, Icons.add_circle);
    await tester.tap(createAddEventButton);
    await tester.pumpAndSettle(Duration(seconds: 5));

    // Verify the "Add New Event" dialog is displayed
    expect(find.text("Add New Event"), findsOneWidget);

    // Interact with the "Add New Event" dialog fields
    final eventNameField = find.byType(TextFormField).at(0);
    final eventCategoryField = find.byType(TextFormField).at(1);
    final eventDateField = find.byType(TextFormField).at(2);
    final eventLocationField = find.byType(TextFormField).at(3);
    final eventDescriptionField = find.byType(TextFormField).at(4);
    final eventStatusField = find.byType(TextFormField).at(5);
    final addButton = find.widgetWithText(ElevatedButton, "Add");

    await tester.enterText(eventNameField, "Birthday Party");
    await tester.enterText(eventCategoryField, "Personal");
    await tester.enterText(eventDateField, "2024-12-31");
    await tester.enterText(eventLocationField, "Home");
    await tester.enterText(eventDescriptionField, "Celebrating with friends and family.");
    await tester.enterText(eventStatusField, "upcoming");

    await tester.tap(addButton);
    await tester.pumpAndSettle(Duration(seconds: 5)); // Allow time for dialog operations

    // Verify the publish dialog is displayed
    expect(find.text("Publish Event"), findsOneWidget);

    // Interact with the publish confirmation dialog
    final yesButton = find.widgetWithText(TextButton, "Yes");
    await tester.tap(yesButton);
    await tester.pumpAndSettle(Duration(seconds: 10));

    // Verify success messages or event list updates
    expect(find.text("Event published to Friends!"), findsOneWidget);

    // Navigate to Gift List Page
    final giftListButton = find.widgetWithIcon(IconButton, Icons.card_giftcard);
    await tester.tap(giftListButton);
    await tester.pumpAndSettle(Duration(seconds: 10));

    // Verify navigation to Gift List Page
    expect(find.text("Add New Gift"), findsOneWidget);

    // Add new gift
    final addGiftButton = find.widgetWithText(ElevatedButton, "Add New Gift");
    await tester.tap(addGiftButton);
    await tester.pumpAndSettle(Duration(seconds: 10));

    // Verify navigation to Add Gift Details Page
    final giftNameField = find.byType(TextFormField).at(0);
    final giftDescriptionField = find.byType(TextFormField).at(1);
    final giftCategoryField = find.byType(DropdownButtonFormField<String>);
    final giftPriceField = find.byType(TextFormField).at(2);
    final pledgeSwitch = find.byType(Switch);
    final saveGiftButton = find.widgetWithText(ElevatedButton, "Add Gift");

    // Fill the form
    await tester.enterText(giftNameField, "Smart Watch");
    await tester.enterText(giftDescriptionField, "Smart watch for health tracking.");
    await tester.tap(giftCategoryField);
    await tester.pumpAndSettle(Duration(seconds: 2));
    await tester.tap(find.text("Electronics").last);
    await tester.pumpAndSettle(Duration(seconds: 2));
    await tester.enterText(giftPriceField, "150");
    await tester.tap(pledgeSwitch);

    // Save the gift
    await tester.tap(saveGiftButton);
    await tester.pumpAndSettle(Duration(seconds: 5));

    // Verify publish confirmation dialog
    final giftPublishYesButton = find.widgetWithText(TextButton, "Yes");
    await tester.tap(giftPublishYesButton);
    await tester.pumpAndSettle(Duration(seconds: 15));

    // Verify success message and navigation back to Gift List Page
    expect(find.text("Gift published to Friends!"), findsOneWidget);
    expect(find.text("Smart Watch"), findsOneWidget); // Ensure the gift is listed

    // Navigate to Profile Page using BottomNavigationBar
    final profileTabIcon = find.byIcon(Icons.person_2_outlined);
    await tester.tap(profileTabIcon);
    await tester.pumpAndSettle();

    // Verify Profile Page
    expect(find.text("Profile"), findsOneWidget);
    expect(find.text("Logout"), findsOneWidget);

    // Logout process
    final logoutButton = find.widgetWithIcon(ListTile, Icons.logout);
    await tester.tap(logoutButton);
    await tester.pumpAndSettle(Duration(seconds: 10));

    // Verify redirection to SignInPage
    expect(find.text("Sign In"), findsOneWidget);
  });
}
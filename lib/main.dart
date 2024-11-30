import 'package:flutter/material.dart';
import 'screens/SignUpPage.dart';
import 'screens/SignInPage.dart';
import 'screens/HomePage.dart';
import 'screens/EventListPage.dart';
import 'screens/GiftListPage.dart';
import 'screens/GiftDetailsPage.dart';
import 'screens/ProfilePage.dart';
import 'screens/MyPledgedGiftsPage.dart';
import 'screens/PledgedGiftsPage.dart';

void main() {
  runApp(HedieatyApp());
}

class HedieatyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Hedieaty',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      initialRoute: '/signUp',
      routes: {
        '/': (context) {
          // Extract userEmail from the arguments and pass it to the ProfilePage
          final args = ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>? ?? {};
          final userEmail = args['userEmail'] ?? ''; // Fallback to empty if not provided
          return HomePage(userEmail: userEmail);
        },
        '/eventList': (context) => EventListPage(),
        '/giftList': (context) {
          final eventId = ModalRoute.of(context)?.settings.arguments as int? ?? 0;
          return GiftListPage(eventId: eventId); // Pass eventId dynamically
          },
        '/giftDetails': (context) {
          final args = ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>? ?? {};
          final eventId = args['eventId'] ?? 0; // Extract eventId from arguments
          return GiftDetailsPage(eventId: eventId); // Pass giftId and eventId dynamically
        },
        '/profile': (context) {
          // Extract userEmail from the arguments and pass it to the ProfilePage
          final args = ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>? ?? {};
          final userEmail = args['userEmail'] ?? ''; // Fallback to empty if not provided
          return ProfilePage(userEmail: userEmail);
        },
        '/MypledgedGifts': (context) => MyPledgedGiftsPage(),
        '/pledgedGifts': (context) => PledgedGiftsPage(pledgedGifts: [],),
        '/signUp': (context) => SignUpPage(),
        '/signIn': (context) => SignInPage(),
      },
    );
  }
}

import 'package:flutter/material.dart';
import 'screens/SignUpPage.dart';
import 'screens/SignInPage.dart';
import 'screens/HomePage.dart';
import 'screens/EventListPage.dart';
import 'screens/UserEventListPage.dart';
import 'screens/GiftListPage.dart';
import 'screens/UserGiftListPage.dart';
import 'screens/GiftDetailsPage.dart';
import 'screens/ProfilePage.dart';
import 'screens/MyPledgedGiftsPage.dart';
import 'screens/PledgedGiftsPage.dart';
import 'package:firebase_core/firebase_core.dart';


void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(HedieatyApp());
}

class HedieatyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Hedieaty',
      initialRoute: '/signUp',
      routes: {
        '/': (context) => HomePage(),
        '/eventList': (context) => EventListPage(),
        '/usereventList': (context) => UserEventListPage(),
        '/userGiftList': (context)=>UserGiftListPage(),
        '/giftList': (context) => GiftListPage(),
        '/giftDetails': (context) {
          final args = ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>? ?? {};
          final eventId = args['eventId'] ?? 0; // Extract eventId from arguments
          return GiftDetailsPage(eventId: eventId); // Pass giftId and eventId dynamically
        },
        '/profile': (context) => ProfilePage(),
        '/MypledgedGifts': (context) => MyPledgedGiftsPage(),
        '/pledgedGifts': (context) => PledgedGiftsPage(pledgedGifts: [],),
        '/signUp': (context) => SignUpPage(),
        '/signIn': (context) => SignInPage(),
      },
    );
  }
}

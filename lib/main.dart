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
        '/': (context) => HomePage(),
        '/eventList': (context) => EventListPage(),
        '/giftList': (context) => GiftListPage(),
        '/giftDetails': (context) => GiftDetailsPage(),
        '/profile': (context) => ProfilePage(userName: '', userEmail: ''),
        '/MypledgedGifts': (context) => MyPledgedGiftsPage(),
        '/pledgedGifts': (context) => PledgedGiftsPage(pledgedGifts: [],),
        '/signUp': (context) => SignUpPage(),
        '/signIn': (context) => SignInPage(),
      },
    );
  }
}

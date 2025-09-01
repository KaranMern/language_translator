import 'package:flutter/material.dart';
import 'package:flutter_alice/alice.dart';
import 'package:language_translator/Notification/Local_Notification.dart';
import 'package:language_translator/alice/Alice_Configuration.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'Home_Screen.dart';
import 'Screens/Profile_screen.dart';

final GlobalKey<NavigatorState> navigatorsKey =
    GlobalKey<NavigatorState>(); //globally access the key

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  tz.initializeTimeZones(); //for local timezone
  await LocalNotification.localInit();//for localnotification
  final alice = Alice(showNotification: true);
  dioProvider.initAlice(alice);
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      navigatorKey: navigatorsKey,
      routes: {'Profile': (context) => ProfileScreen()},
      debugShowCheckedModeBanner: false,
      home: MyHomePage(),
    );
  }
}

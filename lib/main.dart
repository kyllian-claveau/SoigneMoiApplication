import 'package:flutter/material.dart';
import 'package:soignemoiapplication/src/view/home_screen.dart';
import 'package:soignemoiapplication/src/view/sign_in.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

void main() {
  tz.initializeTimeZones();
  tz.setLocalLocation(tz.getLocation('Europe/Paris'));
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Blog app Symfony Backend',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      routes: {
        SignIn.route: (context) => SignIn(),
        HomeScreen.route: (context) => HomeScreen(),
      },
      initialRoute: SignIn.route,
    );
  }
}

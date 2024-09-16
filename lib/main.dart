import 'package:flutter/material.dart';
import 'package:raybud_app/exercise_page.dart';
import 'package:raybud_app/home_page.dart';

Future<void> main() async {
  // const AndroidInitializationSettings initializationSettingsAndroid = AndroidInitializationSettings('@mipmap/ic_launcher');
  // const InitializationSettings initializationSettings = InitializationSettings(android: initializationSettingsAndroid);
  // FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
  //     FlutterLocalNotificationsPlugin();
  // await flutterLocalNotificationsPlugin.initialize(initializationSettings);
  runApp(MaterialApp(
    initialRoute: '/',
    routes: {
      '/': (context) => const HomePage(),
      '/exercise': (context) => const ExercisePage(),
    },
  ));
}

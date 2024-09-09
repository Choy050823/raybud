import 'package:flutter/material.dart';
import 'package:raybud_app/exercise_page.dart';
import 'package:raybud_app/home_page.dart';

void main() {
  runApp(MaterialApp(
    initialRoute: '/',
    routes: {
      '/': (context) => const HomePage(),
      '/exercise': (context) => const ExercisePage(),
    },
  ));
}

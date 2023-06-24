import 'package:flutter/material.dart';
import 'package:planit2/home.dart';
import 'Calendar.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const home(),
      routes: {
        '/Calendar': (context) => MyHomePage()
      },
    );
  }
}

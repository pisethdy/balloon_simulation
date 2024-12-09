import 'package:flutter/material.dart';
import 'screens/home.dart';

void main() => runApp(const MyApp());

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Balloon Animation',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: Center(
        child: ConstrainedBox(
          constraints: BoxConstraints(
            maxWidth: 1280, // Adjust the max width as needed
          ),
          child: HomePage(),
        ),
      ),
    );
  }
}
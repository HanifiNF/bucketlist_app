import 'package:bucketlist_app/addbucketlist.dart';
import 'package:bucketlist_app/mainscreen.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      routes: {
        "/home": (context) {
          return MainScreen();
        },
        "/add": (context) {
          return Addbucketlistscreen();
        },
      },
      initialRoute: "home",
      theme: ThemeData.light(useMaterial3: true),
    );
  }
}

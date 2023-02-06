import 'package:flutter/material.dart';
import 'package:openchat_frontend/views/chat_view.dart';

void main() {
  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(
        useMaterial3: true,
        primarySwatch: Colors.lightBlue,
      ),
      home: Scaffold(
          appBar: AppBar(
            title: Image.asset('assets/images/logo.png', scale: 6.5),
          ),
          body: ChatView()),
    );
  }
}

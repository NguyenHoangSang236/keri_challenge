import 'package:flutter/material.dart';

import '../entities/user.dart';
import '../services/firebase_database_service.dart';

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(widget.title),
      ),
      body: Center(
        child: Column(
          children: [
            ElevatedButton(
              onPressed: () async {
                User newUser = User('nhu', '0977815809', '123', '');

                await FirebaseDatabaseService.set(
                  newUser,
                  newUser.name + newUser.password,
                );
              },
              child: Text('add user'),
            ),
            ElevatedButton(
              onPressed: () async {
                await FirebaseDatabaseService.get('users/sang');
              },
              child: Text('show user'),
            ),
            ElevatedButton(
              onPressed: () async {
                await FirebaseDatabaseService.remove('nhu123');
              },
              child: Text('delete user'),
            ),
          ],
        ),
      ),
    );
  }
}

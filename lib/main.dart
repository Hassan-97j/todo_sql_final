import 'package:flutter/material.dart';
import 'package:todo_sql_final/View/myTodos.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        title: 'ToDo ',
        theme: ThemeData(
          primarySwatch: Colors.lime,
        ),
        home: MyTodos());
  }
}

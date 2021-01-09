import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:intl/intl.dart';
import 'package:sqflite/sqflite.dart';
import 'package:todo_sql_final/Model/Task.dart';
import 'package:todo_sql_final/Services/databaseHelper.dart';

// ignore: must_be_immutable
class QueryTodo extends StatefulWidget {
  Task task;
  QueryTodo({this.task});
  @override
  _QueryTodoState createState() => _QueryTodoState();
}

class _QueryTodoState extends State<QueryTodo> {
  FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();
  DateTime _date;
  TextEditingController dateController;
  final DateFormat _dateFormatter = DateFormat.yMd();
  TextEditingController title;
  TextEditingController description;

  DatabaseHelper databaseHelper = DatabaseHelper();

  void _handleDatePicker() async {
    final DateTime date = await showDatePicker(
        context: context,
        initialDate: _date,
        firstDate: DateTime(2000),
        lastDate: DateTime(2050));
    print(date);
    // if (date != null && date != _date) {
    setState(() {});
    dateController.text = _dateFormatter.format(date);
    print(_dateFormatter.format(date));
  }

  @override
  void dispose() {
    title.dispose();
    description.dispose();
    super.dispose();
  }

  @override
  void initState() {
    title = TextEditingController();
    description = TextEditingController();
    dateController = TextEditingController();
    if (widget.task.title != "Title")
      title.value = TextEditingValue(text: widget.task.title);
    if (widget.task.description != "NoDescription")
      description.value = TextEditingValue(text: widget.task.description);
    _date = DateTime.now();
    dateController.text = _dateFormatter.format(_date);

    super.initState();
    var initializationSettingsAndroid =
        AndroidInitializationSettings("app_icon");
    var initializeSettingsIos = IOSInitializationSettings();
    var initSettings = InitializationSettings(
        android: initializationSettingsAndroid, iOS: initializeSettingsIos);
    flutterLocalNotificationsPlugin.initialize(initSettings,
        onSelectNotification: onSelectNotification);
  }

  _showNotification() async {
    var android = AndroidNotificationDetails('id', 'name', 'description',
        priority: Priority.high, importance: Importance.max);
    var iOs = IOSNotificationDetails();
    var platform = new NotificationDetails(android: android, iOS: iOs);
    await flutterLocalNotificationsPlugin.show(0,
        '${widget.task.title} '.toLowerCase(), "${widget.task.date}", platform,
        payload: 'Task Updated');
  }

  @override
  Widget build(BuildContext context) {
    double height = MediaQuery.of(context).size.height;
    double width = MediaQuery.of(context).size.width;
    return WillPopScope(
      onWillPop: () async {
        Navigator.pop(context, true);
      },
      child: Scaffold(
        appBar: AppBar(
          leading: IconButton(
            icon: Icon(Icons.arrow_back),
            onPressed: () {
              Navigator.pop(context, true);
            },
          ),
          iconTheme: IconThemeData(color: Colors.lime),
          elevation: 0,
          backgroundColor: Colors.transparent,
          title: Text(
            "Add Tasks",
            style: TextStyle(
                color: Colors.blueAccent,
                fontWeight: FontWeight.bold,
                fontSize: 24),
          ),
        ),
        body: SingleChildScrollView(
          child: Column(
            children: [
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
                child: TextField(
                  controller: title,
                  onChanged: (value) {
                    widget.task.title = value;
                  },
                  decoration: InputDecoration(
                    hintText: "Title",
                    disabledBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.lime),
                    ),
                    focusedBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.lime)),
                    enabledBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.lime)),
                    border: OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.lime)),
                  ),
                ),
              ),
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                child: TextField(
                  onChanged: (value) {
                    widget.task.description = value;
                  },
                  controller: description,
                  decoration: InputDecoration(
                    hintText: "Description",
                    disabledBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.lime),
                    ),
                    focusedBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.lime)),
                    enabledBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.lime)),
                    border: OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.lime)),
                  ),
                ),
              ),
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
                child: TextField(
                  controller: dateController,
                  onTap: _handleDatePicker,
                  style: TextStyle(fontSize: 18),
                  decoration: InputDecoration(
                    //hintText: "Title",
                    disabledBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.lime),
                    ),
                    focusedBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.lime)),
                    enabledBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.lime)),
                    border: OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.lime)),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(20.0),
                child: GestureDetector(
                  onTap: () {
                    if (widget.task.title == null ||
                        widget.task.title.length == 0 ||
                        widget.task.title == "Title") {
                      showDialog(
                          context: context,
                          builder: (context) {
                            return errorPrompt(context);
                          });
                    } else {
                      final Future<Database> dbFuture =
                          databaseHelper.initializeDatabase();
                      dbFuture.then((database) async {
                        int status;
                        if (widget.task.id == -1) {
                          widget.task.id = null;
                          status = await databaseHelper.insertTask(widget.task);
                        } else {
                          status = await databaseHelper.updateTask(widget.task);
                        }
                        if (status > 0) {
                          showDialog(
                              context: context,
                              builder: (context) {
                                return successPrompt(context);
                              });

                          _showNotification();
                          Navigator.pop(context, true);
                        } else {
                          showDialog(
                              context: context,
                              builder: (context) {
                                return failPrompt(context);
                              });
                        }

                        print(widget.task.title);
                      });
                    }
                  },
                  child: Container(
                    color: Colors.lime,
                    height: 50,
                    width: width,
                    child: Center(
                        child: Text(
                      "Add",
                      style: TextStyle(
                          color: Colors.blue, fontWeight: FontWeight.bold),
                    )),
                  ),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }

  Future onSelectNotification(String payload) async {}
}

successPrompt(context) {
  return AlertDialog(
    title: Text("Message"),
    content: Text("Task added"),
    actions: [
      FlatButton(
          onPressed: () {
            Navigator.pop(context);
          },
          child: Text("Ok"))
    ],
  );
}

errorPrompt(context) {
  return AlertDialog(
    title: Text("Error"),
    content: Text("Title is empty"),
    actions: [
      FlatButton(
          onPressed: () {
            Navigator.pop(context);
          },
          child: Text("Ok"))
    ],
  );
}

failPrompt(context) {
  return AlertDialog(
    title: Text("Error"),
    content: Text("Try again letter"),
    actions: [
      FlatButton(
          onPressed: () {
            Navigator.pop(context);
          },
          child: Text("Ok"))
    ],
  );
}

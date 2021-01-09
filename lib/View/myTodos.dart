import 'package:flutter/material.dart';
import 'package:sqflite/sqflite.dart';
import 'package:todo_sql_final/Model/Task.dart';
import 'package:todo_sql_final/Services/databaseHelper.dart';
import 'package:todo_sql_final/View/queryTodo.dart';

class MyTodos extends StatefulWidget {
  @override
  _MyTodosState createState() => _MyTodosState();
}

class _MyTodosState extends State<MyTodos> {
  List<Task> tasks;

  DatabaseHelper databaseHelper = DatabaseHelper();
  int count = 0;
  @override
  void initState() {
    updateListView();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    if (tasks == null) {
      tasks = <Task>[];
    }
    return Scaffold(
        appBar: AppBar(
          elevation: 0,
          backgroundColor: Colors.transparent,
          title: Text(
            "All Tasks",
            style: TextStyle(
                color: Colors.lime, fontWeight: FontWeight.bold, fontSize: 24),
          ),
        ),
        body: count == 0
            ? Center(
                child: Text("Add Task"),
              )
            : ListView.builder(
                itemCount: tasks.length,
                itemBuilder: (context, index) {
                  return Padding(
                    padding: EdgeInsets.symmetric(horizontal: 20),
                    child: Column(
                      children: [
                        GestureDetector(
                          onTap: () async {
                            bool result = await Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (conext) =>
                                        QueryTodo(task: tasks[index])));
                            if (result) {
                              updateListView();
                            }
                          },
                          child: Card(
                            color: Colors.lime,
                            elevation: 5,
                            child: ListTile(
                              title: Text(
                                "${tasks[index].title}\n",
                                style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 18),
                              ),
                              subtitle: Text(
                                  '${tasks[index].description}\n${tasks[index].date}'),
                              trailing: IconButton(
                                  icon: Icon(Icons.delete),
                                  onPressed: () {
                                    showDialog(
                                        context: context,
                                        builder: (context) {
                                          return deleteDialog(context);
                                        }).then((value) async {
                                      print(value);
                                      if (value) {
                                        int result = await deleteTaskById(
                                            tasks[index].id);
                                        updateListView();
                                      }
                                    });
                                  }),
                            ),
                          ),
                        ),
                        SizedBox(
                          height: 10,
                        )
                      ],
                    ),
                  );
                }),
        floatingActionButton: FloatingActionButton(
            onPressed: () async {
              Task task = Task.empty();
              bool result = await Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (conext) => QueryTodo(task: task)));
              if (result) {
                updateListView();
              }
            },
            backgroundColor: Colors.lime,
            child: Icon(
              Icons.add,
              color: Colors.blue,
            )));
  }

  void updateListView() {
    final Future<Database> dbFuture = databaseHelper.initializeDatabase();

    dbFuture.then((database) {
      Future<List<Task>> taskListFuture = databaseHelper.getTaskList();

      taskListFuture.then((noteList) {
        setState(() {
          this.tasks = noteList;
          this.count = noteList.length;
        });
      });
    });
  }

  deleteDialog(context) {
    return AlertDialog(
      title: Text('Message'),
      content: Text('Did this task?'),
      actions: [
        FlatButton(
          onPressed: () {
            Navigator.pop(context, true);
          },
          child: Text('Yes'),
        ),
        FlatButton(
          onPressed: () {
            Navigator.pop(context, false);
          },
          child: Text('No'),
        ),
      ],
    );
  }

  Future<int> deleteTaskById(int id) {
    final Future<Database> dbFuture = databaseHelper.initializeDatabase();
    Future<int> result;
    dbFuture.then((database) {
      result = databaseHelper.deleteTask(id);
      result.then((value) {
        return value;
      });
    });
  }
}

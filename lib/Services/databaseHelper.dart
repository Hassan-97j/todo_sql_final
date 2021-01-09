import 'package:sqflite/sqflite.dart';
import 'dart:async';
import 'package:path_provider/path_provider.dart';
import 'dart:io';

import 'package:todo_sql_final/Model/Task.dart';

//import 'package:path/path.dart';
class DatabaseHelper {
  static DatabaseHelper _databaseHelper;
  static Database _database;

  String taskTable = 'task_table';
  String colId = 'id';
  String colTile = 'title';
  String colDescription = 'description';
  String colDate = 'date';
  String colStatus = 'status';

  DatabaseHelper._createInstance();

  factory DatabaseHelper() {
    if (_databaseHelper == null) {
      _databaseHelper = DatabaseHelper._createInstance();
    }

    return _databaseHelper;
  }

  Future<Database> initializeDatabase() async {
    Directory directory = await getApplicationDocumentsDirectory();
    String path = directory.path + 'task.db';
    var taskDatabase =
        await openDatabase(path, version: 1, onCreate: _createDb);
    return taskDatabase;
  }

  Future<Database> get database async {
    if (_database == null) {
      _database = await initializeDatabase();
    }

    return _database;
  }

  Future<List<Map<String, dynamic>>> getTask() async {
    Database db = await this.database;

    var result = await db.query(taskTable);
    return result;
  }

  Future<int> insertTask(Task task) async {
    Database db = await this.database;

    var result = await db.insert(taskTable, task.toMap());
    return result;
  }

  Future<int> updateTask(Task task) async {
    Database db = await this.database;

    var result = await db.update(taskTable, task.toMap(),
        where: '$colId = ?', whereArgs: [task.id]);
    return result;
  }

  Future<int> deleteTask(int id) async {
    Database db = await this.database;

    var result =
        await db.rawDelete('DELETE FROM $taskTable WHERE $colId = $id');
    return result;
  }

  void _createDb(Database db, int newVersion) async {
    await db.execute('''
            CREATE TABLE $taskTable(
                $colId INTEGER PRIMARY KEY AUTOINCREMENT,
                $colTile TEXT,
                $colDescription TEXT,
                $colDate TEXT,
                $colStatus TEXT
              )
        ''');
  }

  Future<int> getCount(int id) async {
    Database db = await this.database;

    List<Map<String, dynamic>> x =
        await db.rawQuery('SELECT COUNT (*) from $taskTable');
    int result = Sqflite.firstIntValue(x);
    return result;
  }

  Future<List<Task>> getTaskList() async {
    var taskMapList = await getTask();
    int count = taskMapList.length;

    List<Task> task = List<Task>();
    for (int i = 0; i < count; ++i) {
      print(i);
      print(count);
      task.add(Task.fromMap(taskMapList[i]));
    }
    return task;
  }
}

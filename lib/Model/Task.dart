import 'dart:async';

//import 'package:date_time_picker/date_time_picker.dart';
class Task {
  int _id = -1;
  String _title = "Title", _description = "NoDescription", _date = "";
  bool _isDone = false;

  Task.empty() {
    DateTime date = DateTime.now();
    _date = "${date.year}-${date.month}-${date.day}";
  }
  Task(this._title, this._date, [this._description]) {
    DateTime date = DateTime.now();
    _date = "${date.year}-${date.month}-${date.day}";
  }
  Task.withId(this._id, this._title, this._date, [this._description]);

  int get id => _id;
  String get title => _title;
  String get description => _description;
  String get date => _date;
  bool get isDone => _isDone;

  set id(int id) {
    this._id = id;
  }

  set title(String title) {
    this._title = title.toUpperCase();
  }

  set description(String description) {
    this._description = description;
  }

  set date(String date) {
    this._date = date;
  }

  set isDone(bool isDone) {
    this._isDone = isDone;
  }

  Map<String, dynamic> toMap() {
    var map = Map<String, dynamic>();

    if (id != null) {
      map['id'] = _id;
    }
    map['title'] = _title;
    map['description'] = _description;
    map['date'] = _date;
    map['status'] = _isDone ? 1 : 0;
    return map;
  }

  Task.fromMap(Map<String, dynamic> map) {
    this._id = map['id'];
    this._title = map['title'];
    this._description = map['description'];
    this._date = map['date'];
    this._isDone = map['status'] == 1 ? true : false;
  }
}

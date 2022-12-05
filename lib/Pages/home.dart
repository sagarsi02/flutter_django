import 'package:flutter/material.dart';
import 'package:flutter_django/Constants/api.dart';
import 'package:flutter_django/Widgets/app_bar.dart';
import 'package:flutter_django/Widgets/todo_container.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter_django/Models/todo.dart';
import 'package:flutter/widgets.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  List<Todo> myTodos = [];
  bool isLoading = true;
  void fetchData() async {
    try {
      http.Response response = await http.get(Uri.parse(api));
      var data = json.decode(response.body);
      data.forEach((todo) {
        Todo t = Todo(
          id: todo['id'],
          title: todo['title'],
          desc: todo['desc'],
          isDone: todo['isDone'],
          // date: todo['date'],
        );
        myTodos.add(t);
      });
      print(myTodos.length);
      setState(() {
        isLoading = false;
      });
    } catch (e) {
      print('Error is $e');
    }
  }

  @override
  void initState() {
    // TODO: implement initState
    fetchData();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: customAppBar(),
        backgroundColor: Color.fromARGB(255, 24, 44, 159),
        body: isLoading
            ? const CircularProgressIndicator()
            : ListView(
                children: myTodos.map((e) {
                return TodoContainer(
                  id: e.id,
                  title: e.title,
                  desc: e.desc,
                  isDone: e.isDone,
                  // date: '1944-06-06 02:00:00.000',
                );
              }).toList()));
  }
}

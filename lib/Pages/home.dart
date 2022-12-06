import 'package:flutter/material.dart';
import 'package:flutter_django/Constants/api.dart';
import 'package:flutter_django/Widgets/app_bar.dart';
import 'package:flutter_django/Widgets/todo_container.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter_django/Models/todo.dart';
import 'package:flutter/widgets.dart';
import 'package:pie_chart/pie_chart.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int done = 0;
  List<Todo> myTodos = [];
  bool isLoading = true;

  // void _handleSubmission(String value){
  //   setState(() {
  //     title = value,
  //   });
  // }

  void _showModal() {
    String title = "";
    String desc = "";
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return Container(
          height: MediaQuery.of(context).size.height / 2,
          color: Colors.white,
          child: Center(
              child: Column(
            children: const [
              Padding(
                padding: EdgeInsets.all(20.0),
                child: Text(
                  "Add Your ToDos",
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              SizedBox(
                height: 20,
              ),
              TextField(
                decoration: InputDecoration(
                  border: OutlineInputBorder(),
                  labelText: 'Todo Title',
                  hintText: 'Enter Todo Title',
                ),
              ),
              SizedBox(
                height: 10,
              ),
              TextField(
                decoration: InputDecoration(
                  border: OutlineInputBorder(),
                  labelText: 'Todo Description',
                  hintText: 'Enter Todo Description',
                ),
              ),
              ElevatedButton(
                onPressed: null,
                child: Text("Add TODOs"),
              )
            ],
          )),
        );
      },
    );
  }

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
        if (todo['isDone']) {
          done += 1;
        }
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

  void delete_todo(String id) async {
    try {
      http.Response response = await http.delete(Uri.parse(api + "/" + id));
      setState(() {
        myTodos = [];
      });
      fetchData();
    } catch (e) {
      print(e);
    }
  }

  void post_todo({String title = "", String desc = ""}) async {
    try {
      http.Response response = await http.post(
        Uri.parse(api),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: jsonEncode(<String, dynamic>{
          "title": title,
          "desc": desc,
          "isDone": false,
        }),
      );
      if (response.statusCode == 201) {
        setState(() {
          myTodos = [];
        });
        fetchData();
      } else {
        print("somthing Went Wrong!");
      }
    } catch (e) {
      print(e);
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
      // backgroundColor: const Color.fromARGB(255, 255, 255, 255),
      body: SingleChildScrollView(
        scrollDirection: Axis.vertical,
        child: Column(
          children: [
            PieChart(
              dataMap: {
                "Done": done.toDouble(),
                "Incomplete": (myTodos.length - done).toDouble()
              },
            ),
            isLoading
                ? const CircularProgressIndicator()
                : Column(
                    children: myTodos.map((e) {
                    return TodoContainer(
                      id: e.id,
                      onPress: () => delete_todo(e.id.toString()),
                      title: e.title,
                      desc: e.desc,
                      isDone: e.isDone,
                      // date: '1944-06-06 02:00:00.000',
                    );
                  }).toList())
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          _showModal();
        },
        backgroundColor: const Color.fromARGB(255, 9, 24, 70),
        child: const Icon(Icons.add),
      ),
    );
  }
}

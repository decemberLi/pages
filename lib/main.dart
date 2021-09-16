import 'dart:convert';

import 'package:flutter/material.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Json to Dart',
      theme: ThemeData(
        // This is the theme of your application.
        //
        // Try running your application with "flutter run". You'll see the
        // application has a blue toolbar. Then, without quitting the app, try
        // changing the primarySwatch below to Colors.green and then invoke
        // "hot reload" (press "r" in the console where you ran "flutter run",
        // or simply save your changes to "hot reload" in a Flutter IDE).
        // Notice that the counter didn't reset back to zero; the application
        // is not restarted.
        primarySwatch: Colors.blue,
      ),
      home: MyHomePage(title: 'Json to Dart'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title}) : super(key: key);

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  TextEditingController _inputController = TextEditingController();
  TextEditingController _controller = TextEditingController();
  TextEditingController _nameController = TextEditingController();

  String jsonToDart(Map<String, dynamic> json, String name) {
    String result = "class ${name.upFirst} {\n";
    List<String> subClass = [];
    String initName = "  ${name.upFirst}(Map<String,dynamic> json) {\n";
    String jsonFunc =
        "  Map<String,dynamic> get json {\n    var result = Map<String,dynamic>();\n";
    appendValue(String name, String key) {
      result += "  $name $key;\n";
      initName += "    this.$key = json[\"$key\"] as $name;\n";
      jsonFunc += "    result[\"$key\"] = this.$key;\n";
    }

    json.forEach((key, value) {
      if (value is String) {
        appendValue("String", key);
      } else if (value is int) {
        appendValue("int", key);
      } else if (value is double) {
        appendValue("double", key);
      } else if (value is List<String>) {
        appendValue("List<String>", key);
      } else if (value is List<int>) {
        appendValue("List<int>", key);
      } else if (value is List<double>) {
        appendValue("List<double>", key);
      } else if (value is Map<String, dynamic>) {
        var subName = name.upFirst + key.upFirst;
        result += "  $subName $key;\n";
        initName += "    this.$key = $subName(json[\"$key\"]);\n";
        jsonFunc += "    result[\"$key\"] = this.$key.json;\n";
        subClass.add(jsonToDart(value, subName));
      } else if (value is List<dynamic>) {
        try {
          var first = value.first;
          var subName = name.upFirst + key.upFirst;
          result += "  List<$subName> $key;\n";
          initName +=
              "    this.$key = json[\"$key\"].map((e)=>$subName(e)).toList();\n";
          jsonFunc +=
              "    result[\"$key\"] = this.$key.map((e)=>e.json).toList();\n";
          subClass.add(jsonToDart(first, subName));
        } catch (e) {}
      }
    });
    initName += "  }\n";
    result += initName;
    jsonFunc += "    return result;\n  }\n";
    result += jsonFunc;
    result += "}\n";
    subClass.forEach((element) {
      result += element;
    });
    return result;
  }

  showAlert() {
    var alert = AlertDialog(
      title: Text("Please Input Class Name"),
      actions: [
        TextButton(
          onPressed: () {
            Navigator.of(context).pop();
          },
          child: Text("OK"),
        ),
      ],
    );
    showDialog(context: context, builder: (c) => alert);
  }

  @override
  Widget build(BuildContext context) {
    // This method is rerun every time setState is called, for instance as done
    // by the _incrementCounter method above.
    //
    // The Flutter framework has been optimized to make rerunning build methods
    // fast, so that you can just rebuild anything that needs updating rather
    // than having to individually change instances of widgets.
    return Scaffold(
      body: Container(
        padding: EdgeInsets.all(20),
        child: Row(
          children: [
            Expanded(
              child: Container(
                height: 300,
                child: TextField(
                  controller: _inputController,
                  autofocus: true,
                  maxLines: 20,
                  decoration: InputDecoration(
                    labelText: 'JSON',
                    labelStyle: TextStyle(
                      color: Colors.blue,
                      fontSize: 12,
                    ),
                    helperText: 'input json',
                    hintText: 'input json ...',
                    border: OutlineInputBorder(
                      borderSide: BorderSide(
                        color: Colors.pink,
                      ),
                    ),
                  ),
                ),
              ),
            ),
            Container(
              padding: EdgeInsets.all(20),
              height: 200,
              child: Column(
                children: [
                  Container(
                    height: 60,
                    width: 60,
                    child: TextField(
                      controller: _nameController,
                      decoration: InputDecoration(
                          hintText: "Class name",
                          hintStyle: TextStyle(
                            fontSize: 10,
                          )),
                    ),
                  ),
                  Padding(padding: EdgeInsets.all(10)),
                  ElevatedButton(
                    onPressed: () {
                      if (_nameController.text.length == 0) {
                        showAlert();
                        return;
                      }
                      Map<String, dynamic> jsonValue =
                          json.decode(_inputController.text);
                      _controller.text =
                          jsonToDart(jsonValue, _nameController.text);
                    },
                    child: Text("->"),
                  )
                ],
              ),
            ),
            Expanded(
              child: Container(
                height: 300,
                child: TextField(
                  controller: _controller,
                  maxLines: 10000,
                  decoration: InputDecoration(
                    labelText: 'Dart Class',
                    labelStyle: TextStyle(
                      color: Colors.blue,
                      fontSize: 12,
                    ),
                    helperText: 'result class',
                    hintText: 'result class',
                    border: OutlineInputBorder(
                      borderSide: BorderSide(
                        color: Colors.pink,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

extension FirstUp on String {
  String get upFirst => replaceRange(0, 1, substring(0, 1).toUpperCase());
}

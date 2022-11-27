import 'package:flutter/material.dart';
import 'package:code_text_field/code_text_field.dart';
import 'package:highlight/languages/xml.dart';
import 'package:flutter_highlight/themes/monokai-sublime.dart';

void main() {
  // runs the fastim application.
  runApp(const FastIMApp());
}

/// root widget that hosts the entire fastim application.
class FastIMApp extends StatelessWidget {
  const FastIMApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      // hide the debug banner on top right
      debugShowCheckedModeBanner: false,
      title: 'FastIM',

      theme: ThemeData(
          fontFamily: 'segoeui',
          appBarTheme: const AppBarTheme(
            backgroundColor: Colors.white,
            foregroundColor: Colors.green,
          ),
          floatingActionButtonTheme: const FloatingActionButtonThemeData(
            backgroundColor: Colors.green,
          )),
      home: const MyHomePage(title: 'Incidents - Overview'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  void _incrementCounter() {
    setState(() {
      // This call to setState tells the Flutter framework that something has
      // changed in this State, which causes it to rerun the build method below
      // so that the display can reflect the updated values. If we changed
      // _counter without calling setState(), then the build method would not be
      // called again, and so nothing would appear to happen.
    });
  }

  @override
  Widget build(BuildContext context) {
    // This method is rerun every time setState is called, for instance as done
    // by the _incrementCounter method above.
    //
    // The Flutter framework has been optimized to make rerunning build methods
    // fast, so that you can just rebuild anything that needs updating rather
    // than having to individually change instances of widgets.

    var source = "void main() {\n    print(\"Hello, world!\");\n}";
    // Instantiate the CodeController
    var _codeController = CodeController(
      text: "<hi>abc</hi>",
      language: xml,
    );

    return Scaffold(
      appBar: AppBar(
        toolbarHeight: 40,
        title: Text(widget.title, style: TextStyle(fontSize: 16)),
      ),

      body: CodeTheme(
        data: const CodeThemeData(styles: monokaiSublimeTheme),
        child: CodeField(
          controller: _codeController,
          // textStyle: TextStyle(fontFamily: 'SourceCode'),
          expands: true,
        ),
      ),

      floatingActionButton: FloatingActionButton(
        onPressed: _incrementCounter,
        tooltip: 'Increment',
        child: const Icon(Icons.add),
      ),

      // This trailing comma makes auto-formatting nicer for build methods.
    );
  }
}

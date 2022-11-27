import 'package:flutter/material.dart';

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

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  void _incrementCounter() {
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        toolbarHeight: 40,
        title: Text(widget.title, style: const TextStyle(fontSize: 16)),
      ),
      body: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
        // for search bar and buttons
        Padding(
          padding: const EdgeInsets.all(0),
          child: Container(
            color: Colors.green[200],
            padding: const EdgeInsets.only(top: 30, bottom: 20),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const SizedBox(width: 500, child: SearchBar()),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: ElevatedButton(
                    style: ButtonStyle(
                        padding: MaterialStateProperty.all(EdgeInsets.all(20)),
                        backgroundColor:
                            MaterialStateProperty.all(Colors.green[400])),
                    child: const Text('search', style: TextStyle(fontSize: 16)),
                    onPressed: () {},
                  ),
                ),
              ],
            ),
          ),
        ),
        // for results list view

        Expanded(
          child: ListView(
            children: [
              ListTile(
                tileColor: Colors.grey[350],
                title: Text('IMG0000012345'),
              ),
              ListTile(
                title: Text('IMG0000012345'),
              ),
            ],
          ),
        ),
      ]),

      floatingActionButton: FloatingActionButton(
        onPressed: _incrementCounter,
        tooltip: 'Increment',
        child: const Icon(Icons.add),
      ), // This trailing comma makes auto-formatting nicer for build methods.
    );
  }
}

class SearchBar extends StatelessWidget {
  const SearchBar({super.key});

  @override
  Widget build(BuildContext context) {
    return TextField(
      onTap: () {},
      decoration: InputDecoration(
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(4),
          borderSide: const BorderSide(
            width: 0,
            style: BorderStyle.none,
          ),
        ),
        contentPadding: const EdgeInsets.all(16),
        fillColor: Colors.grey[200],
        filled: true,
        hintText: 'search',
        prefixIcon: const Icon(
          Icons.search,
          size: 24,
          color: Colors.black,
        ),
      ),
    );
  }
}

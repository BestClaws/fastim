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
          appBarTheme: AppBarTheme(
            backgroundColor: Colors.grey[800],
            foregroundColor: Colors.white,
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
      backgroundColor: Colors.grey[900],
      appBar: AppBar(
        toolbarHeight: 36,
        title: Text(widget.title, style: const TextStyle(fontSize: 14)),
      ),
      body: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
        // for search bar and buttons
        Padding(
          padding: const EdgeInsets.all(0),
          child: Container(
            color: Colors.grey[850],
            padding: const EdgeInsets.only(top: 15, bottom: 10),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const SizedBox(width: 500, child: SearchBar()),
                Padding(
                  padding: const EdgeInsets.only(left: 10),
                  child: ElevatedButton(
                    style: ButtonStyle(
                        backgroundColor:
                            MaterialStateProperty.all(Colors.green),
                        visualDensity: VisualDensity.comfortable,
                        padding: MaterialStateProperty.all(
                            const EdgeInsets.all(12))),
                    child: const Text(
                      'search',
                      style: TextStyle(fontSize: 16),
                    ),
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
            padding:
                const EdgeInsets.only(left: 50, right: 50, top: 20, bottom: 20),
            children: [
              Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: ListTile(
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(5)),
                  contentPadding: const EdgeInsets.only(left: 20, right: 20),
                  tileColor: Colors.grey[850],
                  textColor: Colors.white,
                  title: const Text('IMG0000012345'),
                  subtitle: const Text('th;asdjfl sdaflkjsdf sd f'),
                ),
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
      style: const TextStyle(fontSize: 14),
      decoration: InputDecoration(
        isDense: true,
        contentPadding: const EdgeInsets.all(0),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(4),
          borderSide: const BorderSide(
            width: 2,
            style: BorderStyle.solid,
          ),
        ),
        fillColor: Colors.grey[200],
        filled: true,
        hintText: 'search',
        prefixIcon: const Icon(
          Icons.search,
          size: 14,
          color: Colors.black,
        ),
      ),
    );
  }
}

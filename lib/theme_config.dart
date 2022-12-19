/// All theming related configuration may go here.

import 'package:fluent_ui/fluent_ui.dart';

Map<String, Color> softGreen = {
  "normal": const Color.fromARGB(255, 102, 187, 106),
  "light": const Color.fromARGB(255, 129, 199, 132),
  "dark": const Color.fromARGB(255, 46, 125, 50),
};

/// [ThemeData] to configure dark theme
var darkThemeData = ThemeData(
  accentColor: AccentColor.swatch(softGreen),
  brightness: Brightness.dark,
);

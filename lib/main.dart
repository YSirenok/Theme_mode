// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData.light(),
      darkTheme: ThemeData.dark(),
      themeMode: ThemeMode.system,
      home: const MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key}) : super(key: key);

  @override
  MyHomePageState createState() => MyHomePageState();
}

class MyHomePageState extends State<MyHomePage> {
  late ThemeData _currentTheme =
      ThemeData.light(); // Initialize with a default theme

  @override
  void initState() {
    super.initState();
    _loadTheme();
  }

  Future<void> _loadTheme() async {
    final prefs = await SharedPreferences.getInstance();
    final themeModeValue = prefs.getInt('theme_mode') ?? ThemeMode.system.index;
    final themeMode = ThemeMode.values[themeModeValue];
    setState(() {
      _currentTheme = _getTheme(themeMode);
    });
  }

  ThemeData _getTheme(ThemeMode themeMode) {
    switch (themeMode) {
      case ThemeMode.light:
        return ThemeData.light();
      case ThemeMode.dark:
        return ThemeData.dark();
      case ThemeMode.system:
        return Theme.of(context);
    }
  }

  Future<void> _saveTheme(ThemeMode themeMode) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('theme_mode', themeMode.index);
  }

  void _toggleTheme() {
    final newThemeMode = _currentTheme.brightness == Brightness.dark
        ? ThemeMode.light
        : ThemeMode.dark;

    _saveTheme(newThemeMode);

    setState(() {
      _currentTheme = _getTheme(newThemeMode);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(
        title: 'Theme Mode',
        theme: _currentTheme,
        onPressed: () async {
          final result = await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => SettingsScreen(currentTheme: _currentTheme),
            ),
          );

          if (result != null) {
            setState(() {
              _currentTheme = result;
            });
          }
        },
      ),
      body: Center(
        child: Text(
          'Hello, Theme Mode!',
          style: _currentTheme.textTheme.headlineLarge?.copyWith(
            color: _currentTheme.brightness == Brightness.light
                ? Colors.blue
                : Colors.white,
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _toggleTheme,
        backgroundColor: _currentTheme.brightness == Brightness.light
            ? Colors.blue
            : Colors.lightBlue,
        child: const Icon(Icons.brightness_4),
      ),
      backgroundColor: _currentTheme.scaffoldBackgroundColor,
    );
  }
}

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final ThemeData theme;
  final VoidCallback onPressed;

  const CustomAppBar({
    Key? key,
    required this.title,
    required this.theme,
    required this.onPressed,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    Color? iconColor;
    Color? backgroundColor;
    Color? titleColor;

    if (theme.brightness == Brightness.light) {
      iconColor = Colors.blueAccent;
      backgroundColor = Colors.white;
      titleColor = Colors.blueAccent;
    } else {
      iconColor = Colors.white;
      backgroundColor = Colors.black;
      titleColor = Colors.white;
    }

    return AppBar(
      title: Text(
        title,
        style: TextStyle(color: titleColor),
      ),
      backgroundColor: backgroundColor,
      iconTheme: theme.primaryIconTheme.copyWith(color: iconColor),
      actions: [
        IconButton(
          icon: const Icon(Icons.settings),
          color: iconColor,
          onPressed: onPressed,
        ),
      ],
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}

class SettingsScreen extends StatefulWidget {
  final ThemeData currentTheme;

  const SettingsScreen({Key? key, required this.currentTheme})
      : super(key: key);

  @override
  SettingsScreenState createState() => SettingsScreenState();
}

class SettingsScreenState extends State<SettingsScreen> {
  late ThemeMode _selectedThemeMode;
  late ThemeData _selectedTheme;

  @override
  void initState() {
    super.initState();
    _selectedThemeMode = widget.currentTheme.brightness == Brightness.dark
        ? ThemeMode.dark
        : ThemeMode.light;
    _selectedTheme = widget.currentTheme;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(
        title: 'Settings',
        theme: _selectedTheme,
        onPressed: () async {
          final prefs = await SharedPreferences.getInstance();
          await prefs.setInt('theme_mode', _selectedThemeMode.index);

          final currentContext = context;
          Navigator.pop(currentContext, _selectedTheme);
        },
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Select Theme Mode:',
                style: TextStyle(color: Colors.black)),
            for (var mode in ThemeMode.values)
              RadioListTile<ThemeMode>(
                title: Text(_getModeText(mode),
                    style: const TextStyle(color: Colors.black)),
                activeColor: Colors.blue,
                value: mode,
                groupValue: _selectedThemeMode,
                onChanged: (value) {
                  setState(() {
                    _selectedThemeMode = value!;
                    _selectedTheme = _getTheme(_selectedThemeMode);
                  });
                },
              ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final prefs = await SharedPreferences.getInstance();
          await prefs.setInt('theme_mode', _selectedThemeMode.index);

          final currentContext = context;
          Navigator.pop(currentContext, _selectedTheme);
        },
        backgroundColor: Colors.blueAccent,
        child: const Icon(Icons.save),
      ),
      backgroundColor: _selectedTheme.scaffoldBackgroundColor,
    );
  }

  ThemeData _getTheme(ThemeMode themeMode) {
    switch (themeMode) {
      case ThemeMode.light:
        return ThemeData.light();
      case ThemeMode.dark:
        return ThemeData.dark();
      case ThemeMode.system:
        return Theme.of(context);
    }
  }

  String _getModeText(ThemeMode mode) {
    switch (mode) {
      case ThemeMode.light:
        return 'Light Mode';
      case ThemeMode.dark:
        return 'Dark Mode';
      case ThemeMode.system:
        return 'System Default';
    }
  }
}

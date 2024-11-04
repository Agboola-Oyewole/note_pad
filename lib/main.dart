import 'package:flutter/material.dart';
import 'package:note_pad/screens/home_screen.dart';
import 'package:provider/provider.dart';

import 'note_provider.dart';

void main() {
  runApp(
    ChangeNotifierProvider(
      create: (context) => NoteProvider(),
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        home: const HomeScreen(),
        theme: ThemeData(
          scaffoldBackgroundColor: Colors.black,
          // Set custom background color here
          appBarTheme: AppBarTheme(
            backgroundColor: Colors
                .black, // Optional: Customize AppBar background for dark mode
          ),
          textSelectionTheme: TextSelectionThemeData(
            cursorColor: Colors.white,
            selectionColor: Colors.white.withOpacity(0.5),
            selectionHandleColor: Colors.white,
          ),
          brightness: Brightness.light,
          fontFamily: 'Poppins',
        ),
        darkTheme: ThemeData(
          scaffoldBackgroundColor: Colors.black,
          // Set custom background color here
          appBarTheme: AppBarTheme(
            backgroundColor: Colors
                .black, // Optional: Customize AppBar background for dark mode
          ),
          textSelectionTheme: TextSelectionThemeData(
            cursorColor: Colors.white,
            selectionColor: Colors.white.withOpacity(0.5),
            selectionHandleColor: Colors.white,
          ),
          brightness: Brightness.dark,
          fontFamily: 'Poppins',
        ),
        themeMode: ThemeMode.dark,
      ),
    ),
  );
}

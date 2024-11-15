import 'package:flutter/material.dart';
import 'package:note_pad/screens/home_screen.dart';
import 'package:provider/provider.dart';

import 'data/note_provider.dart';

void main() {
  runApp(
    ChangeNotifierProvider(
      create: (context) => NoteProvider(),
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        home: const HomeScreen(),
        theme: ThemeData(
          scaffoldBackgroundColor: Color(0xffEEEEEE),
          // Set custom background color here
          appBarTheme: AppBarTheme(
            backgroundColor: Colors
                .black, // Optional: Customize AppBar background for dark mode
          ),
          textSelectionTheme: TextSelectionThemeData(
            cursorColor: Color(0xffB17457),
            selectionColor: Color(0xffB17457).withOpacity(0.5),
            selectionHandleColor: Color(0xffB17457),
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
            cursorColor: Color(0xffB17457),
            selectionColor: Color(0xffB17457).withOpacity(0.5),
            selectionHandleColor: Color(0xffB17457),
          ),
          brightness: Brightness.dark,
          fontFamily: 'Poppins',
        ),
        themeMode: ThemeMode.system,
      ),
    ),
  );
}

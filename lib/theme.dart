import 'package:flutter/material.dart';

/*
headline1 is for the page title with 1 word, this will be paired with subtitle1 for the page description
headline2 is for page title with 2 words
headline3 is for page title with 3 words
bodyText1 is for content and bold
bodyText2 is for content NOT bold
 */

final splitterTheme = ThemeData(
    visualDensity: VisualDensity.adaptivePlatformDensity,
    fontFamily: 'Comfortaa',
    textTheme: TextTheme(
      headline1: TextStyle(fontSize: 72, fontWeight: FontWeight.w700, color: Colors.white),
      headline2: TextStyle(fontSize: 60, fontWeight: FontWeight.w700, color: Colors.white),
      headline3: TextStyle(fontSize: 44, fontWeight: FontWeight.w700, color: Colors.white),
      subtitle1: TextStyle(fontSize: 20, color: Colors.white),
      subtitle2: TextStyle(fontSize: 16),
      bodyText1: TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: Colors.white),
      bodyText2: TextStyle(fontSize: 18, color: Colors.white),

      button: TextStyle(fontSize: 20, fontWeight: FontWeight.w700, color: Colors.white)
    ),
    textSelectionTheme: TextSelectionThemeData(
        cursorColor: Colors.white,
        selectionColor: Colors.cyan[300],
        selectionHandleColor: Colors.cyan[300]
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
            primary: Colors.cyan[300],
            minimumSize: Size(200, 50),
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(25),
            ),
            elevation: 4,
        ),
    ),
    cardTheme: CardTheme(
        elevation: 4,
        color: Colors.blueAccent[100],
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
    ),
    inputDecorationTheme: InputDecorationTheme(
        fillColor: Colors.black54,
        hintStyle:TextStyle(fontSize: 30),
        border: OutlineInputBorder(),
        focusedBorder: OutlineInputBorder(),
        labelStyle: TextStyle(color: Colors.black54),
        focusColor: Colors.black54,
    )
);


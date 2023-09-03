import 'package:flutter/material.dart';

var _var1;

var theme = ThemeData(
  bottomNavigationBarTheme: BottomNavigationBarThemeData(
    selectedItemColor: Colors.black
  ),
    textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
            backgroundColor: Colors.grey,
        )
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(

    ),
    iconTheme: IconThemeData(color: Colors.black),
    appBarTheme: AppBarTheme(
        color: Colors.white,
        elevation: 1,
        titleTextStyle: TextStyle(color: Colors.black, fontSize: 25),
        actionsIconTheme: IconThemeData(color: Colors.grey)
    ),
    textTheme: TextTheme(
        bodyText2: TextStyle(color: Colors.red),
        bodyText1: TextStyle(color: Colors.blue)
    )
);
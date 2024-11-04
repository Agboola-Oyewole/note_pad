import 'package:flutter/material.dart';

class Note {
  String title;
  String content;
  TextStyle textStyle;
  String date;

  Note({
    required this.title,
    required this.content,
    required this.textStyle,
    required this.date,
  });
}

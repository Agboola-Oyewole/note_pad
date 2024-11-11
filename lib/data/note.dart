import 'package:flutter/material.dart';

class Note {
  String title;
  String content;
  TextStyle textStyle;
  bool isPinned;
  bool isSelected;
  String date;
  int createInt;

  // Static field to track the latest createInt value
  static int currentCreateInt = 1000;

  Note({
    required this.title,
    required this.content,
    required this.textStyle,
    required this.date,
    required this.isPinned,
    required this.isSelected,
    int? createInt,
  }) : createInt = createInt ?? currentCreateInt--;

  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'content': content,
      'textStyle': {
        'fontSize': textStyle.fontSize,
        'fontWeight': textStyle.fontWeight?.index,
        'fontStyle': textStyle.fontStyle?.index,
      },
      'isPinned': isPinned,
      'isSelected': isSelected,
      'createInt': createInt,
      'date': date,
    };
  }

  static Note fromJson(Map<String, dynamic> json) {
    return Note(
      title: json['title'],
      content: json['content'],
      textStyle: TextStyle(
        fontSize: json['textStyle']['fontSize'] ?? 18.0,
        fontWeight: FontWeight.values[json['textStyle']['fontWeight'] ?? 0],
        fontStyle: FontStyle.values[json['textStyle']['fontStyle'] ?? 0],
      ),
      isPinned: json['isPinned'] ?? false,
      createInt: json['createInt'],
      // Use createInt from JSON if available
      isSelected: false,
      date: json['date'],
    );
  }

  // Override equality operator
  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Note &&
        other.title == title &&
        other.content == content &&
        other.createInt == createInt;
  }

  // Override hashCode
  @override
  int get hashCode => title.hashCode ^ content.hashCode ^ createInt.hashCode;
}

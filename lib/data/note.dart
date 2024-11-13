import 'package:flutter/material.dart';

class Note {
  String title;
  String content;
  TextStyle textStyle;
  bool isPinned;
  bool isSelected;
  String date;

  Note({
    required this.title,
    required this.content,
    required this.textStyle,
    required this.date,
    required this.isPinned,
    required this.isSelected,
  });

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
      isSelected: false,
      date: json['date'],
    );
  }

  // Override equality operator
  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Note && other.title == title && other.content == content;
  }

  // Override hashCode
  @override
  int get hashCode => title.hashCode ^ content.hashCode;
}

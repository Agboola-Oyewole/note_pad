import 'package:flutter/material.dart';

class Note {
  String title;
  String content;
  TextStyle textStyle;
  TextAlign textAlign;
  bool isPinned;
  bool isSelected;
  String date;

  Note({
    required this.title,
    required this.content,
    required this.textStyle,
    required this.textAlign,
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
        'decoration': _textDecorationToString(textStyle.decoration),
        // Store as a string
      },
      'textAlign': textAlign.toString(), // Store textAlign as a string
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
        decoration: _stringToTextDecoration(json['textStyle']['decoration']),
      ),
      textAlign: _stringToTextAlign(json['textAlign']),
      isPinned: json['isPinned'] ?? false,
      isSelected: false,
      date: json['date'],
    );
  }

  // Helper to convert TextDecoration to string
  static String _textDecorationToString(TextDecoration? decoration) {
    if (decoration == TextDecoration.underline) {
      return 'underline';
    } else if (decoration == TextDecoration.lineThrough) {
      return 'lineThrough';
    } else if (decoration == TextDecoration.overline) {
      return 'overline';
    } else {
      return 'none';
    }
  }

  // Helper to convert string back to TextDecoration
  static TextDecoration _stringToTextDecoration(String? decoration) {
    switch (decoration) {
      case 'underline':
        return TextDecoration.underline;
      case 'lineThrough':
        return TextDecoration.lineThrough;
      case 'overline':
        return TextDecoration.overline;
      default:
        return TextDecoration.none;
    }
  }

  // Helper to convert TextAlign to string
  static TextAlign _stringToTextAlign(String? textAlign) {
    switch (textAlign) {
      case 'TextAlign.left':
        return TextAlign.left;
      case 'TextAlign.right':
        return TextAlign.right;
      case 'TextAlign.center':
        return TextAlign.center;
      case 'TextAlign.justify':
        return TextAlign.justify;
      case 'TextAlign.start':
        return TextAlign.start;
      case 'TextAlign.end':
        return TextAlign.end;
      default:
        return TextAlign.start;
    }
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

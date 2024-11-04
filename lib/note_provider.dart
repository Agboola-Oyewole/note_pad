import 'package:flutter/material.dart';

import 'note.dart';

class NoteProvider extends ChangeNotifier {
  List<Note> _notes = [
    Note(
      title: 'Sample Note',
      content: 'This is a sample note.',
      textStyle: const TextStyle(fontSize: 18),
      date: _formatDate(DateTime.now()),
    ),
  ];

  int _currentNoteIndex = 0;

  List<Note> get notes => _notes;

  Note get currentNote => _notes[_currentNoteIndex];

  void addNote() {
    _notes.add(
      Note(
        title: 'New Note ${_notes.length}',
        content: '',
        textStyle: const TextStyle(fontSize: 18),
        date: _formatDate(DateTime.now()),
      ),
    );
    notifyListeners();
  }

  void updateCurrentNoteTitle(String newTitle) {
    _notes[_currentNoteIndex].title = newTitle;
    notifyListeners();
  }

  void updateCurrentNoteContent(String newContent) {
    _notes[_currentNoteIndex].content = newContent;
    notifyListeners();
  }

  void updateCurrentNoteDate(String newContent) {
    _notes[_currentNoteIndex].date = newContent;
    notifyListeners();
  }

  void updateCurrentNoteTextStyle(TextStyle newStyle) {
    _notes[_currentNoteIndex].textStyle = newStyle;
    notifyListeners();
  }

  void switchToNoteAt(int index) {
    _currentNoteIndex = index;
    notifyListeners();
  }

  // Method to format the date as "4th September 2024 12:23 AM"
  static String _formatDate(DateTime dateTime) {
    final int day = dateTime.day;
    final String suffix = _getSuffix(day);
    final String formattedDate =
        '$day$suffix ${_getMonth(dateTime.month)} ${dateTime
        .year} ${_formatTime(dateTime)}';
    return formattedDate;
  }

  static String _getSuffix(int day) {
    if (day >= 11 && day <= 13) {
      return 'th'; // Special case for 11, 12, and 13
    }
    switch (day % 10) {
      case 1:
        return 'st';
      case 2:
        return 'nd';
      case 3:
        return 'rd';
      default:
        return 'th';
    }
  }

  static String _getMonth(int month) {
    const List<String> months = [
      'January',
      'February',
      'March',
      'April',
      'May',
      'June',
      'July',
      'August',
      'September',
      'October',
      'November',
      'December'
    ];
    return months[month - 1];
  }

  static String _formatTime(DateTime dateTime) {
    final String hour =
    dateTime.hour % 12 == 0 ? '12' : (dateTime.hour % 12).toString();
    final String minute = dateTime.minute.toString().padLeft(2, '0');
    final String period = dateTime.hour >= 12 ? 'PM' : 'AM';
    return '$hour:$minute $period';
  }
}

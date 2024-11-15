import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'note.dart';

class NoteProvider extends ChangeNotifier {
  List<Note> _notes = [];
  int _currentNoteIndex = 0;
  bool _isGridView = false;

  List<Note> get notes => _notes;

  Note get currentNote => _notes[_currentNoteIndex];

  bool get isGridView => _isGridView;

  NoteProvider() {
    loadNotes();
  }

  Future<void> loadNotes() async {
    final prefs = await SharedPreferences.getInstance();
    final notesString = prefs.getString('notes');
    final bool? savedDisplayStyle = prefs.getBool('isGridView');

    if (savedDisplayStyle != null) {
      _isGridView = savedDisplayStyle;
    }

    if (notesString != null) {
      final List<dynamic> notesJson = json.decode(notesString);
      _notes = notesJson.map((note) => Note.fromJson(note)).toList();
      filterNotesByPinned();
    } else {
      _notes = [
        Note(
          title: 'Sample Note',
          content: 'This is a sample note.',
          textStyle: const TextStyle(fontSize: 18),
          isPinned: false,
          isSelected: false,
          date: _formatDate(DateTime.now()),
          textAlign: TextAlign.left,
        ),
      ];
    }

    saveNotes();
    notifyListeners(); // Ensures that listeners are updated immediately
  }

  Future<void> saveNotes() async {
    final prefs = await SharedPreferences.getInstance();
    final notesString =
        json.encode(_notes.map((note) => note.toJson()).toList());
    await prefs.setString('notes', notesString);
  }

  Future<void> saveDisplayStyle() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isGridView', _isGridView); // Persist displayStyle
  }

  void toggleDisplayStyle() {
    _isGridView = !_isGridView;
    saveDisplayStyle(); // Save the updated displayStyle
    notifyListeners();
  }

  void addNote() {
    // int noteNumber = 1;
    int highestNumber = 0;
    // while (_notes.any((note) => note.title == 'New Note $noteNumber')) {
    //   noteNumber++;
    // }
    for (var note in _notes) {
      if (note.title.startsWith('New Note')) {
        final parts = note.title.split(' ');
        if (parts.length == 3) {
          final number = int.tryParse(parts[2]) ?? 0;
          if (number > highestNumber) {
            highestNumber = number;
          }
        }
      }
    }
    int nextNumber = highestNumber + 1;
    _notes.add(
      Note(
        title: 'New Note $nextNumber',
        content: '',
        textStyle: const TextStyle(fontSize: 18),
        isPinned: false,
        isSelected: false,
        textAlign: TextAlign.left,
        date: _formatDate(DateTime.now()),
      ),
    );
    saveNotes();
    notifyListeners();
  }

  void updateCurrentNoteTitle(String newTitle) {
    _notes[_currentNoteIndex].title = newTitle;
    saveNotes();
    notifyListeners();
  }

  void updateCurrentNoteContent(String newContent) {
    _notes[_currentNoteIndex].content = newContent;
    saveNotes();
    notifyListeners();
  }

  void updateCurrentNoteTextStyle(TextStyle newStyle) {
    _notes[_currentNoteIndex].textStyle = newStyle;
    saveNotes();
    notifyListeners();
  }

  void updateCurrentNoteTextAlignStyle(TextAlign newStyle) {
    _notes[_currentNoteIndex].textAlign = newStyle;
    saveNotes();
    notifyListeners();
  }

  void updateCurrentNoteIsPinned() {
    _notes[_currentNoteIndex].isPinned = !_notes[_currentNoteIndex].isPinned;
    saveNotes();
    notifyListeners();
  }

  void updateCurrentNoteIsSelected() {
    _notes[_currentNoteIndex].isSelected =
        !_notes[_currentNoteIndex].isSelected;
    saveNotes();
    notifyListeners();
  }

  void deleteNoteAt(Note note) {
    int index = _notes.indexOf(note);
    if (index >= 0 && index < _notes.length) {
      _notes.removeAt(index); // Remove the note at the specified index
      saveNotes(); // Save the updated list to SharedPreferences
      notifyListeners(); // Notify listeners to update the UI
    }
  }

  void switchToNoteAt(Note note) {
    // Find the index of the note in the _notes list
    int index = _notes.indexOf(note);
    // Check if the note exists in the list
    if (index != -1) {
      _currentNoteIndex = index;
      notifyListeners();
    } else {
      print('Note not found in the list');
    }
  }

  void updateCurrentNoteDate(String newContent) {
    _notes[_currentNoteIndex].date = newContent;
    saveNotes(); // Save after updating
    notifyListeners();
  }

  void filterNotesByPinned() {
    // Separate pinned and unpinned notes
    List<Note> pinnedNotes = _notes.where((note) => note.isPinned).toList();
    List<Note> unpinnedNotes = _notes.where((note) => !note.isPinned).toList();

    // Define a date format matching your note date format, including seconds
    final dateFormat = DateFormat("d'th' MMMM yyyy h:mm:ss a");

    pinnedNotes.sort((a, b) {
      final DateTime dateA = dateFormat.parse(a.date);
      final DateTime dateB = dateFormat.parse(b.date);
      return dateB.compareTo(dateA); // Descending order
    });

    // Sort unpinned notes by date in descending order (latest first)
    unpinnedNotes.sort((a, b) {
      final DateTime dateA = dateFormat.parse(a.date);
      final DateTime dateB = dateFormat.parse(b.date);
      return dateB.compareTo(dateA); // Descending order
    });

    // Combine pinned notes first, followed by sorted unpinned notes
    _notes = [...pinnedNotes, ...unpinnedNotes];

    // Save the notes (assuming saveNotes() persists the notes)
    saveNotes();

    // Notify listeners to update the UI
    notifyListeners();
  }

  // Method to format the date as "4th September 2024 12:23 AM"
  static String _formatDate(DateTime dateTime) {
    final int day = dateTime.day;
    final String suffix = _getSuffix(day);
    final String formattedDate =
        '$day$suffix ${_getMonth(dateTime.month)} ${dateTime.year} ${_formatTime(dateTime)}';
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
    final String second =
        dateTime.second.toString().padLeft(2, '0'); // Include seconds
    final String period = dateTime.hour >= 12 ? 'PM' : 'AM';

    return '$hour:$minute:$second $period'; // Include seconds in the return string
  }
}

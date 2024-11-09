import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'note.dart';

class NoteProvider extends ChangeNotifier {
  List<Note> _notes = [];
  int _currentNoteIndex = 0;

  List<Note> get notes => _notes;

  Note get currentNote => _notes[_currentNoteIndex];

  NoteProvider() {
    loadNotes();
  }

  Future<void> loadNotes() async {
    final prefs = await SharedPreferences.getInstance();
    final notesString = prefs.getString('notes');
    final int? savedCreateInt = prefs.getInt('currentCreateInt');

    if (savedCreateInt != null) {
      // If the saved createInt exists, we set it
      Note.currentCreateInt = savedCreateInt;
    }

    if (notesString != null) {
      final List<dynamic> notesJson = json.decode(notesString);
      _notes = notesJson.map((note) => Note.fromJson(note)).toList();
      filterNotesByPinned();
      saveNotes();
    } else {
      _notes = [
        Note(
          title: 'Sample Note',
          content: 'This is a sample note.',
          textStyle: const TextStyle(fontSize: 18),
          isPinned: false,
          isSelected: false,
          date: _formatDate(DateTime.now()),
        ),
      ];
    }
    notifyListeners();
  }

  Future<void> saveNotes() async {
    final prefs = await SharedPreferences.getInstance();
    final notesString =
        json.encode(_notes.map((note) => note.toJson()).toList());
    await prefs.setString('notes', notesString);
    // Save the latest _currentCreateInt value in SharedPreferences
    await prefs.setInt('currentCreateInt', Note.currentCreateInt);
  }

  void addNote() {
    _notes.add(
      Note(
        title: 'New Note ${_notes.length}',
        content: '',
        textStyle: const TextStyle(fontSize: 18),
        isPinned: false,
        isSelected: false,
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

  void deleteNoteAt(int index) {
    if (index >= 0 && index < _notes.length) {
      _notes.removeAt(index); // Remove the note at the specified index
      saveNotes(); // Save the updated list to SharedPreferences
      notifyListeners(); // Notify listeners to update the UI
    }
  }

  void switchToNoteAt(Note note) {
    // Find the index of the note in the _notes list
    print(note.title);
    // print(_notes[0].title);
    // print(_notes[1].title);
    // print(_notes[2].title);
    // print(_notes[3].title);
    int index = _notes.indexOf(note);
    print(index);
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

    // Manually sort unpinned notes by createInt in ascending order (lower values first)
    for (int i = 0; i < unpinnedNotes.length; i++) {
      for (int j = i + 1; j < unpinnedNotes.length; j++) {
        if (unpinnedNotes[i].createInt > unpinnedNotes[j].createInt) {
          // Swap elements if they are in the wrong order
          Note temp = unpinnedNotes[i];
          unpinnedNotes[i] = unpinnedNotes[j];
          unpinnedNotes[j] = temp;
        }
      }
    }

    // Combine pinned notes first, followed by sorted unpinned notes
    _notes = [...pinnedNotes, ...unpinnedNotes];
    saveNotes();
    // Notify listeners to update the UI
    notifyListeners();
  }

  List<Note> filterNotes(List<Note> notes) {
    // Separate pinned and unpinned notes
    List<Note> pinnedNotes = notes.where((note) => note.isPinned).toList();
    List<Note> unpinnedNotes = notes.where((note) => !note.isPinned).toList();

    // Manually sort unpinned notes by createInt in ascending order (lower values first)
    for (int i = 0; i < unpinnedNotes.length; i++) {
      for (int j = i + 1; j < unpinnedNotes.length; j++) {
        if (unpinnedNotes[i].createInt > unpinnedNotes[j].createInt) {
          // Swap elements if they are in the wrong order
          Note temp = unpinnedNotes[i];
          unpinnedNotes[i] = unpinnedNotes[j];
          unpinnedNotes[j] = temp;
        }
      }
    }

    // Combine pinned notes first, followed by sorted unpinned notes
    return [...pinnedNotes, ...unpinnedNotes];
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
    final String period = dateTime.hour >= 12 ? 'PM' : 'AM';
    return '$hour:$minute $period';
  }
}

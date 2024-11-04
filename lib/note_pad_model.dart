// import 'package:flutter/material.dart';
//
// class Note {
//   String title;
//   int id;
//   String content;
//   TextAlign textAlign;
//   double fontSize;
//   bool isBold;
//   bool isItalic;
//   bool isUnderline;
//
//   Note({
//     required this.id,
//     required this.title,
//     required this.content,
//     this.textAlign = TextAlign.left,
//     this.fontSize = 18,
//     this.isBold = false,
//     this.isItalic = false,
//     this.isUnderline = false,
//   });
//
//   TextStyle get currentStyle {
//     return TextStyle(
//       color: Colors.white,
//       fontSize: fontSize,
//       fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
//       fontStyle: isItalic ? FontStyle.italic : FontStyle.normal,
//       decoration: isUnderline ? TextDecoration.underline : TextDecoration.none,
//     );
//   }
// }
//
// class NotePadModel with ChangeNotifier {
//   List<Note> _notes = [];
//
//   List<Note> get notes => _notes;
//
//   void addNewNote() {
//     // Create a new note and add it to the list
//     Note newNote = Note(
//       id: notes.length + 1,
//       title: 'New Note',
//       content: '', // or some default content
//     );
//     _notes.add(newNote);
//     notifyListeners(); // Notify listeners about the change
//   }
//
//   // Get current note
//   // Note get currentNote {
//   //   if (id >= 0 && id < notes.length) {
//   //     return notes[id];
//   //   }
//   //   throw Exception('No current note selected.');
//   // }
//
//   // Save changes to the current note
//   void saveChanges(int id, String title, String content) {
//     if (id >= 0 && id < notes.length) {
//       notes[id].title = title;
//       notes[id].content = content;
//       notifyListeners();
//     }
//   }
//
//   // Undo action
//   void undo() {
//     // Implement undo functionality if needed
//   }
//
//   // Redo action
//   void redo() {
//     // Implement redo functionality if needed
//   }
//
//   // Toggle bold
//   void toggleBold(int id) {
//     if (id >= 0) {
//       notes[id].isBold = !notes[id].isBold;
//       notifyListeners();
//     }
//   }
//
//   // Toggle italic
//   void toggleItalic(int id) {
//     if (id >= 0) {
//       notes[id].isItalic = !notes[id].isItalic;
//       notifyListeners();
//     }
//   }
//
//   // Toggle underline
//   void toggleUnderline(int id) {
//     if (id >= 0) {
//       notes[id].isUnderline = !notes[id].isUnderline;
//       notifyListeners();
//     }
//   }
//
//   // Increase font size
//   void increaseFontSize(int id) {
//     if (id >= 0) {
//       notes[id].fontSize += 2;
//       notifyListeners();
//     }
//   }
//
//   // Decrease font size
//   void decreaseFontSize(int id) {
//     if (id >= 0 && notes[id].fontSize > 10) {
//       notes[id].fontSize -= 2;
//       notifyListeners();
//     }
//   }
//
//   // Set text alignment
//   void setTextAlign(TextAlign align, int id) {
//     if (id >= 0) {
//       notes[id].textAlign = align;
//       notifyListeners();
//     }
//   }
//
//   // Delete a note
//   void deleteNote(int id) {
//     if (id >= 0 && id < notes.length) {
//       notes.removeAt(id);
//       id = notes.isEmpty ? -1 : 0; // Reset current index if no notes are left
//       notifyListeners();
//     }
//   }
// }

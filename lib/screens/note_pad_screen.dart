import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:note_pad/screens/home_screen.dart';
import 'package:provider/provider.dart';

import '../data/note_provider.dart';

class NotePadScreen extends StatefulWidget {
  const NotePadScreen({super.key});

  @override
  State<NotePadScreen> createState() => _NotePadScreenState();
}

class _NotePadScreenState extends State<NotePadScreen> {
  late TextEditingController _titleController;
  late TextEditingController _contentController;
  final List<String> _contentHistory = [];
  int _historyIndex = -1;
  TextAlign _textAlign = TextAlign.left;
  double _fontSize = 18;
  bool _isBold = false;
  bool _isItalic = false;
  bool _isUnderline = false;
  bool _isSaved = true;

  @override
  void initState() {
    super.initState();
    final noteProvider = Provider.of<NoteProvider>(context, listen: false);
    _titleController =
        TextEditingController(text: noteProvider.currentNote.title);
    _contentController =
        TextEditingController(text: noteProvider.currentNote.content);
    setState(() {
      // Set font size from current note's textStyle
      _fontSize = noteProvider.currentNote.textStyle.fontSize ?? 18;

      // Set bold if font weight is greater than or equal to FontWeight.w700 (700 or above is bold)
      _isBold =
          noteProvider.currentNote.textStyle.fontWeight == FontWeight.bold;

      // Set italic if the font style is italic
      _isItalic =
          noteProvider.currentNote.textStyle.fontStyle == FontStyle.italic;

      // Set underline if text decoration includes underline
      _isUnderline = noteProvider.currentNote.textStyle.decoration ==
          TextDecoration.underline;
    });
  }

  @override
  void dispose() {
    _titleController.dispose();
    _contentController.dispose();
    super.dispose();
  }

  // Update content style based on current settings
  TextStyle get _currentStyle {
    return TextStyle(
      color: Colors.white,
      fontSize: _fontSize,
      fontWeight: _isBold ? FontWeight.bold : FontWeight.normal,
      fontStyle: _isItalic ? FontStyle.italic : FontStyle.normal,
      decoration: _isUnderline ? TextDecoration.underline : TextDecoration.none,
    );
  }

  // Save content state for undo/redo
  void _saveContentToHistory() {
    if (_historyIndex < _contentHistory.length - 1) {
      _contentHistory.removeRange(_historyIndex + 1, _contentHistory.length);
    }
    _contentHistory.add(_contentController.text);
    _historyIndex = _contentHistory.length - 1;
  }

  // Undo the last content change
  void _undo() {
    if (_historyIndex > 0) {
      setState(() {
        _historyIndex--;
        _contentController.text = _contentHistory[_historyIndex];
      });
    }
  }

  // Redo the next content change
  void _redo() {
    if (_historyIndex < _contentHistory.length - 1) {
      setState(() {
        _historyIndex++;
        _contentController.text = _contentHistory[_historyIndex];
      });
    }
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

  // Save the current changes and reset history
  void _saveChanges() {
    final noteProvider = Provider.of<NoteProvider>(context, listen: false);
    noteProvider.updateCurrentNoteTitle(_titleController.text);
    noteProvider.updateCurrentNoteContent(_contentController.text);
    noteProvider.updateCurrentNoteTextStyle(_currentStyle);
    noteProvider.updateCurrentNoteDate(_formatDate(DateTime.now()));
    noteProvider.filterNotesByPinned();
    setState(() {});

    setState(() {
      _isSaved = true;
      _contentHistory.clear();
      _saveContentToHistory();
      _historyIndex = 0; // Reset to the initial saved state
    });
  }

  // Update text style properties
  void _toggleBold() {
    // final noteProvider = Provider.of<NoteProvider>(context, listen: false);
    // noteProvider.currentNote.textStyle.
    setState(() {
      _isBold = !_isBold;

      _isSaved = false;
    });
  }

  void _toggleItalic() {
    setState(() {
      _isItalic = !_isItalic;
      _isSaved = false;
    });
  }

  void _toggleUnderline() {
    setState(() {
      _isUnderline = !_isUnderline;
      _isSaved = false;
    });
  }

  void _increaseFontSize() {
    setState(() {
      _fontSize += 2;
      _isSaved = false;
    });
  }

  void _decreaseFontSize() {
    setState(() {
      if (_fontSize > 10) _fontSize -= 2;
      _isSaved = false;
    });
  }

  void _setTextAlign(TextAlign align) {
    setState(() {
      _textAlign = align;
      _isSaved = false;
    });
  }

  String addOrdinalSuffix(int day) {
    if (day >= 11 && day <= 13) {
      return "$day" + "th";
    }
    switch (day % 10) {
      case 1:
        return "$day" + "st";
      case 2:
        return "$day" + "nd";
      case 3:
        return "$day" + "rd";
      default:
        return "$day" + "th";
    }
  }

  String reformatDate(String dateString) {
    // Step 1: Remove ordinal suffixes from the day (e.g., "12th" -> "12")
    dateString = dateString.replaceAll(RegExp(r'(st|nd|rd|th)'), '');

    // Step 2: Parse the date with seconds
    DateTime parsedDate = DateFormat("d MMMM yyyy h:mm:ss a").parse(dateString);

    // Step 3: Reformat the parsed date into the desired format without the seconds
    String formattedDate = DateFormat("d MMMM h:mm a").format(parsedDate);

    // Step 4: Add the ordinal suffix back to the day
    String dayWithSuffix = addOrdinalSuffix(parsedDate.day);

    // Final format: "11th November 12:34 PM"
    return formattedDate.replaceFirst(parsedDate.day.toString(), dayWithSuffix);
  }

  @override
  Widget build(BuildContext context) {
    final noteProvider = Provider.of<NoteProvider>(context, listen: false);
    print(noteProvider.currentNote.date);
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) async {
        if (didPop) {
          return;
        }
        final navigator = Navigator.of(context);
        _saveChanges();

        navigator.pop(result);
      },
      child: Scaffold(
        backgroundColor: Theme.of(context).colorScheme.surface,
        appBar: AppBar(
          surfaceTintColor: Theme.of(context).colorScheme.surface,
          backgroundColor: Theme.of(context).colorScheme.surface,
          leading: GestureDetector(
            onTap: () {
              _saveChanges();
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => const HomeScreen(),
                ),
              );
            },
            child: Icon(
              Icons.arrow_back,
              color: Theme.of(context).brightness == Brightness.dark
                  ? Colors.white
                  : Colors.black,
              size: 28,
            ),
          ),
          actions: <Widget>[
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  IconButton(
                    icon: Icon(Icons.undo,
                        color: _historyIndex > 0
                            ? Theme.of(context).brightness == Brightness.dark
                                ? Colors.white
                                : Colors.black
                            : Colors.grey[300],
                        size: 28),
                    onPressed: _historyIndex > 0 ? _undo : null,
                  ),
                  SizedBox(width: 20),
                  IconButton(
                    icon: Icon(Icons.redo,
                        color: _historyIndex < _contentHistory.length - 1
                            ? Theme.of(context).brightness == Brightness.dark
                                ? Colors.white
                                : Colors.black
                            : Colors.grey[300],
                        size: 28),
                    onPressed: _historyIndex < _contentHistory.length - 1
                        ? _redo
                        : null,
                  ),
                  SizedBox(width: 20),
                  IconButton(
                    icon: Icon(Icons.check,
                        color: _isSaved
                            ? Colors.grey[300]
                            : Theme.of(context).brightness == Brightness.dark
                                ? Colors.white
                                : Colors.black,
                        size: 28),
                    onPressed: _isSaved ? null : _saveChanges,
                  ),
                ],
              ),
            ),
          ],
        ),
        body: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.only(
                    left: 20.0, right: 20, bottom: 200, top: 10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    TextField(
                      controller: _titleController,
                      cursorColor:
                          Theme.of(context).brightness == Brightness.dark
                              ? Colors.white
                              : Colors.black,
                      decoration: InputDecoration(
                        hintText: 'Title',
                        hintStyle: TextStyle(
                            color:
                                Theme.of(context).brightness == Brightness.dark
                                    ? Colors.grey.withOpacity(0.4)
                                    : Colors.grey[400]),
                        border: InputBorder.none,
                      ),
                      style: TextStyle(
                        color: Theme.of(context).brightness == Brightness.dark
                            ? Colors.white
                            : Colors.black,
                        fontSize: 30,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    SizedBox(height: 15),
                    Text(
                      '${_contentController.text.length} Character${_contentController.text.length < 2 ? '' : 's'}  |  ${reformatDate(noteProvider.currentNote.date)}',
                      style: TextStyle(
                        color: Theme.of(context).brightness == Brightness.dark
                            ? Colors.grey
                            : Colors.grey[600],
                      ),
                    ),
                    SizedBox(height: 25),
                    TextField(
                      controller: _contentController,
                      maxLines: null,
                      cursorColor:
                          Theme.of(context).brightness == Brightness.dark
                              ? Colors.white
                              : Colors.black,
                      decoration: InputDecoration(
                        hintText: 'Start Typing',
                        hintStyle: TextStyle(
                            color:
                                Theme.of(context).brightness == Brightness.dark
                                    ? Colors.grey.withOpacity(0.4)
                                    : Colors.grey[400]),
                        border: InputBorder.none,
                      ),
                      style: _currentStyle.copyWith(
                          color: Theme.of(context).brightness == Brightness.dark
                              ? Colors.white
                              : Colors.black),
                      textAlign: _textAlign,
                      onChanged: (value) {
                        // Only save to history if the content has changed
                        setState(() {
                          _isSaved = false;
                          if (_contentHistory.isEmpty ||
                              _contentHistory.last != value) {
                            _saveContentToHistory(); // Save history on text change
                          }
                        });
                      },
                    ),
                  ],
                ),
              ),
            ),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Container(
                padding: EdgeInsets.all(10),
                decoration: BoxDecoration(
                    border: Theme.of(context).brightness == Brightness.dark
                        ? null
                        : Border(
                            top: BorderSide(color: Colors.black, width: 2))),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: <Widget>[
                    IconButton(
                      icon: Icon(Icons.text_increase,
                          size: 30,
                          color: _fontSize > 1
                              ? Theme.of(context).brightness == Brightness.dark
                                  ? Colors.white
                                  : Colors.black
                              : Colors.grey[400]),
                      onPressed: _increaseFontSize,
                    ),
                    SizedBox(width: 15),
                    IconButton(
                      icon: Icon(Icons.text_decrease,
                          size: 30,
                          color: _fontSize > 10
                              ? Theme.of(context).brightness == Brightness.dark
                                  ? Colors.white
                                  : Colors.black
                              : Colors.grey[400]),
                      onPressed: _decreaseFontSize,
                    ),
                    SizedBox(width: 15),
                    IconButton(
                      icon: Icon(Icons.format_bold,
                          size: 30,
                          color: _isBold
                              ? Color(0xffB17457)
                              : Theme.of(context).brightness == Brightness.dark
                                  ? Colors.white
                                  : Colors.black),
                      onPressed: _toggleBold,
                    ),
                    SizedBox(width: 15),
                    IconButton(
                      icon: Icon(Icons.format_underline,
                          size: 30,
                          color: _isUnderline
                              ? Color(0xffB17457)
                              : Theme.of(context).brightness == Brightness.dark
                                  ? Colors.white
                                  : Colors.black),
                      onPressed: _toggleUnderline,
                    ),
                    SizedBox(width: 15),
                    IconButton(
                      icon: Icon(Icons.format_italic,
                          size: 30,
                          color: _isItalic
                              ? Color(0xffB17457)
                              : Theme.of(context).brightness == Brightness.dark
                                  ? Colors.white
                                  : Colors.black),
                      onPressed: _toggleItalic,
                    ),
                    SizedBox(width: 15),
                    IconButton(
                      icon: Icon(Icons.format_align_left,
                          size: 30,
                          color: _textAlign == TextAlign.left
                              ? Color(0xffB17457)
                              : Theme.of(context).brightness == Brightness.dark
                                  ? Colors.white
                                  : Colors.black),
                      onPressed: () => _setTextAlign(TextAlign.left),
                    ),
                    SizedBox(width: 15),
                    IconButton(
                      icon: Icon(Icons.format_align_center,
                          size: 30,
                          color: _textAlign == TextAlign.center
                              ? Color(0xffB17457)
                              : Theme.of(context).brightness == Brightness.dark
                                  ? Colors.white
                                  : Colors.black),
                      onPressed: () => _setTextAlign(TextAlign.center),
                    ),
                    SizedBox(width: 15),
                    IconButton(
                      icon: Icon(Icons.format_align_right,
                          size: 30,
                          color: _textAlign == TextAlign.right
                              ? Color(0xffB17457)
                              : Theme.of(context).brightness == Brightness.dark
                                  ? Colors.white
                                  : Colors.black),
                      onPressed: () => _setTextAlign(TextAlign.right),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

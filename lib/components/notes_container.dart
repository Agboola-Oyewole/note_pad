import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../data/note.dart';

class NotesContainer extends StatelessWidget {
  const NotesContainer({
    super.key,
    required this.note,
  });

  final Note note;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
          color: Theme.of(context).brightness == Brightness.dark
              ? Color(0xFF333333) // Color for dark mode
              : Colors.white, // Dark background color for the search bar
          borderRadius: BorderRadius.circular(15),
          border: note.isSelected
              ? Border.all(color: Colors.white, width: 2)
              : null),
      padding: const EdgeInsets.symmetric(horizontal: 30.0, vertical: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                note.title,
                style: TextStyle(
                    fontWeight: FontWeight.w900,
                    fontSize: 20,
                    color: Theme.of(context).brightness == Brightness.dark
                        ? Colors.white
                        : Colors.black),
              ),
              note.isPinned
                  ? Icon(
                      Icons.push_pin,
                      color: Color(0xffB17457),
                    )
                  : Container()
            ],
          ),
          SizedBox(
            height: 8,
          ),
          Text(
            note.content.isEmpty
                ? 'No text'
                : note.content.length > 50
                    ? '${note.content.substring(0, 50)}....'
                    : note.content,
            style: TextStyle(
                fontWeight: FontWeight.w700,
                fontSize: 15,
                color: Theme.of(context).brightness == Brightness.dark
                    ? Colors.grey[400]
                    : Colors.grey[600]),
          ),
          SizedBox(
            height: 8,
          ),
          Text(
            note.date,
            style: TextStyle(
                fontWeight: FontWeight.w700,
                fontSize: 15,
                color: Color(0xffB17457)),
          ),
        ],
      ),
    );
  }
}

class NotesGridContainer extends StatelessWidget {
  const NotesGridContainer({
    super.key,
    required this.note,
  });

  final Note note;

  @override
  Widget build(BuildContext context) {
    String reformatDate(String dateString) {
      // Step 1: Remove ordinal suffixes from the day (e.g., "11th" -> "11")
      dateString = dateString.replaceAll(RegExp(r'(st|nd|rd|th)'), '');

      // Step 2: Parse the date
      DateTime parsedDate = DateFormat("d MMMM yyyy h:mm a").parse(dateString);

      // Step 3: Reformat the parsed date into the desired format
      String formattedDate = DateFormat("MM/dd/yyyy h:mm a").format(parsedDate);

      return formattedDate;
    }

    return Container(
      decoration: BoxDecoration(
          color: Theme.of(context).brightness == Brightness.dark
              ? Color(0xFF333333) // Color for dark mode
              : Colors.white, // Color for light mode
          // Dark background color for the search bar
          borderRadius: BorderRadius.circular(15),
          border: note.isSelected
              ? Border.all(color: Colors.white, width: 2)
              : null),
      padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                note.isPinned
                    ? note.title.isEmpty
                        ? 'No title'
                        : note.title.length > 7
                            ? '${note.title.substring(0, 7)}....'
                            : note.title
                    : note.title.isEmpty
                        ? 'No title'
                        : note.title.length > 15
                            ? '${note.title.substring(0, 15)}....'
                            : note.title,
                style: TextStyle(
                    fontWeight: FontWeight.w900,
                    fontSize: 16,
                    color: Theme.of(context).brightness == Brightness.dark
                        ? Colors.white
                        : Colors.black),
              ),
              note.isPinned
                  ? Icon(
                      Icons.push_pin,
                      color: Color(0xffB17457),
                    )
                  : Container()
            ],
          ),
          SizedBox(
            height: 16,
          ),
          Text(
            note.content.isEmpty
                ? 'No text'
                : note.content.length > 20
                    ? '${note.content.substring(0, 20)}....'
                    : note.content,
            style: TextStyle(
                fontWeight: FontWeight.w700,
                fontSize: 14,
                color: Theme.of(context).brightness == Brightness.dark
                    ? Colors.grey[400]
                    : Colors.grey[600]),
          ),
          SizedBox(
            height: 13,
          ),
          note.content.length <= 15
              ? Padding(
                  padding: const EdgeInsets.only(top: 20.0),
                  child: Text(
                    reformatDate(note.date),
                    style: TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: 14,
                        color: Color(0xffB17457)),
                  ),
                )
              : Text(
                  reformatDate(note.date),
                  style: TextStyle(
                      fontWeight: FontWeight.w700,
                      fontSize: 14,
                      color: Color(0xffB17457)),
                ),
        ],
      ),
    );
  }
}

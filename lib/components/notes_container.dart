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
    String formatFullDateString(String input) {
      // Split the input string into the date and time part
      List<String> parts = input.split(' ');

      // The date part is the first three elements
      String day = parts[0]; // 11th
      String month = parts[1]; // November
      String year = parts[2]; // 2024

      // Time part is the remaining part
      String time = parts[3]; // 12:34:56
      String period = parts[4]; // PM

      // Extract the hours and minutes from the time part
      List<String> timeParts = time.split(':');
      String hour = timeParts[0]; // 12
      String minute = timeParts[1]; // 34

      // Combine everything back together without the seconds
      return '$day $month $year $hour:$minute $period';
    }

    return Container(
      decoration: BoxDecoration(
          color: Theme.of(context).brightness == Brightness.dark
              ? Color(0xFF333333) // Color for dark mode
              : Colors.white, // Dark background color for the search bar
          borderRadius: BorderRadius.circular(15),
          border: note.isSelected
              ? Theme.of(context).brightness == Brightness.dark
                  ? Border.all(color: Colors.white, width: 2)
                  : Border.all(color: Colors.black, width: 2)
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
            formatFullDateString(note.date),
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
      DateTime parsedDate =
          DateFormat("d MMMM yyyy h:mm:ss a").parse(dateString);

      // Step 3: Reformat the parsed date into the desired format without the seconds
      String formattedDate = DateFormat("d MMMM h:mm a").format(parsedDate);

      // Step 4: Add the ordinal suffix back to the day
      String dayWithSuffix = addOrdinalSuffix(parsedDate.day);

      // Final format: "11th November 12:34 PM"
      return formattedDate.replaceFirst(
          parsedDate.day.toString(), dayWithSuffix);
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

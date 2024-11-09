import 'package:flutter/material.dart';

import 'note.dart';

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
          color: Color(0xFF333333), // Dark background color for the search bar
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
                    color: Colors.white),
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
                color: Colors.grey[400]),
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

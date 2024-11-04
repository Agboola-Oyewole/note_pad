import 'package:flutter/material.dart';

import 'note.dart';

class NotesContainer extends StatelessWidget {
  const NotesContainer({super.key, required this.note});

  final Note note;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Color(0xFF333333), // Dark background color for the search bar
        borderRadius: BorderRadius.circular(15),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 30.0, vertical: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            note.title,
            style: TextStyle(
                fontWeight: FontWeight.w900, fontSize: 20, color: Colors.white),
          ),
          SizedBox(
            height: 8,
          ),
          Text(
            note.content,
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

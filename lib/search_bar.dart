import 'package:flutter/material.dart';

class SearchBarCustom extends StatelessWidget {
  const SearchBarCustom(
      {super.key, required this.controller, required this.focusNode});

  final TextEditingController controller;
  final FocusNode focusNode;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Color(0xFF333333), // Dark background color for the search bar
        borderRadius: BorderRadius.circular(30),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 10),
      child: Row(
        children: [
          Icon(
            Icons.search,
            color: Colors.grey[400],
          ),
          SizedBox(width: 15),
          Expanded(
            child: TextField(
              controller: controller,
              focusNode: focusNode,
              style: TextStyle(color: Colors.white, fontSize: 19),
              decoration: InputDecoration(
                hintText: 'Search notes',
                hintStyle: TextStyle(color: Colors.grey[500]),
                border: InputBorder.none,
              ),
            ),
          ),
          SizedBox(width: 8),
          Icon(
            Icons.grid_view_rounded,
            color: Colors.grey[400],
            size: 28,
          ),
          SizedBox(width: 15),
          Icon(
            Icons.settings,
            color: Colors.grey[400],
            size: 28,
          )
        ],
      ),
    );
  }
}

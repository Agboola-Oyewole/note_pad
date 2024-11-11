import 'package:flutter/material.dart';

class CategoryContainer extends StatelessWidget {
  const CategoryContainer({super.key, required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).brightness == Brightness.dark
            ? Color(0xFF333333)
            : Colors.white,
        // Dark background color for the search bar
        borderRadius: BorderRadius.circular(15),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 13),
      child: Text(
        text,
        style: TextStyle(
          fontWeight: FontWeight.w900,
          fontSize: 18,
          color: Theme.of(context).brightness == Brightness.dark
              ? Colors.grey[400]
              : Colors.black,
        ),
      ),
    );
  }
}

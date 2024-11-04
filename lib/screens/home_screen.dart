import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:note_pad/category_container.dart';
import 'package:note_pad/notes_container.dart';
import 'package:note_pad/screens/note_pad_screen.dart';
import 'package:note_pad/search_bar.dart';
import 'package:provider/provider.dart';

import '../note_provider.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final ScrollController _scrollController = ScrollController();
  bool _isScrollingDown = false;
  bool _showSearchBar = true; // Search bar starts visible
  bool _showIcons = false; // Icons start hidden

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(() {
      // Listen for scroll direction
      setState(() {
        _isScrollingDown = _scrollController.position.userScrollDirection ==
            ScrollDirection.reverse;

        // Show icons when scrolling down
        if (_isScrollingDown) {
          _showIcons = true; // Show icons when scrolling down
          _showSearchBar = false; // Hide search bar
        } else {
          // Only show search bar when scrolled to the top
          if (_scrollController.offset <= 0) {
            _showSearchBar = true; // Show search bar when at the top
            _showIcons = false; // Hide icons when at the top
          } else {
            // Keep search bar hidden if not at the top
            _showSearchBar = false;
          }
        }
      });
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final noteProvider = Provider.of<NoteProvider>(context);
    return Scaffold(
      body: Padding(
        padding:
            const EdgeInsets.only(right: 20.0, left: 20, top: 50, bottom: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Notes',
                  style: TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 40,
                    color: Colors.grey[400],
                  ),
                ),
                if (_showIcons) // Icons are visible when scrolling down
                  Row(
                    children: [
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
              ],
            ),
            if (_showSearchBar) SizedBox(height: 20),
            if (_showSearchBar) SearchBarCustom(),
            // Search bar is visible when scrolled to the top
            SizedBox(height: 25),
            Row(
              children: [
                CategoryContainer(text: 'All (${noteProvider.notes.length})'),
                SizedBox(width: 10),
                CategoryContainer(text: 'Work'),
                SizedBox(width: 10),
                CategoryContainer(text: 'Important'),
              ],
            ),
            Expanded(
              child: ListView.builder(
                itemCount: noteProvider.notes.length,
                itemBuilder: (context, index) {
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 15.0),
                    child: GestureDetector(
                      child: NotesContainer(note: noteProvider.notes[index]),
                      onTap: () {
                        noteProvider.switchToNoteAt(index);
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (context) => NotePadScreen(),
                          ),
                        );
                      },
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: Padding(
        padding: const EdgeInsets.all(10.0),
        child: FloatingActionButton(
          onPressed: () {
            noteProvider.addNote();
            noteProvider.switchToNoteAt(noteProvider.notes.length - 1);
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (context) => NotePadScreen(),
              ),
            );
          },
          backgroundColor: const Color(0xffB17457),
          elevation: 5.0,
          child: const Icon(
            Icons.add,
            color: Colors.white,
            size: 30.0,
          ),
        ),
      ),
    );
  }
}

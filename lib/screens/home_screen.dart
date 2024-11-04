import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:note_pad/category_container.dart';
import 'package:note_pad/notes_container.dart';
import 'package:note_pad/screens/note_pad_screen.dart';
import 'package:note_pad/search_bar.dart';
import 'package:provider/provider.dart';

import '../note.dart';
import '../note_provider.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final ScrollController _scrollController = ScrollController();
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _searchFocusNode = FocusNode(); // Focus node for search bar

  bool _isScrollingDown = false;
  bool _showSearchBar = true;
  bool _showIcons = false;
  List<Note> _filteredNotes = []; // Filtered notes list

  @override
  void initState() {
    super.initState();
    _filteredNotes = Provider.of<NoteProvider>(context, listen: false).notes;

    _scrollController.addListener(() {
      final userScrollDirection =
          _scrollController.position.userScrollDirection;
      if (userScrollDirection == ScrollDirection.reverse && !_isScrollingDown) {
        setState(() {
          _isScrollingDown = true;
          _showSearchBar = false;
          _showIcons = true;
        });
      } else if (userScrollDirection == ScrollDirection.forward &&
          _isScrollingDown) {
        setState(() {
          _isScrollingDown = false;
          _showSearchBar = true;
          _showIcons = false;
        });
      }
    });

    // Listen to search input changes
    _searchController.addListener(_filterNotes);
  }

  void _filterNotes() {
    final query = _searchController.text.toLowerCase();
    final noteProvider = Provider.of<NoteProvider>(context, listen: false);

    setState(() {
      _filteredNotes = noteProvider.notes.where((note) {
        return note.title.toLowerCase().startsWith(query);
      }).toList();
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _searchController.dispose();
    _searchFocusNode.dispose(); // Dispose the focus node
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
                if (_showIcons)
                  Row(
                    children: [
                      Icon(Icons.grid_view_rounded,
                          color: Colors.grey[400], size: 28),
                      SizedBox(width: 15),
                      Icon(Icons.settings, color: Colors.grey[400], size: 28),
                    ],
                  ),
              ],
            ),
            if (_showSearchBar) SizedBox(height: 20),
            if (_showSearchBar)
              SearchBarCustom(
                controller: _searchController,
                focusNode:
                    _searchFocusNode, // Set the focus node for search bar
              ),
            SizedBox(height: 25),
            Row(
              children: [
                CategoryContainer(text: 'All (${_filteredNotes.length})'),
              ],
            ),
            SizedBox(height: 30),
            Expanded(
              child: _filteredNotes.isNotEmpty
                  ? ListView.builder(
                      controller: _scrollController,
                      padding: EdgeInsets.all(0),
                      itemCount: _filteredNotes.length,
                      itemBuilder: (context, index) {
                        final reversedIndex = _filteredNotes.length - 1 - index;
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 15.0),
                          child: GestureDetector(
                            child: NotesContainer(
                                note: _filteredNotes[reversedIndex]),
                            onTap: () {
                              _searchController
                                  .clear(); // Clear the search text
                              _searchFocusNode
                                  .unfocus(); // Remove focus from the search bar
                              _filteredNotes = noteProvider.notes;
                              noteProvider.switchToNoteAt(reversedIndex);
                              Navigator.of(context).push(
                                MaterialPageRoute(
                                  builder: (context) => NotePadScreen(),
                                ),
                              );
                            },
                          ),
                        );
                      },
                    )
                  : Center(
                      child: Padding(
                        padding: const EdgeInsets.only(bottom: 150.0),
                        child: Text(
                          'No Results',
                          style:
                              TextStyle(fontSize: 25, color: Colors.grey[400]),
                        ),
                      ),
                    ),
            ),
          ],
        ),
      ),
      floatingActionButton: Padding(
        padding: const EdgeInsets.all(10.0),
        child: FloatingActionButton(
          onPressed: () {
            _searchController.clear(); // Clear the search text
            _searchFocusNode.unfocus(); // Remove focus from the search bar
            _filteredNotes = noteProvider.notes; // Reset the filtered notes

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

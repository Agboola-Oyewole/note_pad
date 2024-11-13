import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:intl/intl.dart';
import 'package:note_pad/components/notes_container.dart';
import 'package:note_pad/screens/note_pad_screen.dart';
import 'package:provider/provider.dart';

import '../components/category_container.dart';
import '../data/note.dart';
import '../data/note_provider.dart';

// TODO: Work on when changes are made to a note it becomes the first*
// TODO: Work on the grid and menu showing *

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final ScrollController _scrollController = ScrollController();
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _searchFocusNode = FocusNode(); // Focus node for search bar
  late NoteProvider noteProviderVariable;

  bool _isScrollingDown = false;
  bool _showSearchBar = true;
  bool _showIcons = false;
  List<Note> _filteredNotes = []; // Filtered notes list

  @override
  void initState() {
    super.initState();
    // // Load notes when the screen initializes
    // _loadNotesAndInitialize();
    setState(() {
      noteProviderVariable = Provider.of<NoteProvider>(context, listen: false);
    });

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
    // noteProvider.filterNotesByPinned();
    return Scaffold(
      body: Padding(
        padding:
            const EdgeInsets.only(right: 20.0, left: 20, top: 50, bottom: 20),
        child: Consumer<NoteProvider>(builder: (context, noteProvider, child) {
          return Column(
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
                      color: Theme.of(context).brightness == Brightness.dark
                          ? Colors.grey[400]
                          : Colors.black,
                    ),
                  ),
                  if (_showIcons)
                    Row(
                      children: [
                        GestureDetector(
                          onTap: () {
                            noteProvider.toggleDisplayStyle();
                            setState(() {});
                            print(noteProvider.isGridView);
                          },
                          child: Icon(
                              noteProvider.isGridView
                                  ? Icons.menu
                                  : Icons.grid_view_rounded,
                              color: Theme.of(context).brightness ==
                                      Brightness.dark
                                  ? Colors.grey[400]
                                  : Colors.grey[600],
                              size: 28),
                        ),
                      ],
                    ),
                ],
              ),
              if (_showSearchBar) SizedBox(height: 20),
              if (_showSearchBar)
                Container(
                  decoration: BoxDecoration(
                    color: Theme.of(context).brightness == Brightness.dark
                        ? Color(0xFF333333)
                        : Colors.grey[300],
                    // Dark background color for the search bar
                    borderRadius: BorderRadius.circular(30),
                  ),
                  padding: const EdgeInsets.symmetric(
                      horizontal: 20.0, vertical: 10),
                  child: Row(
                    children: [
                      Icon(
                        Icons.search,
                        color: Theme.of(context).brightness == Brightness.dark
                            ? Colors.grey[500]
                            : Colors.grey,
                      ),
                      SizedBox(width: 15),
                      Expanded(
                        child: TextField(
                          controller: _searchController,
                          focusNode: _searchFocusNode,
                          style: TextStyle(
                              color: Theme.of(context).brightness ==
                                      Brightness.dark
                                  ? Colors.white
                                  : Colors.black,
                              fontSize: 19),
                          decoration: InputDecoration(
                            hintText: 'Search notes',
                            hintStyle: TextStyle(
                                color: Theme.of(context).brightness ==
                                        Brightness.dark
                                    ? Colors.grey[500]
                                    : Colors.grey),
                            border: InputBorder.none,
                          ),
                        ),
                      ),
                      SizedBox(width: 8),
                      GestureDetector(
                        onTap: () {
                          noteProvider.toggleDisplayStyle();
                          setState(() {});
                          print(noteProvider.isGridView);
                        },
                        child: Icon(
                          noteProvider.isGridView
                              ? Icons.menu
                              : Icons.grid_view_rounded,
                          color: Theme.of(context).brightness == Brightness.dark
                              ? Colors.grey[400]
                              : Colors.grey[600],
                          size: 28,
                        ),
                      ),
                      // SizedBox(width: 15),
                      // Icon(
                      //   Icons.settings,
                      //   color: Colors.grey[400],
                      //   size: 28,
                      // )
                    ],
                  ),
                ),
              SizedBox(height: 25),
              Row(
                children: [
                  CategoryContainer(
                      text: _searchController.text.isEmpty
                          ? 'All (${noteProvider.notes.length})'
                          : 'All (${_filteredNotes.length})'),
                ],
              ),
              SizedBox(height: 30),
              Expanded(
                child: _searchController.text.isEmpty
                    ? noteProvider.notes.isNotEmpty
                        ? noteProvider.isGridView
                            ? GridView.builder(
                                controller: _scrollController,
                                gridDelegate:
                                    const SliverGridDelegateWithFixedCrossAxisCount(
                                  crossAxisCount:
                                      2, // Number of columns in the grid
                                  crossAxisSpacing:
                                      10, // Horizontal space between grid items
                                  mainAxisSpacing:
                                      10, // Vertical space between grid items
                                  childAspectRatio: 4.2 /
                                      4, // Width to height ratio of each item
                                ),
                                padding: const EdgeInsets.all(0),
                                itemCount: noteProvider.notes.length,
                                itemBuilder: (context, index) {
                                  final note = noteProvider.notes[index];
                                  return GestureDetector(
                                    onLongPress: () {
                                      _searchFocusNode.unfocus();
                                      noteProvider.switchToNoteAt(note);
                                      print(
                                          'Note ${noteProvider.currentNote.title}, selected current: ${noteProvider.currentNote.isSelected}');
                                      noteProvider
                                          .updateCurrentNoteIsSelected();
                                      print(
                                          'Note ${noteProvider.currentNote.title}, selected current: ${noteProvider.currentNote.isSelected}');
                                      setState(() {});
                                      showModalBottomSheet(
                                        context: context,
                                        backgroundColor: Colors.grey[850],
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.vertical(
                                              top: Radius.circular(20)),
                                        ),
                                        builder: (context) => Container(
                                          height: 120,
                                          padding: const EdgeInsets.symmetric(
                                              vertical: 20.0, horizontal: 30.0),
                                          child: Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceEvenly,
                                            children: [
                                              GestureDetector(
                                                onTap: () {
                                                  print(
                                                      'Previous value: ${noteProvider.currentNote.isPinned}');
                                                  noteProvider
                                                      .switchToNoteAt(note);
                                                  noteProvider
                                                      .updateCurrentNoteIsPinned();
                                                  // setState(() {
                                                  //   _filteredNotes =
                                                  //       noteProvider.filterNotes(
                                                  //           noteProvider.notes);
                                                  // });
                                                  noteProvider
                                                      .filterNotesByPinned();
                                                  setState(() {});
                                                  Navigator.pop(context);
                                                  print(
                                                      'Current value: ${noteProvider.currentNote.isPinned}');
                                                },
                                                child: Column(
                                                  mainAxisSize:
                                                      MainAxisSize.min,
                                                  children: [
                                                    Icon(
                                                        Icons.push_pin_outlined,
                                                        color: Colors.white,
                                                        size: 30),
                                                    SizedBox(height: 5),
                                                    Text(
                                                        note.isPinned
                                                            ? 'Unpin'
                                                            : 'Pin',
                                                        style: TextStyle(
                                                            color: Colors.white,
                                                            fontWeight:
                                                                FontWeight.w900,
                                                            fontSize: 20)),
                                                  ],
                                                ),
                                              ),
                                              GestureDetector(
                                                onTap: () {
                                                  Navigator.pop(context);
                                                  showModalBottomSheet(
                                                    context: context,
                                                    backgroundColor:
                                                        Colors.grey[850],
                                                    shape: RoundedRectangleBorder(
                                                        borderRadius:
                                                            BorderRadius.vertical(
                                                                top: Radius
                                                                    .circular(
                                                                        20))),
                                                    builder: (context) =>
                                                        Container(
                                                      padding: const EdgeInsets
                                                          .symmetric(
                                                          vertical: 25.0,
                                                          horizontal: 30.0),
                                                      child: Column(
                                                        mainAxisSize:
                                                            MainAxisSize.min,
                                                        children: [
                                                          Text(
                                                            'Are you sure you want to delete "${noteProvider.currentNote.title}"?',
                                                            style: TextStyle(
                                                                color: Colors
                                                                    .white,
                                                                fontSize: 18,
                                                                fontWeight:
                                                                    FontWeight
                                                                        .w900),
                                                            textAlign: TextAlign
                                                                .center,
                                                          ),
                                                          SizedBox(height: 20),
                                                          Row(
                                                            mainAxisAlignment:
                                                                MainAxisAlignment
                                                                    .spaceEvenly,
                                                            children: [
                                                              ElevatedButton(
                                                                style: ElevatedButton
                                                                    .styleFrom(
                                                                        backgroundColor:
                                                                            Colors.red),
                                                                onPressed: () {
                                                                  Navigator.pop(
                                                                      context);
                                                                  noteProvider
                                                                      .deleteNoteAt(
                                                                          index);
                                                                  // setState(() {
                                                                  //   _filteredNotes =
                                                                  //       noteProvider.filterNotes(
                                                                  //           noteProvider
                                                                  //               .notes);
                                                                  // });

                                                                  print(
                                                                      'Note deleted');
                                                                },
                                                                child: Padding(
                                                                  padding:
                                                                      const EdgeInsets
                                                                          .all(
                                                                          8.0),
                                                                  child: Text(
                                                                      'Yes',
                                                                      style: TextStyle(
                                                                          color: Colors
                                                                              .white,
                                                                          fontWeight: FontWeight
                                                                              .w900,
                                                                          fontSize:
                                                                              17)),
                                                                ),
                                                              ),
                                                              ElevatedButton(
                                                                style: ElevatedButton.styleFrom(
                                                                    backgroundColor:
                                                                        Colors.grey[
                                                                            700]),
                                                                onPressed: () {
                                                                  Navigator.pop(
                                                                      context); // Close the modal
                                                                  print(
                                                                      'Deletion cancelled');
                                                                },
                                                                child: Padding(
                                                                  padding:
                                                                      const EdgeInsets
                                                                          .all(
                                                                          8.0),
                                                                  child: Text(
                                                                      'No',
                                                                      style: TextStyle(
                                                                          color: Colors
                                                                              .white,
                                                                          fontWeight: FontWeight
                                                                              .w900,
                                                                          fontSize:
                                                                              17)),
                                                                ),
                                                              ),
                                                            ],
                                                          ),
                                                        ],
                                                      ),
                                                    ),
                                                  );
                                                },
                                                child: Column(
                                                  mainAxisSize:
                                                      MainAxisSize.min,
                                                  children: [
                                                    Icon(Icons.delete_outline,
                                                        color: Colors.white,
                                                        size: 30),
                                                    SizedBox(height: 5),
                                                    Text('Delete',
                                                        style: TextStyle(
                                                            color: Colors.white,
                                                            fontWeight:
                                                                FontWeight.w900,
                                                            fontSize: 20)),
                                                  ],
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ).then((value) {
                                        noteProvider.switchToNoteAt(note);
                                        noteProvider
                                            .updateCurrentNoteIsSelected();
                                        setState(() {});
                                      });
                                    },
                                    child: NotesGridContainer(note: note),
                                    // Use the note directly, no changes to order
                                    onTap: () {
                                      _searchController
                                          .clear(); // Clear the search text
                                      _searchFocusNode
                                          .unfocus(); // Remove focus from the search bar
                                      noteProvider.switchToNoteAt(note);
                                      Navigator.of(context).push(
                                        MaterialPageRoute(
                                            builder: (context) =>
                                                NotePadScreen()),
                                      );
                                    },
                                  );
                                },
                              )
                            : ListView.builder(
                                controller: _scrollController,
                                padding: EdgeInsets.all(0),
                                itemCount: noteProvider.notes.length,
                                itemBuilder: (context, index) {
                                  final note = noteProvider.notes[
                                      index]; // Access note directly, no changes to order

                                  return Padding(
                                    padding:
                                        const EdgeInsets.only(bottom: 15.0),
                                    child: GestureDetector(
                                      onLongPress: () {
                                        _searchFocusNode.unfocus();
                                        noteProvider.switchToNoteAt(note);
                                        print(
                                            'Note ${noteProvider.currentNote.title}, selected current: ${noteProvider.currentNote.isSelected}');
                                        noteProvider
                                            .updateCurrentNoteIsSelected();
                                        print(
                                            'Note ${noteProvider.currentNote.title}, selected current: ${noteProvider.currentNote.isSelected}');
                                        setState(() {});
                                        showModalBottomSheet(
                                          context: context,
                                          backgroundColor: Colors.grey[850],
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.vertical(
                                                top: Radius.circular(20)),
                                          ),
                                          builder: (context) => Container(
                                            height: 120,
                                            padding: const EdgeInsets.symmetric(
                                                vertical: 20.0,
                                                horizontal: 30.0),
                                            child: Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.spaceEvenly,
                                              children: [
                                                GestureDetector(
                                                  onTap: () {
                                                    print(
                                                        'Previous value: ${noteProvider.currentNote.isPinned}');
                                                    noteProvider
                                                        .switchToNoteAt(note);
                                                    noteProvider
                                                        .updateCurrentNoteIsPinned();
                                                    // setState(() {
                                                    //   _filteredNotes =
                                                    //       noteProvider.filterNotes(
                                                    //           noteProvider.notes);
                                                    // });
                                                    noteProvider
                                                        .filterNotesByPinned();
                                                    setState(() {});
                                                    Navigator.pop(context);
                                                    print(
                                                        'Current value: ${noteProvider.currentNote.isPinned}');
                                                  },
                                                  child: Column(
                                                    mainAxisSize:
                                                        MainAxisSize.min,
                                                    children: [
                                                      Icon(
                                                          Icons
                                                              .push_pin_outlined,
                                                          color: Colors.white,
                                                          size: 30),
                                                      SizedBox(height: 5),
                                                      Text(
                                                          note.isPinned
                                                              ? 'Unpin'
                                                              : 'Pin',
                                                          style: TextStyle(
                                                              color:
                                                                  Colors.white,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .w900,
                                                              fontSize: 20)),
                                                    ],
                                                  ),
                                                ),
                                                GestureDetector(
                                                  onTap: () {
                                                    Navigator.pop(context);
                                                    showModalBottomSheet(
                                                      context: context,
                                                      backgroundColor:
                                                          Colors.grey[850],
                                                      shape: RoundedRectangleBorder(
                                                          borderRadius:
                                                              BorderRadius.vertical(
                                                                  top: Radius
                                                                      .circular(
                                                                          20))),
                                                      builder: (context) =>
                                                          Container(
                                                        padding:
                                                            const EdgeInsets
                                                                .symmetric(
                                                                vertical: 25.0,
                                                                horizontal:
                                                                    30.0),
                                                        child: Column(
                                                          mainAxisSize:
                                                              MainAxisSize.min,
                                                          children: [
                                                            Text(
                                                              'Are you sure you want to delete "${noteProvider.currentNote.title}"?',
                                                              style: TextStyle(
                                                                  color: Colors
                                                                      .white,
                                                                  fontSize: 18,
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .w900),
                                                              textAlign:
                                                                  TextAlign
                                                                      .center,
                                                            ),
                                                            SizedBox(
                                                                height: 20),
                                                            Row(
                                                              mainAxisAlignment:
                                                                  MainAxisAlignment
                                                                      .spaceEvenly,
                                                              children: [
                                                                ElevatedButton(
                                                                  style: ElevatedButton.styleFrom(
                                                                      backgroundColor:
                                                                          Colors
                                                                              .red),
                                                                  onPressed:
                                                                      () {
                                                                    Navigator.pop(
                                                                        context);
                                                                    noteProvider
                                                                        .deleteNoteAt(
                                                                            index);
                                                                    // setState(() {
                                                                    //   _filteredNotes =
                                                                    //       noteProvider.filterNotes(
                                                                    //           noteProvider
                                                                    //               .notes);
                                                                    // });

                                                                    print(
                                                                        'Note deleted');
                                                                  },
                                                                  child:
                                                                      Padding(
                                                                    padding:
                                                                        const EdgeInsets
                                                                            .all(
                                                                            8.0),
                                                                    child: Text(
                                                                        'Yes',
                                                                        style: TextStyle(
                                                                            color:
                                                                                Colors.white,
                                                                            fontWeight: FontWeight.w900,
                                                                            fontSize: 17)),
                                                                  ),
                                                                ),
                                                                ElevatedButton(
                                                                  style: ElevatedButton.styleFrom(
                                                                      backgroundColor:
                                                                          Colors
                                                                              .grey[700]),
                                                                  onPressed:
                                                                      () {
                                                                    Navigator.pop(
                                                                        context); // Close the modal
                                                                    print(
                                                                        'Deletion cancelled');
                                                                  },
                                                                  child:
                                                                      Padding(
                                                                    padding:
                                                                        const EdgeInsets
                                                                            .all(
                                                                            8.0),
                                                                    child: Text(
                                                                        'No',
                                                                        style: TextStyle(
                                                                            color:
                                                                                Colors.white,
                                                                            fontWeight: FontWeight.w900,
                                                                            fontSize: 17)),
                                                                  ),
                                                                ),
                                                              ],
                                                            ),
                                                          ],
                                                        ),
                                                      ),
                                                    );
                                                  },
                                                  child: Column(
                                                    mainAxisSize:
                                                        MainAxisSize.min,
                                                    children: [
                                                      Icon(Icons.delete_outline,
                                                          color: Colors.white,
                                                          size: 30),
                                                      SizedBox(height: 5),
                                                      Text('Delete',
                                                          style: TextStyle(
                                                              color:
                                                                  Colors.white,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .w900,
                                                              fontSize: 20)),
                                                    ],
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ).then((value) {
                                          noteProvider.switchToNoteAt(note);
                                          noteProvider
                                              .updateCurrentNoteIsSelected();
                                          setState(() {});
                                        });
                                      },
                                      child: NotesContainer(note: note),
                                      // Use the note directly, no changes to order
                                      onTap: () {
                                        _searchController
                                            .clear(); // Clear the search text
                                        _searchFocusNode
                                            .unfocus(); // Remove focus from the search bar
                                        noteProvider.switchToNoteAt(note);
                                        Navigator.of(context).push(
                                          MaterialPageRoute(
                                              builder: (context) =>
                                                  NotePadScreen()),
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
                                style: TextStyle(
                                    fontSize: 25, color: Colors.grey[400]),
                              ),
                            ),
                          )
                    : _filteredNotes.isNotEmpty
                        ? noteProvider.isGridView
                            ? GridView.builder(
                                controller: _scrollController,
                                gridDelegate:
                                    const SliverGridDelegateWithFixedCrossAxisCount(
                                  crossAxisCount:
                                      2, // Number of columns in the grid
                                  crossAxisSpacing:
                                      10, // Horizontal space between grid items
                                  mainAxisSpacing:
                                      10, // Vertical space between grid items
                                  childAspectRatio: 4.6 /
                                      4, // Width to height ratio of each item
                                ),
                                padding: const EdgeInsets.all(0),
                                itemCount: _filteredNotes.length,
                                itemBuilder: (context, index) {
                                  final note = _filteredNotes[index];
                                  return GestureDetector(
                                    onLongPress: () {
                                      _searchFocusNode.unfocus();
                                      noteProvider.switchToNoteAt(note);
                                      print(
                                          'Note ${noteProvider.currentNote.title}, selected current: ${noteProvider.currentNote.isSelected}');
                                      noteProvider
                                          .updateCurrentNoteIsSelected();
                                      print(
                                          'Note ${noteProvider.currentNote.title}, selected current: ${noteProvider.currentNote.isSelected}');
                                      setState(() {});
                                      showModalBottomSheet(
                                        context: context,
                                        backgroundColor: Colors.grey[850],
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.vertical(
                                              top: Radius.circular(20)),
                                        ),
                                        builder: (context) => Container(
                                          height: 120,
                                          padding: const EdgeInsets.symmetric(
                                              vertical: 20.0, horizontal: 30.0),
                                          child: Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceEvenly,
                                            children: [
                                              GestureDetector(
                                                onTap: () {
                                                  print(
                                                      'Previous value: ${noteProvider.currentNote.isPinned}');
                                                  noteProvider
                                                      .switchToNoteAt(note);
                                                  noteProvider
                                                      .updateCurrentNoteIsPinned();
                                                  // setState(() {
                                                  //   _filteredNotes =
                                                  //       noteProvider.filterNotes(
                                                  //           noteProvider.notes);
                                                  // });
                                                  noteProvider
                                                      .filterNotesByPinned();
                                                  setState(() {});
                                                  Navigator.pop(context);
                                                  print(
                                                      'Current value: ${noteProvider.currentNote.isPinned}');
                                                },
                                                child: Column(
                                                  mainAxisSize:
                                                      MainAxisSize.min,
                                                  children: [
                                                    Icon(
                                                        Icons.push_pin_outlined,
                                                        color: Colors.white,
                                                        size: 30),
                                                    SizedBox(height: 5),
                                                    Text(
                                                        note.isPinned
                                                            ? 'Unpin'
                                                            : 'Pin',
                                                        style: TextStyle(
                                                            color: Colors.white,
                                                            fontWeight:
                                                                FontWeight.w900,
                                                            fontSize: 20)),
                                                  ],
                                                ),
                                              ),
                                              GestureDetector(
                                                onTap: () {
                                                  Navigator.pop(context);
                                                  showModalBottomSheet(
                                                    context: context,
                                                    backgroundColor:
                                                        Colors.grey[850],
                                                    shape: RoundedRectangleBorder(
                                                        borderRadius:
                                                            BorderRadius.vertical(
                                                                top: Radius
                                                                    .circular(
                                                                        20))),
                                                    builder: (context) =>
                                                        Container(
                                                      padding: const EdgeInsets
                                                          .symmetric(
                                                          vertical: 25.0,
                                                          horizontal: 30.0),
                                                      child: Column(
                                                        mainAxisSize:
                                                            MainAxisSize.min,
                                                        children: [
                                                          Text(
                                                            'Are you sure you want to delete "${noteProvider.currentNote.title}"?',
                                                            style: TextStyle(
                                                                color: Colors
                                                                    .white,
                                                                fontSize: 18,
                                                                fontWeight:
                                                                    FontWeight
                                                                        .w900),
                                                            textAlign: TextAlign
                                                                .center,
                                                          ),
                                                          SizedBox(height: 20),
                                                          Row(
                                                            mainAxisAlignment:
                                                                MainAxisAlignment
                                                                    .spaceEvenly,
                                                            children: [
                                                              ElevatedButton(
                                                                style: ElevatedButton
                                                                    .styleFrom(
                                                                        backgroundColor:
                                                                            Colors.red),
                                                                onPressed: () {
                                                                  Navigator.pop(
                                                                      context);
                                                                  noteProvider
                                                                      .deleteNoteAt(
                                                                          index);
                                                                  // setState(() {
                                                                  //   _filteredNotes =
                                                                  //       noteProvider.filterNotes(
                                                                  //           noteProvider
                                                                  //               .notes);
                                                                  // });

                                                                  print(
                                                                      'Note deleted');
                                                                },
                                                                child: Padding(
                                                                  padding:
                                                                      const EdgeInsets
                                                                          .all(
                                                                          8.0),
                                                                  child: Text(
                                                                      'Yes',
                                                                      style: TextStyle(
                                                                          color: Colors
                                                                              .white,
                                                                          fontWeight: FontWeight
                                                                              .w900,
                                                                          fontSize:
                                                                              17)),
                                                                ),
                                                              ),
                                                              ElevatedButton(
                                                                style: ElevatedButton.styleFrom(
                                                                    backgroundColor:
                                                                        Colors.grey[
                                                                            700]),
                                                                onPressed: () {
                                                                  Navigator.pop(
                                                                      context); // Close the modal
                                                                  print(
                                                                      'Deletion cancelled');
                                                                },
                                                                child: Padding(
                                                                  padding:
                                                                      const EdgeInsets
                                                                          .all(
                                                                          8.0),
                                                                  child: Text(
                                                                      'No',
                                                                      style: TextStyle(
                                                                          color: Colors
                                                                              .white,
                                                                          fontWeight: FontWeight
                                                                              .w900,
                                                                          fontSize:
                                                                              17)),
                                                                ),
                                                              ),
                                                            ],
                                                          ),
                                                        ],
                                                      ),
                                                    ),
                                                  );
                                                },
                                                child: Column(
                                                  mainAxisSize:
                                                      MainAxisSize.min,
                                                  children: [
                                                    Icon(Icons.delete_outline,
                                                        color: Colors.white,
                                                        size: 30),
                                                    SizedBox(height: 5),
                                                    Text('Delete',
                                                        style: TextStyle(
                                                            color: Colors.white,
                                                            fontWeight:
                                                                FontWeight.w900,
                                                            fontSize: 20)),
                                                  ],
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ).then((value) {
                                        noteProvider.switchToNoteAt(note);
                                        noteProvider
                                            .updateCurrentNoteIsSelected();
                                        setState(() {});
                                      });
                                    },
                                    child: NotesGridContainer(note: note),
                                    // Use the note directly, no changes to order
                                    onTap: () {
                                      _searchController
                                          .clear(); // Clear the search text
                                      _searchFocusNode
                                          .unfocus(); // Remove focus from the search bar
                                      noteProvider.switchToNoteAt(note);
                                      Navigator.of(context).push(
                                        MaterialPageRoute(
                                            builder: (context) =>
                                                NotePadScreen()),
                                      );
                                    },
                                  );
                                },
                              )
                            : ListView.builder(
                                controller: _scrollController,
                                padding: EdgeInsets.all(0),
                                itemCount: _filteredNotes.length,
                                itemBuilder: (context, index) {
                                  final note = _filteredNotes[
                                      index]; // Access note directly, no changes to order

                                  return Padding(
                                    padding:
                                        const EdgeInsets.only(bottom: 15.0),
                                    child: GestureDetector(
                                      onLongPress: () {
                                        _searchFocusNode.unfocus();
                                        noteProvider.switchToNoteAt(note);
                                        print(
                                            'Note ${noteProvider.currentNote.title}, selected current: ${noteProvider.currentNote.isSelected}');
                                        noteProvider
                                            .updateCurrentNoteIsSelected();
                                        print(
                                            'Note ${noteProvider.currentNote.title}, selected current: ${noteProvider.currentNote.isSelected}');
                                        setState(() {});
                                        showModalBottomSheet(
                                          context: context,
                                          backgroundColor: Colors.grey[850],
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.vertical(
                                                top: Radius.circular(20)),
                                          ),
                                          builder: (context) => Container(
                                            height: 120,
                                            padding: const EdgeInsets.symmetric(
                                                vertical: 20.0,
                                                horizontal: 30.0),
                                            child: Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.spaceEvenly,
                                              children: [
                                                GestureDetector(
                                                  onTap: () {
                                                    print(
                                                        'Previous value: ${noteProvider.currentNote.isPinned}');
                                                    noteProvider
                                                        .switchToNoteAt(note);
                                                    noteProvider
                                                        .updateCurrentNoteIsPinned();
                                                    // setState(() {
                                                    //   _filteredNotes =
                                                    //       noteProvider.filterNotes(
                                                    //           noteProvider.notes);
                                                    // });
                                                    noteProvider
                                                        .filterNotesByPinned();
                                                    setState(() {});
                                                    Navigator.pop(context);
                                                    print(
                                                        'Current value: ${noteProvider.currentNote.isPinned}');
                                                  },
                                                  child: Column(
                                                    mainAxisSize:
                                                        MainAxisSize.min,
                                                    children: [
                                                      Icon(
                                                          Icons
                                                              .push_pin_outlined,
                                                          color: Colors.white,
                                                          size: 30),
                                                      SizedBox(height: 5),
                                                      Text(
                                                          note.isPinned
                                                              ? 'Unpin'
                                                              : 'Pin',
                                                          style: TextStyle(
                                                              color:
                                                                  Colors.white,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .w900,
                                                              fontSize: 20)),
                                                    ],
                                                  ),
                                                ),
                                                GestureDetector(
                                                  onTap: () {
                                                    Navigator.pop(context);
                                                    showModalBottomSheet(
                                                      context: context,
                                                      backgroundColor:
                                                          Colors.grey[850],
                                                      shape: RoundedRectangleBorder(
                                                          borderRadius:
                                                              BorderRadius.vertical(
                                                                  top: Radius
                                                                      .circular(
                                                                          20))),
                                                      builder: (context) =>
                                                          Container(
                                                        padding:
                                                            const EdgeInsets
                                                                .symmetric(
                                                                vertical: 25.0,
                                                                horizontal:
                                                                    30.0),
                                                        child: Column(
                                                          mainAxisSize:
                                                              MainAxisSize.min,
                                                          children: [
                                                            Text(
                                                              'Are you sure you want to delete "${noteProvider.currentNote.title}"?',
                                                              style: TextStyle(
                                                                  color: Colors
                                                                      .white,
                                                                  fontSize: 18,
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .w900),
                                                              textAlign:
                                                                  TextAlign
                                                                      .center,
                                                            ),
                                                            SizedBox(
                                                                height: 20),
                                                            Row(
                                                              mainAxisAlignment:
                                                                  MainAxisAlignment
                                                                      .spaceEvenly,
                                                              children: [
                                                                ElevatedButton(
                                                                  style: ElevatedButton.styleFrom(
                                                                      backgroundColor:
                                                                          Colors
                                                                              .red),
                                                                  onPressed:
                                                                      () {
                                                                    Navigator.pop(
                                                                        context);
                                                                    noteProvider
                                                                        .deleteNoteAt(
                                                                            index);
                                                                    // setState(() {
                                                                    //   _filteredNotes =
                                                                    //       noteProvider.filterNotes(
                                                                    //           noteProvider
                                                                    //               .notes);
                                                                    // });

                                                                    print(
                                                                        'Note deleted');
                                                                  },
                                                                  child:
                                                                      Padding(
                                                                    padding:
                                                                        const EdgeInsets
                                                                            .all(
                                                                            8.0),
                                                                    child: Text(
                                                                        'Yes',
                                                                        style: TextStyle(
                                                                            color:
                                                                                Colors.white,
                                                                            fontWeight: FontWeight.w900,
                                                                            fontSize: 17)),
                                                                  ),
                                                                ),
                                                                ElevatedButton(
                                                                  style: ElevatedButton.styleFrom(
                                                                      backgroundColor:
                                                                          Colors
                                                                              .grey[700]),
                                                                  onPressed:
                                                                      () {
                                                                    Navigator.pop(
                                                                        context); // Close the modal
                                                                    print(
                                                                        'Deletion cancelled');
                                                                  },
                                                                  child:
                                                                      Padding(
                                                                    padding:
                                                                        const EdgeInsets
                                                                            .all(
                                                                            8.0),
                                                                    child: Text(
                                                                        'No',
                                                                        style: TextStyle(
                                                                            color:
                                                                                Colors.white,
                                                                            fontWeight: FontWeight.w900,
                                                                            fontSize: 17)),
                                                                  ),
                                                                ),
                                                              ],
                                                            ),
                                                          ],
                                                        ),
                                                      ),
                                                    );
                                                  },
                                                  child: Column(
                                                    mainAxisSize:
                                                        MainAxisSize.min,
                                                    children: [
                                                      Icon(Icons.delete_outline,
                                                          color: Colors.white,
                                                          size: 30),
                                                      SizedBox(height: 5),
                                                      Text('Delete',
                                                          style: TextStyle(
                                                              color:
                                                                  Colors.white,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .w900,
                                                              fontSize: 20)),
                                                    ],
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ).then((value) {
                                          noteProvider.switchToNoteAt(note);
                                          noteProvider
                                              .updateCurrentNoteIsSelected();
                                          setState(() {});
                                        });
                                      },
                                      child: NotesContainer(note: note),
                                      // Use the note directly, no changes to order
                                      onTap: () {
                                        _searchController
                                            .clear(); // Clear the search text
                                        _searchFocusNode
                                            .unfocus(); // Remove focus from the search bar
                                        noteProvider.switchToNoteAt(note);
                                        Navigator.of(context).push(
                                          MaterialPageRoute(
                                              builder: (context) =>
                                                  NotePadScreen()),
                                        );
                                      },
                                    ),
                                  );
                                },
                              )
                        : Center(
                            child: Padding(
                              padding: const EdgeInsets.only(bottom: 70.0),
                              child: Text(
                                'No Results',
                                style: TextStyle(
                                    fontSize: 25, color: Colors.grey[400]),
                              ),
                            ),
                          ),
              ),
            ],
          );
        }),
      ),
      floatingActionButton: Padding(
          padding: const EdgeInsets.all(10.0),
          child: FloatingActionButton(
            onPressed: () {
              _searchController.clear(); // Clear search input
              _searchFocusNode.unfocus(); // Remove focus from the search bar

              // Add the new note
              noteProviderVariable.addNote();

              // Check if there are notes and switch to the latest one
              noteProviderVariable.loadNotes().then((_) {
                if (noteProviderVariable.notes.isNotEmpty) {
                  // Sort notes by date in descending order to get the latest
                  final latestNote = noteProviderVariable.notes.reduce((a, b) {
                    final dateA =
                        DateFormat("d'th' MMMM yyyy h:mm:ss a").parse(a.date);
                    final dateB =
                        DateFormat("d'th' MMMM yyyy h:mm:ss a").parse(b.date);
                    return dateA.isAfter(dateB) ? a : b;
                  });
                  noteProviderVariable.switchToNoteAt(latestNote);
                }
              });

              // Optional: Filter notes by pinned or apply any additional filtering
              noteProviderVariable.filterNotesByPinned();

              setState(() {}); // Refresh UI if necessary

              // Navigate to the NotePadScreen
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => const NotePadScreen(),
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
          )),
    );
  }
}

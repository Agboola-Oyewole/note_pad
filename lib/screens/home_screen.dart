import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:intl/intl.dart';
import 'package:note_pad/components/notes_container.dart';
import 'package:note_pad/screens/note_pad_screen.dart';
import 'package:provider/provider.dart';

import '../components/category_container.dart';
import '../data/note.dart';
import '../data/note_provider.dart';

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

  // bool _isSelectedBottom = false;
  bool _showIcons = false;
  bool _isNoteSelected = false;
  List<Note> _selectedNotes = [];
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
    return Scaffold(
      appBar: _isNoteSelected || _selectedNotes.isNotEmpty
          ? AppBar(
              surfaceTintColor: Theme.of(context).colorScheme.surface,
              backgroundColor: Theme.of(context).brightness == Brightness.dark
                  ? Color(0xffEEEEEE)
                  : Colors.grey[850],
              leading: GestureDetector(
                onTap: () {
                  final noteProvider =
                      Provider.of<NoteProvider>(context, listen: false);
                  for (var note in _selectedNotes) {
                    noteProvider.switchToNoteAt(note);
                    noteProvider.updateCurrentNoteIsSelected();
                  }
                  setState(() {
                    _isNoteSelected = false;
                    _selectedNotes = [];
                  });
                },
                child: Padding(
                  padding: const EdgeInsets.only(bottom: 12.0),
                  child: Icon(
                    Icons.close,
                    color: Theme.of(context).brightness == Brightness.dark
                        ? Colors.black
                        : Colors.white,
                    size: 30,
                  ),
                ),
              ),
              title: Padding(
                padding: const EdgeInsets.only(bottom: 12.0),
                child: Center(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Items selected (${_selectedNotes.length})',
                        style: TextStyle(
                            fontWeight: FontWeight.w900,
                            fontSize: 25,
                            color:
                                Theme.of(context).brightness == Brightness.dark
                                    ? Colors.black
                                    : Colors.white),
                      ),
                      GestureDetector(
                        onTap: () {
                          setState(() {
                            _selectedNotes = [];
                          });
                          final noteProvider =
                              Provider.of<NoteProvider>(context, listen: false);
                          if (_searchController.text.isEmpty) {
                            for (var note in noteProvider.notes) {
                              if (note.isSelected) {
                                noteProvider.switchToNoteAt(note);
                                noteProvider.updateCurrentNoteIsSelected();
                              }

                              setState(() {
                                _selectedNotes.add(note);
                              });

                              noteProvider.switchToNoteAt(note);
                              noteProvider.updateCurrentNoteIsSelected();
                            }
                            noteProvider.filterNotesByPinned();
                          } else {
                            for (var note in _filteredNotes) {
                              if (note.isSelected) {
                                noteProvider.switchToNoteAt(note);
                                noteProvider.updateCurrentNoteIsSelected();
                              }

                              setState(() {
                                _selectedNotes.add(note);
                              });

                              noteProvider.switchToNoteAt(note);
                              noteProvider.updateCurrentNoteIsSelected();
                            }
                            noteProvider.filterNotesByPinned();
                          }
                        },
                        child: Icon(
                          Icons.select_all_outlined,
                          color: Theme.of(context).brightness == Brightness.dark
                              ? Colors.black
                              : Colors.white,
                          size: 30,
                        ),
                      )
                    ],
                  ),
                ),
              ),
            )
          : null,
      body: Padding(
        padding: _isNoteSelected
            ? const EdgeInsets.only(right: 20.0, left: 20, top: 15, bottom: 20)
            : const EdgeInsets.only(right: 20.0, left: 20, top: 50, bottom: 20),
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
                      fontSize: 30,
                      color: Theme.of(context).brightness == Brightness.dark
                          ? Colors.grey[400]
                          : Colors.black,
                    ),
                  ),
                  if (_showIcons && noteProvider.notes.length >= 6)
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
              if (_showSearchBar || noteProvider.notes.length < 6)
                SizedBox(height: 20),
              if (_showSearchBar || noteProvider.notes.length < 6)
                Container(
                  decoration: BoxDecoration(
                    color: Theme.of(context).brightness == Brightness.dark
                        ? Color(0xFF333333)
                        : Colors.grey[300],
                    // Dark background color for the search bar
                    borderRadius: BorderRadius.circular(15),
                  ),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 20.0, vertical: 5),
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
                            hintText: 'Search Notes',
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
                                  childAspectRatio: 4.10 /
                                      4, // Width to height ratio of each item
                                ),
                                padding: const EdgeInsets.all(0),
                                itemCount: noteProvider.notes.length,
                                itemBuilder: (context, index) {
                                  final note = noteProvider.notes[index];
                                  return _isNoteSelected
                                      ? GestureDetector(
                                          child: NotesGridContainer(note: note),
                                          // Use the note directly, no changes to order
                                          onTap: () {
                                            _searchFocusNode.unfocus();
                                            noteProvider.switchToNoteAt(note);
                                            setState(() {
                                              _isNoteSelected = true;
                                            });
                                            if (!_selectedNotes
                                                .contains(note)) {
                                              setState(() {
                                                _selectedNotes.add(note);
                                              });
                                            } else {
                                              print(
                                                  'Duplicate note detected: ${note.title}');
                                              setState(() {
                                                _selectedNotes.remove(note);
                                                if (_selectedNotes.isEmpty) {
                                                  setState(() {
                                                    _isNoteSelected = false;
                                                  });
                                                }
                                              });
                                            }
                                            print(_selectedNotes);
                                            print(
                                                'Note ${noteProvider.currentNote.title}, selected current: ${noteProvider.currentNote.isSelected}');
                                            noteProvider
                                                .updateCurrentNoteIsSelected();
                                            print(
                                                'Note ${noteProvider.currentNote.title}, selected current: ${noteProvider.currentNote.isSelected}');
                                            setState(() {});
                                          },
                                        )
                                      : GestureDetector(
                                          onLongPress: () {
                                            _searchFocusNode.unfocus();
                                            noteProvider.switchToNoteAt(note);
                                            setState(() {
                                              _isNoteSelected = true;
                                            });
                                            if (!_selectedNotes
                                                .contains(note)) {
                                              setState(() {
                                                _selectedNotes.add(note);
                                              });
                                            } else {
                                              print(
                                                  'Duplicate note detected: ${note.title}');
                                              setState(() {
                                                _selectedNotes.remove(note);
                                                if (_selectedNotes.isEmpty) {
                                                  setState(() {
                                                    _isNoteSelected = false;
                                                  });
                                                }
                                              });
                                            }
                                            print(_selectedNotes);
                                            print(
                                                'Note ${noteProvider.currentNote.title}, selected current: ${noteProvider.currentNote.isSelected}');
                                            noteProvider
                                                .updateCurrentNoteIsSelected();
                                            print(
                                                'Note ${noteProvider.currentNote.title}, selected current: ${noteProvider.currentNote.isSelected}');
                                            setState(() {});
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
                                    child: _isNoteSelected
                                        ? GestureDetector(
                                            child: NotesContainer(note: note),
                                            // Use the note directly, no changes to order
                                            onTap: () {
                                              _searchFocusNode.unfocus();
                                              noteProvider.switchToNoteAt(note);
                                              setState(() {
                                                _isNoteSelected = true;
                                              });
                                              if (!_selectedNotes
                                                  .contains(note)) {
                                                setState(() {
                                                  _selectedNotes.add(note);
                                                });
                                              } else {
                                                print(
                                                    'Duplicate note detected: ${note.title}');
                                                setState(() {
                                                  _selectedNotes.remove(note);
                                                  if (_selectedNotes.isEmpty) {
                                                    setState(() {
                                                      _isNoteSelected = false;
                                                    });
                                                  }
                                                });
                                              }
                                              print(_selectedNotes);
                                              print(
                                                  'Note ${noteProvider.currentNote.title}, selected current: ${noteProvider.currentNote.isSelected}');
                                              noteProvider
                                                  .updateCurrentNoteIsSelected();
                                              print(
                                                  'Note ${noteProvider.currentNote.title}, selected current: ${noteProvider.currentNote.isSelected}');
                                              setState(() {});
                                            },
                                          )
                                        : GestureDetector(
                                            onLongPress: () {
                                              _searchFocusNode.unfocus();
                                              noteProvider.switchToNoteAt(note);
                                              setState(() {
                                                _isNoteSelected = true;
                                              });
                                              if (!_selectedNotes
                                                  .contains(note)) {
                                                setState(() {
                                                  _selectedNotes.add(note);
                                                });
                                              } else {
                                                print(
                                                    'Duplicate note detected: ${note.title}');
                                                setState(() {
                                                  _selectedNotes.remove(note);
                                                });
                                              }
                                              print(_selectedNotes);
                                              print(
                                                  'Note ${noteProvider.currentNote.title}, selected current: ${noteProvider.currentNote.isSelected}');
                                              noteProvider
                                                  .updateCurrentNoteIsSelected();
                                              print(
                                                  'Note ${noteProvider.currentNote.title}, selected current: ${noteProvider.currentNote.isSelected}');
                                              setState(() {});
                                              // _showUpdateModal(note);
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
                                'No Notes Available',
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
                                  childAspectRatio: 4.15 /
                                      4, // Width to height ratio of each item
                                ),
                                padding: const EdgeInsets.all(0),
                                itemCount: _filteredNotes.length,
                                itemBuilder: (context, index) {
                                  final note = _filteredNotes[index];
                                  return _isNoteSelected
                                      ? GestureDetector(
                                          child: NotesGridContainer(note: note),
                                          // Use the note directly, no changes to order
                                          onTap: () {
                                            _searchFocusNode.unfocus();
                                            noteProvider.switchToNoteAt(note);
                                            setState(() {
                                              _isNoteSelected = true;
                                            });
                                            if (!_selectedNotes
                                                .contains(note)) {
                                              setState(() {
                                                _selectedNotes.add(note);
                                              });
                                            } else {
                                              print(
                                                  'Duplicate note detected: ${note.title}');
                                              setState(() {
                                                _selectedNotes.remove(note);
                                                if (_selectedNotes.isEmpty) {
                                                  setState(() {
                                                    _isNoteSelected = false;
                                                  });
                                                }
                                              });
                                            }
                                            print(_selectedNotes);
                                            print(
                                                'Note ${noteProvider.currentNote.title}, selected current: ${noteProvider.currentNote.isSelected}');
                                            noteProvider
                                                .updateCurrentNoteIsSelected();
                                            print(
                                                'Note ${noteProvider.currentNote.title}, selected current: ${noteProvider.currentNote.isSelected}');
                                            setState(() {});
                                          },
                                        )
                                      : GestureDetector(
                                          onLongPress: () {
                                            _searchFocusNode.unfocus();
                                            noteProvider.switchToNoteAt(note);
                                            setState(() {
                                              _isNoteSelected = true;
                                            });
                                            if (!_selectedNotes
                                                .contains(note)) {
                                              setState(() {
                                                _selectedNotes.add(note);
                                              });
                                            } else {
                                              print(
                                                  'Duplicate note detected: ${note.title}');
                                              setState(() {
                                                _selectedNotes.remove(note);
                                                if (_selectedNotes.isEmpty) {
                                                  setState(() {
                                                    _isNoteSelected = false;
                                                  });
                                                }
                                              });
                                            }
                                            print(_selectedNotes);
                                            print(
                                                'Note ${noteProvider.currentNote.title}, selected current: ${noteProvider.currentNote.isSelected}');
                                            noteProvider
                                                .updateCurrentNoteIsSelected();
                                            print(
                                                'Note ${noteProvider.currentNote.title}, selected current: ${noteProvider.currentNote.isSelected}');
                                            setState(() {});
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
                                    child: _isNoteSelected
                                        ? GestureDetector(
                                            child: NotesContainer(note: note),
                                            // Use the note directly, no changes to order
                                            onTap: () {
                                              _searchFocusNode.unfocus();
                                              noteProvider.switchToNoteAt(note);
                                              setState(() {
                                                _isNoteSelected = true;
                                              });
                                              if (!_selectedNotes
                                                  .contains(note)) {
                                                setState(() {
                                                  _selectedNotes.add(note);
                                                });
                                              } else {
                                                print(
                                                    'Duplicate note detected: ${note.title}');
                                                setState(() {
                                                  _selectedNotes.remove(note);
                                                  if (_selectedNotes.isEmpty) {
                                                    setState(() {
                                                      _isNoteSelected = false;
                                                    });
                                                  }
                                                });
                                              }
                                              print(_selectedNotes);
                                              print(
                                                  'Note ${noteProvider.currentNote.title}, selected current: ${noteProvider.currentNote.isSelected}');
                                              noteProvider
                                                  .updateCurrentNoteIsSelected();
                                              print(
                                                  'Note ${noteProvider.currentNote.title}, selected current: ${noteProvider.currentNote.isSelected}');
                                              setState(() {});
                                            },
                                          )
                                        : GestureDetector(
                                            onLongPress: () {
                                              _searchFocusNode.unfocus();
                                              noteProvider.switchToNoteAt(note);
                                              setState(() {
                                                _isNoteSelected = true;
                                              });
                                              if (!_selectedNotes
                                                  .contains(note)) {
                                                setState(() {
                                                  _selectedNotes.add(note);
                                                });
                                              } else {
                                                print(
                                                    'Duplicate note detected: ${note.title}');
                                                setState(() {
                                                  _selectedNotes.remove(note);
                                                  if (_selectedNotes.isEmpty) {
                                                    setState(() {
                                                      _isNoteSelected = false;
                                                    });
                                                  }
                                                });
                                              }
                                              print(_selectedNotes);
                                              print(
                                                  'Note ${noteProvider.currentNote.title}, selected current: ${noteProvider.currentNote.isSelected}');
                                              noteProvider
                                                  .updateCurrentNoteIsSelected();
                                              print(
                                                  'Note ${noteProvider.currentNote.title}, selected current: ${noteProvider.currentNote.isSelected}');
                                              setState(() {});
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
                                'No Notes Available',
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
      bottomNavigationBar: _isNoteSelected || _selectedNotes.isNotEmpty
          ? Container(
              height: 100,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
                color: Theme.of(context).brightness == Brightness.dark
                    ? Color(0xffEEEEEE)
                    : Colors.grey[850],
              ),
              padding:
                  const EdgeInsets.symmetric(vertical: 10.0, horizontal: 20.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  GestureDetector(
                    onTap: () {
                      final noteProvider =
                          Provider.of<NoteProvider>(context, listen: false);
                      print(
                          'Previous value: ${noteProvider.currentNote.isPinned}');
                      for (var note in _selectedNotes) {
                        noteProvider.switchToNoteAt(note);
                        noteProvider.updateCurrentNoteIsPinned();
                        noteProvider.switchToNoteAt(note);
                        noteProvider.updateCurrentNoteIsSelected();
                      }
                      noteProvider.filterNotesByPinned();
                      setState(() {});
                      setState(() {
                        _isNoteSelected = false;
                        _selectedNotes = [];
                      });

                      print(
                          'Current value: ${noteProvider.currentNote.isPinned}');
                      final query = _searchController.text.toLowerCase();
                      setState(() {
                        _filteredNotes = noteProvider.notes.where((note) {
                          return note.title.toLowerCase().startsWith(query);
                        }).toList();
                      });
                    },
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.push_pin_outlined,
                            color:
                                Theme.of(context).brightness == Brightness.dark
                                    ? Colors.black
                                    : Colors.white,
                            size: 25),
                        SizedBox(height: 5),
                        Text(_selectedNotes[0].isPinned ? 'Unpin' : 'Pin',
                            style: TextStyle(
                                color: Theme.of(context).brightness ==
                                        Brightness.dark
                                    ? Colors.black
                                    : Colors.white,
                                fontWeight: FontWeight.w900,
                                fontSize: 18)),
                      ],
                    ),
                  ),
                  GestureDetector(
                    onTap: () {
                      final noteProvider =
                          Provider.of<NoteProvider>(context, listen: false);

                      showModalBottomSheet(
                        context: context,
                        backgroundColor: Colors.grey[850],
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.vertical(
                                top: Radius.circular(20))),
                        builder: (context) => Container(
                          padding: const EdgeInsets.symmetric(
                              vertical: 25.0, horizontal: 30.0),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                'Are you sure you want to delete ${_selectedNotes.length > 1 ? 'these notes' : 'this note'}?',
                                style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 18,
                                    fontWeight: FontWeight.w900),
                                textAlign: TextAlign.center,
                              ),
                              SizedBox(height: 20),
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceEvenly,
                                children: [
                                  ElevatedButton(
                                    style: ElevatedButton.styleFrom(
                                        backgroundColor: Colors.red),
                                    onPressed: () {
                                      for (var note in _selectedNotes) {
                                        noteProvider.switchToNoteAt(note);
                                        noteProvider.deleteNoteAt(note);
                                        if (noteProvider.notes.isNotEmpty) {
                                          noteProvider
                                              .updateCurrentNoteIsSelected();
                                        }
                                        if (note.isSelected) {
                                          noteProvider.switchToNoteAt(note);
                                          if (noteProvider.notes.isNotEmpty) {
                                            noteProvider
                                                .updateCurrentNoteIsSelected();
                                          }
                                        }
                                      }

                                      setState(() {});
                                      setState(() {
                                        _isNoteSelected = false;
                                        _selectedNotes = [];
                                      });
                                      Navigator.pop(context);
                                      if (noteProvider.notes.isNotEmpty) {
                                        final query = _searchController.text
                                            .toLowerCase();
                                        setState(() {
                                          _filteredNotes =
                                              noteProvider.notes.where((note) {
                                            return note.title
                                                .toLowerCase()
                                                .startsWith(query);
                                          }).toList();
                                        });
                                      }
                                      print('Note deleted');
                                    },
                                    child: Padding(
                                      padding: const EdgeInsets.all(8.0),
                                      child: Text('Yes',
                                          style: TextStyle(
                                              color: Colors.white,
                                              fontWeight: FontWeight.w900,
                                              fontSize: 17)),
                                    ),
                                  ),
                                  ElevatedButton(
                                    style: ElevatedButton.styleFrom(
                                        backgroundColor: Colors.grey[700]),
                                    onPressed: () {
                                      for (var note in _selectedNotes) {
                                        noteProvider.switchToNoteAt(note);
                                        noteProvider
                                            .updateCurrentNoteIsSelected();
                                      }
                                      Navigator.pop(context); //
                                      setState(() {
                                        _isNoteSelected = false;
                                        _selectedNotes = [];
                                      });
                                      // Close the modal
                                      print('Deletion cancelled');
                                    },
                                    child: Padding(
                                      padding: const EdgeInsets.all(8.0),
                                      child: Text('No',
                                          style: TextStyle(
                                              color: Colors.white,
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
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.delete_outline,
                            color:
                                Theme.of(context).brightness == Brightness.dark
                                    ? Colors.black
                                    : Colors.white,
                            size: 25),
                        SizedBox(height: 5),
                        Text('Delete',
                            style: TextStyle(
                                color: Theme.of(context).brightness ==
                                        Brightness.dark
                                    ? Colors.black
                                    : Colors.white,
                                fontWeight: FontWeight.w900,
                                fontSize: 18)),
                      ],
                    ),
                  ),
                ],
              ),
            )
          : null,
      floatingActionButton: !_isNoteSelected || _selectedNotes.isEmpty
          ? Padding(
              padding: const EdgeInsets.all(10.0),
              child: FloatingActionButton(
                onPressed: () {
                  _searchController.clear(); // Clear search input
                  _searchFocusNode
                      .unfocus(); // Remove focus from the search bar

                  // Add the new note
                  noteProviderVariable.addNote();

                  // Check if there are notes and switch to the latest one
                  noteProviderVariable.loadNotes().then((_) {
                    if (noteProviderVariable.notes.isNotEmpty) {
                      // Sort notes by date in descending order to get the latest
                      final latestNote =
                          noteProviderVariable.notes.reduce((a, b) {
                        final dateA = DateFormat("d'th' MMMM yyyy h:mm:ss a")
                            .parse(a.date);
                        final dateB = DateFormat("d'th' MMMM yyyy h:mm:ss a")
                            .parse(b.date);
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
              ),
            )
          : null,
    );
  }
}

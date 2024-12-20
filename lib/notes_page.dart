import 'package:flutter/material.dart';
import 'database_helper.dart';
import 'new_notes_page.dart';

class NotesPage extends StatefulWidget {
  @override
  _NotesPageState createState() => _NotesPageState();
}

class _NotesPageState extends State<NotesPage> {
  List<Map<String, dynamic>> notes = [];

  @override
  void initState() {
    super.initState();
    _loadNotes();
  }

  _loadNotes() async {
    final data = await DatabaseHelper().getNotes();
    setState(() {
      notes = data;
    });
  }

  _deleteNote(int id) async {
    await DatabaseHelper().deleteNote(id);
    _loadNotes();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Notlar"),
        backgroundColor: Colors.deepPurple,
      ),
      body: notes.isEmpty
          ? Center(child: Text('Henüz notunuz yok.'))
          : ListView.builder(
              itemCount: notes.length,
              itemBuilder: (context, index) {
                final note = notes[index];
                return ListTile(
                  title: Text(note['title']),
                  subtitle: Text(note['content']),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Düzenleme butonu
                      IconButton(
                        icon: Icon(Icons.edit),
                        onPressed: () async {
                          final updatedNote = await Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => NewNotePage(note: note),
                            ),
                          );
                          if (updatedNote != null) {
                            _loadNotes();
                          }
                        },
                      ),
                      // Silme butonu
                      IconButton(
                        icon: Icon(Icons.delete),
                        onPressed: () => _deleteNote(note['id']),
                      ),
                    ],
                  ),
                  onTap: () async {
                    final updatedNote = await Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => NewNotePage(note: note)),
                    );
                    if (updatedNote != null) {
                      _loadNotes();
                    }
                  },
                );
              },
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final newNote = await Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => NewNotePage()),
          );

          if (newNote != null) {
            _loadNotes();
          }
        },
        child: Icon(Icons.add),
        backgroundColor: Colors.deepPurple,
      ),
    );
  }
}

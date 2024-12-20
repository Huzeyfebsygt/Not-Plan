import 'package:flutter/material.dart';
import 'database_helper.dart';

class NewNotePage extends StatefulWidget {
  final Map<String, dynamic>? note;

  NewNotePage({this.note});

  @override
  _NewNotePageState createState() => _NewNotePageState();
}

class _NewNotePageState extends State<NewNotePage> {
  final _titleController = TextEditingController();
  final _contentController = TextEditingController();

  @override
  void initState() {
    super.initState();
    if (widget.note != null) {
      _titleController.text = widget.note!['title'];
      _contentController.text = widget.note!['content'];
    }
  }

  _saveNote() async {
    final note = {
      'title': _titleController.text,
      'content': _contentController.text,
    };

    if (widget.note == null) {
  
      await DatabaseHelper().insertNote(note);
    } else {
    
      note['id'] = widget.note!['id'];
      await DatabaseHelper().updateNote(note);
    }

    Navigator.pop(context, note);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.deepPurple,
        title: Text(widget.note == null ? "Yeni Not" : "Not Düzenle", style: TextStyle(color: Colors.white)),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
              controller: _titleController,
              decoration: InputDecoration(
                labelText: 'Başlık',
                labelStyle: TextStyle(color: Colors.deepPurple),
                focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.deepPurple),
                ),
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 16),
            TextField(
              controller: _contentController,
              decoration: InputDecoration(
                labelText: 'İçerik',
                labelStyle: TextStyle(color: Colors.deepPurple),
                focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.deepPurple),
                ),
                border: OutlineInputBorder(),
              ),
              maxLines: 5,
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: _saveNote,
              child: Text(widget.note == null ? 'Kaydet' : 'Güncelle'),
            ),
          ],
        ),
      ),
    );
  }
}

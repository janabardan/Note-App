import 'package:flutter/material.dart';
import '../notes.dart';

class NoteItem extends StatelessWidget {
  final String title;
  final String text;
  final String noteId;
  final Function(String) onDelete;
  final Function(String, String, String) onEdit;

  NoteItem({
    required this.title,
    required this.text,
    required this.noteId,
    required this.onDelete,
    required this.onEdit,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.symmetric(vertical: 10, horizontal: 20),
      padding: EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: Colors.pinkAccent,
        borderRadius: BorderRadius.circular(15),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
          ),
          SizedBox(height: 5),
          Text(
            text,
            style: TextStyle(
              fontSize: 16,
              color: Colors.black,
            ),
          ),
          SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              IconButton(
                icon: Icon(Icons.edit),
                onPressed: () {
                  _editNote(context);
                },
              ),
              IconButton(
                padding: EdgeInsets.only(top: 5, bottom: 3, left: 3, right: 3),
                color: Colors.blue,
                iconSize: 18,
                icon: Icon(Icons.delete),
                onPressed: () {
                  onDelete(noteId);
                },
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _editNote(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        String newTitle = title;
        String newText = text;
        return AlertDialog(
          title: Text("Edit Note"),
          content: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  initialValue: title,
                  onChanged: (value) => newTitle = value,
                  decoration: InputDecoration(labelText: 'Title'),
                ),
                TextFormField(
                  initialValue: text,
                  onChanged: (value) => newText = value,
                  maxLines: null,
                  decoration: InputDecoration(labelText: 'Text'),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                onEdit(noteId, newTitle, newText);
                Navigator.of(context).pop();
              },
              child: Text('Save'),
            ),
          ],
        );
      },
    );
  }
}

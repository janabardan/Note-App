import 'package:flutter/material.dart';
import '../notes.dart';

class ToDoItem extends StatefulWidget {
  final String? text;
  final bool check;
  final ValueChanged<bool>? onChanged;
  final String todoId;
  final Function(String) onDelete;
  final Function(String, String) onEdit;

  ToDoItem({
    Key? key,
    this.text,
    this.check = false,
    this.onChanged,
    required this.todoId,
    required this.onDelete,
    required this.onEdit,
  }) : super(key: key);

  @override
  _ToDoItemState createState() => _ToDoItemState();
}

class _ToDoItemState extends State<ToDoItem> {
  bool _isChecked = false;

  @override
  void initState() {
    super.initState();
    _isChecked = widget.check;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(bottom: 20, left: 20, right: 20),
      height: 60,
      child: ListTile(
        onTap: () {
          setState(() {
            _isChecked = !_isChecked;
            if (widget.onChanged != null) {
              widget.onChanged!(_isChecked);
            }
          });
        },
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        tileColor: Colors.pinkAccent,
        leading: Icon(
          _isChecked ? Icons.check_box : Icons.check_box_outline_blank,
          color: Colors.blue,
        ),
        title: Text(
          widget.text ?? 'Default Value',
          style: TextStyle(
            fontSize: 16,
            color: Colors.black,
            decoration: _isChecked ? TextDecoration.lineThrough : null,
          ),
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(5),
              ),
              child: IconButton(
                padding: EdgeInsets.all(5),
                color: Colors.blue,
                iconSize: 18,
                icon: Icon(Icons.edit),
                onPressed: () {
                  _editToDoItem(context);
                },
              ),
            ),
            SizedBox(width: 8),
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(5),
              ),
              child: IconButton(
                padding: EdgeInsets.only(top: 5, bottom: 3, left: 3, right: 3),
                color: Colors.blue,
                iconSize: 18,
                icon: Icon(Icons.delete),
                onPressed: () {
                  widget.onDelete(widget.todoId);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _editToDoItem(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        String newText = widget.text ?? '';
        return AlertDialog(
          title: Text("Edit To-Do Item"),
          content: TextFormField(
            initialValue: newText,
            onChanged: (value) {
              newText = value;
            },
            decoration: InputDecoration(labelText: 'New Text'),
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
                widget.onEdit(widget.todoId, newText);
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

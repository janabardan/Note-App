import 'package:flutter/material.dart';

class ToDoItem extends StatefulWidget {
  final String? text;
  final bool check;
  final ValueChanged<bool>? onChanged; // Define onChanged callback

  ToDoItem({Key? key, this.text, this.check = false, this.onChanged}) : super(key: key);

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
            if (widget.onChanged != null) { // Call onChanged callback if provided
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
          widget.text ?? 'Default Value', // Provide a default value if widget.text is null
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
                  // Add your edit logic here
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
                  // Add your delete logic here
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

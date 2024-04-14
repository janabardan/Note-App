import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'widgets/todowidget.dart';
import 'widgets/notewidget.dart';

class NoteInputForm extends StatefulWidget {
  @override
  _NoteInputFormState createState() => _NoteInputFormState();
}

class _NoteInputFormState extends State<NoteInputForm> {
  TextEditingController _textEditingController = TextEditingController();
  TextEditingController _titleEditingController = TextEditingController();
  FirebaseAuth _auth = FirebaseAuth.instance;
  FirebaseFirestore _firestore = FirebaseFirestore.instance;
  void _deleteNote(String noteId) async {
    await FirebaseFirestore.instance
        .collection('notes')
        .doc(noteId)
        .delete();
  }
  void _updateNote(String noteId, String newTitle, String newText) async {
    await FirebaseFirestore.instance
        .collection('notes')
        .doc(noteId)
        .update({
      'title': newTitle,
      'content': newText,
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.pinkAccent,
        elevation: 0,
        title: Row(
          children: [
            Container(
              height: 45,
              width: 45,
              child: ClipRRect(
                borderRadius: BorderRadius.zero,
                child: Image.asset('../assets/images.jpg'),
              ),
            ),
          ],
        ),
      ),
      body: SingleChildScrollView(
        child: Container(
          child: Column(
            children: [
              Container(
                margin: EdgeInsets.only(top: 50, bottom: 20),
                child: Text(
                  'Note List',
                  style: TextStyle(
                    fontSize: 30,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              StreamBuilder<QuerySnapshot>(
                stream: _firestore
                    .collection('notes')
                    .where('userId', isEqualTo: _auth.currentUser!.uid)
                    .snapshots(),
                builder: (context, snapshot) {
                  if (!snapshot.hasData) {
                    return CircularProgressIndicator();
                  }
                  var notes = snapshot.data!.docs;
                  List<Widget> noteWidgets = [];
                  for (var note in notes) {
                    var noteData = note.data() as Map<String, dynamic>;
                    noteWidgets.add(NoteItem(
                      title: noteData['title'],
                      text: noteData['content'],
                      noteId: note.id, // Pass the noteId
                      onDelete: _deleteNote,
                      onEdit: _updateNote,
                    ));
                  }
                  return Column(
                    children: noteWidgets,
                  );
                },
              ),


            ],
          ),
        ),
      ),
      bottomNavigationBar: Container(
        padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        color: Colors.blueAccent,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: _titleEditingController,
              style: TextStyle(color: Colors.white),
              decoration: InputDecoration(
                hintText: 'Enter Title',
                hintStyle: TextStyle(color: Colors.white54),
                border: InputBorder.none,
              ),
              onChanged: (value) {
              },
            ),
            SizedBox(height: 10),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _textEditingController,
                    style: TextStyle(color: Colors.black),
                    decoration: InputDecoration(
                      hintText: 'Add a new note Item',
                      hintStyle: TextStyle(color: Colors.white54),
                      border: InputBorder.none,
                    ),
                  ),
                ),
                SizedBox(width: 10),
                ElevatedButton(
                  onPressed: () async {
                    final currentUser = _auth.currentUser;
                    if (currentUser != null) {
                      await FirebaseFirestore.instance.collection('notes').add({
                        'userId': currentUser.uid, // Include user ID for reference
                        'title': _titleEditingController.text,
                        'content': _textEditingController.text,
                      });
                      setState(() {
                        _textEditingController.clear();
                        _titleEditingController.clear();
                      });
                    } else {
                    }
                  },
                  child: Text('+', style: TextStyle(fontSize: 40)),
                  style: ElevatedButton.styleFrom(
                    foregroundColor: Colors.black,
                    backgroundColor: Colors.pinkAccent,
                    padding: EdgeInsets.all(20),
                    shape: CircleBorder(),
                  ),
                ),

              ],
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _textEditingController.dispose();
    _titleEditingController.dispose();
    super.dispose();
  }
}

class TodoListForm extends StatefulWidget {
  @override
  _TodoListFormState createState() => _TodoListFormState();
}

class _TodoListFormState extends State<TodoListForm> {
  TextEditingController _textEditingController = TextEditingController();
  List<Map<String, dynamic>> _toDoList = [];

  @override
  void initState() {
    super.initState();
    _loadToDoList();
  }

  void _loadToDoList() async {
    final currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser != null) {
      final querySnapshot = await FirebaseFirestore.instance
          .collection('todos')
          .where('userId', isEqualTo: currentUser.uid)
          .get();
      setState(() {
        _toDoList = querySnapshot.docs.map((doc) {
          Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
          data['id'] = doc.id;
          return data;
        }).toList();
      });
    }
  }
  void _deleteToDoItem(String todoId) async {
    await FirebaseFirestore.instance
        .collection('todos')
        .doc(todoId)
        .delete();

    setState(() {
      _toDoList.removeWhere((item) => item['id'] == todoId);
    });
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.pinkAccent,
        elevation: 0,
        title: Row(
          children: [
            Container(
              height: 45,
              width: 45,
              child: ClipRRect(
                borderRadius: BorderRadius.zero,
                child: Image.asset('../assets/images.jpg'),
              ),
            ),
          ],
        ),
      ),
      body: SingleChildScrollView(
        child: Container(
          child: Column(
            children: [
              Container(
                margin: EdgeInsets.only(top: 50, bottom: 20),
                child: Text(
                  'To-do List',
                  style: TextStyle(
                    fontSize: 30,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              ListView.builder(
                shrinkWrap: true,
                itemCount: _toDoList.length,
                itemBuilder: (context, index) {
                  final todo = _toDoList[index];
                  return ToDoItem(
                    text: todo['task'] ?? '',
                    check: todo['complete'] ?? false,
                    todoId: todo['id'],
                    onChanged: (value) {
                      setState(() {
                        todo['complete'] = value;
                        _updateToDoItem(todo);
                      });
                    },
                    onDelete: _deleteToDoItem,
                    onEdit: _editToDoItem,
                  );
                },
              ),


            ],
          ),
        ),
      ),
      bottomNavigationBar: Container(
        padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        color: Colors.blueAccent,
        child: Row(
          children: [
            Expanded(
              child: TextField(
                controller: _textEditingController,
                style: TextStyle(color: Colors.black),
                decoration: InputDecoration(
                  hintText: 'Add a new To Do Item',
                  hintStyle: TextStyle(color: Colors.white54),
                  border: InputBorder.none,
                ),
              ),
            ),
            SizedBox(width: 10),
            ElevatedButton(
              onPressed: () {
                setState(() {
                  _addToDoItem({
                    'task': _textEditingController.text,
                    'complete': false,
                  });
                  _textEditingController.clear();
                });
              },
              child: Text('+', style: TextStyle(fontSize: 40)),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.pinkAccent,
                foregroundColor: Colors.black,
                padding: EdgeInsets.all(20),
                shape: CircleBorder(),
              ),
            ),
          ],
        ),
      ),
    );

  }


  void _updateToDoItem(Map<String, dynamic> todo) async {
    final currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser != null) {
      final todoId = todo['id'];
      if (todoId != null) {
        await FirebaseFirestore.instance
            .collection('todos')
            .doc(todoId)
            .update(todo);
      }
    }
  }
  void _editToDoItem(String todoId, String newText) async {
    final currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser != null) {
      final todoIndex = _toDoList.indexWhere((item) => item['id'] == todoId);
      if (todoIndex != -1) {
        await FirebaseFirestore.instance
            .collection('todos')
            .doc(todoId)
            .update({'task': newText});
        setState(() {
          _toDoList[todoIndex]['task'] = newText;
        });
      }
    }
  }

  void _addToDoItem(Map<String, dynamic> todo) async {
    final currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser != null) {
      await FirebaseFirestore.instance.collection('todos').add({
        'userId': currentUser.uid,
        'task': todo['task'],
        'complete': todo['complete'],
      }).then((value) {
        todo['id'] = value.id;
        setState(() {
          _toDoList.add(todo);
        });
      }).catchError((error) {
        print("Failed to add to-do item: $error");
      });
    }
  }
}
// void _deleteToDoItem(String todoId) async {
//   await FirebaseFirestore.instance
//       .collection('todos')
//       .doc(todoId)
//       .delete();
//   setState(() {
//     _toDoList.removeWhere((item) => item['id'] == todoId);
//   });
// }


//
// @override
//   void dispose() {
//     _textEditingController.dispose();
//     super.dispose();
//   }
// }





class NoteAndTodoApp extends StatelessWidget {
  const NoteAndTodoApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Notes App',
      theme: ThemeData(
        primarySwatch: Colors.deepOrange,
      ),
      home: DefaultTabController(
        length: 2,
        child: Center(
          child: Scaffold(
            appBar: AppBar(
              title: const Text('Note and Todo App'),
              centerTitle: true, // Center the title
              bottom: const TabBar(
                tabs: [
                  Tab(text: 'Notes'),
                  Tab(text: 'To-Do List'),
                ],
              ),
            ),
            body:  TabBarView(
              children: [
                NoteInputForm(),
                TodoListForm(),
              ],
            ),
          ),
        ),
      ),
      debugShowCheckedModeBanner: false,
    );
  }
}

void main() {
  runApp(const NoteAndTodoApp());
}

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
                child: Image.asset('../assets/images/image2.jpg'),
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
                // Handle changes to the title here
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
                      // Handle case when user is not authenticated
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
          data['id'] = doc.id; // Add 'id' field to the data
          return data;
        }).toList();
      });
    }
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
                child: Image.asset('assets/images/images.jpeg'), // Change the image path here
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
                  'To-do List', // Change the title here
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
                    onChanged: (value) {
                      setState(() {
                        todo['complete'] = value;
                        _updateToDoItem(todo);
                      });
                    },
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

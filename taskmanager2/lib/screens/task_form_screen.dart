import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart'; // Make sure Firebase is initialized
import 'dart:math';

class TaskFormScreen extends StatefulWidget {
  @override
  _TaskFormScreenState createState() => _TaskFormScreenState();
}

class _TaskFormScreenState extends State<TaskFormScreen> {
  final TextEditingController taskController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  String? taskId;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final args = ModalRoute.of(context)?.settings.arguments;
    if (args is Map && args['title'] != null) {
      taskController.text = args['title'];
      taskId = args['id'];
    } else if (args is String) {
      taskController.text = args;
    }
  }

  void _saveTask() async {
    if (_formKey.currentState!.validate()) {
      String taskName = taskController.text.trim();
      if (taskId != null) {
        // Update existing task
        await FirebaseFirestore.instance.collection('tasks').doc(taskId).update({
          'title': taskName,
          'updatedAt': DateTime.now(),
        });
        Navigator.pop(context, {
          'id': taskId,
          'title': taskName,
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Task updated!')),
        );
      } else {
        // Add new task
        final doc = await FirebaseFirestore.instance.collection('tasks').add({
          'index': Random().nextInt(10000),
          'title': taskName,
          'status': 'pending',
          'createdAt': DateTime.now(),
          'updatedAt': DateTime.now(),
        });
        Navigator.pop(context, {
          'id': doc.id,
          'title': taskName,
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Task saved!')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Add/Edit Task'),
        centerTitle: true,
        backgroundColor: Colors.blue,
      ),
      body: Center(
        child: Container(
          padding: EdgeInsets.all(24),
          width: 350,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.2),
                spreadRadius: 5,
                blurRadius: 7,
                offset: Offset(0, 3),
              ),
            ],
          ),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  controller: taskController,
                  decoration: InputDecoration(
                    labelText: 'Task',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Please enter a task';
                    }
                    return null;
                  },
                ),
                SizedBox(height: 20),
                ElevatedButton(
                  onPressed: _saveTask,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    padding: EdgeInsets.symmetric(horizontal: 40, vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
               child: Text(
                      'Save Task',
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.white, // Set the text color here
                      ),
                    ),
                ),
              ],
            ),
          ),
        ),
      ),
      backgroundColor: Colors.grey[200],
    );
  }
}

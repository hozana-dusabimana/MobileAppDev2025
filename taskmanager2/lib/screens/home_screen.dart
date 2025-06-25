import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<Map<String, dynamic>> tasks = [];
  Set<int> completedTaskIndices = {};

  @override
  void initState() {
    super.initState();
    viewTask();
  }

  void viewTask() async {
    try {
      final query = await FirebaseFirestore.instance.collection('tasks').get();
      if (query.docs.isNotEmpty) {
        final fetchedTasks = query.docs.map((doc) {
          final data = doc.data();
          data['id'] = doc.id;
          return data;
        }).toList();

        setState(() {
          tasks = fetchedTasks;
          completedTaskIndices = {
            for (int i = 0; i < tasks.length; i++)
              if (tasks[i]['status'] == 'canceled') i
          };
        });
      }
    } catch (e) {
      print('Error fetching tasks: $e');
    }
  }

  void _navigateToTaskForm({int? index}) async {
    final existingTask = index != null ? tasks[index] : null;

    final result = await Navigator.pushNamed(
      context,
      '/task-form',
      arguments: existingTask,
    );

    if (result != null && result is Map<String, dynamic>) {
      setState(() {
        if (index != null) {
          tasks[index] = result;
        } else {
          tasks.add(result);
        }
      });
    }
  }

  void _toggleTaskCompletion(int index) async {
    final taskId = tasks[index]['id'];
    final isCompleted = completedTaskIndices.contains(index);

    setState(() {
      if (isCompleted) {
        completedTaskIndices.remove(index);
      } else {
        completedTaskIndices.add(index);
      }
    });

    try {
      await FirebaseFirestore.instance.collection('tasks').doc(taskId).update({
        'status': isCompleted ? 'pending' : 'canceled',
        'updatedAt': DateTime.now(),
      });
    } catch (e) {
      print('Error updating task: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('My Tasks'),
        centerTitle: true,
        backgroundColor: Colors.blue,
        actions: [
          IconButton(
            icon: Icon(Icons.help_outline),
            onPressed: () {
              showDialog(
                context: context,
                builder: (context) => AlertDialog(
                  title: Text('Help'),
                  content: Text(
                    'Tap the checkbox to mark a task as done.\n'
                    'Tap the task to edit it.\n'
                    'Use the + button to add a new one.',
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.of(context).pop(),
                      child: Text('OK'),
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
      body: tasks.isEmpty
          ? Center(child: CircularProgressIndicator())
          : ListView.builder(
              itemCount: tasks.length,
              itemBuilder: (context, index) {
                final task = tasks[index];
                final taskTitle = task['title'] ?? 'Untitled';
                final isCompleted = completedTaskIndices.contains(index);

                return Card(
                  margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  elevation: 3,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: ListTile(
                    leading: IconButton(
                      icon: Icon(
                        isCompleted
                            ? Icons.check_box
                            : Icons.check_box_outline_blank,
                        color: isCompleted ? Colors.green : Colors.grey,
                      ),
                      onPressed: () => _toggleTaskCompletion(index),
                    ),
                    title: Text(
                      taskTitle,
                      style: TextStyle(
                        decoration: isCompleted
                            ? TextDecoration.lineThrough
                            : TextDecoration.none,
                        color: isCompleted ? Colors.grey : Colors.black,
                      ),
                    ),
                    trailing: Icon(Icons.edit, color: Colors.blue),
                    onTap: () => _navigateToTaskForm(index: index),
                  ),
                );
              },
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _navigateToTaskForm(),
        backgroundColor: Colors.blue,
        child: Icon(Icons.add),
        tooltip: 'Add New Task',
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
      backgroundColor: Colors.grey[200],
    );
  }
}

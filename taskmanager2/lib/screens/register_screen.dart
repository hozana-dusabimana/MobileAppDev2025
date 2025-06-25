import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart'; // Make sure Firebase is initialized


class RegisterScreen extends StatelessWidget {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController telController = TextEditingController();
  final TextEditingController genderController = TextEditingController();
  final TextEditingController departmentController = TextEditingController();
  final TextEditingController classController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();


Future<void> register(BuildContext context) async {
  final email = emailController.text.trim();
  final tel = telController.text.trim();
  final gender = genderController.text.trim();
  final department = departmentController.text.trim();
  final studentClass = classController.text.trim(); // "class" is a reserved word
  final password = passwordController.text.trim();

  if (email.isEmpty || tel.isEmpty || gender.isEmpty || department.isEmpty || studentClass.isEmpty || password.isEmpty) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Please fill all fields')),
    );
  } else {
    try {
      await FirebaseFirestore.instance.collection('users').add({
        'email': email,
        'tel': tel,
        'gender': gender,
        'department': department,
        'class': studentClass,
        'password': password, // In production, **never store plain passwords!**
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Registration successful')),
      );
      Navigator.pushReplacementNamed(context, '/login');
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: ${e.toString()}')),
      );
    }
  }
}


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Register'),
        centerTitle: true,
        backgroundColor: Colors.blue,
        actions: [
          IconButton(
            icon: Icon(Icons.more_vert),
            onPressed: () {
              // Show help dialog
              showDialog(
                context: context,
                builder: (context) => AlertDialog(
                  title: Text('Help'),
                  content: Text('Please Enter your valid credentials.'),
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
      backgroundColor: Colors.grey[200],
      body: Center(
        child: SingleChildScrollView(
          child: Container(
            width: 350,
            padding: EdgeInsets.all(24),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.zero,
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black26,
                  blurRadius: 10,
                  offset: Offset(0, 5),
                ),
              ],
            ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: emailController,
                decoration: InputDecoration(labelText: 'Email'),
              ),
               TextField(
                controller: telController,
                decoration: InputDecoration(labelText: 'Tel'),
              ),
               TextField(
                controller: genderController,
                decoration: InputDecoration(labelText: 'Gender'),
              ),
               TextField(
                controller: departmentController,
                decoration: InputDecoration(labelText: 'Department'),
              ),
               TextField(
                controller: classController,
                decoration: InputDecoration(labelText: 'Class'),
              ),
            TextField(
                controller: passwordController,
                decoration: InputDecoration(labelText: 'Password'),
                obscureText: true),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () => register(context),
              child: Text('Register'),
            ),
          ],
        ),
          )
       )
       
      ),
    );
  }
}

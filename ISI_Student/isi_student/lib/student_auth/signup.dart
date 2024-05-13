import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart' as firebase_storage;
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:isi_student/student_auth/subscribeCategories.dart';

class SignUp extends StatefulWidget {
  const SignUp({Key? key}) : super(key: key);

  @override
  _SignUpState createState() => _SignUpState();
}

class _SignUpState extends State<SignUp> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _isSigningUp = false;
  File? _selectedImage;

  Future<void> _selectImage() async {
    final pickedFile =
        await ImagePicker().getImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _selectedImage = File(pickedFile.path);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Sign Up"),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 15),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              "Sign Up",
              style: TextStyle(fontSize: 27, fontWeight: FontWeight.bold),
            ),
            const SizedBox(
              height: 30,
            ),
            GestureDetector(
              onTap: _selectImage,
              child: CircleAvatar(
                radius: 50,
                backgroundColor: Colors.grey,
                backgroundImage:
                    _selectedImage != null ? FileImage(_selectedImage!) : null,
                child: _selectedImage == null
                    ? const Icon(Icons.camera_alt, size: 50)
                    : null,
              ),
            ),
            const SizedBox(height: 20),
            TextField(
              controller: _usernameController,
              decoration: const InputDecoration(labelText: 'Username'),
            ),
            TextField(
              controller: _emailController,
              decoration: const InputDecoration(labelText: 'Email'),
            ),
            TextField(
              controller: _passwordController,
              decoration: const InputDecoration(labelText: 'Password'),
              obscureText: true,
            ),
            const SizedBox(height: 20),
            GestureDetector(
              onTap: _signUp,
              child: Container(
                width: double.infinity,
                height: 45,
                decoration: BoxDecoration(
                  color: const Color(0xFF80A4FF),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Center(
                  child: _isSigningUp
                      ? const CircularProgressIndicator(
                          color: Colors.white,
                        )
                      : const Text(
                          "Continue",
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _signUp() async {
    setState(() {
      _isSigningUp = true;
    });

    String username = _usernameController.text.trim();
    String email = _emailController.text.trim();
    String password = _passwordController.text.trim();

    try {
      // Upload image to Firebase Storage
      String imageUrl = '';
      if (_selectedImage != null) {
        final storageRef = firebase_storage.FirebaseStorage.instance
            .ref()
            .child('profile_images')
            .child(username);
        await storageRef.putFile(_selectedImage!);
        imageUrl = await storageRef.getDownloadURL();
      }

      // Store user data in Firestore
      DocumentReference newUserRef =
          await _firestore.collection('students').add({
        'username': username,
        'email': email,
        'password': password,
        'categories': [], // Initially empty categories array
        'profileImage': imageUrl, // Add the image URL to the user data
      });

      // Navigate to subscription page to select categories
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
            builder: (context) => SubscriptionPage(userRef: newUserRef)),
      );
    } catch (e) {
      // Handle sign-up errors
      print("Error signing up: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error signing up: $e'),
        ),
      );
    } finally {
      setState(() {
        _isSigningUp = false;
      });
    }
  }
}

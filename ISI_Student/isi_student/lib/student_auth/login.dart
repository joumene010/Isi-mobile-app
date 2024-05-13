import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:isi_student/student_auth/signup.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Login extends StatefulWidget {
  const Login({Key? key}) : super(key: key);

  @override
  _LoginState createState() => _LoginState();
}

class _LoginState extends State<Login> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _isSigning = false;

  final FirebaseFirestore _firestore =
      FirebaseFirestore.instance; // Add this line

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Login"),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 15),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              "Login",
              style: TextStyle(fontSize: 27, fontWeight: FontWeight.bold),
            ),
            const SizedBox(
              height: 30,
            ),
            TextFormField(
              controller: _emailController,
              decoration: const InputDecoration(labelText: 'Email'),
            ),
            const SizedBox(
              height: 10,
            ),
            TextFormField(
              controller: _passwordController,
              decoration: const InputDecoration(labelText: 'Password'),
              obscureText: true,
            ),
            const SizedBox(
              height: 30,
            ),
            GestureDetector(
              onTap: () {
                _signIn();
              },
              child: Container(
                width: double.infinity,
                height: 45,
                decoration: BoxDecoration(
                  color: const Color(0xFF80A4FF),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Center(
                  child: _isSigning
                      ? const CircularProgressIndicator(
                          color: Colors.white,
                        )
                      : const Text(
                          "Login",
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                ),
              ),
            ),
            const SizedBox(
              height: 20,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text("Don't have an account?"),
                const SizedBox(
                  width: 5,
                ),
                GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const SignUp()),
                    );
                  },
                  child: const Text(
                    "Sign Up",
                    style: TextStyle(
                      color:  const Color(0xFF80A4FF),
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _signIn() async {
    setState(() {
      _isSigning = true;
    });

    String email = _emailController.text.trim();
    String password = _passwordController.text.trim();

    try {
      QuerySnapshot<Map<String, dynamic>> querySnapshot = await _firestore
          .collection('students')
          .where('email', isEqualTo: email)
          .get();

      if (querySnapshot.docs.isNotEmpty) {
        var userData = querySnapshot.docs.first.data();
        String storedPassword = userData['password'];
        if (password == storedPassword) {
          // Save credentials including the profile image URL
          await saveCredentials(
              email, userData['username'], userData['profileImage'] ?? '');
          Navigator.pushReplacementNamed(context, '/home');
        } else {
          // Incorrect password
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Incorrect password'),
            ),
          );
        }
      } else {
        // User not found
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('User not found'),
          ),
        );
      }
    } catch (e) {
      // Handle login errors
      print("Error logging in: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error logging in: $e'),
        ),
      );
    } finally {
      setState(() {
        _isSigning = false;
      });
    }
  }

  Future<void> saveCredentials(
      String email, String username, String profileImageUrl) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setString('email', email);
    prefs.setString('username', username);
    prefs.setString(
        'profileImage', profileImageUrl); // Save the profile image URL
  }
}

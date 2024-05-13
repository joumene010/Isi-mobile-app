import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:isi_admin/admin_auth/firebase_auth_implementation/firebase_auth_services.dart';
import 'package:isi_admin/admin_auth/pages/login.dart';
import 'package:isi_admin/admin_auth/widgets/form_container_widget.dart';
import 'package:isi_admin/global/toast.dart';
import 'package:firebase_storage/firebase_storage.dart' as firebase_storage;
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:image_cropper/image_cropper.dart';

class SignUp extends StatefulWidget {
  const SignUp({super.key});

  @override
  State<SignUp> createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUp> {
  final FirebaseAuthService _auth = FirebaseAuthService();

  TextEditingController _usernameController = TextEditingController();
  TextEditingController _emailController = TextEditingController();
  TextEditingController _passwordController = TextEditingController();

  bool isSigningUp = false;
  File? _imageFile;
  final ImagePicker _picker = ImagePicker();

  Future<void> _pickImage() async {
    final XFile? pickedFile =
        await _picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      // Crop the image
      File? croppedFile = await ImageCropper().cropImage(
        sourcePath: pickedFile.path,
        aspectRatioPresets: [
          CropAspectRatioPreset.square, // Use square aspect ratio
        ],
        androidUiSettings: AndroidUiSettings(
          toolbarTitle: 'Crop your image',
          toolbarColor: Color(0xFF7553F6),
          toolbarWidgetColor: Colors.white,
          initAspectRatio: CropAspectRatioPreset.original,
          lockAspectRatio: true,
        ),
        iosUiSettings: IOSUiSettings(
          minimumAspectRatio: 1.0,
        ),
      );

      if (croppedFile != null) {
        setState(() {
          _imageFile = croppedFile;
        });
      }
    }
  }

  @override
  void dispose() {
    _usernameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: Text("Welcome to Sign Up Page"),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 15),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                "Sign Up",
                style: TextStyle(fontSize: 27, fontWeight: FontWeight.bold),
              ),
              SizedBox(
                height: 30,
              ),
              FormContainerWidget(
                controller: _usernameController,
                hintText: "Username",
                isPasswordField: false,
              ),
              SizedBox(
                height: 10,
              ),
              FormContainerWidget(
                controller: _emailController,
                hintText: "Email",
                isPasswordField: false,
              ),
              SizedBox(
                height: 10,
              ),
              FormContainerWidget(
                controller: _passwordController,
                hintText: "Password",
                isPasswordField: true,
              ),
              SizedBox(
                height: 30,
              ),
              GestureDetector(
                onTap: () {
                  _signUp();
                },
                child: Container(
                  width: double.infinity,
                  height: 45,
                  decoration: BoxDecoration(
                    color: Color(0xFF7553F6),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Center(
                      child: isSigningUp
                          ? CircularProgressIndicator(
                              color: Colors.white,
                            )
                          : Text(
                              "Sign Up",
                              style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold),
                            )),
                ),
              ),
              SizedBox(
                height: 30,
              ),
              // Insert the image picker here
              GestureDetector(
                onTap: _pickImage,
                child: CircleAvatar(
                  radius: 55,
                  backgroundColor: Color(0xFF7553F6),
                  backgroundImage:
                      _imageFile != null ? FileImage(_imageFile!) : null,
                  child: _imageFile == null
                      ? Icon(Icons.add_a_photo, color: Colors.white, size: 50)
                      : null,
                ),
              ),
              SizedBox(
                height: 20,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text("Already have an account?"),
                  SizedBox(
                    width: 5,
                  ),
                  GestureDetector(
                      onTap: () {
                        Navigator.pushAndRemoveUntil(
                            context,
                            MaterialPageRoute(builder: (context) => Login()),
                            (route) => false);
                      },
                      child: Text(
                        "Login",
                        style: TextStyle(
                            color: Color(0xFF7553F6),
                            fontWeight: FontWeight.bold),
                      ))
                ],
              )
            ],
          ),
        ),
      ),
    );
  }

  void _signUp() async {
    setState(() {
      isSigningUp = true;
    });

    String username = _usernameController.text.trim();
    String email = _emailController.text.trim();
    String password = _passwordController.text.trim();

    try {
      User? user = await _auth.signUpWithEmailAndPassword(email, password);

      if (user != null) {
        // Upload image to Firebase Storage
        String? imageUrl;
        if (_imageFile != null) {
          final ref = firebase_storage.FirebaseStorage.instance
              .ref()
              .child('user_images')
              .child(user.uid + '.jpg');
          await ref.putFile(_imageFile!);
          imageUrl = await ref.getDownloadURL();
        }

        // Update user profile
        await user.updateDisplayName(username);
        await user.updatePhotoURL(imageUrl);

        showToast(message: "User successfully created");
        Navigator.pushNamed(context, "/");
      }
    } catch (e) {
      showToast(message: "Error occurred: $e");
    } finally {
      setState(() {
        isSigningUp = false;
      });
    }
  }
}

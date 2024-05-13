import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart' as firebase_storage;
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:path/path.dart';

class PostsPage extends StatefulWidget {
  @override
  _PostsPageState createState() => _PostsPageState();
}

class _PostsPageState extends State<PostsPage> {
  late TextEditingController _searchController;
  late Stream<QuerySnapshot> _PostStream;

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController();
    _PostStream = FirebaseFirestore.instance.collection("posts").snapshots();
  }

  void _showPostDetailsDialog(BuildContext context, String title,
      String description, String imageUrl, List<dynamic> categories) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(title),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                imageUrl.isNotEmpty
                    ? Image.network(imageUrl, fit: BoxFit.cover)
                    : Text('No image available'),
                SizedBox(height: 10),
                Text('Description: $description'),
                SizedBox(height: 10),
                Text('Categories: ${categories.join(', ')}'),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: Text('Close'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        automaticallyImplyLeading: false,
        title: TextField(
          controller: _searchController,
          decoration: InputDecoration(
            icon: Icon(Icons.search),
            hintText: 'Search...',
            border: InputBorder.none,
          ),
          onChanged: _onSearchTextChanged,
        ),
        actions: <Widget>[
          IconButton(
            icon: Icon(Icons.clear),
            onPressed: () {
              _searchController.clear();
              _onSearchTextChanged('');
            },
          ),
        ],
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: _PostStream,
        builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
          if (snapshot.hasError) {
            return Center(
              child: Text('Error: ${snapshot.error}'),
            );
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(
              child: CircularProgressIndicator(),
            );
          }

          User? user = FirebaseAuth.instance.currentUser;

          if (user == null) {
            // Handle the case where the user is not authenticated
            return Center(
              child: Text('User not authenticated'),
            );
          }

          List<DocumentSnapshot> Post = snapshot.data!.docs;

          return ListView.builder(
            itemCount: Post.length,
            itemBuilder: (BuildContext context, int index) {
              var post = Post[index];
              Map<String, dynamic>? postData =
                  post.data() as Map<String, dynamic>?;
              String title = postData != null && postData.containsKey('title')
                  ? postData['title']
                  : 'No Title';
              String description =
                  postData != null && postData.containsKey('description')
                      ? postData['description']
                      : 'No Description';
              List<dynamic> categories =
                  postData != null && postData.containsKey('categories')
                      ? postData['categories']
                      : [];
              String imageUrl =
                  postData != null && postData.containsKey('image')
                      ? postData['image']
                      : '';

              return GestureDetector(
                onTap: () => _showPostDetailsDialog(
                    context, title, description, imageUrl, categories),
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: Card(
                    elevation: 2,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10.0),
                    ),
                    child: ListTile(
                      leading: Icon(Icons.text_snippet),
                      title: Text(title),
                      trailing: IconButton(
                        icon: Icon(Icons.delete,
                            color: const Color.fromARGB(255, 54, 244, 228)),
                        onPressed: () =>
                            _showDeleteConfirmationDialog(context, post),
                      ),
                    ),
                  ),
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          _showAddPostDialog(context);
        },
        child: Icon(Icons.add),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      bottomNavigationBar: BottomAppBar(),
    );
  }

  void _onSearchTextChanged(String text) {
    setState(() {
      _PostStream = FirebaseFirestore.instance
          .collection("posts")
          .where('title', isGreaterThanOrEqualTo: text)
          .where('title', isLessThan: text + 'z')
          .snapshots();
    });
  }

  void _showAddPostDialog(BuildContext context) {
    TextEditingController _titleController = TextEditingController();
    TextEditingController _descriptionController = TextEditingController();
    List<String> _selectedCategories = [];
    List<String> _categories = [];
    File? _image;
    final ImagePicker _picker = ImagePicker();

   /* Future pickImage() async {
      final pickedFile = await _picker.pickImage(source: ImageSource.gallery);
      if (pickedFile != null) {
        _image = File(pickedFile.path);
      }
    }
*/


Future<void> pickImage() async {
  final picker = ImagePicker();
      final pickedFile = await picker.pickImage(source: ImageSource.gallery);
      if (pickedFile != null) {
        setState(() {
          _image = File(pickedFile.path);
        });
        print(_image);
      }
}

    Future<String?> uploadImage(File image) async {
      try {
        String fileName = basename(image.path);
        firebase_storage.Reference ref = firebase_storage
            .FirebaseStorage.instance
            .ref()
            .child('post_images').child(fileName.toString());
        firebase_storage.UploadTask task = ref.putFile(image);
        return await (await task).ref.getDownloadURL();
      } catch (e) {
        print("Failed to upload image: $e");
        return null;
      }
    }

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setState) {
            return AlertDialog(
              title: Text('Add post'),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    TextField(
                      controller: _titleController,
                      decoration: InputDecoration(labelText: 'Post Title'),
                    ),
                    SizedBox(height: 16),
                    TextField(
                      controller: _descriptionController,
                      decoration:
                          InputDecoration(labelText: 'Post Description'),
                      maxLines: 5,
                    ),
                    SizedBox(height: 16),
                    StreamBuilder<QuerySnapshot>(
                      stream: FirebaseFirestore.instance
                          .collection("categories")
                          .snapshots(),
                      builder: (BuildContext context,
                          AsyncSnapshot<QuerySnapshot> snapshot) {
                        if (snapshot.hasError || !snapshot.hasData) {
                          return Text('Error loading categories');
                        }

                        // Extract category names from snapshot
                        _categories.clear();
                        for (DocumentSnapshot doc in snapshot.data!.docs) {
                          _categories.add(doc['name']);
                        }

                        return DropdownButtonFormField<String>(
                          value: null,
                          hint: Text('Select category'),
                          items: _categories.map((String category) {
                            return DropdownMenuItem<String>(
                              value: category,
                              child: Text(category),
                            );
                          }).toList(),
                          onChanged: (String? value) {
                            setState(() {
                              if (value != null) {
                                _selectedCategories
                                    .add(value); // Add selected category
                              }
                            });
                          },
                        );
                      },
                    ),
                    SizedBox(height: 16),
                    _image!= null ? CircleAvatar(
                      backgroundImage: FileImage(_image!),
                    ): 
                    ElevatedButton(
                      onPressed: () => pickImage(),
                      child: Text('Pick Image'),
                    ),
                    // Add StreamBuilder for categories if needed here
                  ],
                ),
              ),
              actions: <Widget>[
                TextButton(
                  child: Text('Cancel'),
                  onPressed: () => Navigator.of(context).pop(),
                ),
                TextButton(
                  child: Text('Add'),
                  onPressed: () async {
                    if (_image != null) {
                      String? imageUrl = await uploadImage(_image!);
                      if (imageUrl != null) {
                        String title = _titleController.text.trim();
                        String description = _descriptionController.text.trim();
                        FirebaseFirestore.instance.collection('posts').add({
                          'title': title,
                          'description': description,
                          'categories': _selectedCategories,
                          'image': imageUrl,
                        }).then((value) => Navigator.of(context).pop());
                      }
                    } else {
                      print('No image selected');
                    }
                  },
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _showDeleteConfirmationDialog(
      BuildContext context, DocumentSnapshot post) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Confirm Delete'),
          content: Text('Are you sure you want to delete ${post['title']}?'),
          actions: <Widget>[
            TextButton(
              child: Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: Text('Delete'),
              onPressed: () {
                _deletepost(context, post);
              },
            ),
          ],
        );
      },
    );
  }

  void _deletepost(BuildContext context, DocumentSnapshot post) {
    FirebaseFirestore.instance
        .collection("posts")
        .doc(post.id)
        .delete()
        .then((value) {
      Navigator.of(context).pop(); // Close the dialog
    }).catchError((error) {
      print("Error deleting post: $error");
    });
  }
}

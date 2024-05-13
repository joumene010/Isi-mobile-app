import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class CategoriesPage extends StatefulWidget {
  @override
  _CategoriesPageState createState() => _CategoriesPageState();
}

class _CategoriesPageState extends State<CategoriesPage> {
  late TextEditingController _searchController;
  late Stream<QuerySnapshot> _categoriesStream;

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController();
    _categoriesStream =
        FirebaseFirestore.instance.collection("categories").snapshots();
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
        stream: _categoriesStream,
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

          List<DocumentSnapshot> categories = snapshot.data!.docs;

          return ListView.builder(
            itemCount: categories.length,
            itemBuilder: (BuildContext context, int index) {
              var category = categories[index];
              // Check if the category belongs to the current user

              return Padding(
                padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Card(
                  elevation: 2,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10.0),
                  ),
                  child: ListTile(
                    leading:
                        Icon(Icons.school), // Add icon before category name
                    title: Text(
                      category['name'],
                      style: TextStyle(
                        fontSize: 18,
                      ),
                    ),
                    trailing: IconButton(
                      icon: Icon(
                        Icons.delete,
                        color: Color.fromARGB(255, 143, 177, 194),
                      ),
                      onPressed: () {
                        _showDeleteConfirmationDialog(context, category);
                      },
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
          _showAddCategoryDialog(context);
        },
        child: Icon(Icons.add),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      bottomNavigationBar: BottomAppBar(),
    );
  }

  void _onSearchTextChanged(String text) {
    setState(() {
      _categoriesStream = FirebaseFirestore.instance
          .collection("categories")
          .where('name', isGreaterThanOrEqualTo: text)
          .where('name', isLessThan: text + 'z')
          .snapshots();
    });
  }

  void _showAddCategoryDialog(BuildContext context) {
    TextEditingController _categoryNameController = TextEditingController();

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Add Category'),
          content: TextField(
            controller: _categoryNameController,
            decoration: InputDecoration(labelText: 'Category Name'),
          ),
          actions: <Widget>[
            TextButton(
              child: Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: Text('Add'),
              onPressed: () {
                // Add logic to add category to Firestore
                String categoryName = _categoryNameController.text;
                if (categoryName.isNotEmpty) {
                  // Add category to Firestore
                  FirebaseFirestore.instance.collection('categories').add({
                    'name': categoryName,
                    // Add other fields if needed
                  }).then((value) {
                    // Category added successfully
                    Navigator.of(context).pop(); // Close the dialog
                  }).catchError((error) {
                    // Error adding category
                    print("Error adding category: $error");
                    // You can show a snackbar or error message here
                  });
                }
              },
            ),
          ],
        );
      },
    );
  }

  void _showDeleteConfirmationDialog(
      BuildContext context, DocumentSnapshot category) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Confirm Delete'),
          content: Text('Are you sure you want to delete ${category['name']}?'),
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
                _deleteCategory(context, category);
              },
            ),
          ],
        );
      },
    );
  }

  void _deleteCategory(BuildContext context, DocumentSnapshot category) {
    FirebaseFirestore.instance
        .collection("categories")
        .doc(category.id)
        .delete()
        .then((value) {
      // Category deleted successfully
      Navigator.of(context).pop(); // Close the dialog
    }).catchError((error) {
      // Error deleting category
      print("Error deleting category: $error");
      // You can show a snackbar or error message here
    });
  }
}

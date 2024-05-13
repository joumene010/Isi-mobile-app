import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class SubscriptionPage extends StatefulWidget {
  final DocumentReference userRef;

  const SubscriptionPage({Key? key, required this.userRef}) : super(key: key);

  @override
  _SubscriptionPageState createState() => _SubscriptionPageState();
}

class _SubscriptionPageState extends State<SubscriptionPage> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  List<String> _selectedCategories = [];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Select Categories"),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: _firestore.collection('categories').snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }

          List<DocumentSnapshot> documents = snapshot.data!.docs;
          return ListView.builder(
            itemCount: documents.length,
            itemBuilder: (context, index) {
              String category = documents[index]['name'];
              bool isSelected = _selectedCategories.contains(category);

              return ListTile(
                title: Text(category),
                trailing: isSelected ? Icon(Icons.check) : null,
                onTap: () {
                  setState(() {
                    if (isSelected) {
                      _selectedCategories.remove(category);
                    } else {
                      _selectedCategories.add(category);
                    }
                  });
                },
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          _saveCategories();
        },
        label: Text('Subscribe'),
        icon: Icon(Icons.check),
      ),
    );
  }

  Future<void> _saveCategories() async {
    try {
      // Update the categories field in the user document
      await widget.userRef.update({'categories': _selectedCategories});

      Navigator.pushReplacementNamed(context, '/login');
    } catch (e) {
      // Handle error
      print("Error saving categories: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error saving categories: $e'),
        ),
      );
    }
  }
}

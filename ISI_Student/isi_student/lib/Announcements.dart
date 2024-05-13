import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AnnouncementsPage extends StatefulWidget {
  @override
  _AnnouncementsPageState createState() => _AnnouncementsPageState();
}

class _AnnouncementsPageState extends State<AnnouncementsPage> {
  late List<Map<String, dynamic>> _announcements = [];
  late List<Map<String, dynamic>> _filteredAnnouncements = [];
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  late TextEditingController _searchController;

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController();
    _fetchUserCategories();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _fetchUserCategories() async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String userEmail = prefs.getString('email') ?? '';

      // Query Firestore to find the user document using the email
      QuerySnapshot userSnapshot = await _firestore
          .collection('students')
          .where('email', isEqualTo: userEmail)
          .get();

      // Extract the categories list from the user document
      if (userSnapshot.docs.isNotEmpty) {
        List<dynamic> userCategories = userSnapshot.docs.first['categories'];
        await _fetchAnnouncements(userCategories);
      }
    } catch (error) {
      // Error occurred during fetching user categories
      print('Error fetching user categories: $error');
    }
  }

  Future<void> _fetchAnnouncements(List<dynamic> userCategories) async {
    try {
      // Query Firestore to fetch announcements
      QuerySnapshot announcementsSnapshot = await _firestore
          .collection('posts')
          .where('categories', arrayContainsAny: userCategories)
          .get();

      // Extract announcements data
      _announcements = announcementsSnapshot.docs.map((doc) {
        return doc.data() as Map<String, dynamic>;
      }).toList();

      // Initialize filtered announcements with all announcements
      _filteredAnnouncements = List.from(_announcements);

      setState(() {});
    } catch (error) {
      // Error occurred during Firebase query
      print('Error fetching announcements: $error');
    }
  }

  void _filterAnnouncements(String query) {
    setState(() {
      if (query.isNotEmpty) {
        _filteredAnnouncements = _announcements.where((announcement) {
          return announcement['title']
                  .toString()
                  .toLowerCase()
                  .contains(query.toLowerCase()) ||
              announcement['description']
                  .toString()
                  .toLowerCase()
                  .contains(query.toLowerCase());
        }).toList();
      } else {
        _filteredAnnouncements = List.from(_announcements);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        /*decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/bg.png'), // Replace with your image path
            fit: BoxFit.cover,
          ),
        ),*/
        child: Column(
          children: [
            Padding(
              padding: EdgeInsets.all(8.0),
              child: TextField(
                controller: _searchController,
                decoration: const InputDecoration(
                  prefixIcon: Icon(Icons.search),
                  hintText: 'Search...',
                ),
                onChanged: _filterAnnouncements,
              ),
            ),
            Expanded(
              child: _buildAnnouncementsList(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAnnouncementsList() {
    if (_filteredAnnouncements.isEmpty) {
      return const Center(child: Text('There is no announcement available.'));
    } else {
      return ListView.builder(
        itemCount: _filteredAnnouncements.length,
        itemBuilder: (context, index) {
          Map<String, dynamic> announcement = _filteredAnnouncements[index];

          return GestureDetector(
            onTap: () => _showAnnouncementDetailsDialog(context, announcement),
            child: Padding(
              padding:
                  const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
              child: Card(
                elevation: 2.0,
                child: ListTile(
                  title: Text(announcement['title'] as String),
                  subtitle: Text(announcement['description'] as String),
                ),
              ),
            ),
          );
        },
      );
    }
  }

  void _showAnnouncementDetailsDialog(
      BuildContext context, Map<String, dynamic> announcement) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(announcement['title'] as String),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                (announcement['image'] as String?)?.isNotEmpty ?? false
                    ? Image.network(
                        announcement['image'] as String,
                        fit: BoxFit.cover,
                      )
                    : Text('No image available'),
                SizedBox(height: 10),
                Text('Description: ${announcement['description']}'),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: Text('Close'),
              onPressed: () => Navigator.of(context).pop(),
            ),
          ],
        );
      },
    );
  }
}

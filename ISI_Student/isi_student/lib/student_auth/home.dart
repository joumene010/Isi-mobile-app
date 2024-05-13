import 'package:flutter/material.dart';
import 'package:isi_student/Announcements.dart';
import 'package:isi_student/global/toast.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Home extends StatefulWidget {
  const Home({Key? key}) : super(key: key);

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<Home> {
  int _selectedIndex = 0;
  late String _displayName = '';
  late String _email = '';

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  late String _profileImageUrl = '';

  void _loadUserData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      _displayName = prefs.getString('username') ?? 'User Name';
      _email = prefs.getString('email') ?? 'user@example.com';
      _profileImageUrl =
          prefs.getString('profileImage') ?? ''; // Retrieve image URL
    });
    print(
        "Loaded profile image URL: $_profileImageUrl"); // Add this line to check URL
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Welcome Dear Student"),
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: <Widget>[
            UserAccountsDrawerHeader(
              decoration: const BoxDecoration(
                color: const Color(0xFF80A4FF), // Change the background color as needed
              ),
              accountName: Text(_displayName),
              accountEmail: Text(_email),
              currentAccountPicture: _profileImageUrl.isNotEmpty
                  ? CircleAvatar(
                      backgroundImage: NetworkImage(_profileImageUrl),
                    )
                  : const CircleAvatar(
                      backgroundColor: Colors.white,
                      child: Icon(
                        Icons.person,
                        color: const Color(0xFF80A4FF),
                      ),
                    ),
            ),
            ListTile(
              title: const Text('Annoncements'),
              leading: const Icon(Icons.local_post_office),
              onTap: () {
                Navigator.pop(context); // Close the drawer
                _onItemTapped(0);
              },
            ),
            ListTile(
              title: const Text('Sign Out'),
              leading: const Icon(Icons.exit_to_app),
              onTap: () {
                // Handle sign out
                _signOut();
              },
            ),
          ],
        ),
      ),
      body: _buildPage(),
    );
  }

  Widget _buildPage() {
    switch (_selectedIndex) {
      case 0:
        return AnnouncementsPage(); // Replace with your annoncements page
      default:
        throw UnimplementedError('no widget for $_selectedIndex');
    }
  }

  void _signOut() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.clear(); // Clear user data
    Navigator.pushNamed(context, "/login");
    showToast(message: "Successfully signed out");
  }
}

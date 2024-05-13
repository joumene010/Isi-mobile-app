import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:isi_admin/global/toast.dart';
import 'package:isi_admin/pages/ImageUploads.dart';
import 'package:isi_admin/pages/categories.dart';
import 'package:isi_admin/pages/posts.dart';

//import '../../pages/Forms.dart';

class Home extends StatefulWidget {
  const Home({Key? key}) : super(key: key);

  @override
  State<Home> createState() => _HomePageState();
}

class _HomePageState extends State<Home> {
  int _selectedIndex = 0;
  late User _user;

  @override
  void initState() {
    super.initState();
    _user = FirebaseAuth.instance.currentUser!;
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
        title: Text("Administrator"),
      ),
      drawer: Drawer(
        child: FutureBuilder<User?>(
          future: FirebaseAuth.instance.authStateChanges().first,
          builder: (BuildContext context, AsyncSnapshot<User?> snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return CircularProgressIndicator();
            } else if (snapshot.hasError) {
              // Handle error state
              return Center(child: Text('Error loading user data'));
            } else if (snapshot.hasData && snapshot.data != null) {
              User user = snapshot.data!;
              String displayName = user.displayName ?? "User Name";
              String email = user.email ?? "user@example.com";
              String? photoURL = user.photoURL;

              return ListView(
                children: <Widget>[
                  UserAccountsDrawerHeader(
                    accountName: Text(displayName),
                    accountEmail: Text(email),
                    currentAccountPicture: CircleAvatar(
                      backgroundColor: Colors.white,
                      backgroundImage:
                          photoURL != null ? NetworkImage(photoURL) : null,
                      child: photoURL == null
                          ? Icon(Icons.person,
                              color: Color(0xFF7553F6))
                          : null,
                    ),
                  ),
                  ListTile(
                    title: Text('Categories'),
                    leading: Icon(Icons.category),
                    onTap: () {
                      Navigator.pop(context);
                      // _onItemTapped(0); // Handle the navigation or action
                    },
                  ),
                  ListTile(
                    title: Text('Posts'),
                    leading: Icon(Icons.message),
                    onTap: () {
                      Navigator.pop(context); // Close the drawer
                      _onItemTapped(1);
                      // Handle messages action
                    },
                  ),
                  ListTile(
                    title: Text('Sign Out'),
                    leading: Icon(Icons.exit_to_app),
                    onTap: () {
                      FirebaseAuth.instance.signOut();
                      Navigator.pushNamed(context, "/login");
                      showToast(message: "Successfully signed out");
                    },
                  ),
                ],
              );
            } else {
              // Handle the case when there's no data
              return Center(child: Text("No user data available"));
            }
          },
        ),
      ),
      body: _buildPage(),
    );
  }

  Widget _buildPage() {
    switch (_selectedIndex) {
      case 0:
        return CategoriesPage();
      case 1:
        return PostsPage();
      /*case 2:
        return FormBuilder();*/
      case 2:
        return ImageUploads();
      default:
        throw UnimplementedError('no widget for $_selectedIndex');
    }
  }
}

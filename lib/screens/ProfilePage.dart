import 'package:flutter/material.dart';
import 'mydatabase.dart'; // Import your database class

class ProfilePage extends StatefulWidget {
  final String userEmail; // User email to fetch details from the database

  ProfilePage({required this.userEmail});

  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  late TextEditingController _usernameController;
  String _userName = "";
  final MyDatabaseClass _mydb = MyDatabaseClass(); // Initialize the database class

  @override
  void initState() {
    super.initState();
    _fetchUserDetails(); // Fetch user details from the database
  }
  int _selectedIndex = 0;
  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });

    // Add navigation logic for each page
    if (index == 0) {
      Navigator.pushNamed(context, '/');
    } else if (index == 1) {
      Navigator.pushNamed(context, '/eventList');
    } else if (index == 2) {
      Navigator.pushNamed(context, '/profile');
    }
  }
  Future<void> _fetchUserDetails() async {
    try {
      final user = await _mydb.getUserByEmail(widget.userEmail);
      if (user != null) {
        setState(() {
          _userName = user['username']; // Assuming 'username' field exists in your database
          _usernameController = TextEditingController(text: _userName);
        });
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error fetching user details: ${e.toString()}')),
      );
    }
  }

  Future<void> _updateUserName() async {
    String newUserName = _usernameController.text.trim();
    if (newUserName.isNotEmpty && newUserName != _userName) {
      try {
        await _mydb.updateUserName(widget.userEmail, newUserName); // Update username in the database
        setState(() {
          _userName = newUserName;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Username updated successfully!')),
        );
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error updating username: ${e.toString()}')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Profile",
          style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.black87,
      ),
      body: _userName.isEmpty
          ? Center(child: CircularProgressIndicator()) // Show loading indicator while fetching data
          : Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Card(
              elevation: 4,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    CircleAvatar(
                      radius: 50,
                      backgroundColor: Colors.teal[100],
                      child: Icon(Icons.person, size: 50, color: Colors.black87),
                    ),
                    SizedBox(height: 15),
                    TextFormField(
                      controller: _usernameController,
                      decoration: InputDecoration(
                        labelText: 'Username',
                        labelStyle: TextStyle(color: Colors.black87),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                    ),
                    SizedBox(height: 15),
                    Text(
                      widget.userEmail, // Display the user email
                      style: TextStyle(fontSize: 16, color: Colors.black87),
                    ),
                    SizedBox(height: 15),
                    ElevatedButton(
                      onPressed: _updateUserName, // Update username action
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.teal[400],
                        padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: Text(
                        "Save Changes",
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                    SizedBox(height: 20),
                    ListTile(
                      title: Text(
                        "Your Events",
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500, color: Colors.teal[800]),
                      ),
                      trailing: Icon(Icons.arrow_forward_ios, color: Colors.teal[400]),
                      onTap: () {
                        Navigator.pushNamed(context, '/eventList');
                      },
                    ),
                    Divider(color: Colors.grey[300]),
                    ListTile(
                      title: Text(
                        "My Pledged Gifts",
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500, color: Colors.teal[800]),
                      ),
                      trailing: Icon(Icons.arrow_forward_ios, color: Colors.teal[400]),
                      onTap: () {
                        Navigator.pushNamed(context, '/MypledgedGifts');
                      },
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.event),
            label: 'My Events',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person_2_outlined),
            label: 'My profile',
          ),
        ],
        backgroundColor: Colors.black87,
        selectedItemColor: Colors.tealAccent,
        unselectedItemColor: Colors.white,
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'mydatabase.dart';
import 'session_manger.dart'; // Import session manager for shared preferences

class ProfilePage extends StatefulWidget {
  ProfilePage({Key? key}) : super(key: key); // No need to pass userEmail or userId

  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  late TextEditingController _usernameController;
  String _userName = "";
  String _userEmail = "";  // To store user email
  final MyDatabaseClass _mydb = MyDatabaseClass(); // Initialize the database class

  @override
  void initState() {
    super.initState();
    _usernameController = TextEditingController();
    _fetchUserDetails(); // Fetch user details when the page loads
  }

  // Fetch user details (username and email) from the database based on userId
  Future<void> _fetchUserDetails() async {
    try {
      final userId = await getUserId(); // Retrieve the user ID from SharedPreferences
      if (userId != null) {
        // Fetch user details from database by userId
        final user = await _mydb.getUserById(userId);
        if (user != null) {
          setState(() {
            _userName = user['username']; // Assuming 'username' field exists in your database
            _userEmail = user['email']; // Assuming 'email' field exists in your database
            _usernameController = TextEditingController(text: _userName);
          });
        }
      } else {
        // Handle case where userId is not found
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('User not logged in. Please log in again.')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error fetching user details: ${e.toString()}')),
      );
    }
  }

  // Update the username in the database
  Future<void> _updateUserName() async {
    String newUserName = _usernameController.text.trim();
    if (newUserName.isNotEmpty && newUserName != _userName) {
      try {
        final userId = await getUserId(); // Get the userId from SharedPreferences
        if (userId != null) {
          await _mydb.updateUserName(userId, newUserName); // Update username in the database by userId
          setState(() {
            _userName = newUserName;
          });
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Username updated successfully!')),
          );
        }
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error updating username: ${e.toString()}')),
        );
      }
    }
  }

  // Bottom navigation
  int _selectedIndex = 0;
  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });

    if (index == 0) {
      Navigator.pushNamed(context, '/');
    } else if (index == 1) {
      Navigator.pushNamed(context, '/eventList');
    } else if (index == 2) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
            builder: (context) => ProfilePage()), // No need to pass userEmail and userId
      );
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
      body: Stack(
        children: [
          Positioned.fill(
            child: Image.network(
              'https://images.pexels.com/photos/5485112/pexels-photo-5485112.jpeg',
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) {
                return Container(
                  color: Colors.grey[200],
                  child: Icon(
                    Icons.broken_image,
                    size: 100,
                    color: Colors.grey,
                  ),
                );
              },
            ),
          ),
          _userName.isEmpty
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
                          _userEmail, // Display the user email
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
        ],
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

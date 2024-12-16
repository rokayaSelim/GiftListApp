import 'package:flutter/material.dart';
import 'mydatabase.dart';
import 'session_manger.dart';
import 'firebase.dart';// Import session manager for shared preferences

class ProfilePage extends StatefulWidget {
  ProfilePage({Key? key}) : super(key: key); // No need to pass userEmail or userId

  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  String _userName = "";
  String _userEmail = "";
  String _userphone = "";
  late String imagePath;
 // To store user email
  final MyDatabaseClass _mydb = MyDatabaseClass(); // Initialize the database class

  @override
  void initState() {
    super.initState();
    _fetchUserDetails();
    imagePath = '';// Fetch user details when the page loads
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
            _userEmail = user['email'];
            _userphone = user['phoneNumber'];
            imagePath = user['imagePath'] ?? '';
          });
        }
      } else {
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
  void showAddImageDialog() async {
    final TextEditingController _imageUrlController = TextEditingController();

    final result = await showDialog<String>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Add Profile Picture URL'),
          content: TextField(
            controller: _imageUrlController,
            decoration: InputDecoration(
              hintText: 'Enter image URL',
              border: OutlineInputBorder(),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(_imageUrlController.text.trim());
              },
              child: Text('Save'),
            ),
          ],
        );
      },
    );

    if (result != null && result.isNotEmpty) {
      final userId = await getUserId();
      if (userId != null) {
        setState(() {
          imagePath = result;
        });

        // Save to the local database
        await _mydb.updateUserProfilePic(userId, imagePath);

        // Save to Firestore
        final firestoreHelper = FirestoreHelper();
        await firestoreHelper.updateUserProfilePic(userId.toString(), imagePath);

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Profile picture updated successfully!')),
        );
      }
    }
  }

  // Show dialog to edit the username
  void _showEditUsernameDialog() {
    final TextEditingController _editController =
    TextEditingController(text: _userName);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text("Edit Username"),
        content: TextField(
          controller: _editController,
          decoration: InputDecoration(
            labelText: "New Username",
            border: OutlineInputBorder(),
          ),
        ),
        backgroundColor: Colors.white.withOpacity(0.6),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text("Cancel"),
          ),
          ElevatedButton(
            onPressed: () async {
              String newUserName = _editController.text.trim();
              if (newUserName.isNotEmpty && newUserName != _userName) {
                try {
                  final userId = await getUserId();
                  if (userId != null) {
                    await _mydb.updateUserName(userId, newUserName);
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
              Navigator.pop(context);
            },
            child: Text("Save"),
          ),
        ],
      ),
    );
  }
// Show dialog to edit the username
  void _showEditPhoneDialog() {
    final TextEditingController _editController =
    TextEditingController(text: _userphone);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text("Edit Phone Number"),
        content: TextField(
          controller: _editController,
          decoration: InputDecoration(
            labelText: "New Phone Number",
            border: OutlineInputBorder(),
          ),
        ),
        backgroundColor: Colors.white.withOpacity(0.6),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text("Cancel"),
          ),
          ElevatedButton(
            onPressed: () async {
              String newPhone = _editController.text.trim();
              if (newPhone.isNotEmpty && newPhone != _userphone) {
                try {
                  final userId = await getUserId();
                  if (userId != null) {
                    await _mydb.updateUserPhone(userId, newPhone);
                    setState(() {
                      _userphone = newPhone;
                    });
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Phone Number updated successfully!')),
                    );
                  }
                } catch (e) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Error updating Phone Number: ${e.toString()}')),
                  );
                }
              }
              Navigator.pop(context);
            },
            child: Text("Save"),
          ),
        ],
      ),
    );
  }
  Future<void> _deleteUserAccount() async {
    try {
      final userId = await getUserId(); // Get user ID from session
      if (userId != null) {
        final userIdStr = userId.toString();
        await _mydb.deleteUser(userId); // Delete user from local database
        final firestoreHelper = FirestoreHelper();
        await firestoreHelper.deleteUser(userIdStr); // Delete user from Firestore
        await clearUserSession(); // Clear user session locally

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Account deleted successfully!')),
        );
        Navigator.pushReplacementNamed(context, '/signIn'); // Navigate to sign-in page
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: User ID not found.')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error deleting account: ${e.toString()}')),
      );
    }
  }

  void _showDeleteUserDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text("Delete Account"),
        content: Text("Are you sure you want to delete your account? This action cannot be undone."),
        backgroundColor: Colors.white.withOpacity(0.6),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text("Cancel"),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context); // Close the dialog
              await _deleteUserAccount(); // Delete the user
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.white),
            child: Text("Delete"),
          ),
        ],
      ),
    );
  }

  void _logOut() async {
    try {
      await clearUserSession(); // Clear the user's session (function from session_manager.dart)
      Navigator.pushReplacementNamed(context, '/signIn'); // Navigate to the sign-in page
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error logging out: ${e.toString()}')),
      );
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
    final screenHeight = MediaQuery.of(context).size.height;
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Profile",
          style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.black87,
        iconTheme: IconThemeData(color: Colors.white),
      ),
      body: Stack(
        children: [
          // Background image positioned behind the scrollable content
          Positioned.fill(
            child: Image.network(
              'https://images.unsplash.com/photo-1511886277144-49a67943f819?w=500&auto=format&fit=crop&q=60&ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxzZWFyY2h8MTc5fHxnaWZ0JTIwYmFja2dyb3VuZHxlbnwwfHwwfHx8MA%3D%3D',
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
          // Scrollable content wrapped in SingleChildScrollView
          SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  Card(
                    color: Colors.white.withOpacity(0.6),
                    elevation: 4,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(25.0),
                      child: screenHeight > 600
                          ? Column(
                        children: [
                          CircleAvatar(
                            radius: 50,
                            backgroundImage: imagePath.isNotEmpty
                                ? NetworkImage(imagePath)
                                : null,
                            child: imagePath.isEmpty
                                ? Icon(Icons.person, size: 50, color: Colors.black87)
                                : null,
                            backgroundColor: Colors.teal[100],
                          ),
                          ListTile(
                            title: Text("Profile Picture"),
                            subtitle: Text(imagePath.isNotEmpty
                                ? "Change your profile picture"
                                : "Add your profile picture"),
                            trailing: Icon(Icons.add_photo_alternate, color: Colors.teal[400]),
                            onTap: showAddImageDialog,
                          ),
                          Divider(color: Colors.grey[300]),
                          ListTile(
                            title: Text("Username"),
                            subtitle: Text(_userName),
                            trailing: IconButton(
                              icon: Icon(Icons.edit, color: Colors.teal[400]),
                              onPressed: _showEditUsernameDialog,
                            ),
                          ),
                          Divider(color: Colors.grey[300]),
                          ListTile(
                            title: Text("Phone Number"),
                            subtitle: Text(_userphone),
                            trailing: IconButton(
                              icon: Icon(Icons.edit, color: Colors.teal[400]),
                              onPressed: _showEditPhoneDialog,
                            ),
                          ),
                          Divider(color: Colors.grey[300]),
                          ListTile(
                            title: Text("Email"),
                            subtitle: Text(_userEmail),
                            trailing: Icon(Icons.lock, color: Colors.grey[500]),
                          ),
                          Divider(color: Colors.grey[300]),
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
                          Divider(color: Colors.grey[300]),
                          ListTile(
                            title: Text(
                              "Logout",
                              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500, color: Colors.red),
                            ),
                            trailing: Icon(Icons.logout, color: Colors.red),
                            onTap: _logOut,
                          ),
                          Divider(color: Colors.grey[300]),
                          ListTile(
                            title: Text(
                              "Delete Account",
                              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500, color: Colors.red),
                            ),
                            trailing: Icon(Icons.delete, color: Colors.red),
                            onTap: _showDeleteUserDialog,
                          ),
                        ],
                      )
                          : Column( // For smaller screens
                        children: [
                          CircleAvatar(
                            radius: 50,
                            backgroundImage: imagePath.isNotEmpty
                                ? NetworkImage(imagePath)
                                : null,
                            child: imagePath.isEmpty
                                ? Icon(Icons.person, size: 50, color: Colors.black87)
                                : null,
                            backgroundColor: Colors.teal[100],
                          ),
                          ListTile(
                            title: Text("Profile Picture"),
                            subtitle: Text(imagePath.isNotEmpty
                                ? "Change your profile picture"
                                : "Add your profile picture"),
                            trailing: Icon(Icons.add_photo_alternate, color: Colors.teal[400]),
                            onTap: showAddImageDialog,
                          ),
                          Divider(color: Colors.grey[300]),
                          ListTile(
                            title: Text("Username"),
                            subtitle: Text(_userName),
                            trailing: IconButton(
                              icon: Icon(Icons.edit, color: Colors.teal[400]),
                              onPressed: _showEditUsernameDialog,
                            ),
                          ),
                          Divider(color: Colors.grey[300]),
                          ListTile(
                            title: Text("Phone Number"),
                            subtitle: Text(_userphone),
                            trailing: IconButton(
                              icon: Icon(Icons.edit, color: Colors.teal[400]),
                              onPressed: _showEditPhoneDialog,
                            ),
                          ),
                          Divider(color: Colors.grey[300]),
                          ListTile(
                            title: Text("Email"),
                            subtitle: Text(_userEmail),
                            trailing: Icon(Icons.lock, color: Colors.grey[500]),
                          ),
                          Divider(color: Colors.grey[300]),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
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
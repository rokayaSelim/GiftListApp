import 'package:flutter/material.dart';

class ProfilePage extends StatelessWidget {
  final String userName;
  final String userEmail;

  // Constructor accepting userName and userEmail
  ProfilePage({required this.userName, required this.userEmail});

  @override
  Widget build(BuildContext context) {
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
          // Fullscreen background image using the provided URL
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
          // Semi-transparent overlay to darken the background image
          Positioned.fill(
            child: Container(
              color: Colors.black.withOpacity(0.1),
            ),
          ),
          // Page content
          Padding(
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
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        CircleAvatar(
                          radius: 50,
                          backgroundColor: Colors.teal[100],
                          child: Icon(Icons.person, size: 50, color: Colors.black87),
                        ),
                        SizedBox(height: 15),
                        Text(
                          userName, // Display the user name
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 22,
                            color: Colors.black87,
                          ),
                        ),
                        SizedBox(height: 4),
                        Text(
                          userEmail, // Display the user email
                          style: TextStyle(fontSize: 16, color: Colors.black87),
                        ),
                        SizedBox(height: 15),
                        ElevatedButton(
                          onPressed: () {
                            // Edit Profile action
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.teal[400],
                            padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          child: Text(
                            "Edit Profile",
                            style: TextStyle(color: Colors.white),
                          ),
                        ),
                      ],
                    ),
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
        ],
      ),

    );
  }
}

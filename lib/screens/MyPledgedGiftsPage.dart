import 'package:flutter/material.dart';

class MyPledgedGiftsPage extends StatelessWidget {
  final List<Map<String, String>> pledgedGifts = [
    {
      "name": "Headphones",
      "event": "Birthday",
      "friendName": "John Doe",
      "dueDate": "Nov 10, 2024"
    },
    {
      "name": "Cookbook",
      "event": "Wedding",
      "friendName": "Jane Smith",
      "dueDate": "Dec 20, 2024"
    },
    {
      "name": "Yoga Mat",
      "event": "Graduation",
      "friendName": "Emily Johnson",
      "dueDate": "Jan 5, 2025"
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "My Pledged Gifts",
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: Colors.black87,
        iconTheme: IconThemeData(color: Colors.white),
      ),
      body: Stack(
        children: [
          // Fullscreen background image
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
          // Semi-transparent overlay
          Positioned.fill(
            child: Container(
              color: Colors.black.withOpacity(0.2),
            ),
          ),
          // List of pledged gifts
          ListView.builder(
            padding: EdgeInsets.all(16.0),
            itemCount: pledgedGifts.length,
            itemBuilder: (context, index) {
              final gift = pledgedGifts[index];
              return Card(
                elevation: 4,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
                margin: EdgeInsets.only(bottom: 16),
                child: Padding(
                  padding: EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        gift["name"]!,
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.teal[600],
                        ),
                      ),
                      SizedBox(height: 8),
                      Text(
                        "Event: ${gift["event"]}",
                        style: TextStyle(color: Colors.grey[700]),
                      ),
                      Text(
                        "Friend: ${gift["friendName"]}",
                        style: TextStyle(color: Colors.grey[700]),
                      ),
                      Text(
                        "Due Date: ${gift["dueDate"]}",
                        style: TextStyle(color: Colors.grey[700]),
                      ),
                      SizedBox(height: 12),
                      ElevatedButton(
                        onPressed: () {
                          // Action to modify or remove pledge if needed
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.black87,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        child: Text(
                          "Modify Pledge",
                          style: TextStyle(color: Colors.white),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ],
      ),

    );
  }
}

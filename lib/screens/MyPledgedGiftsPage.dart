import 'package:flutter/material.dart';
import 'session_manger.dart';
import 'mydatabase.dart';
import 'firebase.dart';

class MyPledgedGiftsPage extends StatefulWidget {
  @override
  _MyPledgedGiftsPageState createState() => _MyPledgedGiftsPageState();
}

class _MyPledgedGiftsPageState extends State<MyPledgedGiftsPage> {
  List<Map<String, dynamic>> pledgedGifts = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchPledgedGifts();
  }

  Future<void> fetchPledgedGifts() async {
    try {
      final userId = await getUserId(); // Assuming you have a function to get the current user's ID
      if (userId != null) {
        // Fetch pledged gifts for the user using FirestoreHelper
        final gifts = await FirestoreHelper().getPledgedGiftsByUserId(userId);

        setState(() {
          pledgedGifts = gifts;
          isLoading = false;
        });
      } else {
        // Handle case when userId is null
        setState(() {
          pledgedGifts = [];
          isLoading = false;
        });
      }
    } catch (e) {
      print('Error fetching pledged gifts: $e');
      setState(() {
        isLoading = false;
      });
    }
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Pledged Gifts',
          style: TextStyle(
            color: Colors.white,
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Colors.black87,
        iconTheme: IconThemeData(color: Colors.white),
      ),
      body: Stack(
        children: [
          // Background image
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
          // Semi-transparent overlay
          Positioned.fill(
            child: Container(
              color: Colors.black.withOpacity(0.1),
            ),
          ),
          // Main content
          isLoading
              ? Center(
                child: CircularProgressIndicator(),
              )
              : pledgedGifts.isEmpty
              ? Center(
                child: Text(
              'No gifts have been pledged yet.',
              style: TextStyle(fontSize: 18, color: Colors.grey),
               ),
          )
              : ListView.builder(
                itemCount: pledgedGifts.length,
                itemBuilder: (context, index) {
                  final gift = pledgedGifts[index];
                return Padding(
                  padding: const EdgeInsets.symmetric(
                      vertical: 8.0, horizontal: 16.0),
                  child: Card(
                    shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15),
                    ),
                    color: Colors.white.withOpacity(0.6),
                    elevation: 6,
                    child: ListTile(
                      contentPadding: EdgeInsets.symmetric(
                          horizontal: 16, vertical: 8),
                      leading: gift['imagePath'] != null && gift['imagePath'].isNotEmpty
                          ? Image.network(
                            gift['imagePath'], // Replace with the local file path if needed.
                            width: 50,
                            height: 50,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) => Icon(
                              Icons.broken_image,
                              color: Colors.grey,
                            ),
                          )
                          : Icon(
                            Icons.image_not_supported,
                            size: 50,
                            color: Colors.grey,
                          ),
                      title: Text(
                        gift['name'],
                        style: TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 18),
                      ),
                      subtitle: Text(
                        'Category: ${gift['category']}',
                        style: TextStyle(color: Colors.teal[700]),
                      ),
                      trailing: IconButton(
                      icon: Icon(Icons.info_outline, color: Colors.teal),
                      onPressed: () {
                        showDialog(
                          context: context,
                          builder: (context) {
                            return AlertDialog(
                              backgroundColor: Colors.white.withOpacity(0.6),
                              title: Text(
                                '${gift['name']} Details',
                                style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 24,
                                    color: Colors.teal),
                              ),
                              content: Column(
                                mainAxisSize: MainAxisSize.min,
                                crossAxisAlignment:
                                CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Category: ${gift['category']}',
                                    style: TextStyle(fontSize: 18),
                                  ),
                                  SizedBox(height: 8),
                                  Text(
                                    'Description: ${gift['description']}',
                                    style: TextStyle(fontSize: 18),
                                  ),
                                  SizedBox(height: 8),
                                  Text(
                                    'Price: \$${gift['price'].toStringAsFixed(2)}',
                                    style: TextStyle(fontSize: 18),
                                  ),
                                ],
                              ),
                              actions: [
                                TextButton(
                                  onPressed: () =>
                                      Navigator.pop(context),
                                  child: Text('Close'),
                                ),
                              ],
                            );
                          },
                        );
                      },
                    ),
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

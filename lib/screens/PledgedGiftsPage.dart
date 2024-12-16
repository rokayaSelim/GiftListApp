import 'package:flutter/material.dart';

class PledgedGiftsPage extends StatelessWidget {
  final List<Map<String, dynamic>> pledgedGifts;

  PledgedGiftsPage({required this.pledgedGifts});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Pledged Gifts',
          style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold),
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
          pledgedGifts.isEmpty
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
                padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
                child: Card(
                  color: Colors.white.withOpacity(0.6),
                  shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15),
                  ),
                  elevation: 6,
                  child: ListTile(
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
                    contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    title: Text(
                      gift['name'],
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                    ),
                    subtitle: Text(
                      'Category: ${gift['category']}',
                      style: TextStyle(color: Colors.teal[700]),
                    ),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: Icon(Icons.info_outline, color: Colors.teal),
                          onPressed: () {
                            showDialog(
                              context: context,
                              builder: (context) {
                                return AlertDialog(
                                  title: Text('${gift['name']} Details',style: TextStyle(fontWeight: FontWeight.bold, fontSize: 24,color: Colors.teal),),
                                  backgroundColor: Colors.white.withOpacity(0.6),
                                  content: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text('Category: ${gift['category']}',style: TextStyle(fontSize: 18,),),
                                      SizedBox(height: 8),
                                      Text('Description: ${gift['description']}',style: TextStyle(fontSize: 18,)),
                                      SizedBox(height: 8),
                                      Text('Price: \$${gift['price'].toStringAsFixed(2)}',style: TextStyle(fontSize: 18,)),
                                    ],
                                  ),
                                  actions: [
                                    TextButton(
                                      onPressed: () => Navigator.pop(context),
                                      child: Text('Close'),
                                    ),
                                  ],
                                );
                              },
                            );
                          },
                        ),
                      ],
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

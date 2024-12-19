import 'package:flutter/material.dart';
import 'GiftDetailsPage.dart';
import 'mydatabase.dart';
import 'session_manger.dart';
import 'firebase.dart';// Your database class
import 'HomePage.dart';
import 'EventListPage.dart';
import 'ProfilePage.dart';

class GiftListPage extends StatefulWidget {
  @override
  _GiftListPageState createState() => _GiftListPageState();
}

class _GiftListPageState extends State<GiftListPage> {
  int eventId = 0; // Default value for eventId
  List<Map<String, dynamic>> gifts = []; // List of all gifts
  List<Map<String, dynamic>> pledgedGifts = []; // List of pledged gifts
  String sortBy = 'name'; // Default sorting criteria
  late final MyDatabaseClass mydb; // Database instance

  @override
  void initState() {
    super.initState();
    mydb = MyDatabaseClass();
    loadEventId().then((_) {
      mydb.init().then((_) {
        loadGifts(); // Load all gifts from the database
      });
    });
  }

  // Load eventId from SharedPreferences
  Future<void> loadEventId() async {
    eventId = await getEventId();
    if (eventId == 0) {
      // Handle the case where no eventId is set
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('No event selected. Redirecting to event list.')),
      );
      Navigator.pushReplacementNamed(context, '/eventList');
    }
  }

  // Load all gifts and filter pledged gifts
  void loadGifts() async {
    final data = await mydb.getGiftsForEvent(eventId); // Pass eventId to filter gifts
    setState(() {
      gifts = data;
      pledgedGifts = data.where((gift) => gift['isPledged'] == 1).toList(); // Filter pledged gifts
    });
  }
  void _navigateWithFade(BuildContext context, String routeName) {
    // Define the page you want to navigate to based on the route name
    Widget page;
    switch (routeName) {
      case '/eventList':
        page = EventListPage();
        break;
      case '/':
        page = HomePage();
        break;
      case '/profile':
        page = ProfilePage();
        break;
      default:
        page = HomePage(); // Fallback page in case route is undefined
        break;
    }

    Navigator.push(
      context,
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) {
          return page;
        },
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          const begin = 0.0;
          const end = 1.0;
          const curve = Curves.easeInOut;

          var tween = Tween(begin: begin, end: end).chain(CurveTween(curve: curve));
          var opacityAnimation = animation.drive(tween);

          return FadeTransition(opacity: opacityAnimation, child: child);
        },
      ),
    );
  }
  int _selectedIndex = 0;
  void _onItemTapped(int index) async {
    setState(() {
      _selectedIndex = index;
    });
    if (index == 0) {
      _navigateWithFade(context, '/');
    }
    if (index == 1) {
      _navigateWithFade(context, '/eventList');
    }
    if (index == 2) {
      _navigateWithFade(context, '/profile');
    }
  }
  // Function to pledge a gift
  void pledgeGift(int index) async {
    final gift = gifts[index];
    final userId = await getUserId(); // Retrieve the logged-in user ID

    await mydb.updateGift(
      gift['ID'],
      gift['name'],
      gift['category'],
      gift['description'],
      gift['price'],
      true, // Set `isPledged` to true
      userId: userId, // Save the user ID
    );
    loadGifts(); // Reload gifts after updating
  }

  // Function to add a new gift
  void addGift() async{
    eventId = await getEventId();
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => GiftDetailsPage(eventId: eventId),
      ),
    ).then((value) {
      if (value == true) loadGifts(); // Reload gifts if a gift was added
    });
  }
  // Function to edit a gift
  void editGift(int index) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        String name = gifts[index]['name'];
        String category = gifts[index]['category'];
        String description = gifts[index]['description'];
        double price = gifts[index]['price'];

        return AlertDialog(
          title: Text('Edit Gift'),
          backgroundColor: Colors.white.withOpacity(0.6),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                onChanged: (value) => name = value,
                controller: TextEditingController(text: name),
                decoration: InputDecoration(labelText: 'Gift Name'),
              ),
              TextField(
                onChanged: (value) => category = value,
                controller: TextEditingController(text: category),
                decoration: InputDecoration(labelText: 'Category'),
              ),
              TextField(
                onChanged: (value) => description = value,
                controller: TextEditingController(text: description),
                decoration: InputDecoration(labelText: 'Description'),
              ),
              TextField(
                onChanged: (value) => price = double.tryParse(value) ?? price,
                keyboardType: TextInputType.number,
                controller: TextEditingController(text: price.toString()),
                decoration: InputDecoration(labelText: 'Price'),
              ),
            ],
          ),
          actions: [
            ElevatedButton(
              onPressed: () async {
                // Update the local database (SQLite)
                mydb.updateGift(gifts[index]['ID'], name, category, description, price, gifts[index]['isPledged'] == 1);

                // Get the updated gift data
                final updatedGift = {
                  'ID': gifts[index]['ID'],
                  'name': name,
                  'category': category,
                  'description': description,
                  'price': price,
                  'isPledged': gifts[index]['isPledged'],
                };

                // Check if the gift exists in Firestore
                final firestoreHelper = FirestoreHelper();
                final giftSnapshot = await firestoreHelper.getGiftById(gifts[index]['ID']);

                if (giftSnapshot.exists) {
                  // If the gift exists, update it in Firestore
                  await firestoreHelper.updateGift(updatedGift); // Update Firestore
                  print('Gift updated in Firestore');
                } else {
                  print('Gift with ID ${gifts[index]['ID']} does not exist in Firestore. No update performed.');
                }

                loadGifts(); // Reload gifts from the local database
                Navigator.pop(context); // Close the dialog
              },
              child: Text('Save'),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context), // Close the dialog without saving
              child: Text('Cancel'),
            ),
          ],
        );
      },
    );
  }
  // Function to delete a gift
  void deleteGift(int index) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Are you sure?'),
          content: Text('Do you really want to delete this gift?'),
          backgroundColor: Colors.white.withOpacity(0.6),
          actions: [
            TextButton(
              onPressed: () async {
                try {
                  final giftID = gifts[index]['ID'];

                  // Ensure the gift ID is not null
                  if (giftID == null) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Error: Gift ID is null. Unable to delete.')),
                    );
                    Navigator.pop(context);
                    return;
                  }

                  // Delete the gift from Firebase
                  final firestoreHelper = FirestoreHelper();
                  await firestoreHelper.deleteGift(giftID.toString());

                  // Delete the gift locally from SQLite
                  await mydb.deleteGift(giftID);

                  // Reload the list of gifts
                  loadGifts();

                  // Show success message
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Gift deleted successfully!')),
                  );
                } catch (e) {
                  // Handle any errors
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Error deleting gift: ${e.toString()}')),
                  );
                } finally {
                  Navigator.pop(context);
                }
              },
              child: Text('Yes', style: TextStyle(color: Colors.red)),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('No'),
            ),
          ],
        );
      },
    );
  }
  // Sort gifts by the selected criteria
  void sortGifts(String criteria) {
    setState(() {
      sortBy = criteria;
      if (criteria == 'name') {
        gifts.sort((a, b) => a['name'].compareTo(b['name']));
      } else if (criteria == 'category') {
        gifts.sort((a, b) => a['category'].compareTo(b['category']));
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;
    return Scaffold(
      appBar: AppBar(
        title: Text('Gift List', style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.black87,
        iconTheme: IconThemeData(color: Colors.white),
      ),
      body: Stack(
        children: [
          Positioned.fill(
            child: Image.network(
              'https://images.unsplash.com/photo-1511886277144-49a67943f819?w=500&auto=format&fit=crop&q=60&ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxzZWFyY2h8MTc5fHxnaWZ0JTIwYmFja2dyb3VuZHxlbnwwfHwwfHx8MA%3D%3D',
              fit: BoxFit.cover,
            ),
          ),
          Positioned.fill(
            child: Container(color: Colors.black.withOpacity(0.1)),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    DropdownButton<String>(
                      iconEnabledColor: Colors.teal,
                      padding: EdgeInsets.symmetric(vertical: screenHeight * 0.001,horizontal: screenWidth * 0.02),
                      value: sortBy,
                      onChanged: (String? newValue) {
                        if (newValue != null) {
                          sortGifts(newValue);
                        }
                      },
                      items: <String>['name', 'category']
                          .map<DropdownMenuItem<String>>((String value) {
                        return DropdownMenuItem<String>(
                          value: value,
                          child: Text('Sort by $value', style: TextStyle(color: Colors.teal)),
                        );
                      }).toList(),
                    ),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(backgroundColor: Colors.white.withOpacity(0.6)),
                      onPressed: addGift,
                      child: Text("Add New Gift", style: TextStyle(color: Colors.black87)),
                    ),
                  ],
                ),
                SizedBox(height: 6),
                Expanded(
                  child: ListView.builder(
                    itemCount: gifts.length,
                    itemBuilder: (context, index) {
                      final gift = gifts[index];
                      return Card(
                        color: Colors.white.withOpacity(0.6),
                        margin:  EdgeInsets.symmetric(vertical: screenHeight * 0.01,horizontal: screenWidth * 0.001),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
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
                          title: Text(gift['name'], style: TextStyle(fontWeight: FontWeight.bold)),
                          subtitle: Text('Category: ${gift['category']} | Status: ${gift['isPledged'] == 1 ? 'Pledged' : 'Available'}'),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              if (gift['isPledged'] == 0)
                                IconButton(
                                  icon: Icon(Icons.edit),
                                  onPressed: () => editGift(index),
                                ),

                              IconButton(
                                icon: Icon(Icons.delete, color: Colors.red),
                                onPressed: () => deleteGift(index),
                              ),
                              IconButton(
                                icon: Icon(Icons.info_outline, color: Colors.teal),
                                onPressed: () {
                                  showDialog(
                                    context: context,
                                    builder: (context) {
                                      return AlertDialog(
                                        backgroundColor: Colors.white.withOpacity(0.6),
                                        title: Text('${gift['name']} Details',style: TextStyle(fontWeight: FontWeight.bold, fontSize: 24,color: Colors.teal),),
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
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      // Bottom Navigation Bar
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

import 'package:flutter/material.dart';
import 'PledgedGiftsPage.dart';
import 'mydatabase.dart';
import 'session_manger.dart';
import 'firebase.dart';// Your database class

class UserGiftListPage extends StatefulWidget {

  @override
  _UserGiftListPageState createState() => _UserGiftListPageState();
}

class _UserGiftListPageState extends State<UserGiftListPage> {
  int eventId = 0;
  List<Map<String, dynamic>> gifts = []; // List of all gifts
  List<Map<String, dynamic>> pledgedGifts = []; // List of pledged gifts
  String sortBy = 'name';
  late final FirestoreHelper firestoreHelper;// Default sorting criteria
  late final MyDatabaseClass mydb; // Database instance

  @override
  void initState() {
    super.initState();
    firestoreHelper = FirestoreHelper();
    loadGifts(); // Load events during initialization
  }
  // Load all gifts and filter pledged gifts
  void loadGifts() async {
    eventId = await getEventId(); // Get the eventId, perhaps from shared preferences or passed
    final data = await firestoreHelper.getGiftsForEvent(eventId); // Fetch gifts for the event

    setState(() {
      gifts = data;
      pledgedGifts = data.where((gift) => gift['isPledged'] == true).toList(); // Filter pledged gifts
    });
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
  // Function to pledge a gift
// Function to pledge a gift
  void pledgeGift(int index) async {
    final gift = gifts[index]; // Get the selected gift from the list
    final userId = await getUserId(); // Retrieve the logged-in user ID

    // Create an updated gift with isPledged set to true
    final updatedGift = {
      'ID': gift['ID'],
      'name': gift['name'],
      'category': gift['category'],
      'description': gift['description'],
      'price': gift['price'],
      'isPledged': true, // Set 'isPledged' to true
      'PledgedBy': userId, // Save the user ID as the person pledging the gift
    };

    // Update the gift in Firestore
    try {
      await firestoreHelper.updateGift(updatedGift); // Call FirestoreHelper's updateGift method
      loadGifts(); // Reload gifts after updating
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Gift pledged successfully!')),
      );
    } catch (e) {
      print('Error pledging gift: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error pledging gift')),
      );
    }
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
    return Scaffold(
      appBar: AppBar(
        title: Text('Gift List', style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.black87,
        actions: [
          IconButton(
            icon: Icon(Icons.list_alt, color: Colors.tealAccent),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => PledgedGiftsPage(pledgedGifts: pledgedGifts,),
                ),
              );
            },
          ),
        ],
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
                  ],
                ),
                SizedBox(height: 20),
                Expanded(
                  child: ListView.builder(
                    itemCount: gifts.length,
                    itemBuilder: (context, index) {
                      final gift = gifts[index];
                      return Card(
                        color: Colors.white.withOpacity(0.6),
                        margin: EdgeInsets.symmetric(vertical: 8.0),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                        child: ListTile(
                          title: Text(gift['name'], style: TextStyle(fontWeight: FontWeight.bold)),
                          subtitle: Text('Category: ${gift['category']} | Status: ${gift['isPledged'] == true ? 'Pledged' : 'Available'}'),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(
                                icon: Icon(
                                  Icons.volunteer_activism,
                                  color: gift['isPledged'] == true ? Colors.grey : Colors.teal,
                                ),
                                onPressed: gift['isPledged'] == true
                                    ? null // Disable the button if the gift is already pledged
                                    : () => pledgeGift(index),
                              ),
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

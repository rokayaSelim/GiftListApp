import 'package:flutter/material.dart';
import 'UserGiftListPage.dart';
import 'mydatabase.dart';
import 'session_manger.dart';
import 'firebase.dart';

class UserEventListPage extends StatefulWidget {
  @override
  _UserEventListPageState createState() => _UserEventListPageState();
}

class _UserEventListPageState extends State<UserEventListPage> {
  List<Map<String, dynamic>> events = [];
  String sortBy = 'name';
  String searchQuery = '';
  late final FirestoreHelper firestoreHelper;// Search query
  late final MyDatabaseClass mydb;

  @override
  void initState() {
    super.initState();
    firestoreHelper = FirestoreHelper();
    loadEvents(); // Load events during initialization
  }
  // Load events from Firestore with an optional search query
  void loadEvents({String searchQuery = ''}) async {
    final userId = await getFriendId(); // Assuming this method returns the friend's userId
    final userIdStr = userId.toString();
    if (userId != null) {
      print("Loading events for userId: $userId");

      // Fetch events from Firestore
      final data = await firestoreHelper.getEventsByUserId(userIdStr);

      // Debug log to check if events are fetched
      if (data.isEmpty) {
        print('No events found for user $userId');
      } else {
        print('Found ${data.length} events for user $userId');
      }

      setState(() {
        events = data.where((event) {
          return event['name'].toLowerCase().contains(searchQuery.toLowerCase()) ||
              event['category'].toLowerCase().contains(searchQuery.toLowerCase()) ||
              event['status'].toLowerCase().contains(searchQuery.toLowerCase());
        }).toList();
      });
    } else {
      print('User ID not found. Redirecting to login.');
      Navigator.pushReplacementNamed(context, '/login');
    }
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
  // Sort events based on criteria
  void sortEvents(String criteria) {
    setState(() {
      sortBy = criteria;
      if (criteria == 'name') {
        events.sort((a, b) => a['name'].compareTo(b['name']));
      } else if (criteria == 'category') {
        events.sort((a, b) => a['category'].compareTo(b['category']));
      } else if (criteria == 'status') {
        events.sort((a, b) => a['status'].compareTo(b['status']));
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Events',
          style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.black87,
        elevation: 0,
        iconTheme: IconThemeData(color: Colors.white),
      ),
      body: Stack(
        children: [
          Positioned.fill(
            child: Image.network(
              'https://images.unsplash.com/photo-1511886277144-49a67943f819?w=500&auto=format&fit=crop&q=60&ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxzZWFyY2h8MTc5fHxnaWZ0JTIwYmFja2dyb3VuZHxlbnwwfHwwfHx8MA%3D%3D',
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) {
                return Center(child: Text('Image not found'));
              },
            ),
          ),
          Positioned.fill(
            child: Container(
              color: Colors.black.withOpacity(0.1),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                Container(
                  child: Row(
                    children: [
                      Expanded(
                        child: TextField(
                          onChanged: (query) {
                            setState(() {
                              searchQuery = query;
                            });
                            loadEvents(searchQuery: searchQuery); // Implement search logic
                          },
                          decoration: InputDecoration(
                            contentPadding: EdgeInsets.all(16.0),
                            hintText: 'Search',
                            hintStyle: TextStyle(color: Colors.black87,fontWeight: FontWeight.bold),
                            border: InputBorder.none,
                            suffixIcon: Icon(Icons.search),

                          ),
                        ),
                      ),
                      PopupMenuButton<String>(
                        color: Colors.white.withOpacity(0.8),
                        icon: Icon(Icons.sort),
                        onSelected: (String criteria) {
                          sortEvents(criteria); // Call sortEvents with the selected criteria
                        },
                        itemBuilder: (context) => [
                          PopupMenuItem(
                            value: 'name',
                            child: Text('Sort by Name'),
                          ),
                          PopupMenuItem(
                            value: 'category',
                            child: Text('Sort by Category'),
                          ),
                          PopupMenuItem(
                            value: 'status',
                            child: Text('Sort by Status'),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: events.isEmpty
                      ? Center(child: Text('No upcoming events'))
                      : ListView.builder(
                      itemCount: events.length,
                      itemBuilder: (context, index) {
                      final event = events[index];
                      return Card(
                        color: Colors.white.withOpacity(0.6),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15.0),
                        ),
                        margin: EdgeInsets.symmetric(vertical: 8),
                        elevation: 3,
                        child: ListTile(
                          title: Text(event['name']),
                          subtitle: Text('Category: ${event['category']} | Status: ${event['status']}'),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(
                                icon: Icon(Icons.card_giftcard, color: Colors.teal),
                                onPressed: () async {
                                  // Save the event ID to shared preferences
                                  await saveEventId(event['ID']);
                                  // Navigate to the UserGiftListPage
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => UserGiftListPage(),
                                    ),
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

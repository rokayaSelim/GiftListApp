import 'package:flutter/material.dart';
import 'mydatabase.dart';

class EventListPage extends StatefulWidget {
  @override
  _EventListPageState createState() => _EventListPageState();
}

class _EventListPageState extends State<EventListPage> {
  List<Map<String, dynamic>> events = [];
  String sortBy = 'name';
  String searchQuery = ''; // Search query
  late final MyDatabaseClass db;

  @override
  void initState() {
    super.initState();
    db = MyDatabaseClass();
    db.init().then((_) {
      loadEvents(); // Load events during initialization
    });
  }

  // Load events from the database with an optional search query
  void loadEvents({String searchQuery = ''}) async {
    final data = await db.getAllEvents();
    setState(() {
      // Filter events based on the search query
      events = data.where((event) {
        return event['name'].toLowerCase().contains(searchQuery.toLowerCase()) ||
            event['category'].toLowerCase().contains(searchQuery.toLowerCase()) ||
            event['status'].toLowerCase().contains(searchQuery.toLowerCase());
      }).toList();
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
      Navigator.pushNamed(context, '/giftList');
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

  // Show add event dialog
  void _showAddEventDialog(int userID) {
    final TextEditingController eventNameController = TextEditingController();
    final TextEditingController eventCategoryController = TextEditingController();
    final TextEditingController eventDateController = TextEditingController();
    final TextEditingController eventLocationController = TextEditingController();
    final TextEditingController eventDescriptionController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Add New Event'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: eventNameController,
                decoration: InputDecoration(labelText: 'Event Name'),
              ),
              TextField(
                controller: eventCategoryController,
                decoration: InputDecoration(labelText: 'Category'),
              ),
              TextField(
                controller: eventDateController,
                decoration: InputDecoration(labelText: 'Date'),
              ),
              TextField(
                controller: eventLocationController,
                decoration: InputDecoration(labelText: 'Location'),
              ),
              TextField(
                controller: eventDescriptionController,
                decoration: InputDecoration(labelText: 'Description'),
              ),
            ],
          ),
          actions: [
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: Colors.teal[400]),
              onPressed: () async {
                if (eventNameController.text.isNotEmpty) {
                  await db.addEvent(
                    eventNameController.text,
                    eventDateController.text,
                    eventLocationController.text,
                    eventDescriptionController.text,
                    eventCategoryController.text,
                    userID, // Assuming the userID is passed to this method
                  );
                  loadEvents(); // Reload events from the database
                }
                Navigator.pop(context);
              },
              child: Text('Add'),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('Cancel', style: TextStyle(color: Colors.grey)),
            ),
          ],
        );
      },
    );
  }

  // Show edit event dialog
  void _showEditEventDialog(int eventID, String eventName, String eventCategory, String eventDate, String eventLocation, String eventDescription) {
    final TextEditingController eventNameController = TextEditingController(text: eventName);
    final TextEditingController eventCategoryController = TextEditingController(text: eventCategory);
    final TextEditingController eventDateController = TextEditingController(text: eventDate);
    final TextEditingController eventLocationController = TextEditingController(text: eventLocation);
    final TextEditingController eventDescriptionController = TextEditingController(text: eventDescription);

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Edit Event'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: eventNameController,
                decoration: InputDecoration(labelText: 'Event Name'),
              ),
              TextField(
                controller: eventCategoryController,
                decoration: InputDecoration(labelText: 'Category'),
              ),
              TextField(
                controller: eventDateController,
                decoration: InputDecoration(labelText: 'Date'),
              ),
              TextField(
                controller: eventLocationController,
                decoration: InputDecoration(labelText: 'Location'),
              ),
              TextField(
                controller: eventDescriptionController,
                decoration: InputDecoration(labelText: 'Description'),
              ),
            ],
          ),
          actions: [
            ElevatedButton(
              onPressed: () async {
                // Call the updateEvent method with 6 parameters
                await db.updateEvent(
                  eventID,                  // Pass the event's ID
                  eventNameController.text, // Pass the updated name
                  eventDateController.text, // Pass the updated date
                  eventLocationController.text, // Pass the updated location
                  eventDescriptionController.text, // Pass the updated description
                  eventCategoryController.text, // Pass the updated category
                  // Optionally, update the status as well
                );
                loadEvents(); // Reload events from the database
                Navigator.pop(context);
              },
              child: Text('Save'),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('Cancel', style: TextStyle(color: Colors.grey)),
            ),
          ],
        );
      },
    );
  }

  // Delete event from the database
  void deleteEvent(int eventID) async {
    await db.deleteEvent(eventID);
    loadEvents(); // Reload events from the database
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
              'https://images.pexels.com/photos/5485112/pexels-photo-5485112.jpeg',
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) {
                return Center(child: Text('Image not found'));
              },
            ),
          ),
          Positioned.fill(
            child: Container(
              color: Colors.black.withOpacity(0.3),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                Container(
                  child: Row(
                    children: [
                      IconButton(
                        onPressed: () => _showAddEventDialog(1), // Assuming user ID is 1
                        icon: Icon(Icons.add_circle, color: Colors.teal),
                      ),
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
                                icon: Icon(Icons.edit),
                                onPressed: () => _showEditEventDialog(
                                  event['ID'],             // Pass event ID
                                  event['name'],           // Pass event name
                                  event['category'],       // Pass event category
                                  event['date'],           // Pass event date
                                  event['location'],       // Pass event location
                                  event['description'],    // Pass event description
                                ),
                              ),
                              IconButton(
                                icon: Icon(Icons.delete, color: Colors.redAccent),
                                onPressed: () => deleteEvent(event['ID']),
                              ),
                              IconButton(
                                icon: Icon(Icons.card_giftcard, color: Colors.teal),
                                onPressed: () {
                                  Navigator.pushNamed(context, '/giftList');
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
            label: 'Events',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.card_giftcard),
            label: 'My Gifts',
          ),
        ],
        backgroundColor: Colors.black87,
        selectedItemColor: Colors.tealAccent,
        unselectedItemColor: Colors.white,
      ),
    );
  }
}

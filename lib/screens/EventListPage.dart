import 'package:flutter/material.dart';
import 'GiftListPage.dart';
import 'mydatabase.dart';
import 'session_manger.dart';
import 'firebase.dart';
import 'HomePage.dart';
import 'EventListPage.dart';
import 'ProfilePage.dart';


class EventListPage extends StatefulWidget {
  @override
  _EventListPageState createState() => _EventListPageState();
}

class _EventListPageState extends State<EventListPage> {
  List<Map<String, dynamic>> events = [];
  String sortBy = 'name';
  String searchQuery = ''; // Search query
  late final MyDatabaseClass mydb;

  @override
  void initState() {
    super.initState();
    mydb = MyDatabaseClass();
    mydb.init().then((_) {
      loadEvents(); // Load events during initialization
    });
  }
  // Load events from the database with an optional search query
  void loadEvents({String searchQuery = ''}) async {
    int? userId = await getUserId();  // Retrieve the user ID
    if (userId != null) {
      final data = await mydb.getEventsByUserId(userId);  // Pass user ID to the database method
      setState(() {
        events = data.where((event) {
          return event['name'].toLowerCase().contains(searchQuery.toLowerCase()) ||
              event['category'].toLowerCase().contains(searchQuery.toLowerCase()) ||
              event['status'].toLowerCase().contains(searchQuery.toLowerCase());
        }).toList();
      });
    }
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
      case '/giftList':
        page = GiftListPage();
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
  // Sort events based on criteria
  void sortEvents(String criteria) {
    setState(() {
      sortBy = criteria;
      if (criteria == 'name') {
        events.sort((a, b) => a['name'].compareTo(b['name']));
      } else if (criteria == 'category') {
        events.sort((a, b) => a['category'].compareTo(b['category']));
      } else if (criteria == 'status') {
        events.sort((a, b) => a['Status'].compareTo(b['Status']));
      }
    });
  }

  // Show add event dialog
  void _showAddEventDialog() async {
    final _formKey = GlobalKey<FormState>();
    final TextEditingController eventNameController = TextEditingController();
    final TextEditingController eventCategoryController = TextEditingController();
    final TextEditingController eventDateController = TextEditingController();
    final TextEditingController eventLocationController = TextEditingController();
    final TextEditingController eventDescriptionController = TextEditingController();
    final TextEditingController eventStatusController = TextEditingController();
    // Retrieve the user ID from SharedPreferences
    int? userId = await getUserId();

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Add New Event'),
          backgroundColor: Colors.white.withOpacity(0.6),
          content: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  controller: eventNameController,
                  decoration: InputDecoration(labelText: 'Event Name'),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Event name is required';
                    }
                    return null;
                  },
                ),
                TextFormField(
                  controller: eventCategoryController,
                  decoration: InputDecoration(labelText: 'Category'),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Category is required';
                    }
                    return null;
                  },
                ),
                TextFormField(
                  controller: eventDateController,
                  decoration: InputDecoration(labelText: 'Date'),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Date is required';
                    }
                    // Regular expression for validating the date format: yyyy-MM-dd
                    final dateRegex = RegExp(r'^\d{4}-\d{2}-\d{2}$');
                    if (!dateRegex.hasMatch(value)) {
                      return 'Enter a valid date (yyyy-MM-dd)';
                    }
                    return null; // No validation errors
                  },
                ),
                TextFormField(
                  controller: eventLocationController,
                  decoration: InputDecoration(labelText: 'Location'),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Location is required';
                    }
                    return null;
                  },
                ),
                TextFormField(
                  controller: eventDescriptionController,
                  decoration: InputDecoration(labelText: 'Description'),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Description is required';
                    }
                    return null;
                  },
                ),
                TextFormField(
                  controller: eventStatusController,
                  decoration: InputDecoration(labelText: 'Status'),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Status is required';
                    }
                    return null;
                  },
                ),
              ],
            ),
          ),
          actions: [
            ElevatedButton(
              onPressed: () async {
                if (_formKey.currentState!.validate() && userId != null) {
                  // Add the event to SQL and retrieve its ID
                  final sqlEventId = await mydb.addEvent(
                    eventNameController.text,
                    eventDateController.text,
                    eventLocationController.text,
                    eventDescriptionController.text,
                    eventCategoryController.text,
                    eventStatusController.text,
                    userId,
                  );

                  // Create a new event object
                  final newEvent = {
                    'ID': sqlEventId, // Use the SQL-generated ID
                    'name': eventNameController.text,
                    'category': eventCategoryController.text,
                    'date': eventDateController.text,
                    'location': eventLocationController.text,
                    'description': eventDescriptionController.text,
                    'Status':eventStatusController.text,
                    'userId': userId,
                    'isPublished': false, // New flag
                  };

                  // Show confirmation dialog for publishing
                  final shouldPublish = await showDialog<bool>(
                    context: context,
                    builder: (context) {
                      return AlertDialog(
                        title: Text('Publish Event'),
                        content: Text('Do you want to publish this event to your Friends?'),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.of(context).pop(false), // No
                            child: Text('No'),
                          ),
                          TextButton(
                            onPressed: () => Navigator.of(context).pop(true), // Yes
                            child: Text('Yes'),
                          ),
                        ],
                      );
                    },
                  );

                  if (shouldPublish == true) {
                    final firestoreHelper = FirestoreHelper();
                    newEvent['isPublished'] = true;

                    // Publish to Firestore with the same ID as SQL
                    await firestoreHelper.syncEvents([newEvent]);

                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Event published to Friends!')),
                    );
                    print("Event published to Friends!");
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Event saved for you only!')),
                    );
                  }
                  loadEvents();
                  Navigator.pop(context); // Close the dialog after all operations
                } else {
                  // If validation fails, show a message
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Please fill in all required fields.')),
                  );
                }
              },// Reload events
              child: Text('Add'),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('Cancel', style: TextStyle(color: Colors.black87)),
            ),
          ],
        );
      },
    );
  }
  void _showEditEventDialog(
      int eventID,
      String eventName,
      String eventCategory,
      String eventDate,
      String eventLocation,
      String eventDescription,
      String eventStatus,
      ) {
    final _formKey = GlobalKey<FormState>();
    final TextEditingController eventNameController = TextEditingController(text: eventName);
    final TextEditingController eventCategoryController = TextEditingController(text: eventCategory);
    final TextEditingController eventDateController = TextEditingController(text: eventDate);
    final TextEditingController eventLocationController = TextEditingController(text: eventLocation);
    final TextEditingController eventDescriptionController = TextEditingController(text: eventDescription);
    final TextEditingController eventStatusController = TextEditingController(text: eventStatus);
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Edit Event'),
          backgroundColor: Colors.white.withOpacity(0.6),
          content: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  controller: eventNameController,
                  decoration: InputDecoration(labelText: 'Event Name'),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Event name is required';
                    }
                    return null;
                  },
                ),
                TextFormField(
                  controller: eventCategoryController,
                  decoration: InputDecoration(labelText: 'Category'),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Category is required';
                    }
                    return null;
                  },
                ),
                TextFormField(
                  controller: eventDateController,
                  decoration: InputDecoration(labelText: 'Date'),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Date is required';
                    }
                    // Regular expression for validating the date format: yyyy-MM-dd
                    final dateRegex = RegExp(r'^\d{4}-\d{2}-\d{2}$');
                    if (!dateRegex.hasMatch(value)) {
                      return 'Enter a valid date (yyyy-MM-dd)';
                    }
                    return null; // No validation errors
                  },
                ),
                TextFormField(
                  controller: eventLocationController,
                  decoration: InputDecoration(labelText: 'Location'),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Location is required';
                    }
                    return null;
                  },
                ),
                TextFormField(
                  controller: eventDescriptionController,
                  decoration: InputDecoration(labelText: 'Description'),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Description is required';
                    }
                    return null;
                  },
                ),
                TextFormField(
                  controller: eventStatusController,
                  decoration: InputDecoration(labelText: 'Status'),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Status is required';
                    }
                    return null;
                  },
                ),
              ],
            ),
          ),
          actions: [
            ElevatedButton(
              onPressed: () async {
                try {
                  if (_formKey.currentState!.validate()) {
                    // Update the event in SQLite
                    await mydb.updateEvent(
                      eventID, // Pass the event's ID
                      eventNameController.text, // Pass the updated name
                      eventDateController.text, // Pass the updated date
                      eventLocationController.text, // Pass the updated location
                      eventDescriptionController.text, // Pass the updated description
                      eventCategoryController.text,
                      eventStatusController.text, // Pass the updated category
                    );
                    // Get the updated event from the local list
                    final updatedEvent = {
                      'ID': eventID,
                      'name': eventNameController.text,
                      'category': eventCategoryController.text,
                      'date': eventDateController.text,
                      'location': eventLocationController.text,
                      'description': eventDescriptionController.text,
                      'status': eventStatusController.text,
                    };
                    // Check if the event exists in Firestore
                    final firestoreHelper = FirestoreHelper();
                    final eventSnapshot = await firestoreHelper.getEventById(
                        eventID);
                    if (eventSnapshot.exists) {
                      // If the event exists, update it in Firestore
                      await firestoreHelper.updateEvent(
                          updatedEvent); // Update Firestore
                      print('Event updated in Firestore');
                    } else {
                      print(
                          'Event with ID $eventID does not exist in Firestore. No update performed.');
                    }
                    loadEvents(); // Reload events from the local database
                    Navigator.pop(context);
                  }// Close the dialog
                } catch (e) {
                  // Handle any errors that occur during the update process
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Error updating event: ${e.toString()}')),
                  );
                }
              },
              child: Text('Save'),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context), // Close the dialog without saving
              child: Text('Cancel', style: TextStyle(color: Colors.black87)),
            ),
          ],
        );
      },
    );
  }
  // Delete event from the database
  void deleteEvent(int? eventID) async {
    try {
      // Ensure the event ID is not null
      if (eventID == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: Event ID is null. Unable to delete.')),
        );
        return;
      }
      // If the event is published, delete it from Firestore
      final firestoreHelper = FirestoreHelper();
      await firestoreHelper.deleteEvent(eventID.toString()); // Ensure correct ID is passed
      // Delete the event locally from SQLite
      await mydb.deleteEvent(eventID);
      // Reload events from the local database
      loadEvents();
      // Show success message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Event deleted successfully!')),
      );
    } catch (e) {
      // Handle errors if any
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error deleting event: ${e.toString()}')),
      );
    }
  }
  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;
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
                      IconButton(
                        onPressed: () => _showAddEventDialog(), // Assuming user ID is 1
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
                        margin: EdgeInsets.symmetric(vertical: screenHeight * 0.01,horizontal: screenWidth * 0.01),
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
                                  event['description'],
                                  event['status'],// Pass event description
                                ),
                              ),
                              IconButton(
                                icon: Icon(Icons.delete, color: Colors.redAccent),
                                onPressed: () => deleteEvent(event['ID']),
                              ),
                              IconButton(
                                icon: Icon(Icons.card_giftcard, color: Colors.teal),
                                onPressed: () async {
                                  // Save the event ID to shared preferences
                                  await saveEventId(event['ID']);
                                  // Navigate to the UserGiftListPage
                                  _navigateWithFade(context, '/giftList');
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

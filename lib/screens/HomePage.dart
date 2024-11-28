import 'package:flutter/material.dart';

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  // List of friends with names and friend request statuses
  final List<Map<String, dynamic>> friends = [
    {"name": "Alice Johnson", "upcomingEvents": 3, "hasFriendRequest": true},
    {"name": "Bob Smith", "upcomingEvents": 1, "hasFriendRequest": false},
    {"name": "Catherine Lee", "upcomingEvents": 2, "hasFriendRequest": true},
    {"name": "David Brown", "upcomingEvents": 4, "hasFriendRequest": false},
    {"name": "Emma Wilson", "upcomingEvents": 0, "hasFriendRequest": true},
    {"name": "freddie Alison", "upcomingEvents": 6, "hasFriendRequest": true},
    {"name": "Jenson Button", "upcomingEvents": 5, "hasFriendRequest": false},
    {"name": "Dory Shelby", "upcomingEvents": 9, "hasFriendRequest": true},
    {"name": "lewis Tomlinson", "upcomingEvents": 7, "hasFriendRequest": true},
    {"name": "Harry McAdams", "upcomingEvents": 8, "hasFriendRequest": false},
    {"name": "Emily Henry", "upcomingEvents": 3, "hasFriendRequest": true},
  ];

  // List to hold filtered friends based on the search query
  List<Map<String, dynamic>> filteredFriends = [];

  // List to track added friends (friends that have the checkmark)
  List<Map<String, dynamic>> addedFriends = [];

  // Controller for the search field
  final TextEditingController _searchController = TextEditingController();

  // Selected index for the BottomNavigationBar
  int _selectedIndex = 0;

  @override
  void initState() {
    super.initState();

    // Initialize with one added friend (for example, Alice Johnson)
    addedFriends.add(friends[0]);  // Adds Alice Johnson as the initially added friend
    addedFriends.add(friends[7]);
    addedFriends.add(friends[4]);
    // Initially show only the friends that have been added (those with checkmarks)
    filteredFriends = friends.where((friend) => addedFriends.contains(friend)).toList();

    // Add listener to the search field to trigger search when the text changes
    _searchController.addListener(_filterFriends);
  }

  // Function to filter the list of friends based on the search query
  void _filterFriends() {
    final query = _searchController.text.toLowerCase();
    setState(() {
      if (query.isEmpty) {
        // If the search field is empty, show only the added friends
        filteredFriends = friends.where((friend) => addedFriends.contains(friend)).toList();
      } else {
        // Show all friends that match the search query, including the ones that are not added yet
        filteredFriends = friends.where((friend) {
          return friend['name'].toLowerCase().contains(query);
        }).toList();
      }
    });
  }

  // Function to mark a friend as added
  void _addFriend(Map<String, dynamic> newFriend) {
    setState(() {
      // Add the friend to the addedFriends list (only marking them, not removing from view)
      if (!addedFriends.contains(newFriend)) {
        addedFriends.add(newFriend);
      }
    });
  }

  // Function to handle bottom navigation selection
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

  @override
  void dispose() {
    _searchController.removeListener(_filterFriends);
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Hedieaty',
          style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.person, size: 35, color: Colors.white),
            onPressed: () {
              Navigator.pushNamed(context, '/profile');
            },
          ),
        ],
        backgroundColor: Colors.black87,
        elevation: 0,
        iconTheme: IconThemeData(color: Colors.white),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Navigator.pushNamed(context, '/eventList');
        },
        label: Text(
          'Create Event/List',
          style: TextStyle(fontSize: 16, color: Colors.white),
        ),
        icon: Icon(Icons.add, color: Colors.white),
        backgroundColor: Colors.black87,
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
          // Content on top of the background image
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 14.0, vertical: 20.0),
                child: Container(
                  padding: EdgeInsets.symmetric(horizontal: 10),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(15),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black26,
                        blurRadius: 5,
                        offset: Offset(0, 3),
                      ),
                    ],
                  ),
                  child: TextField(
                    controller: _searchController,
                    decoration: InputDecoration(
                      hintText: 'Search Friends',
                      hintStyle: TextStyle(color: Colors.black87),
                      border: InputBorder.none,
                      prefixIcon: Icon(Icons.search, color: Colors.teal[400]),
                      contentPadding: EdgeInsets.only(top: 12),
                    ),
                  ),
                ),
              ),
              SizedBox(height: 7),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Text(
                  'Friends',
                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.black87),
                ),
              ),
              SizedBox(height: 10),
              Expanded(
                child: ListView.builder(
                  itemCount: filteredFriends.length, // Use filtered list
                  padding: EdgeInsets.symmetric(horizontal: 16.0),
                  itemBuilder: (context, index) {
                    final friend = filteredFriends[index];
                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8.0),
                      child: Card(
                        elevation: 4,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15),
                        ),
                        child: ListTile(
                          leading: CircleAvatar(
                            radius: 30,
                            backgroundColor: Colors.teal[50],
                            child: Icon(Icons.person, size: 40, color: Colors.black87),
                          ),
                          title: Text(
                            friend['name'],
                            style: TextStyle(fontWeight: FontWeight.w600, fontSize: 18, color: Colors.black87),
                          ),
                          subtitle: Text(
                            'Upcoming Events: ${friend['upcomingEvents']}',
                            style: TextStyle(color: Colors.teal[600], fontSize: 15),
                          ),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              if (!addedFriends.contains(friend))
                                IconButton(
                                  icon: Icon(Icons.person_add, color: Colors.orangeAccent),
                                  onPressed: () {
                                    // Mark as added but don't remove from the list
                                    _addFriend(friend);
                                  },
                                ),
                              if (addedFriends.contains(friend))
                                Icon(Icons.check, color: Colors.green),
                              SizedBox(width: 10),
                              IconButton(
                                icon: Icon(Icons.arrow_forward_ios, color: Colors.teal[400]),
                                onPressed: () {
                                  Navigator.pushNamed(context, '/eventList');
                                },
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
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

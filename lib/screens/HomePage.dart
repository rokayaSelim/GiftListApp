import 'package:flutter/material.dart';
import 'mydatabase.dart'; // Import your database class file

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final MyDatabaseClass db = MyDatabaseClass(); // Initialize database instance

  List<Map<String, dynamic>> friends = []; // List to store users from the database
  List<Map<String, dynamic>> filteredFriends = [];
  List<Map<String, dynamic>> addedFriends = [];

  final TextEditingController _searchController = TextEditingController();
  int _selectedIndex = 0;

  @override
  void initState() {
    super.initState();
    _fetchUsersFromDatabase(); // Fetch users on initialization
    _searchController.addListener(_filterFriends);
  }

  Future<void> _fetchUsersFromDatabase() async {
    final users = await db.getAllUsers(); // Fetch users from database
    setState(() {
      friends = users.map((user) {
        return {
          "name": user['username'], // Assuming username is the name field
          "upcomingEvents": 0, // Placeholder, modify as needed
          "hasFriendRequest": false, // Placeholder, modify as needed
        };
      }).toList();
      filteredFriends = friends;
    });
  }

  void _filterFriends() {
    final query = _searchController.text.toLowerCase();
    setState(() {
      if (query.isEmpty) {
        filteredFriends = friends;
      } else {
        filteredFriends = friends.where((friend) {
          return friend['name'].toLowerCase().contains(query);
        }).toList();
      }
    });
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
    if (index == 0) Navigator.pushNamed(context, '/');
    if (index == 1) Navigator.pushNamed(context, '/eventList');
    if (index == 2) Navigator.pushNamed(context, '/giftList');
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
            onPressed: () => Navigator.pushNamed(context, '/profile'),
          ),
        ],
        backgroundColor: Colors.black87,
        elevation: 0,
        iconTheme: IconThemeData(color: Colors.white),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => Navigator.pushNamed(context, '/eventList'),
        label: Text(
          'Create Event/List',
          style: TextStyle(fontSize: 16, color: Colors.white),
        ),
        icon: Icon(Icons.add, color: Colors.white),
        backgroundColor: Colors.black87,
      ),
      body: Stack(
        children: [
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
          Positioned.fill(
            child: Container(
              color: Colors.black.withOpacity(0.1),
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
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
                  itemCount: filteredFriends.length,
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
                          trailing:IconButton(
                            icon: Icon(Icons.arrow_forward_ios, color: Colors.teal[400]),
                            onPressed: () {
                              Navigator.pushNamed(context, '/eventList');
                            },
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

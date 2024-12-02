import 'package:flutter/material.dart';
import 'mydatabase.dart';
import 'session_manger.dart'; // Import your session manager

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key); // Removed userEmail and userId

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final MyDatabaseClass db = MyDatabaseClass(); // Initialize database instance

  List<Map<String, dynamic>> friends = [];
  List<Map<String, dynamic>> filteredFriends = [];
  List<Map<String, dynamic>> addedFriends = [];

  final TextEditingController _searchController = TextEditingController();
  int _selectedIndex = 0;

  String userEmail = ''; // To store email of the current user
  String userName = ''; // To store username of the current user

  @override
  void initState() {
    super.initState();
    _initializeUserData();
    _searchController.addListener(_filterFriends);
  }

  // Function to initialize user data
  Future<void> _initializeUserData() async {
    try {
      // Get the current user's ID from session manager
      final currentUserId = await getUserId();
      if (currentUserId == null) {
        print('Current user ID is null');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to retrieve current user ID')),
        );
        return;
      }

      // Fetch the current user's data (email and username)
      final user = await db.getUserById(currentUserId);
      if (user != null) {
        setState(() {
          userName =
          user['username']; // Assuming 'username' field exists in your database
          userEmail =
          user['email']; // Assuming 'email' field exists in your database

        });
      }

      _fetchUsersFromDatabase(); // After getting user data, fetch all users
    } catch (e) {
      print('Error initializing user data: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to retrieve user data')),
      );
    }
  }

  Future<void> _addFriend(Map<String, dynamic> friend) async {
    try {
      final currentUserId = await getUserId();
      if (currentUserId == null) {
        print('Current user ID is null');
        return;
      }
      await db.addFriend(currentUserId, friend['ID']);
      setState(() {
        addedFriends.add(friend);
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('${friend['name']} added as a friend')),
      );
    } catch (e) {
      print('Error adding friend: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to add friend')),
      );
    }
  }


  Future<void> _fetchUsersFromDatabase() async {
    try {
      final currentUserId = await getUserId();
      if (currentUserId == null) {
        print('Current user ID is null');
        return;
      }

      final allUsers = await db.getAllUsers();
      final friendsList = await db.getFriends(currentUserId);
      final friendsIds = friendsList.map((friend) => friend['ID']).toSet();

      setState(() {
        friends = allUsers
            .where((user) => user['ID'] != currentUserId)
            .map((user) {
          return {
            "ID": user['ID'],
            "name": user['username'],
            "email": user['email'],
            "upcomingEvents": 0,
            "hasFriendRequest": false,
          };
        }).toList();

        addedFriends =
            friends.where((user) => friendsIds.contains(user['ID'])).toList();
        filteredFriends = List.from(friends);
      });
    } catch (e) {
      print('Error fetching friends from database: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to fetch friends')),
      );
    }
  }

  void _filterFriends() {
    final query = _searchController.text.toLowerCase();
    setState(() {
      if (query.isNotEmpty) {
        filteredFriends = friends.where((friend) {
          final nameMatches = friend['name'].toLowerCase().contains(query);
          final notCurrentUser = friend['email'] != userEmail;
          return nameMatches && notCurrentUser;
        }).toList();
      }
    });
  }

  void _onItemTapped(int index) async {
    setState(() {
      _selectedIndex = index;
    });
    if (index == 0) {
      Navigator.pushNamed(context, '/');
    }
    if (index == 1) {
      Navigator.pushNamed(context, '/eventList');
    }
    if (index == 2) {
      Navigator.pushNamed(context, '/profile');
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
          style: TextStyle(
              fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white),
        ),
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
                      Icons.broken_image, size: 100, color: Colors.grey),
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
                padding: const EdgeInsets.symmetric(
                    horizontal: 14.0, vertical: 20.0),
                child: Container(
                  padding: EdgeInsets.symmetric(horizontal: 10),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(15),
                    boxShadow: [
                      BoxShadow(color: Colors.black26,
                          blurRadius: 5,
                          offset: Offset(0, 3))
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
                  style: TextStyle(fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87),
                ),
              ),
              SizedBox(height: 10),
              Expanded(
                child: ListView.builder(
                  itemCount: filteredFriends.length,
                  padding: EdgeInsets.symmetric(horizontal: 16.0),
                  itemBuilder: (context, index) {
                    final friend = filteredFriends[index];
                    final isFriend = addedFriends.contains(friend);
                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8.0),
                      child: Card(
                        elevation: 4,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius
                            .circular(15)),
                        child: ListTile(
                          leading: CircleAvatar(
                            radius: 30,
                            backgroundColor: Colors.teal[50],
                            child: Icon(
                                Icons.person, size: 40, color: Colors.black87),
                          ),
                          title: Text(
                            friend['name'],
                            style: TextStyle(fontWeight: FontWeight.w600,
                                fontSize: 18,
                                color: Colors.black87),
                          ),
                          subtitle: Text(
                            'Upcoming Events: ${friend['upcomingEvents']}',
                            style: TextStyle(
                                color: Colors.teal[600], fontSize: 15),
                          ),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              if (!isFriend)
                                IconButton(
                                  icon: Icon(Icons.person_add,
                                      color: Colors.orangeAccent),
                                  onPressed: () => _addFriend(friend),
                                ),
                              if (isFriend)
                                IconButton(
                                  icon: Icon(
                                      Icons.person_remove, color: Colors.red),
                                  onPressed: () async {
                                    final currentUser = await db.getUserByEmail(
                                        userEmail);

                                    if (currentUser != null) {
                                      await db.removeFriend(
                                          currentUser['ID'], friend['ID']);
                                      setState(() {
                                        addedFriends.remove(friend);
                                        filteredFriends.remove(friend);
                                      });
                                      ScaffoldMessenger.of(context)
                                          .showSnackBar(
                                        SnackBar(content: Text(
                                            '${friend['name']} removed from friends')),
                                      );
                                    } else {
                                      ScaffoldMessenger.of(context)
                                          .showSnackBar(
                                        SnackBar(content: Text(
                                            'Failed to identify current user')),
                                      );
                                    }
                                  },
                                ),
                              SizedBox(width: 10),
                              IconButton(
                                icon: Icon(Icons.arrow_forward_ios,
                                    color: Colors.teal[400]),
                                onPressed: () {
                                  Navigator.pushNamed(
                                    context,
                                    '/friendDetails',
                                    arguments: {'friendId': friend['ID']},
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
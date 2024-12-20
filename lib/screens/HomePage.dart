import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'mydatabase.dart';
import 'session_manger.dart'; // Import your session manager
import 'firebase.dart';
import 'EventListPage.dart';
import 'UserEventListPage.dart';
import 'ProfilePage.dart';

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
  List<Map<String, dynamic>> allUsers = []; // Holds all users fetched
  List<Map<String, dynamic>> displayedUsers = []; // For the search modal
  final TextEditingController _searchController = TextEditingController();
  int _selectedIndex = 0;
  String userEmail = ''; // To store email of the current user
  String userName = '';
  late final FirestoreHelper firestoreHelper;
  late final MyDatabaseClass mydb;

  @override
  void initState() {
    super.initState();
    firestoreHelper = FirestoreHelper();
    _initializeUserData();
    _searchController.addListener(_filterFriends);
  }
  void _navigateWithFade(BuildContext context, String routeName) {
    // Define the page you want to navigate to based on the route name
    Widget page;
    switch (routeName) {
      case '/eventList':
        page = EventListPage();
        break;
      case '/usereventList':
        page = UserEventListPage();
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
      _fetchFriends(); // After getting user data, fetch all users
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
      final friendId = friend['ID'];
      // Prevent duplicate entries
      if (addedFriends.any((f) => f['ID'] == friendId)) {
        print('Friend already exists in addedFriends list');
        return;
      }
      // Add friend to local and Firestore
      await db.addFriend(currentUserId, friendId);
      await firestoreHelper.addFriendToFirestore(currentUserId, friendId);
      await _fetchFriends();
      setState(() {
        addedFriends.add(friend);
        friend['isFriend'] = true;
      });
      print('Friend ${friend['name']} (ID: $friendId) added successfully.');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('${friend['name']} added as a friend')),
      );
    } catch (e) {
      print('Error adding friend: $e');
    }
  }

  Future<void> _removeFriend(Map<String, dynamic> friend) async {
    try {
      final currentUserId = await getUserId();
      if (currentUserId == null) {
        print('Current user ID is null');
        return;
      }
      final friendId = friend['ID'];
      // Remove friend from local and Firestore
      await db.removeFriend(currentUserId, friendId);
      await firestoreHelper.deleteFriend(currentUserId, friendId);
      await _fetchFriends();
      setState(() {
        addedFriends.removeWhere((f) => f['ID'] == friendId);
        friend['isFriend'] = false;
      });
      print('Friend ${friend['name']} (ID: $friendId) removed successfully.');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('${friend['name']} removed from friends')),
      );
    } catch (e) {
      print('Error removing friend: $e');
    }
  }

  Future<void> _fetchUsers() async {
    try {
      final currentUserId = await getUserId();
      if (currentUserId == null) {
        print('Current user ID is null');
        return;
      }
      // Fetch friends from the local SQLite database
      final localFriends = await db.getFriends(currentUserId);
      final friendsIds = localFriends.map((f) => f['ID'].toString()).toSet();
      // Fetch all users from Firestore
      final usersCollection = FirebaseFirestore.instance.collection('users');
      final eventsCollection = FirebaseFirestore.instance.collection('events');

      final allUsersSnapshot = await usersCollection.get();
      final allUsers = allUsersSnapshot.docs
          .map((doc) => {'ID': doc.id, ...doc.data() as Map<String, dynamic>})
          .where((user) => user['ID'] != currentUserId)
          .toList();

      final allEventsSnapshot = await eventsCollection.get();
      final allEvents = allEventsSnapshot.docs
          .map((doc) => doc.data() as Map<String, dynamic>)
          .toList();
      // Update UI
      setState(() {
        friends = allUsers.map((user) {
          final isFriend = friendsIds.contains(user['ID'].toString());
          print('User ${user['username']} (ID: ${user['ID']}) isFriend: $isFriend');
          final friendEvents = allEvents.where((event) {
            print('Checking event: $event for user: ${user['ID']}');
            return event['userId'] == user['ID'] &&
                event['Status'] == 'upcoming';
          }).toList();
          final upcomingEventsCount = friendEvents.length;
          print('User ${user['username']} has $upcomingEventsCount upcoming events.');
          return {
            "ID": user['ID'],
            "name": user['username'] ?? 'Unknown',
            "email": user['email'],
            "phonenumber": user['phoneNumber'],
            "imagePath": user['imagePath'] ?? '',
            "isFriend": isFriend,
            "upcomingEventsCount": upcomingEventsCount,
          };
        }).toList();
        addedFriends = friends.where((user) => user['isFriend']).toList();
        displayedUsers = List.from(friends);
      });
      print('Fetched ${friends.length} users and ${addedFriends.length} friends.');
    } catch (e) {
      print('Error fetching friends: $e');
    }
  }
  Future<void> _fetchFriends() async {
    try {
      final currentUserId = await getUserId();
      if (currentUserId == null) {
        print('Current user ID is null');
        return;
      }
      final eventsCollection = FirebaseFirestore.instance.collection('events');

      final allEventsSnapshot = await eventsCollection.get();
      final allEvents = allEventsSnapshot.docs
          .map((doc) => doc.data() as Map<String, dynamic>)
          .toList();

      // Fetch friends from Firestore or local SQLite
      final localFriends = await db.getFriends(currentUserId);
      print('Local friends count: ${localFriends.length}');
      setState(() {
        friends = localFriends.map((friend) {
          final friendEvents = allEvents.where((event) {
            print('Checking event: $event for user: ${friend['ID']}');
            return event['userId'] == friend['ID'] &&
                event['Status'] == 'upcoming';
          }).toList();
          final upcomingEventsCount = friendEvents.length;
          print('User ${friend['username']} has $upcomingEventsCount upcoming events.');
          return {
            "ID": friend['ID'],
            "name": friend['username'] ?? 'Unknown',
            "email": friend['email'],
            "phonenumber": friend['phoneNumber'],
            "imagePath": friend['imagePath'] ?? '',
            "isFriend": true, // Since they are already friends
            "upcomingEventsCount": upcomingEventsCount,
          };
        }).toList();
        filteredFriends = List.from(friends);
        addedFriends = List.from(friends); // Initialize as all friends
      });
      print('Fetched ${friends.length} friends successfully.');
    } catch (e) {
      print('Error fetching friends: $e');
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
  void showCustomSearch() {
    _fetchUsers(); // Fetch updated list of users
    setState(() {
      displayedUsers = List.from(allUsers); // Initialize with all users
    });
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) {
        final screenHeight = MediaQuery.of(context).size.height;
        final screenWidth = MediaQuery.of(context).size.width;
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Container(
              height: MediaQuery.of(context).size.height,
              width: MediaQuery.of(context).size.width,
              decoration: BoxDecoration(
                image: DecorationImage(
                  image: NetworkImage(
                      'https://images.unsplash.com/photo-1511886277144-49a67943f819?w=500&auto=format&fit=crop&q=60'),
                  fit: BoxFit.cover,
                ),
              ),
              child: Stack(
                children: [
                  Container(color: Colors.black.withOpacity(0.1)),
                  Column(
                    children: [
                      SizedBox(height: 50),
                      Padding(
                        padding: EdgeInsets.symmetric(vertical: screenHeight * 0.001,horizontal: screenWidth * 0.04),
                        child: Row(
                          children: [
                            IconButton(
                              icon: Icon(Icons.arrow_back, color: Colors.white),
                              onPressed: () => Navigator.of(context).pop(),
                            ),
                            Expanded(
                              child: TextField(
                                autofocus: true,
                                onChanged: (value) {
                                  setModalState(() {
                                    displayedUsers = value.isEmpty
                                        ? List.from(allUsers)
                                        : allUsers.where((user) =>
                                        user['name']
                                            .toLowerCase()
                                            .contains(value.toLowerCase()))
                                        .toList();
                                  });
                                },
                                style: TextStyle(color: Colors.white),
                                decoration: InputDecoration(
                                  hintText: 'Search all users...',
                                  hintStyle: TextStyle(color: Colors.black87),
                                  filled: true,
                                  fillColor: Colors.white.withOpacity(0.6),
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12.0),
                                    borderSide: BorderSide.none,
                                  ),
                                  prefixIcon: Icon(Icons.search, color: Colors.teal),
                                  contentPadding:  EdgeInsets.symmetric(vertical: screenHeight * 0.001,horizontal: screenWidth * 0.01),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(height: 10),
                      Expanded(
                        child: ListView.builder(
                          itemCount: displayedUsers.length,
                          padding:  EdgeInsets.symmetric(vertical: screenHeight * 0.001,horizontal: screenWidth * 0.03),
                          itemBuilder: (context, index) {
                            final user = displayedUsers[index];
                            final isFriend = addedFriends.any((f) => f['ID'] == user['ID']);
                            return Padding(
                              padding: const EdgeInsets.symmetric(vertical: 6.0),
                              child: Card(
                                color: Colors.white.withOpacity(0.6),
                                elevation: 4,
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(15)),
                                child: ListTile(
                                  leading: CircleAvatar(
                                    radius: 30,
                                    backgroundColor: Colors.teal[50],
                                    backgroundImage: user['imagePath'] != null &&
                                        user['imagePath'].isNotEmpty
                                        ? NetworkImage(user['imagePath'])
                                        : AssetImage('assets/images/default_profile.png')
                                    as ImageProvider,
                                  ),
                                  title: Text(
                                    user['name'],
                                    style: TextStyle(
                                      fontWeight: FontWeight.w600,
                                      fontSize: 20,
                                      color: Colors.black87,
                                    ),
                                  ),
                                  subtitle: Text(
                                    'Upcoming Events: ${user['upcomingEventsCount'] ?? 0}',
                                    style: TextStyle(
                                        color: Colors.teal[600], fontSize: 16),
                                  ),
                                  trailing: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      if (!isFriend)
                                        IconButton(
                                          icon: Icon(Icons.person_add,
                                              color: Colors.orangeAccent),
                                          onPressed: () async {
                                            await _addFriend(user);
                                            setModalState(() {
                                              user['isFriend'] = true;
                                            });
                                          },
                                        ),
                                      if (isFriend)
                                        IconButton(
                                          icon: Icon(Icons.person_remove,
                                              color: Colors.red),
                                          onPressed: () async {
                                            await _removeFriend(user);
                                            setModalState(() {
                                              user['isFriend'] = false;
                                            });
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
            );
          },
        );
      },
    );
  }
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
  @override
  void dispose() {
    _searchController.removeListener(_filterFriends);
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;
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
        onPressed: () =>  _navigateWithFade(context, '/eventList'),
        label: Text(
          'Create Event/List',
          style: TextStyle(fontSize: 16, color: Colors.black87),
        ),
        icon: Icon(Icons.add, color: Colors.black87),
        backgroundColor: Colors.white.withOpacity(0.6),
      ),
      body: Stack(
        children: [
          Positioned.fill(
            child: Image.network(
              'https://images.unsplash.com/photo-1511886277144-49a67943f819?w=500&auto=format&fit=crop&q=60&ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxzZWFyY2h8MTc5fHxnaWZ0JTIwYmFja2dyb3VuZHxlbnwwfHwwfHx8MA%3D%3D',
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
                  padding: EdgeInsets.symmetric(vertical: screenHeight * 0.001,horizontal: screenWidth * 0.02),
                  decoration: BoxDecoration(
                    color:Colors.white.withOpacity(0.6),
                    borderRadius: BorderRadius.circular(15),
                    boxShadow: [
                      BoxShadow(color: Colors.black26,
                          blurRadius: 5,
                          offset: Offset(0, 3))
                    ],
                  ),
                  child: TextField(
                    controller: _searchController,
                    onTap: showCustomSearch, // Opens the search modal
                    readOnly: true, // Prevents editing in the main screen
                    decoration: InputDecoration(
                      hintText: 'Search Friends',
                      hintStyle: TextStyle(color: Colors.black87),
                      border: InputBorder.none,
                      prefixIcon: Icon(Icons.search, color: Colors.teal[400]),
                      contentPadding: EdgeInsets.only(top: 13),
                    ),
                  )
                ),
              ),
              SizedBox(height: 7),
              Padding(
                padding:  EdgeInsets.symmetric(vertical: screenHeight * 0.001,horizontal: screenWidth * 0.04),
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
                  padding:EdgeInsets.symmetric(vertical: screenHeight * 0.001,horizontal: screenWidth * 0.03),
                  itemBuilder: (context, index) {
                    final friend = filteredFriends[index];
                    final isFriend = addedFriends.any((f) => f['ID'] == friend['ID']);
                    print('Friend ${friend['name']} isFriend: $isFriend');
                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8.0),
                      child: Card(
                        color: Colors.white.withOpacity(0.6),
                        elevation: 4,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius
                            .circular(15)),
                        child: ListTile(
                          leading: CircleAvatar(
                            radius: 30,
                            backgroundColor: Colors.teal[50],
                            backgroundImage: friend['imagePath'] != null && friend['imagePath'].isNotEmpty
                                ? NetworkImage(friend['imagePath'])  // Replace with Image URL or Firebase path
                                : AssetImage('assets/images/default_profile.png') as ImageProvider,  // Default profile image if no image path
                          ),

                          title: Text(
                            friend['name'],
                            style: TextStyle(fontWeight: FontWeight.w600,
                                fontSize: 20,
                                color: Colors.black87),
                          ),
                          subtitle: Text(
                            'Upcoming Events: ${friend['upcomingEventsCount']}',
                            style: TextStyle(
                                color: Colors.teal[600], fontSize: 16),
                          ),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              if (!isFriend)
                                if (!isFriend)
                                  IconButton(
                                    icon: Icon(Icons.person_add, color: Colors.orangeAccent),
                                    onPressed: () => _addFriend(friend),  // Use _addFriend method
                                  ),
                              if (isFriend)
                                IconButton(
                                  icon: Icon(Icons.person_remove, color: Colors.red),
                                  onPressed: () => _removeFriend(friend),  // Use _removeFriend method
                                ),
                              IconButton(
                                icon: Icon(Icons.arrow_forward_ios,
                                    color: Colors.teal[400]),
                                onPressed: () async {
                                  final friendId = friend['ID'];
                                  await saveFriendId(friendId);
                                  _navigateWithFade(context, '/usereventList');
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
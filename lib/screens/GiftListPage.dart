import 'package:flutter/material.dart';
import 'PledgedGiftsPage.dart';
import 'mydatabase.dart'; // Your database class

class GiftListPage extends StatefulWidget {
  @override
  _GiftListPageState createState() => _GiftListPageState();
}

class _GiftListPageState extends State<GiftListPage> {
  List<Map<String, dynamic>> gifts = []; // List of all gifts
  List<Map<String, dynamic>> pledgedGifts = []; // List of pledged gifts
  String sortBy = 'name'; // Default sorting criteria
  late final MyDatabaseClass db; // Database instance

  @override
  void initState() {
    super.initState();
    db = MyDatabaseClass();
    db.init().then((_) {
      loadGifts(); // Load all gifts from the database
    });
  }

  // Load all gifts and filter pledged gifts
  void loadGifts() async {
    final data = await db.getAllGifts();
    setState(() {
      gifts = data;
      pledgedGifts = data.where((gift) => gift['isPledged'] == 1).toList(); // Filter pledged gifts
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
  // Function to pledge a gift
  void pledgeGift(int index) async {
    final gift = gifts[index];
    await db.updateGift(
      gift['ID'],
      gift['name'],
      gift['category'],
      gift['description'],
      gift['price'],
      true, // Set `isPledged` to true
    );
    loadGifts(); // Reload gifts after updating
  }

  // Function to add a new gift
  void addGift() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        String name = '';
        String category = '';
        String description = '';
        double price = 0.0;

        return AlertDialog(
          title: Text('Add New Gift'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                onChanged: (value) => name = value,
                decoration: InputDecoration(labelText: 'Gift Name'),
              ),
              TextField(
                onChanged: (value) => category = value,
                decoration: InputDecoration(labelText: 'Category'),
              ),
              TextField(
                onChanged: (value) => description = value,
                decoration: InputDecoration(labelText: 'Description'),
              ),
              TextField(
                onChanged: (value) => price = double.tryParse(value) ?? 0.0,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(labelText: 'Price'),
              ),
            ],
          ),
          actions: [
            ElevatedButton(
              onPressed: () async {
                if (name.isNotEmpty && category.isNotEmpty && price > 0) {
                  await db.addGift(name, category, description, price); // Add gift to database
                  loadGifts(); // Reload gifts
                  Navigator.pop(context); // Close the dialog
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Please fill all fields properly')),
                  );
                }
              },
              child: Text('Add'),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context), // Close dialog
              child: Text('Cancel'),
            ),
          ],
        );
      },
    );
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
              onPressed: () {
                db.updateGift(gifts[index]['ID'], name, category, description, price, gifts[index]['isPledged'] == 1);
                Navigator.pop(context);
                loadGifts(); // Reload gifts
              },
              child: Text('Save'),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context),
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
          actions: [
            TextButton(
              onPressed: () {
                db.deleteGift(gifts[index]['ID']); // Delete the gift from the database
                loadGifts(); // Reload gifts
                Navigator.pop(context);
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
              'https://images.pexels.com/photos/5485112/pexels-photo-5485112.jpeg',
              fit: BoxFit.cover,
            ),
          ),
          Positioned.fill(
            child: Container(color: Colors.black.withOpacity(0.5)),
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
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(backgroundColor: Colors.black87),
                      onPressed: addGift,
                      child: Text("Add New Gift", style: TextStyle(color: Colors.white)),
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
                        margin: EdgeInsets.symmetric(vertical: 8.0),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                        child: ListTile(
                          title: Text(gift['name'], style: TextStyle(fontWeight: FontWeight.bold)),
                          subtitle: Text('Category: ${gift['category']} | Status: ${gift['isPledged'] == 1 ? 'Pledged' : 'Available'}'),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(
                                icon: Icon(Icons.edit),
                                onPressed: () => editGift(index),
                              ),
                              IconButton(
                                icon: Icon(Icons.delete, color: Colors.red),
                                onPressed: () => deleteGift(index),
                              ),
                              IconButton(
                                icon: Icon(
                                  Icons.volunteer_activism,
                                  color: gift['isPledged'] == 1 ? Colors.grey : Colors.teal,
                                ),
                                onPressed: gift['isPledged'] == 1 ? null : () => pledgeGift(index),
                              ),
                              IconButton(
                                icon: Icon(Icons.info_outline, color: Colors.blueGrey),
                                onPressed: () {
                                  Navigator.pushNamed(context, '/giftDetails');
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

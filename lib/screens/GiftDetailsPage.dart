import 'package:flutter/material.dart';
import 'mydatabase.dart';
import 'firebase.dart';

class GiftDetailsPage extends StatefulWidget {
  final int eventId; // Event ID to associate the gift with

  GiftDetailsPage({required this.eventId});

  @override
  _GiftDetailsPageState createState() => _GiftDetailsPageState();
}

class _GiftDetailsPageState extends State<GiftDetailsPage> {
  final _formKey = GlobalKey<FormState>();
  late String name, category, description, imagePath;
  late double price;
  bool isPledged = false;
  int value = 0;

  @override
  void initState() {
    super.initState();
    name = '';
    category = 'Electronics';
    description = '';
    price = 0.0;
    imagePath = '';
    isPledged = false;
    value = 0;
  }

  void saveGift() async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();

      final db = MyDatabaseClass();
      final firestoreHelper = FirestoreHelper();

      int value = isPledged ? 1 : 0;

      // Add the gift to the SQL database and retrieve the generated ID
      final sqlGiftId = await db.addGift(name, category, description, price, widget.eventId, value ,imagePath);

      // Create a new gift object with the SQL-generated ID
      final newGift = {
        'ID': sqlGiftId, // Use the ID from SQL
        'name': name,
        'category': category,
        'description': description,
        'price': price,
        'eventId': widget.eventId,
        'PledgedBy': null,
        'isPledged': isPledged,
        'imagePath': imagePath,
      };

      // Confirmation dialog to ask the user about publishing
      final shouldPublish = await showDialog<bool>(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text('Publish Gift'),
            content: Text('Do you want to publish this gift to your friends?'),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(false),
                child: Text('No'),
              ),
              TextButton(
                onPressed: () => Navigator.of(context).pop(true),
                child: Text('Yes'),
              ),
            ],
          );
        },
      );
      // Default to false if user cancels
      if (shouldPublish == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Gift saved for you only!')),
        );
        return;
      }
      // Publish to Firestore if requested
      if (shouldPublish) {
        await firestoreHelper.syncGifts([newGift]);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Gift published to Friends!')),
        );
        print("Gift published to Friends!");
      }
      Navigator.pop(context, true); // Return to the previous page
    }
  }

  void showAddImageDialog() async {
    final TextEditingController _imageUrlController = TextEditingController();

    final result = await showDialog<String>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Add Image URL'),
          content: TextField(
            controller: _imageUrlController,
            decoration: InputDecoration(
              hintText: 'Enter image URL',
              border: OutlineInputBorder(),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(_imageUrlController.text.trim());
              },
              child: Text('Save'),
            ),
          ],
        );
      },
    );
    if (result != null && result.isNotEmpty) {
      setState(() {
        imagePath = result;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Image URL saved successfully!')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Add New Gift' ,
          style: TextStyle(
            color: Colors.white,
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Colors.black87,
        iconTheme: IconThemeData(color: Colors.white),
      ),
      body: Stack(
        children: [
          // Background image with a fallback to a grey background
          Positioned.fill(
            child: Image.network(
              'https://images.unsplash.com/photo-1511886277144-49a67943f819?w=500&auto=format&fit=crop&q=60&ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxzZWFyY2h8MTc5fHxnaWZ0JTIwYmFja2dyb3VuZHxlbnwwfHwwfHx8MA%3D%3D',
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) {
                return Container(color: Colors.grey[200]);
              },
            ),
          ),
          Positioned.fill(
            child: Container(color: Colors.black.withOpacity(0.3)), // Slight overlay
          ),
         Positioned(
            top: 20,
            left: 10,
            right: 10,
            child: Card(
              color: Colors.white.withOpacity(0.6),
              shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
              ),
              elevation: 5,
              child: Padding(
                padding: const EdgeInsets.all(14.0),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      TextFormField(
                        initialValue: name,
                        decoration: InputDecoration(
                          labelText: 'Gift Name',
                          border: OutlineInputBorder(),
                        ),
                        validator: (value) => value == null || value.isEmpty
                            ? 'Please enter a name'
                            : null,
                        onSaved: (value) => name = value!,
                      ),
                      SizedBox(height: 16),
                      TextFormField(
                        initialValue: description,
                        decoration: InputDecoration(
                          labelText: 'Description',
                          border: OutlineInputBorder(),
                        ),
                        onSaved: (value) => description = value!,
                      ),
                      SizedBox(height: 16),
                      DropdownButtonFormField<String>(
                        value: category,
                        decoration: InputDecoration(
                          labelText: 'Category',
                          border: OutlineInputBorder(),
                        ),
                        items: ['Electronics', 'Books', 'Clothing', 'Other']
                            .map((String category) => DropdownMenuItem<String>(
                          value: category,
                          child: Text(category),
                        ))
                            .toList(),
                        onChanged: (value) => setState(() => category = value!),
                      ),
                      SizedBox(height: 16),
                      TextFormField(
                        decoration: InputDecoration(
                          labelText: 'Price',
                          prefixText: '\$',
                          border: OutlineInputBorder(),
                        ),
                        keyboardType: TextInputType.number,
                        validator: (value) => (double.tryParse(value!) ?? 0) > 0
                            ? null
                            : 'Please enter a valid price',
                        onSaved: (value) => price = double.parse(value!),
                      ),
                      SizedBox(height: 24),
                      Center(
                        child: ElevatedButton.icon(
                          onPressed: showAddImageDialog,
                          icon: Icon(Icons.link, color: Colors.teal),
                          label: Text(
                            'Add Image',
                            style: TextStyle(color: Colors.teal),
                          ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white,
                          padding: EdgeInsets.symmetric(vertical: 12, horizontal: 30),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
                    ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Pledge Gift',
                            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                          ),
                          Switch(
                            value: isPledged,
                            onChanged: (value) {
                              setState(() {
                                isPledged = value;
                              });
                            },
                            activeColor: Colors.teal,
                            inactiveTrackColor: Colors.grey.shade400,
                          ),
                        ],
                      ),
                      if (isPledged)
                      Padding(
                      padding: const EdgeInsets.only(top: 8.0, left: 16.0),
                      child: Text(
                      'NOTE: Pledged gifts cannot be modified',
                      style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
                        ),
                      ),
                      SizedBox(height: 24),
                      Center(
                        child: ElevatedButton(
                          onPressed: saveGift,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.white,
                            padding: EdgeInsets.symmetric(vertical: 12, horizontal: 30),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: Text(
                            'Add Gift',
                            style: TextStyle(color: Colors.teal, fontSize: 16),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

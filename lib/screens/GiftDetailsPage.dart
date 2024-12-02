import 'package:flutter/material.dart';
import 'mydatabase.dart';

class GiftDetailsPage extends StatefulWidget {
  final Map<String, dynamic>? gift; // Existing gift data for editing
  final int eventId; // Event ID to associate the gift with

  GiftDetailsPage({this.gift, required this.eventId});

  @override
  _GiftDetailsPageState createState() => _GiftDetailsPageState();
}

class _GiftDetailsPageState extends State<GiftDetailsPage> {
  final _formKey = GlobalKey<FormState>();
  late String name, category, description;
  late double price;
  bool isPledged = false;

  @override
  void initState() {
    super.initState();
    // Pre-fill form if editing an existing gift
    name = widget.gift?['name'] ?? '';
    category = widget.gift?['category'] ?? 'Electronics';
    description = widget.gift?['description'] ?? '';
    price = widget.gift?['price']?.toDouble() ?? 0.0;
    isPledged = widget.gift?['isPledged'] == 1;
  }

  void saveGift() async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();
      final db = MyDatabaseClass();
      if (widget.gift == null) {
        // Adding a new gift
        await db.addGift(name, category, description, price, widget.eventId);
      } else {
        // Editing an existing gift
        await db.updateGift(
          widget.gift!['ID'],
          name,
          category,
          description,
          price,
          isPledged,
        );
      }
      Navigator.pop(context, true); // Return to the previous page
    }
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.gift == null ? 'Add New Gift' : 'Edit Gift',
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
                        initialValue: price.toString(),
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
                      ElevatedButton.icon(
                        onPressed: () {
                          // Logic for uploading an image (placeholder)
                        },
                        icon: Icon(Icons.upload, color: Colors.teal),
                        label: Text(
                          'Upload Image',
                          style: TextStyle(color: Colors.teal),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white,
                          padding: EdgeInsets.symmetric(vertical: 12, horizontal: 115,),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
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
                            widget.gift == null ? 'Add Gift' : 'Save Changes',
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

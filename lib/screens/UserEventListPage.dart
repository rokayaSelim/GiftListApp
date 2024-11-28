import 'package:flutter/material.dart';

class UserEventListPage extends StatelessWidget {
  final String friendName;
  final List<Map<String, dynamic>> events;

  UserEventListPage({required this.friendName, required this.events});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('$friendName\'s Events'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            ElevatedButton(
              onPressed: () {
                _showAddEventDialog(context);
              },
              child: Text("Add New Event"),
            ),
            SizedBox(height: 20),
            // Check if there are events to display
            if (events.isEmpty)
              Center(child: Text('No upcoming events available for $friendName.'))
            else
              Expanded(
                child: ListView.builder(
                  itemCount: events.length,
                  itemBuilder: (context, index) {
                    final event = events[index];
                    return Card(
                      margin: EdgeInsets.symmetric(vertical: 8),
                      child: ListTile(
                        title: Text(event['name']),
                        subtitle: Text('Category: ${event['category']} | Status: ${event['status']}'),
                      ),
                    );
                  },
                ),
              ),
          ],
        ),
      ),
    );
  }

  void _showAddEventDialog(BuildContext context) {
    final TextEditingController eventNameController = TextEditingController();
    final TextEditingController eventCategoryController = TextEditingController();

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
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                if (eventNameController.text.isNotEmpty && eventCategoryController.text.isNotEmpty) {
                  // Logic to add the new event
                  // This is where you would handle adding the event to your data structure
                  // For example, notify the main page to refresh events if needed
                  print('Adding event: ${eventNameController.text}, Category: ${eventCategoryController.text}');
                }
                Navigator.pop(context);
              },
              child: Text('Add'),
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
}

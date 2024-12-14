import 'package:cloud_firestore/cloud_firestore.dart';

class FirestoreHelper {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<void> syncUsers(List<Map<String, dynamic>> users) async {
    for (var user in users) {
      await _firestore.collection('users').doc(user['ID'].toString()).set(user);
    }
  }
  // Delete a specific user from Firestore
  Future<void> deleteUser(String userId) async {
    try {
      await _firestore.collection('users').doc(userId).delete();
      print('Event $userId successfully deleted from Firestore.');
    } catch (e) {
      throw Exception('Error deleting user from Firestore: $e');
    }
  }
  Future<void> syncEvents(List<Map<String, dynamic>> events) async {
    for (var event in events) {
      try {
        await _firestore
            .collection('events')
            .doc(event['ID'].toString()) // Use the event ID as the document ID
            .set(event, SetOptions(merge: true)); // Merge to avoid overwriting
      } catch (e) {
        print('Error syncing event ${event['ID']}: $e');
      }
    }
  }
  Future<List<Map<String, dynamic>>> getEventsByUserId(String userId) async {
    try {
      print("Fetching events from Firestore for userId: $userId");

      // Ensure the userId is treated as an integer in the query
      final int parsedUserId = int.tryParse(userId) ?? 0;

      // Fetch events where the userId matches the friend's userId
      QuerySnapshot snapshot = await _firestore
          .collection('events')
          .where('userID', isEqualTo: parsedUserId) // Compare as integer
          .get();

      print("Fetched ${snapshot.docs.length} events from Firestore");

      // Convert the query snapshot to a list of maps
      return snapshot.docs.map((doc) => doc.data() as Map<String, dynamic>).toList();
    } catch (e) {
      print('Error fetching events for user $userId: $e');
      return []; // Return an empty list in case of error
    }
  }


  Future<DocumentSnapshot> getEventById(int eventId) async {
    try {
      return await _firestore.collection('events').doc(eventId.toString()).get();
    } catch (e) {
      print('Error fetching event with ID $eventId: $e');
      throw Exception('Error fetching event: $e');
    }
  }
  // Update a specific event in Firestore
  Future<void> updateEvent(Map<String, dynamic> event) async {
    try {
      await _firestore
          .collection('events')
          .doc(event['ID'].toString())
          .set(event, SetOptions(merge: true)); // Ensure fields are merged
    } catch (e) {
      print('Error updating event ${event['ID']}: $e');
    }
  }
  // Delete an event from Firestore
  Future<void> deleteEvent(String eventId) async {
    try {
      await _firestore.collection('events').doc(eventId).delete();
      print('Event $eventId successfully deleted from Firestore.');
    } catch (e) {
      print('Error deleting event $eventId: $e');
      throw Exception('Error deleting event $eventId from Firestore: $e');
    }
  }
  Future<void> syncGifts(List<Map<String, dynamic>> gifts) async {
    for (var gift in gifts) {
      await _firestore.collection('gifts').doc(gift['ID'].toString()).set(gift);
    }
  }
  Future<List<Map<String, dynamic>>> getGiftsForEvent(int eventId) async {
    try {
      print("Fetching gifts from Firestore for eventId: $eventId");

      // Query Firestore to get gifts associated with the specific eventId
      QuerySnapshot snapshot = await _firestore
          .collection('gifts')
          .where('eventId', isEqualTo: eventId) // Assuming you have 'eventID' field in gifts collection
          .get();

      print("Fetched ${snapshot.docs.length} gifts from Firestore");

      // Convert query snapshot to a list of maps
      return snapshot.docs.map((doc) => doc.data() as Map<String, dynamic>).toList();
    } catch (e) {
      print('Error fetching gifts for eventId $eventId: $e');
      return []; // Return an empty list in case of error
    }
  }

  // Get gift by ID
  Future<DocumentSnapshot> getGiftById(int giftId) async {
    try {
      return await _firestore.collection('gifts').doc(giftId.toString()).get();
    } catch (e) {
      print('Error fetching gift with ID $giftId: $e');
      throw Exception('Error fetching gift: $e');
    }
  }
  // Update gift in Firestore
  Future<void> updateGift(Map<String, dynamic> gift) async {
    try {
      await _firestore
          .collection('gifts')
          .doc(gift['ID'].toString()) // Use the gift ID as the document ID
          .set(gift, SetOptions(merge: true)); // Merge to avoid overwriting
    } catch (e) {
      print('Error updating gift ${gift['ID']}: $e');
    }
  }
  // Update gift in Firestore
  Future<void> deleteGift(String giftId) async {
    try {
      await _firestore.collection('gifts').doc(giftId).delete();
      print('Event $giftId successfully deleted from Firestore.');
    } catch (e) {
      print('Error deleting event $giftId: $e');
      throw Exception('Error deleting event $giftId from Firestore: $e');
    }
  }

  Future<void> syncFriends(List<Map<String, dynamic>> friends) async {
    for (var friend in friends) {
      await _firestore.collection('friends').doc(friend['ID'].toString()).set(friend);
    }
  }
}

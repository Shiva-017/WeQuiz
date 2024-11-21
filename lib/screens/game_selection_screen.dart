import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class GameSelectionScreen extends StatelessWidget {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<List<Map<String, dynamic>>> _getActiveGames() async {
    // Fetch active game rooms from Firestore
    QuerySnapshot querySnapshot =
        await _firestore.collection('gameRooms').get();
    List<Map<String, dynamic>> activeGames = querySnapshot.docs
        .where((doc) => doc['isActive'] == true) // Filter active games
        .map((doc) => {
              'id': doc.id,
              'questions': doc['questions'],
              'players': doc['players'],
            })
        .toList();
    return activeGames;
  }

  Future<String> _createNewGame(currentUser) async {
    // Create a new game room in Firestore
    DocumentReference newGameRef =
        await _firestore.collection('gameRooms').add({
      'questions': [], // Empty array to hold questions
      'players': [currentUser],
      'isActive': true, // Game status is active
      'createdAt': Timestamp.now(),
    });

    return newGameRef.id; // Return the room ID of the new game
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Select a Game'),
        titleTextStyle: TextStyle(color: Colors.white, fontSize: 20),
        centerTitle: true,
        backgroundColor: Colors.deepPurple,
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          children: [
            // StreamBuilder for fetching active games
            StreamBuilder<QuerySnapshot>(
              stream: _firestore
                  .collection('gameRooms')
                  .where('isActive', isEqualTo: true) // Only active games
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(child: CircularProgressIndicator());
                }

                if (snapshot.hasError) {
                  return Center(child: Text('Error fetching games'));
                }

                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return Center(child: Text('No active games available'));
                }

                return Expanded(
                  child: ListView.builder(
                    shrinkWrap: true,
                    itemCount: snapshot.data!.docs.length,
                    itemBuilder: (context, index) {
                      final gameDoc = snapshot.data!.docs[index];
                      final roomId = gameDoc.id;
                      final questions = gameDoc['questions'] as List;
                      final players = gameDoc['players'] as List;

                      return Card(
                        shadowColor: Colors.deepPurple,
                        surfaceTintColor: Colors.grey,
                        margin: EdgeInsets.symmetric(vertical: 8.0),
                        elevation: 5,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12.0),
                        ),
                        child: ListTile(
                          contentPadding: EdgeInsets.all(16.0),
                          title: Text(
                            'Game Room $roomId',
                            style: TextStyle(
                                fontSize: 18, fontWeight: FontWeight.bold),
                          ),
                          subtitle: Text(
                            'Players: ${players.length}, Questions: ${questions.length}',
                            style: TextStyle(fontSize: 14),
                          ),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              ElevatedButton(
                                onPressed: () {
                                  // Navigate to Join Game screen
                                  Navigator.pushNamed(
                                    context,
                                    '/create-quiz',
                                    arguments: roomId,
                                  );
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.blueAccent,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                ),
                                child: Text('Join',
                                    style: TextStyle(color: Colors.white)),
                              ),
                              SizedBox(width: 10),
                              ElevatedButton(
                                onPressed: () {
                                  // Navigate to Start Game screen
                                  Navigator.pushNamed(
                                    context,
                                    '/start-quiz',
                                    arguments: roomId,
                                  );
                                },
                                style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.green,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    textStyle: TextStyle(color: Colors.white)),
                                child: Text(
                                  'Start Game',
                                  style: TextStyle(color: Colors.white),
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                );
              },
            ),
            SizedBox(height: 20),
            // "Create New Game" button
            ElevatedButton(
              onPressed: () async {
                final currentUser = ModalRoute.of(context)!.settings.arguments;
                String newRoomId = await _createNewGame(currentUser);
                Navigator.pushNamed(
                  context,
                  '/create-quiz',
                  arguments: newRoomId,
                );
              },
              style: ElevatedButton.styleFrom(
                textStyle: TextStyle(fontSize: 18, color: Colors.white),
                backgroundColor: Colors.deepPurple, // Button color
                padding: EdgeInsets.symmetric(vertical: 12, horizontal: 24),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12), // Rounded corners
                ),
              ),
              child: Text('Create New Game',
                  style: TextStyle(color: Colors.white)),
            ),
          ],
        ),
      ),
    );
  }
}

import 'package:cloud_firestore/cloud_firestore.dart';

Future<void> createGameRoom(String roomId, List<String> playerIds) async {
  await FirebaseFirestore.instance.collection('gameRooms').doc(roomId).set({
    'players': playerIds,
    'questions': [],
    'scores': {for (var id in playerIds) id: 0},
  });
}

Future<void> submitQuestion(
    String roomId, String question, String answer, String playerId) async {
  final roomRef =
      FirebaseFirestore.instance.collection('gameRooms').doc(roomId);
  await roomRef.update({
    'questions': FieldValue.arrayUnion([
      {'question': question, 'answer': answer, 'submittedBy': playerId}
    ])
  });
}

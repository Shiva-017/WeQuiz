import 'dart:async';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:audioplayers/audioplayers.dart';

class StartQuizScreen extends StatefulWidget {
  final String roomId;

  StartQuizScreen({required this.roomId});

  @override
  _StartQuizScreenState createState() => _StartQuizScreenState();
}

class _StartQuizScreenState extends State<StartQuizScreen> {
  int _currentQuestionIndex = 0;
  int _timeLeft = 30;
  Timer? _timer;
  List questions = [];
  int totalQuestions = 0;
  int score = 0;
  String? selectedAnswer;
  bool isAnswered = false;
  final AudioPlayer _audioPlayer = AudioPlayer();

  @override
  void initState() {
    super.initState();
    _getQuestions();
    _startTimer();
  }

  void _playWrongSoundEffect() async {
    await _audioPlayer.play(AssetSource('sounds/wrong.mp3'));
  }

  void _playCorrectSoundEffect() async {
    await _audioPlayer.play(AssetSource('sounds/correct.mp3'));
  }

  void _getQuestions() async {
    DocumentSnapshot doc = await FirebaseFirestore.instance
        .collection('gameRooms')
        .doc(widget.roomId)
        .get();

    setState(() {
      questions = doc['questions'];
      totalQuestions = questions.length;
    });
  }

  void _startTimer() {
    _timer = Timer.periodic(Duration(seconds: 1), (timer) {
      if (_timeLeft > 0) {
        setState(() {
          _timeLeft--;
        });
      } else {
        _submitAnswer();
      }
    });
  }

  void _submitAnswer([String? answer]) {
    if (isAnswered) return;

    setState(() {
      isAnswered = true;
      selectedAnswer = answer;

      // Check if the answer is correct and update the score
      if (answer == questions[_currentQuestionIndex]['correctAnswer']) {
        _playCorrectSoundEffect();
        score += 10; // Increase score by 10 for a correct answer
      } else {
        _playWrongSoundEffect();
      }

      // Show answer for 1 second, then proceed to the next question
      Future.delayed(Duration(seconds: 1), () {
        if (_currentQuestionIndex >= totalQuestions - 1) {
          _endQuiz();
        } else {
          setState(() {
            _currentQuestionIndex++;
            _timeLeft = 30;
            selectedAnswer = null;
            isAnswered = false;
          });
        }
      });
    });
  }

  void _endQuiz() async {
    _timer?.cancel();

    // Store the final score in the user's document in the 'userScores' collection
    User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      final userScoresRef =
          FirebaseFirestore.instance.collection('userScores').doc(user.email);

      await userScoresRef.set(
          {
            'scores': FieldValue.arrayUnion([
              {'roomId': widget.roomId, 'score': score}
            ])
          },
          SetOptions(
              merge: true)); // Use merge to avoid overwriting existing data
    }

    Navigator.pushNamed(context, '/leaderboard', arguments: widget.roomId);
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
    _audioPlayer.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (questions.isEmpty) {
      return Scaffold(
        appBar: AppBar(title: Text("Start Quiz")),
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Quiz Game",
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.deepPurple,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildScoreAndTimer(),
            SizedBox(height: 20),
            _buildQuestionCard(),
            SizedBox(height: 20),
            _buildAnswerButtons(),
          ],
        ),
      ),
    );
  }

  Widget _buildScoreAndTimer() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          "Score: $score",
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        Text(
          "Time Left: $_timeLeft s",
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.red,
          ),
        ),
      ],
    );
  }

  Widget _buildQuestionCard() {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.deepPurple.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.deepPurple, width: 2),
      ),
      child: Text(
        "Q${_currentQuestionIndex + 1}. ${questions[_currentQuestionIndex]['question']}",
        style: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildAnswerButtons() {
    return Column(
      children:
          questions[_currentQuestionIndex]['answers'].map<Widget>((answer) {
        bool isCorrect =
            answer == questions[_currentQuestionIndex]['correctAnswer'];
        double opacity = isAnswered ? 1.0 : 0.0;

        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 8.0),
          child: Stack(
            children: [
              // Hidden color layer (revealed upon selection)
              Opacity(
                opacity: opacity,
                child: AnimatedOpacity(
                  opacity: opacity,
                  duration: Duration(milliseconds: 300),
                  child: Container(
                    decoration: BoxDecoration(
                      color: isCorrect ? Colors.green : Colors.red,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    width: double.infinity,
                    height: 50,
                  ),
                ),
              ),
              // Button layer
              ElevatedButton(
                onPressed: isAnswered ? null : () => _submitAnswer(answer),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue.shade400,
                  foregroundColor: Colors.white,
                  minimumSize: Size(double.infinity, 50),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                child: Text(
                  answer,
                  style: TextStyle(fontSize: 18, color: Colors.white),
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }
}

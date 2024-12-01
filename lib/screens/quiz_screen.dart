import 'package:flutter/material.dart';

class QuizDisplay extends StatefulWidget {
  final Map<String, dynamic> quizData;

  const QuizDisplay({Key? key, required this.quizData}) : super(key: key);

  @override
  _QuizDisplayState createState() => _QuizDisplayState();
}

class _QuizDisplayState extends State<QuizDisplay> {
  int currentQuestionIndex = 0;
  int score = 0;
  String? selectedAnswer;
  bool isAnswered = false;

  @override
  Widget build(BuildContext context) {
    List<dynamic> questions = widget.quizData['questions'];
    var currentQuestion = questions[currentQuestionIndex];

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Quiz Game',
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
            const SizedBox(height: 20),
            _buildQuestionCard(currentQuestion['question']),
            const SizedBox(height: 20),
            _buildAnswerButtons(currentQuestion),
            const SizedBox(height: 20),
            _buildNextButton(questions),
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
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        Text(
          "Question ${currentQuestionIndex + 1}",
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
      ],
    );
  }

  Widget _buildQuestionCard(String question) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.deepPurple.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.deepPurple, width: 2),
      ),
      child: Text(
        "Q${currentQuestionIndex + 1}. $question",
        style: const TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildAnswerButtons(Map<String, dynamic> currentQuestion) {
    return Column(
      children: (currentQuestion['options'] as Map<String, dynamic>)
          .entries
          .map<Widget>((option) {
        String key = option.key;
        String value = option.value;
        bool isCorrect = value == currentQuestion['answer'].substring(3);

        // Default background color and opacity
        Color backgroundColor = Colors.white;
        double opacity =
            isAnswered ? 1.0 : 0.0; // Fully visible after answering
        Color textColor = Colors.black; // Text is always visible

        // Adjust background color after answering
        if (isAnswered) {
          if (key == currentQuestion['answer'].substring(0, 1)) {
            // Highlight the correct answer
            backgroundColor = Colors.green;
          } else if (selectedAnswer == key) {
            // Highlight the selected answer (if wrong, make it red)
            backgroundColor = isCorrect ? Colors.green : Colors.red;
          } else {
            // Non-selected options stay gray
            backgroundColor = Colors.grey.shade300;
          }
        }

        return GestureDetector(
          onTap: isAnswered
              ? null // Prevent further interaction after answering
              : () {
                  setState(() {
                    isAnswered = true;
                    selectedAnswer = key;

                    // Increment score only if the selected answer is correct
                    if (isCorrect) {
                      score += 10;
                    }
                  });
                },
          child: Stack(
            children: [
              // Background container with opacity
              Opacity(
                opacity: isAnswered ? 1.0 : 0.0, // Control opacity dynamically
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  margin: const EdgeInsets.symmetric(vertical: 8),
                  decoration: BoxDecoration(
                    color: backgroundColor,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  height: 50,
                ),
              ),
              // Always visible text
              Positioned.fill(
                child: Center(
                  child: Text(
                    value,
                    style: TextStyle(
                      fontSize: 18,
                      color: textColor, // Text stays visible at all times
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }

  Widget _buildNextButton(List<dynamic> questions) {
    return ElevatedButton(
      onPressed: isAnswered
          ? () {
              if (currentQuestionIndex < questions.length - 1) {
                setState(() {
                  currentQuestionIndex++;
                  selectedAnswer = null;
                  isAnswered = false; // Reset for the next question
                });
              } else {
                _showQuizFinishedDialog();
              }
            }
          : null,
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.deepPurple,
        foregroundColor: Colors.white,
        minimumSize: const Size(double.infinity, 50),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
      ),
      child: Text(
        currentQuestionIndex == questions.length - 1
            ? 'Finish Quiz'
            : 'Next Question',
        style: const TextStyle(fontSize: 18),
      ),
    );
  }

  void _showQuizFinishedDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Quiz Finished'),
          content: Text('Your final score is $score'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('OK'),
            ),
          ],
        );
      },
    );
  }
}

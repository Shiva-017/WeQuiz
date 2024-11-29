import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class QuizDisplay extends StatelessWidget {
  final Map<String, dynamic> quizData;

  const QuizDisplay({Key? key, required this.quizData}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Quiz Generated:',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 16.0),
          Text('Question: ${quizData['question'] ?? 'N/A'}'),
          const SizedBox(height: 8.0),
          ...((quizData['options'] as List<dynamic>? ?? [])
              .map((option) => Text('- $option'))
              .toList()),
          const SizedBox(height: 16.0),
          ElevatedButton(
            onPressed: () {
              // Handle quiz submission logic if needed
            },
            child: Text('Submit'),
          ),
        ],
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class CreateQuizScreen extends StatefulWidget {
  final String roomId;

  CreateQuizScreen({required this.roomId});

  @override
  _CreateQuizScreenState createState() => _CreateQuizScreenState();
}

class _CreateQuizScreenState extends State<CreateQuizScreen> {
  final TextEditingController _questionController = TextEditingController();
  final List<TextEditingController> _optionControllers =
      List.generate(4, (_) => TextEditingController());
  String? _correctAnswer;
  bool _isLoading = true;

  Future<void> _populateOptions() async {
    setState(() {
      // Check if all option fields are populated (i.e., text length > 0)
      _isLoading =
          _optionControllers.every((controller) => controller.text.isNotEmpty)
              ? false
              : true;
    });
  }

  Future<void> _addQuestion() async {
    if (_questionController.text.isEmpty || _correctAnswer == null) {
      // Handle validation
      return;
    }

    List<String> options = _optionControllers.map((c) => c.text).toList();
    await FirebaseFirestore.instance
        .collection('gameRooms')
        .doc(widget.roomId)
        .update({
      'questions': FieldValue.arrayUnion([
        {
          'question': _questionController.text,
          'answers': options,
          'correctAnswer': _correctAnswer,
        }
      ]),
    });

    // Clear inputs after adding question
    _questionController.clear();
    _optionControllers.forEach((c) => c.clear());
    setState(() {
      _correctAnswer = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Create Quiz"),
        titleTextStyle: TextStyle(color: Colors.white, fontSize: 20),
        backgroundColor: Colors.deepPurple,
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // Question TextField
            TextField(
              controller: _questionController,
              decoration: InputDecoration(
                labelText: "Enter your question",
                labelStyle: TextStyle(color: Colors.deepPurple),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
            SizedBox(height: 16),

            // Options TextFields
            ...List.generate(4, (index) {
              return Padding(
                padding: const EdgeInsets.only(bottom: 12.0),
                child: TextField(
                  controller: _optionControllers[index],
                  decoration: InputDecoration(
                    labelText: "Option ${index + 1}",
                    labelStyle: TextStyle(color: Colors.deepPurple),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  onChanged: (_) {
                    _populateOptions(); // Check if options are populated after each change
                  },
                ),
              );
            }),

            // Correct Answer Dropdown
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 12.0),
              child: _isLoading
                  ? Center(child: CircularProgressIndicator())
                  : DropdownButtonFormField<String>(
                      hint: Text("Select Correct Answer"),
                      value: _correctAnswer,
                      onChanged: (String? value) {
                        setState(() {
                          _correctAnswer = value;
                        });
                      },
                      items: _optionControllers.map((controller) {
                        return DropdownMenuItem<String>(
                          value: controller.text,
                          child: Text(controller.text),
                        );
                      }).toList(),
                      decoration: InputDecoration(
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
            ),

            // Add Question Button
            ElevatedButton(
              onPressed: _addQuestion,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.deepPurple, // Button color
                padding: EdgeInsets.symmetric(vertical: 16.0, horizontal: 32.0),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12), // Rounded corners
                ),
                textStyle: TextStyle(fontSize: 18),
              ),
              child: Text(
                "Add Question",
                style: TextStyle(color: Colors.white),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

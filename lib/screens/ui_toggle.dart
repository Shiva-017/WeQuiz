import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';

class QuizModeSelector extends StatefulWidget {
  @override
  _QuizModeSelectorState createState() => _QuizModeSelectorState();
}

class _QuizModeSelectorState extends State<QuizModeSelector>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _topButtonAnimation;
  late Animation<double> _bottomButtonAnimation;
  final AudioPlayer _audioPlayer = AudioPlayer();

  @override
  void initState() {
    super.initState();

    // Initialize animation controller
    _controller = AnimationController(
      vsync: this,
      duration: Duration(seconds: 2),
    );

    // Define animations for top and bottom buttons with adjusted start positions
    _topButtonAnimation = Tween<double>(
      begin: -200, // Start higher to make space for the bottom button
      end: 0, // Settle in the center
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.bounceOut,
    ));

    _bottomButtonAnimation = Tween<double>(
      begin: 200, // Start lower, but within range to avoid overlap
      end: 0, // Settle in the center, below the top button
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.bounceOut,
    ));

    // Start animation and play sound after a small delay
    Future.delayed(Duration(milliseconds: 500), () {
      _controller.forward();
    });

    // Listen to animation status to play bounce sound after animation completes
    _controller.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        _playMusicEffect(); // Start the looping music after the bounce sound
      }
    });
  }

  void _playBounceSoundEffect() async {
    await _audioPlayer.play(AssetSource('sounds/bounce.mp3'));
  }

  void _playMusicEffect() async {
    await _audioPlayer.setReleaseMode(ReleaseMode.loop); // Loop the music
    await _audioPlayer.play(AssetSource('sounds/music.mp3'));
  }

  @override
  void dispose() {
    _controller.dispose();
    _audioPlayer.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Choose Quiz Mode"),
        backgroundColor: Colors.deepPurple,
      ),
      body: Stack(
        fit: StackFit.expand,
        children: [
          // Background image
          Image.asset(
            'assets/images/locquiz.jpg', // Replace with your asset image
            fit: BoxFit.cover,
          ),
          Center(
            child: Stack(
              children: [
                // Top button
                AnimatedBuilder(
                  animation: _topButtonAnimation,
                  builder: (context, child) {
                    return Positioned(
                      top: MediaQuery.of(context).size.height / 2 +
                          _topButtonAnimation.value -
                          30,
                      left: MediaQuery.of(context).size.width * 0.1,
                      right: MediaQuery.of(context).size.width * 0.1,
                      child: child!,
                    );
                  },
                  child: _buildPanelButton(
                    context,
                    label: "Multiplayer Quiz",
                    onPressed: () {
                      Navigator.pushNamed(context, '/location-quiz');
                      _audioPlayer.stop(); // Stop music when navigating
                    },
                  ),
                ),
                // Bottom button
                AnimatedBuilder(
                  animation: _bottomButtonAnimation,
                  builder: (context, child) {
                    return Positioned(
                      top: MediaQuery.of(context).size.height / 2 +
                          _bottomButtonAnimation.value +
                          100, // Adjust spacing
                      left: MediaQuery.of(context).size.width * 0.1,
                      right: MediaQuery.of(context).size.width * 0.1,
                      child: child!,
                    );
                  },
                  child: _buildPanelButton(
                    context,
                    label: "Location-Based Quiz",
                    onPressed: () {
                      Navigator.pushNamed(context, '/location-quiz');
                      _audioPlayer.stop(); // Stop music when navigating
                    },
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPanelButton(BuildContext context,
      {required String label, required VoidCallback onPressed}) {
    return Container(
      height: 100, // Make buttons large
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            offset: Offset(0, 4),
            blurRadius: 6,
          ),
        ],
      ),
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.transparent,
          shadowColor: Colors.transparent,
          padding: EdgeInsets.symmetric(vertical: 16, horizontal: 32),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
        ),
        child: Text(
          label,
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        ),
      ),
    );
  }
}

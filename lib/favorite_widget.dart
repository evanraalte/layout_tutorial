import 'package:flutter/material.dart';
import 'package:confetti/confetti.dart';

class FavoriteWidget extends StatefulWidget {
  const FavoriteWidget({super.key});

  @override
  State<FavoriteWidget> createState() => _FavoriteWidgetState();
}

class _FavoriteWidgetState extends State<FavoriteWidget> {
  bool _isFavorited = false;
  int _favoriteCount = 0;
  final ConfettiController _confettiController =
      ConfettiController(duration: const Duration(milliseconds: 500));
  Duration animationDuration = const Duration(milliseconds: 200);

  @override
  void dispose() {
    _confettiController.dispose();
    super.dispose();
  }

  void _toggleFavorite() {
    setState(() {
      if (_isFavorited) {
        _favoriteCount -= 1;
        _isFavorited = false;
      } else {
        _favoriteCount += 1;
        _isFavorited = true;
        _confettiController.play();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _toggleFavorite,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.all(0),
            child: AnimatedSwitcher(
              duration: animationDuration,
              transitionBuilder: (Widget child, Animation<double> animation) {
                return ScaleTransition(scale: animation, child: child);
              },
              child: Icon(
                _isFavorited ? Icons.star : Icons.star_border,
                key: ValueKey<bool>(_isFavorited),
                color: Colors.red[500],
                size: 24,
              ),
            ),
          ),
          SizedBox(width: 18, child: Text('$_favoriteCount')),
          ConfettiWidget(
            confettiController: _confettiController,
            blastDirectionality:
                BlastDirectionality.explosive, // Full-screen blast
            shouldLoop: false,
            colors: const [
              Colors.green,
              Colors.blue,
              Colors.pink,
              Colors.orange,
              Colors.purple
            ], // Add more colors as you like
            maxBlastForce: 20, // set a lower max blast force
            minBlastForce: 2, // set a lower min blast force
            numberOfParticles: 500, // number of particles to be emitted
          ),
        ],
      ),
    );
  }
}

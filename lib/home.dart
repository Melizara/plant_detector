import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class AccueilScreen extends StatelessWidget {
  const AccueilScreen({super.key, required this.onStart});

  final VoidCallback onStart;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: [
          // Affichage de l'image SVG en fond
          SvgPicture.asset(
            'assets/images/background.svg', // adapte ce chemin
            fit: BoxFit.cover,
          ),
          // Flèche en bas à droite
          Positioned(
            bottom: 80,
            right: 30,
            child: ElevatedButton(
              onPressed: onStart,
              style: ElevatedButton.styleFrom(
                shape: const CircleBorder(),
                padding: const EdgeInsets.all(20),
                backgroundColor: Colors.green,
                elevation: 5,
              ),
              child: const Icon(
                Icons.arrow_forward,
                color: Colors.white,
                size: 30,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

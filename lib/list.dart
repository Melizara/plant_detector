import 'package:flutter/material.dart';

class HistoriquePage extends StatelessWidget {
  final List<String> historique;

  HistoriquePage({super.key, required this.historique});

  // Dictionnaire anglais → français
  final Map<String, String> plantesFrancais = {
    'apple': 'Pomme',
    'blueberry': 'Myrtille',
    'cherry': 'Cerise',
    'corn maize': 'Maïs',
    'grape': 'Raisin',
    'orange': 'Orange',
    'peach': 'Pêche',
    'pepper bell': 'Poivron',
    'potato': 'Pomme de terre',
    'raspberry': 'Framboise',
    'soybean': 'Soja',
    'squash': 'Courge',
    'strawberry': 'Fraise',
    'tomato': 'Tomate',
  };

  // Fonction pour obtenir le nom français simple
  String getNomPlanteFrancais(String label) {
    label = label.toLowerCase();
    for (final planteAng in plantesFrancais.keys) {
      if (label.startsWith(planteAng)) {
        return plantesFrancais[planteAng]!;
      }
    }
    return "Plante inconnue";
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('PlantDetector'),
        backgroundColor: Colors.green[300],
      ),
      backgroundColor: Colors.green[50],
      body: historique.isEmpty
          ? const Center(child: Text('Aucune plante détectée pour le moment.'))
          : ListView.builder(
              itemCount: historique.length,
              itemBuilder: (context, index) {
                // On récupère le nom français simplifié ici
                final nomFrancais = getNomPlanteFrancais(historique[index]);

                return Card(
                  margin: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  elevation: 3,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: ListTile(
                    leading: const Icon(
                      Icons.local_florist,
                      color: Colors.green,
                    ),
                    title: Text(
                      nomFrancais,
                      style: const TextStyle(fontWeight: FontWeight.w600),
                    ),
                  ),
                );
              },
            ),
    );
  }
}

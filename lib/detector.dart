import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:tflite_flutter/tflite_flutter.dart';
import 'package:image/image.dart' as img;

class PlantDetector extends StatefulWidget {
  final void Function(String) onDetected;

  const PlantDetector({super.key, required this.onDetected});

  @override
  State<PlantDetector> createState() => _PlantDetectorState();
}

class _PlantDetectorState extends State<PlantDetector> {
  final ImagePicker _picker = ImagePicker();
  File? _image;
  late Interpreter _interpreter;
  late List<String> _labels;
  String _prediction = "Aucune détection";
  Map<String, String> _infos = {};

  final Map<String, Map<String, String>> infosPlantes = {
    'apple apple scab': {
      'ensoleillement': 'Eviter l’humidité prolongée, exposition variable',
      'sol': 'Sol bien drainé, éviter l’excès d’humidité',
      'arrosage': 'Réduire l’arrosage pour éviter l’humidité stagnante',
      'entretien': 'Traitements fongicides, éliminer feuilles infectées',
    },
    'apple black rot': {
      'ensoleillement': 'Plein soleil conseillé pour sécher le feuillage',
      'sol': 'Sol bien drainé',
      'arrosage': 'Eviter l’excès d’humidité',
      'entretien': 'Éliminer les fruits tombés, traitement antifongique',
    },
    'apple cedar apple rust': {
      'ensoleillement': 'Plein soleil pour réduire humidité',
      'sol': 'Sol bien drainé',
      'arrosage': 'Arrosage modéré, éviter humidité sur feuilles',
      'entretien': 'Pulvérisation de fongicides, enlever parties atteintes',
    },
    'apple healthy': {
      'ensoleillement': 'Soleil partiel à plein soleil',
      'sol': 'Sol bien drainé, légèrement acide',
      'arrosage': 'Régulier, surtout pendant la fructification',
      'entretien': 'Taille annuelle, fertilisation au printemps',
    },
    'blueberry healthy': {
      'ensoleillement': 'Plein soleil à mi-ombre',
      'sol': 'Sol acide, riche en matière organique',
      'arrosage': 'Arrosage régulier, garder sol humide',
      'entretien': 'Paillage, apport d’engrais acide en début de saison',
    },
    'cherry including sour powdery mildew': {
      'ensoleillement': 'Plein soleil pour limiter humidité',
      'sol': 'Sol bien drainé',
      'arrosage': 'Modéré, éviter mouiller feuillage',
      'entretien': 'Traitements antifongiques, enlever parties malades',
    },
    'cherry including sour healthy': {
      'ensoleillement': 'Plein soleil',
      'sol': 'Sol fertile et bien drainé',
      'arrosage': 'Arrosage régulier, surtout en période sèche',
      'entretien': 'Taille régulière, fertilisation au printemps',
    },
    'corn maize cercospora leaf spot gray leaf spot': {
      'ensoleillement': 'Plein soleil',
      'sol': 'Sol léger, bien drainé',
      'arrosage': 'Modéré, éviter humidité excessive',
      'entretien': 'Rotation des cultures, traitements fongicides',
    },
    'corn maize common rust': {
      'ensoleillement': 'Plein soleil',
      'sol': 'Sol bien drainé',
      'arrosage': 'Arrosage modéré',
      'entretien': 'Traitements antifongiques, éliminer résidus',
    },
    'corn maize northern leaf blight': {
      'ensoleillement': 'Plein soleil',
      'sol': 'Sol fertile et drainé',
      'arrosage': 'Arrosage régulier sans excès',
      'entretien': 'Traitements fongicides, rotation des cultures',
    },
    'corn maize healthy': {
      'ensoleillement': 'Plein soleil',
      'sol': 'Sol riche, bien drainé',
      'arrosage': 'Arrosage régulier, surtout en période de croissance',
      'entretien': 'Fertilisation équilibrée, désherbage régulier',
    },
    'grape black rot': {
      'ensoleillement': 'Plein soleil conseillé',
      'sol': 'Sol bien drainé',
      'arrosage': 'Éviter l’excès d’humidité',
      'entretien': 'Traitements antifongiques, éliminer grappes malades',
    },
    'grape esca black measles': {
      'ensoleillement': 'Plein soleil',
      'sol': 'Sol bien drainé',
      'arrosage': 'Arrosage modéré',
      'entretien': 'Élagage, traitements phytosanitaires',
    },
    'grape leaf blight isariopsis leaf spot': {
      'ensoleillement': 'Plein soleil',
      'sol': 'Sol fertile et bien drainé',
      'arrosage': 'Éviter humidité stagnante',
      'entretien': 'Traitements antifongiques, éliminer feuilles malades',
    },
    'grape healthy': {
      'ensoleillement': 'Plein soleil',
      'sol': 'Sol riche et bien drainé',
      'arrosage': 'Arrosage régulier en période sèche',
      'entretien': 'Taille, fertilisation équilibrée',
    },
    'orange haunglongbing citrus greening': {
      'ensoleillement': 'Plein soleil',
      'sol': 'Sol fertile, bien drainé',
      'arrosage': 'Arrosage modéré',
      'entretien':
          'Contrôle des insectes vecteurs, élimination arbres infectés',
    },
    'peach bacterial spot': {
      'ensoleillement': 'Plein soleil',
      'sol': 'Sol bien drainé',
      'arrosage': 'Éviter excès d’humidité',
      'entretien': 'Traitements bactéricides, éliminer parties malades',
    },
    'peach healthy': {
      'ensoleillement': 'Plein soleil',
      'sol': 'Sol fertile, bien drainé',
      'arrosage': 'Arrosage régulier',
      'entretien': 'Taille annuelle, fertilisation',
    },
    'pepper bell bacterial spot': {
      'ensoleillement': 'Plein soleil',
      'sol': 'Sol bien drainé',
      'arrosage': 'Modéré, éviter humidité stagnante',
      'entretien': 'Traitements bactéricides, rotation des cultures',
    },
    'pepper bell healthy': {
      'ensoleillement': 'Plein soleil',
      'sol': 'Sol riche, bien drainé',
      'arrosage': 'Arrosage régulier',
      'entretien': 'Apport d’engrais, paillage',
    },
    'potato early blight': {
      'ensoleillement': 'Plein soleil',
      'sol': 'Sol léger, bien drainé',
      'arrosage': 'Éviter humidité excessive',
      'entretien': 'Traitements antifongiques précoces',
    },
    'potato late blight': {
      'ensoleillement': 'Plein soleil',
      'sol': 'Sol bien drainé',
      'arrosage': 'Réduire arrosage en période humide',
      'entretien': 'Traitements antifongiques',
    },
    'potato healthy': {
      'ensoleillement': 'Plein soleil',
      'sol': 'Sol fertile, léger et bien drainé',
      'arrosage': 'Arrosage régulier',
      'entretien': 'Buttage, fertilisation équilibrée',
    },
    'raspberry healthy': {
      'ensoleillement': 'Plein soleil à mi-ombre',
      'sol': 'Sol riche en matière organique',
      'arrosage': 'Arrosage régulier',
      'entretien': 'Taille, apport d’engrais organique',
    },
    'soybean healthy': {
      'ensoleillement': 'Plein soleil',
      'sol': 'Sol bien drainé, fertile',
      'arrosage': 'Arrosage modéré',
      'entretien': 'Rotation des cultures, fertilisation équilibrée',
    },
    'squash powdery mildew': {
      'ensoleillement': 'Plein soleil',
      'sol': 'Sol bien drainé',
      'arrosage': 'Éviter excès d’humidité',
      'entretien': 'Traitements antifongiques, éliminer feuilles malades',
    },
    'strawberry leaf scorch': {
      'ensoleillement': 'Plein soleil',
      'sol': 'Sol fertile, bien drainé',
      'arrosage': 'Arrosage modéré',
      'entretien': 'Traitements fongicides, enlever parties atteintes',
    },
    'strawberry healthy': {
      'ensoleillement': 'Plein soleil',
      'sol': 'Sol riche, bien drainé',
      'arrosage': 'Arrosage régulier',
      'entretien': 'Apport d’engrais organique, paillage',
    },
    'tomato bacterial spot': {
      'ensoleillement': 'Plein soleil',
      'sol': 'Sol bien drainé',
      'arrosage': 'Éviter mouillage feuillage',
      'entretien': 'Traitements bactéricides, rotation des cultures',
    },
    'tomato early blight': {
      'ensoleillement': 'Plein soleil',
      'sol': 'Sol léger, bien drainé',
      'arrosage': 'Réduire humidité sur feuillage',
      'entretien': 'Traitements antifongiques précoces',
    },
    'tomato late blight': {
      'ensoleillement': 'Plein soleil',
      'sol': 'Sol bien drainé',
      'arrosage': 'Arrosage modéré',
      'entretien': 'Traitements antifongiques',
    },
    'tomato leaf mold': {
      'ensoleillement': 'Plein soleil',
      'sol': 'Sol fertile et bien drainé',
      'arrosage': 'Éviter humidité stagnante',
      'entretien': 'Traitements fongicides',
    },
    'tomato septoria leaf spot': {
      'ensoleillement': 'Plein soleil',
      'sol': 'Sol bien drainé',
      'arrosage': 'Arrosage modéré, éviter humidité',
      'entretien': 'Traitements fongicides, enlever feuilles malades',
    },
    'tomato spider mites two spotted spider mite': {
      'ensoleillement': 'Plein soleil',
      'sol': 'Sol bien drainé',
      'arrosage': 'Arrosage régulier',
      'entretien': 'Traitements acaricides, enlever parties infectées',
    },
    'tomato target spot': {
      'ensoleillement': 'Plein soleil',
      'sol': 'Sol bien drainé',
      'arrosage': 'Arrosage modéré',
      'entretien': 'Traitements fongicides, élimination des feuilles atteintes',
    },
    'tomato tomato yellow leaf curl virus': {
      'ensoleillement': 'Plein soleil',
      'sol': 'Sol fertile',
      'arrosage': 'Arrosage modéré',
      'entretien':
          'Élimination des plantes infectées, lutte contre insectes vecteurs',
    },
    'tomato tomato mosaic virus': {
      'ensoleillement': 'Plein soleil',
      'sol': 'Sol fertile',
      'arrosage': 'Arrosage modéré',
      'entretien': 'Élimination des plantes malades, désinfection outils',
    },
    'tomato healthy': {
      'ensoleillement': 'Plein soleil direct',
      'sol': 'Sol riche, bien drainé',
      'arrosage': 'Arrosage au pied, fréquent en été',
      'entretien': 'Tuteurage, engrais riche en potassium',
    },
  };

  final Map<String, String> categoriesPlantes = {
    'apple': 'Alimentaire',
    'blueberry': 'Alimentaire',
    'cherry': 'Alimentaire',
    'corn maize': 'Industrielle',
    'grape': 'Alimentaire',
    'orange': 'Alimentaire',
    'peach': 'Alimentaire',
    'pepper bell': 'Alimentaire',
    'potato': 'Alimentaire',
    'raspberry': 'Alimentaire',
    'soybean': 'Industrielle',
    'squash': 'Alimentaire',
    'strawberry': 'Alimentaire',
    'tomato': 'Alimentaire',
  };

  @override
  void initState() {
    super.initState();
    _loadModelAndLabels();
  }

  Future<void> _loadModelAndLabels() async {
    _interpreter = await Interpreter.fromAsset(
      'assets/plant_disease_model.tflite',
    );
    final labelsData = await rootBundle.loadString('assets/plant_labels.txt');
    _labels = labelsData.split('\n');
  }

  Future<void> _pickImage(ImageSource source) async {
    final pickedFile = await _picker.pickImage(source: source);
    if (pickedFile == null) return;

    setState(() {
      _image = File(pickedFile.path);
    });

    _runModelOnImage(File(pickedFile.path));
  }

  Future<void> _runModelOnImage(File imageFile) async {
    final imageBytes = await imageFile.readAsBytes();
    img.Image? image = img.decodeImage(imageBytes);
    if (image == null) return;

    img.Image resizedImage = img.copyResize(image, width: 224, height: 224);
    var input = imageToByteListFloat32(resizedImage, 224, 127.5, 127.5);

    var output = List.filled(_labels.length, 0.0).reshape([1, _labels.length]);
    _interpreter.run(input, output);

    var scores = output[0] as List<double>;
    int maxIndex = scores.indexWhere(
      (e) => e == scores.reduce((a, b) => a > b ? a : b),
    );

    String predictedLabel = _labels[maxIndex].trim();

    // Fonction pour récupérer le nom français à partir du label
    String getNomPlanteFrancais(String label) {
      final plantesFrancais = {
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

      for (final planteAng in plantesFrancais.keys) {
        if (label.startsWith(planteAng)) {
          return plantesFrancais[planteAng]!;
        }
      }
      return "Plante inconnue";
    }

    String getCategoriePlante(String label) {
      for (final planteAng in categoriesPlantes.keys) {
        if (label.startsWith(planteAng)) {
          return categoriesPlantes[planteAng]!;
        }
      }
      return "Non classée";
    }

    String nomPlante = getNomPlanteFrancais(predictedLabel.toLowerCase());

    Map<String, String> infos =
        infosPlantes[predictedLabel.toLowerCase()] ?? {};

    widget.onDetected(predictedLabel);

    setState(() {
      _prediction =
          '$nomPlante (confiance ${(scores[maxIndex] * 100).toStringAsFixed(2)}%)';
      _infos = {
        ...infos,
        'categorie': getCategoriePlante(predictedLabel.toLowerCase()),
      };
    });
  }

  Uint8List imageToByteListFloat32(
    img.Image image,
    int inputSize,
    double mean,
    double std,
  ) {
    var convertedBytes = Float32List(1 * inputSize * inputSize * 3);
    var buffer = Float32List.view(convertedBytes.buffer);
    int pixelIndex = 0;
    for (int y = 0; y < inputSize; y++) {
      for (int x = 0; x < inputSize; x++) {
        int pixel = image.getPixel(x, y);
        buffer[pixelIndex++] = ((img.getRed(pixel)) - mean) / std;
        buffer[pixelIndex++] = ((img.getGreen(pixel)) - mean) / std;
        buffer[pixelIndex++] = ((img.getBlue(pixel)) - mean) / std;
      }
    }
    return convertedBytes.buffer.asUint8List();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('PlantDetector'),
        backgroundColor: Colors.green[300],
      ),
      backgroundColor: Colors.green[50],
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              _image != null
                  ? Image.file(_image!, height: 250)
                  : const Icon(Icons.image, size: 100, color: Colors.grey),
              const SizedBox(height: 20),
              if (_infos.isNotEmpty) ...[
                Card(
                  elevation: 3,
                  child: ListTile(
                    leading: Icon(
                      Icons.local_florist,
                      color: Colors.green,
                    ), // icône plante
                    title: const Text("Plante détectée"),
                    subtitle: Text(_prediction),
                  ),
                ),
                const SizedBox(height: 10),
                Card(
                  elevation: 3,
                  child: ListTile(
                    leading: Icon(Icons.category, color: Colors.purple),
                    title: const Text("Classe"),
                    subtitle: Text(_infos['categorie'] ?? 'Non classée'),
                  ),
                ),
                const SizedBox(height: 10),
                Card(
                  elevation: 3,
                  child: ListTile(
                    leading: Icon(Icons.wb_sunny, color: Colors.orange),
                    title: const Text("Ensoleillement"),
                    subtitle: Text(_infos['ensoleillement'] ?? 'Inconnu'),
                  ),
                ),
                const SizedBox(height: 10),
                Card(
                  elevation: 3,
                  child: ListTile(
                    leading: Icon(Icons.terrain, color: Colors.brown),
                    title: const Text("Sol compatible"),
                    subtitle: Text(_infos['sol'] ?? 'Inconnu'),
                  ),
                ),
                const SizedBox(height: 10),
                Card(
                  elevation: 3,
                  child: ListTile(
                    leading: Icon(Icons.opacity, color: Colors.blue),
                    title: const Text("Arrosage"),
                    subtitle: Text(_infos['arrosage'] ?? 'Inconnu'),
                  ),
                ),
                const SizedBox(height: 10),
                Card(
                  elevation: 3,
                  child: ListTile(
                    leading: Icon(Icons.eco, color: Colors.green),
                    title: const Text("Entretien / Engrais"),
                    subtitle: Text(_infos['entretien'] ?? 'Inconnu'),
                  ),
                ),
              ] else ...[
                const SizedBox(height: 20),
                Text(
                  _prediction,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],

              const SizedBox(height: 30),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  ElevatedButton.icon(
                    icon: const Icon(Icons.photo_camera),
                    label: const Text(
                      'Caméra',
                      style: TextStyle(color: Colors.black),
                    ),
                    onPressed: () => _pickImage(ImageSource.camera),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green[300],
                      iconColor: Colors.black,
                    ),
                  ),
                  ElevatedButton.icon(
                    icon: const Icon(Icons.photo),
                    label: const Text(
                      'Galerie',
                      style: TextStyle(color: Colors.black),
                    ),
                    onPressed: () => _pickImage(ImageSource.gallery),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green[300],
                      iconColor: Colors.black,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

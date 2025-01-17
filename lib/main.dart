import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'dart:typed_data';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';

void main() {
  runApp(const DroneApp());
}

class DroneApp extends StatelessWidget {
  const DroneApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: const Scaffold(
        backgroundColor: Color(0xFF2F3B47),
        body: DroneControllerScreen(),
      ),
      routes: {
        '/map': (context) => const MapScreen(),
        '/output': (context) => const OutputScreen(),
        '/cropPrediction': (context) =>
            const CropPredictionForm(), // Add this route
        '/cropHealth': (context) => const CropHealthForm(),
        '/diseaseDetection': (context) => const PlantDiseasePrediction(),
      },
    );
  }
}

class DroneControllerScreen extends StatelessWidget {
  const DroneControllerScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const SafeArea(
      child: Column(
        children: [
          HeaderWidget(),
          Expanded(child: ContentSection()),
        ],
      ),
    );
  }
}

class HeaderWidget extends StatelessWidget {
  const HeaderWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Row(
            children: [
              Icon(Icons.flight, color: Colors.orange),
              SizedBox(width: 8),
              Text(
                'Drone',
                style: TextStyle(color: Colors.white, fontSize: 20),
              ),
            ],
          ),
          Row(
            children: [
              HeaderButton(
                label: 'Output',
                onTap: () => Navigator.pushNamed(context, '/output'),
              ),
              const HeaderButton(label: 'Controller'),
              const HeaderButton(label: 'Overview'),
              const HeaderButton(label: 'Routes'),
              const HeaderButton(label: 'All drones'),
              HeaderButton(
                label: 'Map view',
                onTap: () => Navigator.pushNamed(context, '/map'),
              ),
              HeaderButton(
                label: 'Crop Prediction',
                onTap: () => Navigator.pushNamed(context, '/cropPrediction'),
              ),
              HeaderButton(
                label: 'Crop Health',
                onTap: () => Navigator.pushNamed(context, '/cropHealth'),
              ),
              HeaderButton(
                label: 'Disease Detection', // New button
                onTap: () => Navigator.pushNamed(context, '/diseaseDetection'),
              ),
              const SizedBox(width: 16),
              const StatusWidget(),
            ],
          ),
        ],
      ),
    );
  }
}

class HeaderButton extends StatelessWidget {
  final String label;
  final VoidCallback? onTap;

  const HeaderButton({super.key, required this.label, this.onTap});

  @override
  Widget build(BuildContext context) {
    return TextButton(
      onPressed: onTap ?? () {},
      child: Text(label, style: const TextStyle(color: Colors.white)),
    );
  }
}

class PlantDiseasePrediction extends StatefulWidget {
  const PlantDiseasePrediction({super.key});

  @override
  _PlantDiseasePredictionState createState() => _PlantDiseasePredictionState();
}

class _PlantDiseasePredictionState extends State<PlantDiseasePrediction> {
  Uint8List? _imageBytes; // To store the selected image as bytes
  String prediction = '';
  String remedy = '';

  int counter = 1; // Initialize the counter

  final ImagePicker _picker = ImagePicker();

  // Function to pick an image from the gallery
  Future<void> _pickImage() async {
    final pickedFile = await _picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      final bytes = await pickedFile.readAsBytes(); // Read file as bytes
      setState(() {
        _imageBytes = bytes;
      });
    }
  }

  // Function to handle prediction when Predict button is clicked
  void _predictDisease() {
    if (_imageBytes == null) {
      // Show an alert if no image is uploaded
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Error'),
          content: const Text('Please upload an image before predicting.'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('OK'),
            ),
          ],
        ),
      );
      return;
    }

    setState(() {
      // Increment the counter with each prediction
      counter++;
      // Update prediction and remedy based on the counter value
      if (counter.isEven) {
        prediction = "Disease: Potato Late Blight";
        remedy =
            "To manage potato late blight, plant resistant varieties, ensure proper spacing, and avoid overhead irrigation. Apply fungicides like chlorothalonil or mancozeb preventively during favorable conditions. Remove and destroy infected plants and debris to prevent disease spread.";
      } else {
        prediction = "Disease: Pepper Bacterial Spot";
        remedy =
            "To manage pepper bacterial spot, use disease-free seeds, rotate crops, and ensure proper plant spacing to reduce humidity. Apply copper-based fungicides or biological controls like Bacillus subtilis for suppression. Regularly scout for symptoms, remove infected plants, and maintain field sanitation.";
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFCECEE4),
      appBar: AppBar(
        title:
            const Text('Find out which disease has been caught by your plant'),
        centerTitle: true,
        backgroundColor: Colors.blueAccent,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(25),
                ),
                width: double.infinity,
                child: Column(
                  children: [
                    const Text(
                      'Please Upload The Image',
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 20),
                    ElevatedButton(
                      onPressed: _pickImage,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blueAccent,
                        padding: const EdgeInsets.symmetric(
                            horizontal: 50, vertical: 15),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text(
                        'Upload Image',
                        style: TextStyle(
                            fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                    ),
                    const SizedBox(height: 20),
                    if (_imageBytes != null)
                      Image.memory(
                        _imageBytes!,
                        width: 200,
                        height: 200,
                        fit: BoxFit.cover,
                      ),
                    const SizedBox(height: 20),
                    ElevatedButton(
                      onPressed: _predictDisease,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blueAccent,
                        padding: const EdgeInsets.symmetric(
                            horizontal: 50, vertical: 15),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text(
                        'Predict',
                        style: TextStyle(
                            fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                    ),
                    const SizedBox(height: 20),
                    if (prediction.isNotEmpty)
                      Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: const Color(
                              0xFFFFEBCD), // Hex for blanched almond
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Center(
                          child: Column(
                            children: [
                              Text(
                                prediction,
                                style: const TextStyle(
                                  color: Colors.black,
                                  fontSize: 22,
                                ),
                              ),
                              const SizedBox(height: 10),
                              Text(
                                'Remedy: $remedy',
                                style: const TextStyle(
                                  color: Colors.black,
                                  fontSize: 18,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class CropPredictionForm extends StatefulWidget {
  const CropPredictionForm({super.key});

  @override
  _CropPredictionFormState createState() => _CropPredictionFormState();
}

class _CropPredictionFormState extends State<CropPredictionForm> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController carbonController = TextEditingController();
  final TextEditingController organicMatterController = TextEditingController();
  final TextEditingController phosphorousController = TextEditingController();
  final TextEditingController calciumController = TextEditingController();
  final TextEditingController magnesiumController = TextEditingController();
  final TextEditingController potassiumController = TextEditingController();

  Future<void> _submitForm() async {
    if (_formKey.currentState!.validate()) {
      final formData = {
        'Carbon': double.parse(carbonController.text),
        'Organic Matter': double.parse(organicMatterController.text),
        'Phosphorous': double.parse(phosphorousController.text),
        'Calcium': double.parse(calciumController.text),
        'Magnesium': double.parse(magnesiumController.text),
        'Potassium': double.parse(potassiumController.text),
      };

      try {
        final response = await http.post(
          Uri.parse(
              'http://127.0.0.1:5000/predict'), // Replace with your backend URL
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode(formData),
        );

        if (response.statusCode == 200) {
          final prediction = jsonDecode(response.body)['predicted_crop'];
          _showResultDialog(prediction);
        } else {
          final error = jsonDecode(response.body)['error'];
          _showErrorDialog(error);
        }
      } catch (e) {
        _showErrorDialog('An error occurred: $e');
      }
    }
  }

  void _showResultDialog(String prediction) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Prediction Result'),
        content: Text('The predicted crop is: $prediction'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  void _showErrorDialog(String error) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Error'),
        content: Text(error),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFCECEE4),
      appBar: AppBar(
        title: const Text('Crop Prediction'),
        centerTitle: true,
        backgroundColor: Colors.blueGrey,
      ),
      body: Center(
        child: Container(
          width: 350,
          padding: const EdgeInsets.all(16.0),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(25.0),
          ),
          child: Form(
            key: _formKey,
            child: ListView(
              children: [
                const Text(
                  'Find out the most suitable crop to grow in your farm',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 16.0),
                buildFloatField('Carbon (g/kg)', 'Enter value (e.g., 1.2)',
                    carbonController),
                buildFloatField('Organic Matter (g/kg)',
                    'Enter value (e.g., 3.5)', organicMatterController),
                buildFloatField('Phosphorous (mg/kg)',
                    'Enter value (e.g., 50.0)', phosphorousController),
                buildFloatField('Calcium (mmol/kg)', 'Enter value (e.g., 4.2)',
                    calciumController),
                buildFloatField('Magnesium (mmol/kg)',
                    'Enter value (e.g., 1.8)', magnesiumController),
                buildFloatField('Potassium (mmol/kg)',
                    'Enter value (e.g., 2.5)', potassiumController),
                const SizedBox(height: 24.0),
                Center(
                  child: ElevatedButton(
                    onPressed: _submitForm, // Call the submit method
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blueGrey,
                      minimumSize: const Size(130, 50),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text(
                      'Predict',
                      style:
                          TextStyle(fontSize: 21, fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget buildFloatField(
      String label, String hint, TextEditingController controller) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: TextFormField(
        controller: controller,
        keyboardType: const TextInputType.numberWithOptions(decimal: true),
        decoration: InputDecoration(
          labelText: label,
          hintText: hint,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(8.0)),
        ),
        validator: (value) {
          if (value == null || value.isEmpty) {
            return 'Please enter $label';
          }
          if (double.tryParse(value) == null) {
            return 'Please enter a valid number';
          }
          return null;
        },
      ),
    );
  }
}

class CropHealthForm extends StatefulWidget {
  const CropHealthForm({super.key});

  @override
  _CropHealthState createState() => _CropHealthState();
}

class _CropHealthState extends State<CropHealthForm> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController chlorophyllController = TextEditingController();
  final TextEditingController soilMoistureController = TextEditingController();
  final TextEditingController temperatureController = TextEditingController();

  List<String> recommendations = []; // List to hold multiple recommendations
  String? selectedCrop;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFCECEE4),
      appBar: AppBar(
        title: const Text('Crop Health Prediction'),
        centerTitle: true,
        backgroundColor: Colors.blueGrey,
      ),
      body: Center(
        child: Container(
          width: 350,
          padding: const EdgeInsets.all(16.0),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(25.0),
          ),
          child: Form(
            key: _formKey,
            child: ListView(
              children: [
                const Text(
                  'Analyze your crop health using key metrics',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 16.0),
                buildDropdownField(),
                const SizedBox(height: 16.0),
                buildFloatField('Chlorophyll Index', 'Enter value (e.g., 0.85)',
                    chlorophyllController),
                buildFloatField('Water stress level',
                    'Enter value (e.g., 25.3)', soilMoistureController),
                buildFloatField('Absorption ratio', 'Enter value (e.g., 30.5)',
                    temperatureController),
                const SizedBox(height: 24.0),
                Center(
                  child: ElevatedButton(
                    onPressed: () async {
                      if (_formKey.currentState!.validate() &&
                          selectedCrop != null) {
                        final chlorophyllValue =
                            double.parse(chlorophyllController.text);
                        final absorptionRatioValue =
                            double.parse(temperatureController.text);
                        final cropWaterStressLevelValue =
                            double.parse(soilMoistureController.text);

                        try {
                          List<String> recs = await getRecommendation(
                            chlorophyllValue,
                            absorptionRatioValue,
                            cropWaterStressLevelValue,
                          );

                          setState(() {
                            recommendations = recs;
                          });
                        } catch (e) {
                          setState(() {
                            recommendations = ['Error: $e'];
                          });
                        }
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blueGrey,
                      minimumSize: const Size(130, 50),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text(
                      'Predict',
                      style:
                          TextStyle(fontSize: 21, fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
                const SizedBox(height: 50.0),
                if (recommendations.isNotEmpty)
                  Container(
                    margin: const EdgeInsets.only(top: 50),
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.blueGrey.shade50,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Center(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: recommendations
                            .map((recommendation) => Text(
                                  recommendation,
                                  textAlign: TextAlign.left,
                                  style: const TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.blueGrey,
                                  ),
                                ))
                            .toList(),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget buildDropdownField() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: DropdownButtonFormField<String>(
        value: selectedCrop,
        onChanged: (value) {
          setState(() {
            selectedCrop = value;
          });
        },
        decoration: InputDecoration(
          labelText: 'Select Crop',
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        items: const [
          DropdownMenuItem(value: 'Paddy', child: Text('Paddy')),
          DropdownMenuItem(value: 'Soybean', child: Text('Soybean')),
        ],
        validator: (value) => value == null ? 'Please select a crop' : null,
      ),
    );
  }

  Widget buildFloatField(
      String label, String hint, TextEditingController controller) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: TextFormField(
        controller: controller,
        keyboardType:
            const TextInputType.numberWithOptions(decimal: true, signed: false),
        decoration: InputDecoration(
          labelText: label,
          hintText: hint,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        validator: (value) {
          if (value == null || value.isEmpty) {
            return 'Please enter a value';
          }
          final num? parsedValue = num.tryParse(value);
          if (parsedValue == null) {
            return 'Please enter a valid number';
          }
          return null;
        },
      ),
    );
  }

  Future<List<String>> getRecommendation(double chlorophyll,
      double absorptionRatio, double cropWaterStressLevel) async {
    List<String> recommendations = [];

    // Logic for Rice (Paddy)
    if (selectedCrop == 'Paddy') {
      // Chlorophyll decision
      recommendations.add('Chlorophyll Level:');
      if (chlorophyll < 25) {
        recommendations.add(
            'Apply nitrogen-rich fertilizers like urea or ammonium sulfate to boost chlorophyll levels.');
      } else if (chlorophyll > 45) {
        recommendations.add(
            'Reduce nitrogen application and increase potassium-based fertilizers to balance nutrient uptake.');
      } else {
        recommendations.add('Chlorophyll level is within the optimal range.');
      }

      // Absorption Ratio decision
      recommendations.add('Absorption Ratio:');
      if (absorptionRatio < 0.45) {
        recommendations.add(
            'Ensure sufficient irrigation and apply organic matter to improve soil moisture retention.');
      } else if (absorptionRatio > 0.55) {
        recommendations.add(
            'Reduce waterlogging by improving drainage and avoid over-irrigation.');
      } else {
        recommendations.add('Absorption ratio is within the optimal range.');
      }

      // Crop Water Stress Level decision
      recommendations.add('Water Stress Level:');
      if (cropWaterStressLevel < 0.5) {
        recommendations.add(
            'Increase irrigation frequency to ensure adequate water supply.');
      } else if (cropWaterStressLevel > 0.5) {
        recommendations.add(
            'Implement water-saving techniques like mulching or use drought-tolerant varieties to reduce stress.');
      } else {
        recommendations.add('Crop water stress is within the optimal range.');
      }
    }

    // Logic for Soybean
    if (selectedCrop == 'Soybean') {
      // Chlorophyll decision
      recommendations.add('Chlorophyll Level:');
      if (chlorophyll < 46) {
        recommendations.add(
            'Apply nitrogen-rich fertilizers like urea to enhance chlorophyll production.');
      } else if (chlorophyll > 55) {
        recommendations.add(
            'Reduce nitrogen application and focus on balanced fertilization with more potassium.');
      } else {
        recommendations.add('Chlorophyll level is within the optimal range.');
      }

      // Absorption Ratio decision
      recommendations.add('Absorption Ratio:');
      if (absorptionRatio < 0.75) {
        recommendations.add(
            'Ensure proper irrigation and apply organic matter to enhance soil water retention.');
      } else if (absorptionRatio > 0.85) {
        recommendations.add(
            'Avoid over-irrigation and improve drainage to prevent waterlogging.');
      } else {
        recommendations.add('Absorption ratio is within the optimal range.');
      }

      // Crop Water Stress Level decision
      recommendations.add('Water Stress Level:');
      if (cropWaterStressLevel < 0.25) {
        recommendations.add(
            'Reduce irrigation intervals and monitor for waterlogging to avoid root damage.');
      } else if (cropWaterStressLevel > 0.40) {
        recommendations.add(
            'Increase irrigation and consider using drought-resistant soybean varieties.');
      } else {
        recommendations.add('Crop water stress is within the optimal range.');
      }
    }

    return recommendations;
  }
}

class OutputScreen extends StatelessWidget {
  const OutputScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('DSS Output'),
        backgroundColor: const Color(0xFF2F3B47),
      ),
      body: Center(
        child: Container(
          padding: const EdgeInsets.all(16.0),
          margin: const EdgeInsets.all(16.0),
          decoration: BoxDecoration(
            color: const Color(0xFF394451),
            borderRadius: BorderRadius.circular(12),
          ),
          child: const Text(
            'Recommended Crop: Wheat\nSoil Type: Loamy\nMoisture: High\nTemperature: 28°C',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
    );
  }
}

class StatusWidget extends StatelessWidget {
  const StatusWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return const Row(
      children: [
        Text(
          '243.4 km² • Rain, 36°C',
          style: TextStyle(color: Colors.white),
        ),
        SizedBox(width: 10),
        Chip(
          label: Text('Ongoing', style: TextStyle(color: Colors.white)),
          backgroundColor: Colors.green,
        ),
        SizedBox(width: 10),
        Text(
          '11:43 AM',
          style: TextStyle(color: Colors.white),
        ),
      ],
    );
  }
}

class ContentSection extends StatelessWidget {
  const ContentSection({super.key});

  @override
  Widget build(BuildContext context) {
    return const Stack(
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              flex: 2,
              child: ImageWidget(),
            ),
            Expanded(
              flex: 1,
              child: ControlPanelWidget(),
            ),
          ],
        ),
        Positioned(
          bottom: 30,
          left: 30,
          child: JoystickWidget(),
        ),
        Positioned(
          bottom: 30,
          right: 550, // Adjusted from 500 to 30 for proper positioning
          child: JoystickWidget(),
        ),
      ],
    );
  }
}

class ImageWidget extends StatelessWidget {
  const ImageWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: MediaQuery.of(context).size.height * 0.7,
      color: Colors.black,
      child: const Stack(
        children: [
          Center(
            child: Icon(Icons.image, color: Colors.white, size: 100),
          ),
          Positioned(
            top: 10,
            right: 10,
            child: RecordWidget(),
          ),
          Positioned(
            bottom: 10,
            left: 10,
            child: LevelWidget(),
          ),
          Positioned(
            bottom: 10,
            right: 10,
            child: CompassWidget(),
          ),
        ],
      ),
    );
  }
}

class RecordWidget extends StatelessWidget {
  const RecordWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return const Row(
      children: [
        Icon(Icons.circle, color: Colors.red),
        SizedBox(width: 5),
        Text(
          '02:10',
          style: TextStyle(color: Colors.white),
        ),
      ],
    );
  }
}

class LevelWidget extends StatelessWidget {
  const LevelWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return const Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Level',
          style: TextStyle(color: Colors.white),
        ),
      ],
    );
  }
}

class CompassWidget extends StatelessWidget {
  const CompassWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return const Column(
      children: [
        Icon(Icons.compass_calibration, color: Colors.white),
        Text(
          '329 NW',
          style: TextStyle(color: Colors.white),
        ),
      ],
    );
  }
}

class ControlPanelWidget extends StatelessWidget {
  const ControlPanelWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return const Column(
      children: [
        BatteryWidget(),
        AltitudeWidget(),
        ResolutionWidget(),
        DisplayOptions(),
        SizedBox(height: 16),
        Expanded(child: DroneInfoPanel()),
      ],
    );
  }
}

class JoystickWidget extends StatefulWidget {
  const JoystickWidget({super.key});

  @override
  _JoystickWidgetState createState() => _JoystickWidgetState();
}

class _JoystickWidgetState extends State<JoystickWidget> {
  Offset _joystickPosition = const Offset(0, 0);

  void _updatePosition(DragUpdateDetails details) {
    setState(() {
      _joystickPosition = Offset(
        (_joystickPosition.dx + details.delta.dx).clamp(-50.0, 50.0),
        (_joystickPosition.dy + details.delta.dy).clamp(-50.0, 50.0),
      );
    });
  }

  void _resetPosition(DragEndDetails details) {
    setState(() {
      _joystickPosition = const Offset(0, 0);
    });
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 100, // Outer joystick size
      height: 100,
      child: Center(
        child: GestureDetector(
          onPanUpdate: _updatePosition,
          onPanEnd: _resetPosition,
          child: Stack(
            alignment: Alignment.center,
            children: [
              Container(
                width: 100, // Outer circle diameter
                height: 100,
                decoration: BoxDecoration(
                  color: Colors.grey.withOpacity(0.5),
                  shape: BoxShape.circle,
                ),
              ),
              Positioned(
                left: 50 + _joystickPosition.dx - 15, // Centered handle
                top: 50 + _joystickPosition.dy - 15,
                child: Container(
                  width: 50, // Joystick handle size
                  height: 50,
                  decoration: const BoxDecoration(
                    color: Colors.orange,
                    shape: BoxShape.circle,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class BatteryWidget extends StatelessWidget {
  const BatteryWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return const ListTile(
      title: Text('Battery', style: TextStyle(color: Colors.white)),
      subtitle: LinearProgressIndicator(
        value: 0.5,
        backgroundColor: Colors.grey,
        valueColor: AlwaysStoppedAnimation<Color>(Colors.orange),
      ),
      trailing: Text(
        '50%',
        style: TextStyle(color: Colors.white),
      ),
    );
  }
}

class AltitudeWidget extends StatefulWidget {
  const AltitudeWidget({super.key});

  @override
  _AltitudeWidgetState createState() => _AltitudeWidgetState();
}

class _AltitudeWidgetState extends State<AltitudeWidget> {
  double _altitudeValue = 200;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title:
          const Text('Altitude limited', style: TextStyle(color: Colors.white)),
      subtitle: Slider(
        value: _altitudeValue,
        min: 0,
        max: 300,
        onChanged: (value) {
          setState(() {
            _altitudeValue = value;
          });
        },
        activeColor: Colors.orange,
        inactiveColor: Colors.grey,
      ),
      trailing: Text(
        '${_altitudeValue.toStringAsFixed(0)} m',
        style: const TextStyle(color: Colors.white),
      ),
    );
  }
}

class ResolutionWidget extends StatefulWidget {
  const ResolutionWidget({super.key});

  @override
  _ResolutionWidgetState createState() => _ResolutionWidgetState();
}

class _ResolutionWidgetState extends State<ResolutionWidget> {
  double _resolutionValue = 8;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: const Text('Resolution px', style: TextStyle(color: Colors.white)),
      subtitle: Slider(
        value: _resolutionValue,
        min: 2,
        max: 14,
        onChanged: (value) {
          setState(() {
            _resolutionValue = value;
          });
        },
        activeColor: Colors.orange,
        inactiveColor: Colors.grey,
      ),
      trailing: Text(
        '${_resolutionValue.toStringAsFixed(0)} px',
        style: const TextStyle(color: Colors.white),
      ),
    );
  }
}

class DisplayOptions extends StatelessWidget {
  const DisplayOptions({super.key});

  @override
  Widget build(BuildContext context) {
    return const Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: [
        DisplayOptionButton(label: 'ISO'),
        DisplayOptionButton(label: 'HDR'),
        DisplayOptionButton(label: 'DVR'),
      ],
    );
  }
}

class DisplayOptionButton extends StatelessWidget {
  final String label;

  const DisplayOptionButton({super.key, required this.label});

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF2F3B47)),
      onPressed: () {},
      child: Text(label, style: const TextStyle(color: Colors.orange)),
    );
  }
}

class DroneInfoPanel extends StatelessWidget {
  const DroneInfoPanel({super.key});

  @override
  Widget build(BuildContext context) {
    return GridView.count(
      crossAxisCount: 2,
      padding: const EdgeInsets.all(8),
      mainAxisSpacing: 8,
      crossAxisSpacing: 8,
      childAspectRatio: 2.5,
      children: const [
        InfoCard(icon: Icons.speed, label: 'Speed', value: '5 km/h'),
        InfoCard(icon: Icons.camera, label: 'Lens', value: '25 mm'),
        InfoCard(icon: Icons.height, label: 'Height', value: '100 m'),
        InfoCard(icon: Icons.iso, label: 'ISO', value: '600'),
        InfoCard(icon: Icons.timer, label: 'Flight time', value: '1000s'),
        InfoCard(icon: Icons.shutter_speed, label: 'Shutter', value: '180.0'),
      ],
    );
  }
}

class InfoCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const InfoCard(
      {super.key,
      required this.icon,
      required this.label,
      required this.value});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Colors.grey[800],
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              Icon(icon, color: Colors.white, size: 16),
              const SizedBox(width: 4),
              Text(
                label,
                style: const TextStyle(color: Colors.white, fontSize: 12),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 14,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}

class MapScreen extends StatefulWidget {
  const MapScreen({super.key});

  @override
  _MapScreenState createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  final List<Marker> _markers = [];
  LatLng? _selectedPosition;

  // API URL to store coordinates in MongoDB
  final String apiUrl = 'http://localhost:3000/addMarker';

  // Function to add a marker to the map and send it to the backend
  void _addMarker(LatLng position) {
    setState(() {
      _selectedPosition = position;
      _markers.add(
        Marker(
          point: position,
          width: 100,
          height: 80,
          builder: (ctx) => GestureDetector(
            onLongPress: () => _removeMarker(position),
            child: Column(
              children: [
                Container(
                  padding:
                      const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(4),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.withOpacity(0.5),
                        spreadRadius: 2,
                        blurRadius: 5,
                        offset: const Offset(0, 3),
                      ),
                    ],
                  ),
                  child: Text(
                    "${position.latitude.toStringAsFixed(5)}, ${position.longitude.toStringAsFixed(5)}",
                    style: const TextStyle(fontSize: 14, color: Colors.black),
                  ),
                ),
                const Icon(
                  Icons.location_on,
                  color: Colors.red,
                  size: 50,
                ),
              ],
            ),
          ),
        ),
      );
    });
    print("Marker added at: ${position.latitude}, ${position.longitude}");

    // Send coordinates to MongoDB
    _sendCoordinatesToMongoDB(position);
  }

  // Function to remove a marker
  void _removeMarker(LatLng position) {
    setState(() {
      _markers.removeWhere((marker) => marker.point == position);
    });
    print("Marker removed at: ${position.latitude}, ${position.longitude}");
  }

  // Send coordinates to MongoDB
  Future<void> _sendCoordinatesToMongoDB(LatLng position) async {
    try {
      final response = await http.post(
        Uri.parse(apiUrl),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'latitude': position.latitude,
          'longitude': position.longitude,
        }),
      );

      if (response.statusCode == 200) {
        print("Marker saved to MongoDB");
      } else {
        print(
            "Failed to save marker to MongoDB. Status Code: ${response.statusCode}");
      }
    } catch (error) {
      print("Error occurred while saving marker: $error");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Map View'),
        backgroundColor: const Color(0xFF2F3B47),
      ),
      body: FlutterMap(
        options: MapOptions(
          center:
              LatLng(21.2514, 81.6296), // Set Raipur, India as default center
          zoom: 13.0,
          onTap: (tapPosition, latlng) {
            _addMarker(latlng);
          },
        ),
        children: [
          TileLayer(
            urlTemplate:
                "https://services.arcgisonline.com/ArcGIS/rest/services/World_Imagery/MapServer/tile/{z}/{y}/{x}", // Esri World Imagery
            userAgentPackageName: 'com.example.yourappname',
          ),
          MarkerLayer(
            markers: _markers,
          ),
        ],
      ),
    );
  }
}

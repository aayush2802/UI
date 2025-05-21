import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'dart:typed_data';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'dart:math';

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
        '/cropUsage': (context) => const CropUsageScreen(),
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
              HeaderButton(
                label: 'Crop Usage',
                onTap: () => Navigator.pushNamed(
                    context, '/cropUsage'), // <--- Navigates
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
  Uint8List? _imageBytes;
  String prediction = '';
  String remedy = '';

  final ImagePicker _picker = ImagePicker();
  final String apiUrl = "http://127.0.0.1:5000/predict"; // Backend URL

  // Function to pick an image from the gallery
  Future<void> _pickImage() async {
    final pickedFile = await _picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      final bytes = await pickedFile.readAsBytes();
      setState(() {
        _imageBytes = bytes;
      });
    }
  }

  // Function to send Base64 image to backend
  Future<void> _predictDisease() async {
    if (_imageBytes == null) {
      _showErrorDialog('Please upload an image before predicting.');
      return;
    }

    try {
      String base64Image = base64Encode(_imageBytes!);

      var response = await http.post(
        Uri.parse(apiUrl),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({'image': base64Image}), // Send Base64 string
      );

      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);
        setState(() {
          prediction = responseData['prediction'] ?? 'Unknown';
          remedy = responseData['remedy'] ?? 'No remedy found.';
        });
      } else {
        _showErrorDialog('Failed to predict disease. Please try again.');
      }
    } catch (e) {
      _showErrorDialog('Error: ${e.toString()}');
    }
  }

  // Function to show error messages
  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Error'),
        content: Text(message),
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
                      style:
                          TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
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
                          color: const Color(0xFFFFEBCD),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Center(
                          child: Column(
                            children: [
                              Text(
                                'Disease: $prediction',
                                style: const TextStyle(
                                    color: Colors.black, fontSize: 22),
                              ),
                              const SizedBox(height: 10),
                              Text(
                                'Remedy: $remedy',
                                style: const TextStyle(
                                    color: Colors.black, fontSize: 18),
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

class CropUsageScreen extends StatefulWidget {
  const CropUsageScreen({super.key});

  @override
  State<CropUsageScreen> createState() => _CropUsageScreenState();
}

class _CropUsageScreenState extends State<CropUsageScreen> {
  // 1. Rename controller for clarity
  final TextEditingController _fieldIdController = TextEditingController();
  bool _isLoading = false;
  // 3. Store the fetched data structure (fieldId + list of usages)
  Map<String, dynamic>? _fetchedData;
  List<dynamic>? _usagesList; // Extracted list of usages for easier access
  String? _errorMessage;

  // Make sure this points to your running server.js backend
  final String _baseUrl = "http://localhost:3000"; // Example for Web/iOS Sim

  Future<void> _fetchFieldUsage() async {
    // Renamed function
    // 1. Get Field ID from input
    final String fieldId = _fieldIdController.text.trim();
    if (fieldId.isEmpty) {
      setState(() {
        // 1. Update error message
        _errorMessage = "Please enter a Field ID.";
        _fetchedData = null;
        _usagesList = null;
      });
      return;
    }
    // Validate if the input is a number
    if (int.tryParse(fieldId) == null) {
      setState(() {
        // 1. Update error message
        _errorMessage = "Please enter a valid numerical Field ID.";
        _fetchedData = null;
        _usagesList = null;
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
      _fetchedData = null; // Clear previous data
      _usagesList = null;
    });

    try {
      // 2. Use the new API endpoint
      final Uri url = Uri.parse('$_baseUrl/crop-usage/field/$fieldId');
      print('Calling API: $url');
      final response = await http.get(url).timeout(const Duration(seconds: 15));
      print('Response Status Code: ${response.statusCode}');

      if (!mounted) return;

      if (response.statusCode == 200) {
        final Map<String, dynamic> decodedData = jsonDecode(response.body);
        setState(() {
          // 3. Store the whole response and extract the list
          _fetchedData = decodedData;
          _usagesList = decodedData['usages'] as List<dynamic>?; // Safely cast
          _isLoading = false;
        });
      } else {
        // Handle backend errors (like 500 if fieldId is invalid format server-side)
        // Note: A valid fieldId with no usages will return 200 and an empty usages list
        print('API Error Body: ${response.body}');
        setState(() {
          _errorMessage =
              'Error fetching data (Status: ${response.statusCode}). Check Field ID or server.';
          _isLoading = false;
        });
      }
    } catch (e) {
      print('Error occurred during fetch: $e');
      if (!mounted) return;
      setState(() {
        _errorMessage =
            'Network error. Please check connection and server status.';
        _isLoading = false;
      });
    }
  }

  @override
  void dispose() {
    // 1. Dispose the renamed controller
    _fieldIdController.dispose();
    super.dispose();
  }

  // --- Timestamp Formatter (no changes needed) ---
  String _formatTimestamp(String? timestampString) {
    if (timestampString == null) return 'N/A';
    try {
      final int seconds = int.parse(timestampString);
      final DateTime dateTime =
          DateTime.fromMillisecondsSinceEpoch(seconds * 1000);
      return dateTime.toLocal().toString().split('.')[0];
    } catch (e) {
      print("Error parsing timestamp: $e");
      return timestampString;
    }
  }

  // --- Helper for individual data rows (no changes needed) ---
  Widget _buildDataRow(String label, dynamic value) {
    String displayValue = value?.toString() ?? 'N/A';
    if (displayValue != 'N/A') {
      if (label.toLowerCase().contains('fertilizer') ||
          label.toLowerCase().contains('pesticide')) {
        displayValue += ' kg';
      }
    }
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: const TextStyle(fontWeight: FontWeight.w500)),
          const SizedBox(width: 8),
          Expanded(child: Text(displayValue, textAlign: TextAlign.end)),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        // 1. Update title slightly
        title: const Text('View Field Crop Usage'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            // 1. Update TextField
            TextField(
              controller: _fieldIdController, // Use renamed controller
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'Enter Field ID', // Update label
                hintText: 'e.g., 1', // Update hint
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 20),
            // Update Button action
            ElevatedButton.icon(
              icon: _isLoading
                  ? const SizedBox(
                      height: 18,
                      width: 18,
                      child: CircularProgressIndicator(
                          strokeWidth: 2, color: Colors.white),
                    )
                  : const Icon(Icons.search),
              label: Text(_isLoading
                  ? 'Fetching...'
                  : 'Get Field Usage Data'), // Update label
              onPressed:
                  _isLoading ? null : _fetchFieldUsage, // Call updated function
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 14),
              ),
            ),
            const SizedBox(height: 20), // Reduced space slightly

            // --- Display Area ---
            if (_errorMessage != null)
              Padding(
                padding: const EdgeInsets.only(top: 16.0),
                child: Text(
                  _errorMessage!,
                  style: TextStyle(
                      color: Colors.red[700], fontWeight: FontWeight.bold),
                  textAlign: TextAlign.center,
                ),
              ),

            // 4. Update Display Logic
            if (_fetchedData != null && _errorMessage == null)
              Padding(
                padding: const EdgeInsets.only(top: 16.0, bottom: 8.0),
                child: Text(
                  "Usage Data for Field ID: ${_fetchedData!['fieldId'] ?? 'N/A'}",
                  style: Theme.of(context)
                      .textTheme
                      .titleLarge, // Larger title for the field
                  textAlign: TextAlign.center,
                ),
              ),

            // Show list of usages or 'not found' message
            Expanded(
              // Make the list scrollable if it exceeds screen height
              child: _isLoading
                  ? const Center(
                      child:
                          CircularProgressIndicator()) // Show loader while list is building
                  : _usagesList == null
                      ? const SizedBox
                          .shrink() // Nothing to show yet (initial state or error handled above)
                      : _usagesList!.isEmpty
                          ? const Center(
                              // Message if list is empty
                              child: Text(
                              'No usage records found for this field.',
                              style: TextStyle(
                                  fontSize: 16, fontStyle: FontStyle.italic),
                            ))
                          : ListView.builder(
                              // Build the list of cards
                              itemCount: _usagesList!.length,
                              itemBuilder: (context, index) {
                                final usage = _usagesList![index]
                                    as Map<String, dynamic>; // Cast item
                                return Card(
                                  margin: const EdgeInsets.only(
                                      bottom: 12.0), // Add space between cards
                                  elevation: 2,
                                  child: Padding(
                                    padding: const EdgeInsets.all(12.0),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        // Display Crop Batch ID prominently inside the card
                                        Text(
                                          'Crop Batch ID: ${usage['cropBatchId'] ?? 'N/A'}',
                                          style: Theme.of(context)
                                              .textTheme
                                              .titleMedium
                                              ?.copyWith(
                                                  fontWeight: FontWeight.bold),
                                        ),
                                        const Divider(height: 15),
                                        // Use the helper for the details
                                        _buildDataRow('Fertilizer Amount:',
                                            usage['fertilizerAmount']),
                                        _buildDataRow('Pesticide Amount:',
                                            usage['pesticideAmount']),
                                        _buildDataRow(
                                            'Timestamp:',
                                            _formatTimestamp(
                                                usage['timestamp'])),
                                      ],
                                    ),
                                  ),
                                );
                              },
                            ),
            ),
          ],
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
              'https://newbackend-sq6b.onrender.com/predict'), // Replace with your backend URL
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
  final TextEditingController absorptionRatioController =
      TextEditingController();

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
                    absorptionRatioController),
                const SizedBox(height: 24.0),
                Center(
                  child: ElevatedButton(
                    onPressed: () async {
                      if (_formKey.currentState!.validate() &&
                          selectedCrop != null) {
                        final chlorophyllValue =
                            double.parse(chlorophyllController.text);
                        final absorptionRatioValue =
                            double.parse(absorptionRatioController.text);
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

    final response = await http.post(
      Uri.parse(
          'https://health-backend-zvel.onrender.com/predict_health'), // Replace with your backend URL
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'Chlorophyll': chlorophyll,
        'Soil Moisture': cropWaterStressLevel,
        'Absorption Ratio': absorptionRatio,
        'Crop': selectedCrop,
      }),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      recommendations = List<String>.from(data['recommendations']);
    } else {
      throw Exception('Failed to load recommendations');
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
  const MapScreen({Key? key}) : super(key: key);

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  final List<LatLng> _polygonPoints = [];
  final List<LatLng> _rasterScanPoints = [];
  bool _showOptimalPath = false;
  bool _editMode = true;

  void _toggleOptimalPath() {
    if (_polygonPoints.length < 4) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('Need at least 4 points to calculate path')),
      );
      return;
    }

    setState(() {
      _showOptimalPath = !_showOptimalPath;
      if (_showOptimalPath) {
        _generateOptimalPath();
      } else {
        _rasterScanPoints.clear();
      }
    });
  }

  void _generateOptimalPath() {
    final pathPoints = <LatLng>[];

    double minLat = _polygonPoints.map((p) => p.latitude).reduce(min);
    double maxLat = _polygonPoints.map((p) => p.latitude).reduce(max);
    double minLng = _polygonPoints.map((p) => p.longitude).reduce(min);
    double maxLng = _polygonPoints.map((p) => p.longitude).reduce(max);

    final latRange = maxLat - minLat;
    final double step = latRange / 20; // Adjust to ~150 horizontal scan lines

    bool reverseDirection = false;

    for (double lat = minLat; lat <= maxLat; lat += step) {
      List<double> longitudes = [];

      for (double lng = minLng; lng <= maxLng; lng += step) {
        if (_isPointInPolygon(LatLng(lat, lng), _polygonPoints)) {
          longitudes.add(lng);
        }
      }

      if (longitudes.isEmpty) continue;

      longitudes.sort(reverseDirection
          ? (a, b) => b.compareTo(a)
          : (a, b) => a.compareTo(b));
      reverseDirection = !reverseDirection;

      pathPoints.addAll(longitudes.map((lng) => LatLng(lat, lng)));
    }

    setState(() {
      _rasterScanPoints
        ..clear()
        ..addAll(pathPoints);
    });
  }

  bool _isPointInPolygon(LatLng point, List<LatLng> polygon) {
    bool inside = false;
    for (int i = 0, j = polygon.length - 1; i < polygon.length; j = i++) {
      final p1 = polygon[i], p2 = polygon[j];
      if (((p1.latitude > point.latitude) != (p2.latitude > point.latitude)) &&
          (point.longitude <
              (p2.longitude - p1.longitude) *
                      (point.latitude - p1.latitude) /
                      (p2.latitude - p1.latitude) +
                  p1.longitude)) {
        inside = !inside;
      }
    }
    return inside;
  }

  void _toggleViewMode() {
    setState(() {
      _editMode = !_editMode;
      if (!_editMode) {
        _showOptimalPath = false;
        _rasterScanPoints.clear();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Field Scanning Map'),
        actions: [
          IconButton(
            icon: Icon(_editMode ? Icons.map : Icons.edit),
            onPressed: _toggleViewMode,
            tooltip: _editMode ? 'Back to Normal Map' : 'Edit Polygon',
          ),
          if (_editMode)
            IconButton(
              icon: Icon(Icons.alt_route,
                  color:
                      _polygonPoints.length >= 4 ? Colors.white : Colors.grey),
              onPressed: _polygonPoints.length >= 4 ? _toggleOptimalPath : null,
              tooltip: 'Optimal Path',
            ),
        ],
      ),
      body: FlutterMap(
        options: MapOptions(
          center: LatLng(21.2514, 81.6296),
          zoom: 16.0,
          minZoom: 3.0,
          maxZoom: 18.0,
          onTap: _editMode
              ? (tapPosition, latlng) =>
                  setState(() => _polygonPoints.add(latlng))
              : null,
        ),
        children: [
          TileLayer(
            urlTemplate:
                'https://services.arcgisonline.com/ArcGIS/rest/services/World_Imagery/MapServer/tile/{z}/{y}/{x}',
            userAgentPackageName: 'com.example.yourapp',
          ),
          if (_editMode && _polygonPoints.isNotEmpty)
            PolygonLayer(
              polygons: [
                Polygon(
                  points: _polygonPoints,
                  color: Colors.blue.withOpacity(0.3),
                  borderColor: Colors.blue,
                  borderStrokeWidth: 2,
                )
              ],
            ),
          if (_editMode && _showOptimalPath)
            PolylineLayer(
              polylines: [
                Polyline(
                  points: _rasterScanPoints,
                  color: Colors.green,
                  strokeWidth: 2,
                )
              ],
            ),
          if (_editMode)
            MarkerLayer(
              markers: _polygonPoints.map((point) {
                return Marker(
                  point: point,
                  width: 100,
                  height: 60,
                  builder: (ctx) => Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: Colors.black.withOpacity(0.6),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          '${point.latitude.toStringAsFixed(5)},\n${point.longitude.toStringAsFixed(5)}',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 10,
                            height: 1.2,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                      const Icon(
                        Icons.location_pin,
                        color: Colors.red,
                        size: 30,
                      ),
                    ],
                  ),
                );
              }).toList(),
            ),
        ],
      ),
      floatingActionButton: _editMode
          ? FloatingActionButton(
              onPressed: () => setState(() {
                _polygonPoints.clear();
                _rasterScanPoints.clear();
                _showOptimalPath = false;
              }),
              child: const Icon(Icons.clear),
            )
          : null,
    );
  }
}

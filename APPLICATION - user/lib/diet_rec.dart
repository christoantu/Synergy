import 'dart:async';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class SmartDietPage extends StatefulWidget {
  @override
  _SmartDietPageState createState() => _SmartDietPageState();
}

class _SmartDietPageState extends State<SmartDietPage> {
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;
  String? _generatedDietPlan;
  bool _showHealthWarning = false;
  String _warningMessage = '';

  // Controllers
  final TextEditingController _genderController = TextEditingController();
  final TextEditingController _bmiController = TextEditingController();
  final TextEditingController _bloodPressureController = TextEditingController();
  final TextEditingController _mainHealthConcernController = TextEditingController();
  final TextEditingController _lifestyleController = TextEditingController();
  final TextEditingController _prevWeekCalorieController = TextEditingController();

  List<String> _selectedConditions = [];

  final List<String> _seriousConditions = [
    'Heart Problems',
    'Kidney Issues',
    'Liver Issues',
    'Cancer History',
    'Stroke History'
  ];

  final List<String> _healthConditions = [
    'Diabetes', 'High Cholesterol', 'Heart Problems',
    'Kidney Issues', 'Liver Issues', 'Food Allergies',
    'Arthritis', 'Asthma', 'Digestive Issues',
    'Headaches', 'Depression', 'Cancer History',
    'Stroke History', 'Pregnancy'
  ];

  // --- CUSTOM TOAST LOGIC ---
  void _showToast(BuildContext context) {
    late OverlayEntry overlayEntry;

    overlayEntry = OverlayEntry(
      builder: (context) => GestureDetector(
        // captures tap anywhere to dismiss
        behavior: HitTestBehavior.translucent,
        onTap: () {
          if (overlayEntry.mounted) {
            overlayEntry.remove();
          }
        },
        child: Material(
          color: Colors.transparent,
          child: Align(
            alignment: Alignment.bottomCenter,
            child: Container(
              margin: EdgeInsets.only(bottom: 100), // Adjusted height
              padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              decoration: BoxDecoration(
                color: Colors.green,
                borderRadius: BorderRadius.circular(25),
                boxShadow: [BoxShadow(color: Colors.black26, blurRadius: 10)],
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.arrow_downward, color: Colors.white, size: 20),
                  SizedBox(width: 8),
                  Text(
                    'Scroll Down to view plan',
                    style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );

    Overlay.of(context).insert(overlayEntry);

    // Auto-remove after 10 seconds if not tapped
    Future.delayed(Duration(seconds: 10), () {
      if (overlayEntry.mounted) {
        overlayEntry.remove();
      }
    });
  }

  void _checkHealthConditions() {
    int seriousCount = _selectedConditions
        .where((condition) => _seriousConditions.contains(condition))
        .length;

    setState(() {
      if (seriousCount >= 2) {
        _showHealthWarning = true;
        _warningMessage = '⚠️ Multiple Serious Health Conditions Detected\n\n'
            'For your safety, we cannot generate an AI diet plan. Please consult a doctor.';
      } else if (seriousCount == 1) {
        _showHealthWarning = true;
        _warningMessage = '⚠️ Important Health Consideration\n\n'
            'You have selected a serious health condition. Consult a professional for supervision.';
      } else {
        _showHealthWarning = false;
        _warningMessage = '';
      }
    });
  }

  Future<String> _getBaseUrl() async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    return sharedPreferences.getString('url') ?? 'http://localhost:8000';
  }

  Future<void> _generateDietPlan() async {
    int seriousCount = _selectedConditions
        .where((condition) => _seriousConditions.contains(condition))
        .length;

    if (seriousCount >= 2) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Cannot generate diet plan due to serious health risks'), backgroundColor: Colors.red),
      );
      return;
    }

    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });

      SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
      String? lid = sharedPreferences.getString('lid');

      var data = {
        'Gender': _genderController.text,
        'BMI': _bmiController.text,
        'BloodPressure': _bloodPressureController.text,
        'MainHealthConcern': _mainHealthConcernController.text,
        'Lifestyle': _lifestyleController.text,
        'HealthConditions': _selectedConditions,
        'PrevWeekCalories': _prevWeekCalorieController.text,
        'lid': lid,
      };

      try {
        String baseUrl = await _getBaseUrl();
        final response = await http.post(
          Uri.parse('$baseUrl/generate_diet_plan'),
          headers: {'Content-Type': 'application/json'},
          body: json.encode(data),
        ).timeout(Duration(seconds: 30));

        final jsonResponse = json.decode(response.body);

        if (jsonResponse['success'] == true) {
          setState(() {
            _generatedDietPlan = jsonResponse['diet_plan'];
          });
          // Call the custom toast instead of SnackBar
          _showToast(context);
        } else {
          throw Exception(jsonResponse['error'] ?? 'Unknown error');
        }

      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      } finally {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  void _clearForm() {
    setState(() {
      _genderController.clear();
      _bmiController.clear();
      _bloodPressureController.clear();
      _mainHealthConcernController.clear();
      _lifestyleController.clear();
      _prevWeekCalorieController.clear();
      _selectedConditions.clear();
      _generatedDietPlan = null;
      _showHealthWarning = false;
    });
    _formKey.currentState?.reset();
  }

  @override
  Widget build(BuildContext context) {
    int seriousCount = _selectedConditions.where((c) => _seriousConditions.contains(c)).length;
    bool canGeneratePlan = seriousCount < 2;

    return Scaffold(
      appBar: AppBar(
        title: Text('AI Diet Planner'),
        backgroundColor: canGeneratePlan ? Colors.green : Colors.grey,
        actions: [IconButton(icon: Icon(Icons.refresh), onPressed: _clearForm)],
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator(color: Colors.green))
          : Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              if (_showHealthWarning) _buildHealthWarning(),

              _buildInfoCard(
                'Basic Information',
                Icons.person,
                [
                  _buildDropdownField('Gender', ['Male', 'Female', 'Other'], _genderController),
                  SizedBox(height: 15),
                  _buildTextField('BMI', 'Enter your BMI', TextInputType.number, _bmiController),
                  SizedBox(height: 15),
                  _buildDropdownField('Blood Pressure', ['Low', 'Normal', 'High'], _bloodPressureController),
                ],
              ),

              SizedBox(height: 16),

              _buildInfoCard(
                'Weekly Nutrition History',
                Icons.history,
                [
                  _buildTextField(
                      'Calories (Last Week)',
                      'e.g. 2100',
                      TextInputType.number,
                      _prevWeekCalorieController
                  ),
                  SizedBox(height: 8),
                  Text(
                    "This helps AI understand your recent metabolism.",
                    style: TextStyle(fontSize: 12, color: Colors.grey[600], fontStyle: FontStyle.italic),
                  )
                ],
              ),

              SizedBox(height: 16),

              _buildInfoCard(
                'Lifestyle',
                Icons.fitness_center,
                [
                  _buildDropdownField(
                    'Alcohol Consumption',
                    ['None', 'Social Drinker', 'Regular Drinker', 'Heavy Drinker'],
                    _lifestyleController,
                  ),
                ],
              ),

              SizedBox(height: 16),

              _buildConditionsCard(seriousCount),

              SizedBox(height: 16),

              _buildInfoCard(
                'Health Goals',
                Icons.flag,
                [
                  _buildDropdownField(
                    'Primary Health Goal',
                    ['Weight Loss', 'Weight Gain', 'Muscle Building', 'General Health Maintenance'],
                    _mainHealthConcernController,
                  ),
                ],
              ),

              SizedBox(height: 24),

              ElevatedButton.icon(
                onPressed: canGeneratePlan ? _generateDietPlan : null,
                icon: Icon(Icons.auto_awesome),
                label: Text(canGeneratePlan ? 'Generate AI Diet Plan' : 'Medical Block active'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: canGeneratePlan ? Colors.green : Colors.grey,
                  foregroundColor: Colors.white,
                  padding: EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),

              if (_generatedDietPlan != null) _buildResultCard(),

              SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  // --- WIDGET HELPER METHODS ---

  Widget _buildInfoCard(String title, IconData icon, List<Widget> children) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(children: [Icon(icon, color: Colors.green), SizedBox(width: 8), Text(title, style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold))]),
            SizedBox(height: 12),
            ...children,
          ],
        ),
      ),
    );
  }

  Widget _buildConditionsCard(int seriousCount) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Health Conditions', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            SizedBox(height: 12),
            Wrap(
              spacing: 8,
              children: _healthConditions.map((condition) {
                bool isSerious = _seriousConditions.contains(condition);
                bool isSelected = _selectedConditions.contains(condition);
                return FilterChip(
                  label: Text(condition),
                  selected: isSelected,
                  selectedColor: isSerious ? Colors.red.withOpacity(0.2) : Colors.green.withOpacity(0.2),
                  onSelected: (selected) {
                    setState(() {
                      selected ? _selectedConditions.add(condition) : _selectedConditions.remove(condition);
                    });
                    _checkHealthConditions();
                  },
                );
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildResultCard() {
    return Card(
      margin: EdgeInsets.only(top: 24),
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Your Personalized Diet Plan', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.green)),
            Divider(),
            Text(_generatedDietPlan!, style: TextStyle(height: 1.5)),
          ],
        ),
      ),
    );
  }

  Widget _buildHealthWarning() {
    return Container(
      padding: EdgeInsets.all(16),
      margin: EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(color: Colors.red.withOpacity(0.1), borderRadius: BorderRadius.circular(12)),
      child: Text(_warningMessage, style: TextStyle(color: Colors.red[900])),
    );
  }

  Widget _buildDropdownField(String label, List<String> options, TextEditingController controller) {
    return DropdownButtonFormField<String>(
      value: controller.text.isNotEmpty ? controller.text : null,
      decoration: InputDecoration(labelText: label, border: OutlineInputBorder()),
      items: options.map((o) => DropdownMenuItem(value: o, child: Text(o))).toList(),
      onChanged: (v) {
        controller.text = v!;
      },
      validator: (v) => (v == null || v.isEmpty) ? 'Required' : null,
    );
  }

  Widget _buildTextField(String label, String hint, TextInputType type, TextEditingController controller) {
    return TextFormField(
      controller: controller,
      decoration: InputDecoration(labelText: label, hintText: hint, border: OutlineInputBorder()),
      keyboardType: type,
      validator: (v) => (v == null || v.isEmpty) ? 'Required' : null,
    );
  }

  @override
  void dispose() {
    _genderController.dispose();
    _bmiController.dispose();
    _bloodPressureController.dispose();
    _mainHealthConcernController.dispose();
    _lifestyleController.dispose();
    _prevWeekCalorieController.dispose();
    super.dispose();
  }
}
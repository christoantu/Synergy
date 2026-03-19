import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class AddFoodPage extends StatefulWidget {
  final double totalCalories;
  final double totalWeight;
  final double caloriesPer100g;

  const AddFoodPage({
    Key? key,
    required this.totalCalories,
    required this.totalWeight,
    required this.caloriesPer100g,
  }) : super(key: key);

  @override
  _AddFoodPageState createState() => _AddFoodPageState();
}

class _AddFoodPageState extends State<AddFoodPage> {
  late TextEditingController _nameController;
  late TextEditingController _calorieController;
  late TextEditingController _weightController;
  late TextEditingController _per100Controller;

  // NEW: Controllers for the specific intake amount
  final TextEditingController _intakeGramsController = TextEditingController();
  final TextEditingController _intakeCalorieController = TextEditingController();

  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController();
    _calorieController = TextEditingController(text: widget.totalCalories.toString());
    _weightController = TextEditingController(text: widget.totalWeight.toString());
    _per100Controller = TextEditingController(text: widget.caloriesPer100g.toString());

    // Add listener to auto-calculate calories based on grams typed
    _intakeGramsController.addListener(_calculateIntakeCalories);
  }

  void _calculateIntakeCalories() {
    final String text = _intakeGramsController.text;
    if (text.isEmpty) {
      _intakeCalorieController.text = "";
      return;
    }

    double? grams = double.tryParse(text);
    if (grams != null) {
      // Logic: (Calories per 100g / 100) * grams consumed
      double calculatedCals = (widget.caloriesPer100g / 100) * grams;
      _intakeCalorieController.text = calculatedCals.toStringAsFixed(1);
    }
  }

  Future<void> _saveFoodToServer() async {
    // if (_nameController.text.isEmpty || _intakeGramsController.text.isEmpty) {
    //   _showSnackBar("Please fill in the food name and amount taken", Colors.red);
    //   return;
    // }

    setState(() => _isSaving = true);


    SharedPreferences sh = await SharedPreferences.getInstance();
    String baseUrl = sh.getString('url') ?? "";
    String lid = sh.getString('lid') ?? "";
    final url = Uri.parse(baseUrl + "/save_user_intake");
    print(url);
    print('url==============');
    print('url==============');
    print('url==============');
    print('url==============');

    final response = await http.post(
      url,
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({
        'food_name': _nameController.text,
        'lid': lid,
        'total_recipe_calories': widget.totalCalories,
        'grams_consumed': double.tryParse(_intakeGramsController.text),
        'calories_consumed': double.tryParse(_intakeCalorieController.text),
        'date_added': DateTime.now().toIso8601String(),
      }),
    );

    if (response.statusCode == 200 || response.statusCode == 201) {
      _showSnackBar("Food logged successfully!", Colors.green);
      Navigator.pop(context); // Go back to recipe page
    } else {
      _showSnackBar("Failed to save: ${response.body}", Colors.red);
    }
  }



  void _showSnackBar(String message, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: color),
    );
  }

  @override
  void dispose() {
    _intakeGramsController.dispose();
    _intakeCalorieController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Log My Portion"),
        backgroundColor: Colors.orange.shade700,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text("Recipe Summary", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.grey)),
            SizedBox(height: 10),
            Row(
              children: [
                Expanded(child: _buildReadOnlyField("Total Cal", _calorieController)),
                SizedBox(width: 10),
                Expanded(child: _buildReadOnlyField("Cal/100g", _per100Controller)),
              ],
            ),
            Divider(height: 40),
            Text("My Intake", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
            SizedBox(height: 15),
            TextField(
              controller: _nameController,
              decoration: InputDecoration(
                labelText: "Dish Name",
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.restaurant_menu),
              ),
            ),
            SizedBox(height: 15),
            TextField(
              controller: _intakeGramsController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                labelText: "Amount I'm Eating (grams)",
                hintText: "e.g. 250",
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.scale),
                suffixText: "g",
              ),
            ),
            SizedBox(height: 15),
            TextField(
              controller: _intakeCalorieController,
              readOnly: true, // Automatically calculated
              decoration: InputDecoration(
                labelText: "Calculated Calories",
                filled: true,
                fillColor: Colors.orange.shade50,
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.local_fire_department, color: Colors.orange),
                suffixText: "kcal",
              ),
            ),
            SizedBox(height: 30),
            ElevatedButton(
              onPressed: _isSaving ? null : _saveFoodToServer,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                padding: EdgeInsets.symmetric(vertical: 15),
              ),
              child: _isSaving
                  ? CircularProgressIndicator(color: Colors.white)
                  : Text("Confirm & Save to Diary", style: TextStyle(fontSize: 16, color: Colors.white)),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildReadOnlyField(String label, TextEditingController controller) {
    return TextField(
      controller: controller,
      readOnly: true,
      style: TextStyle(fontSize: 12),
      decoration: InputDecoration(
        labelText: label,
        filled: true,
        fillColor: Colors.grey.shade100,
        border: OutlineInputBorder(),
      ),
    );
  }
}
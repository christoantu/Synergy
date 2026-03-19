import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

import 'AddFoodPage.dart';

class RecipeCaloriePage extends StatefulWidget {
  @override
  _RecipeCaloriePageState createState() => _RecipeCaloriePageState();
}

class _RecipeCaloriePageState extends State<RecipeCaloriePage> {
  final TextEditingController _recipeController = TextEditingController();
  Map<String, dynamic>? _result;
  bool _isLoading = false;

  Future<void> calculateCalories() async {
    setState(() {
      _isLoading = true;
      _result = null;
    });

    try {
      // 1. Get Base URL from SharedPreferences
      SharedPreferences sh = await SharedPreferences.getInstance();
      String baseUrl = sh.getString('url') ?? "http://10.0.2.2:8000/"; // Default for emulator

      // Construct the specific endpoint URL
      final url = Uri.parse(baseUrl + "/calculate_recipe_calories/");

      // 2. Prepare the Request body
      final response = await http.post(
        url,
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          'recipe_text': _recipeController.text,
        }),
      );

      // 3. Handle Response
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['success']) {
          setState(() {
            // result_data is stored in data['data'] based on your Django code
            _result = data['data'];
          });
        } else {
          _showError(data['error'] ?? "Failed to analyze recipe");
        }
      } else if (response.statusCode == 429) {
        _showError("Quota exceeded. Please wait a moment.");
      } else {
        _showError("Server Error: ${response.statusCode}");
      }
    } catch (e) {
      _showError("Connection Error: $e");
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.red),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Recipe Calorie Counter"),
        backgroundColor: Colors.green,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                "Enter your recipe details below:",
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 10),
              TextField(
                controller: _recipeController,
                maxLines: 5,
                decoration: InputDecoration(
                  hintText: "e.g., 2 cups of rice, 200g chicken...",
                  border: OutlineInputBorder(),
                  filled: true,
                  fillColor: Colors.grey[100],
                ),
              ),
              SizedBox(height: 16),
              ElevatedButton(
                onPressed: _isLoading ? null : calculateCalories,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  padding: EdgeInsets.symmetric(vertical: 15),
                ),
                child: _isLoading
                    ? CircularProgressIndicator(color: Colors.white)
                    : Text("Analyze Recipe", style: TextStyle(fontSize: 16, color: Colors.white)),
              ),
              Divider(height: 40, thickness: 2),

              // DISPLAY RESULTS
              if (_result != null) ...[
                _buildSummaryCard(),
                SizedBox(height: 20),
                Text("Ingredients Detected:",
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                _buildIngredientList(),
              ]
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSummaryCard() {
    return Card(
      elevation: 4,
      color: Colors.green.shade50,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            Text("Total Calories", style: TextStyle(fontSize: 16, color: Colors.green.shade700)),
            Text("${_result!['total_calories']} kcal",
                style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: Colors.green.shade900)),
            SizedBox(height: 15),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _statTile("Total Weight", "${_result!['total_weight_grams']}g"),
                _statTile("Per 100g", "${_result!['calories_per_100g']} kcal"),
              ],
            ),
            SizedBox(height: 20),
            ElevatedButton.icon(
              onPressed: () {
                // Navigate to the new page with the data
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => AddFoodPage(
                      totalCalories: _result!['total_calories'].toDouble(),
                      totalWeight: _result!['total_weight_grams'].toDouble(),
                      caloriesPer100g: _result!['calories_per_100g'].toDouble(),
                    ),
                  ),
                );
              },
              icon: Icon(Icons.add_circle_outline),
              label: Text("Add to My Food"),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.orange.shade700,
                foregroundColor: Colors.white,
              ),
            )
          ],
        ),
      ),
    );
  }

  Widget _statTile(String label, String value) {
    return Column(
      children: [
        Text(label, style: TextStyle(color: Colors.grey.shade600, fontSize: 14)),
        Text(value, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
      ],
    );
  }

  Widget _buildIngredientList() {
    final List ingredients = _result!['ingredients'] ?? [];
    if (ingredients.isEmpty) return Text("No ingredient details available.");

    return ListView.builder(
      shrinkWrap: true,
      physics: NeverScrollableScrollPhysics(),
      itemCount: ingredients.length,
      itemBuilder: (context, index) {
        return Card(
          margin: EdgeInsets.symmetric(vertical: 4),
          child: ListTile(
            leading: Icon(Icons.restaurant, color: Colors.green),
            title: Text(ingredients[index].toString()),
          ),
        );
      },
    );
  }
}
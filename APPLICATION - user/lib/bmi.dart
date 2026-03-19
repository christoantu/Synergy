import 'package:flutter/material.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'BMI Calculator',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: BMIPage(),
    );
  }
}

class BMIPage extends StatefulWidget {
  @override
  _BMIPageState createState() => _BMIPageState();
}

class _BMIPageState extends State<BMIPage> {
  final TextEditingController _heightController = TextEditingController();
  final TextEditingController _weightController = TextEditingController();
  String _bmiResult = '';
  String _bmiCategory = '';
  String _errorMessage = '';

  void _calculateBMI() {
    setState(() {
      _errorMessage = '';  // Reset the error message
      double height = double.tryParse(_heightController.text) ?? 0.0;
      double weight = double.tryParse(_weightController.text) ?? 0.0;

      // Validation for height and weight
      if (height <= 0 || weight <= 0) {
        _errorMessage = "Please enter valid values for height and weight!";
        return;
      }

      // Convert height to meters if entered in centimeters
      if (height > 3) {
        height = height / 100; // Convert from cm to meters if height is > 3
      }

      double bmi = weight / (height * height);

      setState(() {
        _bmiResult = bmi.toStringAsFixed(2);

        if (bmi < 18.5) {
          _bmiCategory = 'Underweight';
        } else if (bmi >= 18.5 && bmi < 24.9) {
          _bmiCategory = 'Healthy weight';
        } else if (bmi >= 25 && bmi < 29.9) {
          _bmiCategory = 'Overweight';
        } else {
          _bmiCategory = 'Obesity';
        }
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('BMI Calculator'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            TextField(
              controller: _heightController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                labelText: 'Height (in cm)',
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 10),
            TextField(
              controller: _weightController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                labelText: 'Weight (in kg)',
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: _calculateBMI,
              child: Text('Calculate BMI'),
            ),
            SizedBox(height: 20),
            if (_errorMessage.isNotEmpty)
              Text(
                _errorMessage,
                style: TextStyle(color: Colors.red, fontSize: 16),
                textAlign: TextAlign.center,
              ),
            if (_bmiResult.isNotEmpty)
              Text(
                'BMI: $_bmiResult',
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
            if (_bmiCategory.isNotEmpty)
              Text(
                'Category: $_bmiCategory',
                style: TextStyle(fontSize: 18, fontStyle: FontStyle.italic),
                textAlign: TextAlign.center,
              ),
          ],
        ),
      ),
    );
  }
}

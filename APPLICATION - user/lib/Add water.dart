import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'userhome.dart';

class AddWater extends StatefulWidget {
  const AddWater({super.key, required this.title});
  final String title;

  @override
  State<AddWater> createState() => _AddWaterState();
}

class _AddWaterState extends State<AddWater> {
  final TextEditingController alertControler = TextEditingController();
  final TextEditingController typeControler = TextEditingController();
  final _formkey = GlobalKey<FormState>();

  // Brand Color Constant
  final Color brandTeal = const Color.fromARGB(255, 18, 82, 98);

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) =>  DietHome()));
        return false;
      },
      child: Scaffold(
        backgroundColor: const Color(0xFFF5F7F8), // Light grey background
        appBar: AppBar(
          elevation: 0,
          backgroundColor: brandTeal,
          title: const Text('Add Water Log', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
          centerTitle: true,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.white),
            onPressed: () => Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) =>  DietHome())),
          ),
        ),
        body: SingleChildScrollView(
          child: Column(
            children: [
              // Header Visual
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 40),
                decoration: BoxDecoration(
                  color: brandTeal,
                  borderRadius: const BorderRadius.vertical(bottom: Radius.circular(30)),
                ),
                child: const Column(
                  children: [
                    Icon(Icons.water_drop, size: 70, color: Colors.cyanAccent),
                    SizedBox(height: 10),
                    Text(
                      "Stay Hydrated!",
                      style: TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 30),

              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Form(
                  key: _formkey,
                  child: Column(
                    children: [
                      // Type Input
                      _buildInputCard(
                        controller: typeControler,
                        label: "Type",
                        hint: "e.g. Morning Water, Post-Workout",
                        icon: Icons.category_outlined,
                        validator: (value) => (value == null || value.isEmpty) ? "Please enter type." : null,
                      ),

                      const SizedBox(height: 20),

                      // Alert/Note Input
                      _buildInputCard(
                        controller: alertControler,
                        label: "Alert / Note",
                        hint: "e.g. Set 1-hour reminder",
                        icon: Icons.notifications_active_outlined,
                        validator: (value) => (value == null || value.isEmpty) ? "Please enter alert info." : null,
                      ),

                      const SizedBox(height: 40),

                      // Submit Button
                      SizedBox(
                        width: double.infinity,
                        height: 55,
                        child: ElevatedButton(
                          onPressed: () {
                            if (_formkey.currentState!.validate()) {
                              sendAddWateraint();
                            }
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: brandTeal,
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                            elevation: 4,
                          ),
                          child: const Text(
                            "ADD TO LOG",
                            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, letterSpacing: 1.1),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInputCard({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
    required String? Function(String?) validator,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 4)),
        ],
      ),
      child: TextFormField(
        controller: controller,
        validator: validator,
        decoration: InputDecoration(
          labelText: label,
          hintText: hint,
          prefixIcon: Icon(icon, color: brandTeal),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(15), borderSide: BorderSide.none),
          filled: true,
          fillColor: Colors.white,
          contentPadding: const EdgeInsets.symmetric(vertical: 18),
        ),
      ),
    );
  }

  void sendAddWateraint() async {
    try {
      SharedPreferences sh = await SharedPreferences.getInstance();
      String url = sh.getString('url').toString();
      String lid = sh.getString('lid').toString();
      final urls = Uri.parse("$url/add_water");

      final response = await http.post(urls, body: {
        'lid': lid,
        'alert': alertControler.text,
        'type': typeControler.text,
      });

      if (response.statusCode == 200) {
        if (jsonDecode(response.body)['status'] == 'ok') {
          Fluttertoast.showToast(msg: 'Water Log Added');
          Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) =>  DietHome()));
        } else {
          Fluttertoast.showToast(msg: 'Failed to add log');
        }
      }
    } catch (e) {
      Fluttertoast.showToast(msg: "Error: $e");
    }
  }
}
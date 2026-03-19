import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'userhome.dart';

class AddFoods extends StatefulWidget {
  const AddFoods({super.key, required this.title});
  final String title;

  @override
  State<AddFoods> createState() => _AddFoodsState();
}

class _AddFoodsState extends State<AddFoods> {
  final TextEditingController nameControler = TextEditingController();
  final TextEditingController gramControler = TextEditingController();
  String? selectedType;
  final _formkey = GlobalKey<FormState>();

  // Brand Color
  final Color brandTeal = const Color.fromARGB(255, 18, 82, 98);

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) =>  DietHome()));
        return false;
      },
      child: Scaffold(
        backgroundColor: const Color(0xFFF5F7F8),
        appBar: AppBar(
          elevation: 0,
          backgroundColor: brandTeal,
          centerTitle: true,
          title: const Text('Log Your Meal', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.white),
            onPressed: () => Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) =>  DietHome())),
          ),
        ),
        body: SingleChildScrollView(
          child: Column(
            children: [
              // Visual Header
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 30),
                decoration: BoxDecoration(
                  color: brandTeal,
                  borderRadius: const BorderRadius.vertical(bottom: Radius.circular(30)),
                ),
                child: const Column(
                  children: [
                    CircleAvatar(
                      radius: 40,
                      backgroundColor: Colors.white24,
                      child: Icon(Icons.restaurant, size: 40, color: Colors.white),
                    ),
                    SizedBox(height: 15),
                    Text("What are you eating?", style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w500)),
                  ],
                ),
              ),

              Padding(
                padding: const EdgeInsets.all(20.0),
                child: Form(
                  key: _formkey,
                  child: Column(
                    children: [
                      // Card containing all inputs
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: [
                            BoxShadow(color: brandTeal.withOpacity(0.1), blurRadius: 20, offset: const Offset(0, 10)),
                          ],
                        ),
                        child: Column(
                          children: [
                            // Food Name Field
                            _buildTextField(
                              controller: nameControler,
                              label: "Food Name",
                              icon: Icons.fastfood_outlined,
                              hint: "e.g. Grilled Chicken",
                              isLowercase: true,
                            ),
                            const SizedBox(height: 20),

                            // Category Dropdown
                            _buildDropdownField(),

                            const SizedBox(height: 20),

                            // Gram Field
                            _buildTextField(
                              controller: gramControler,
                              label: "Grams",
                              icon: Icons.scale_outlined,
                              hint: "e.g. 250",
                              isNumber: true,
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 40),

                      // Submit Button
                      SizedBox(
                        width: double.infinity,
                        height: 55,
                        child: ElevatedButton(
                          onPressed: () {
                            if (_formkey.currentState!.validate()) {
                              sendAddFoodsaint();
                            }
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: brandTeal,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                            elevation: 5,
                          ),
                          child: const Text("SAVE MEAL", style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold, letterSpacing: 1.2)),
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

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    required String hint,
    bool isNumber = false,
    bool isLowercase = false,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: isNumber ? TextInputType.number : TextInputType.text,
      inputFormatters: isLowercase ? [
        TextInputFormatter.withFunction((oldValue, newValue) => TextEditingValue(
          text: newValue.text.toLowerCase(),
          selection: newValue.selection,
        )),
      ] : null,
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        prefixIcon: Icon(icon, color: brandTeal),
        border: UnderlineInputBorder(borderSide: BorderSide(color: Colors.grey[300]!)),
        enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: Colors.grey[300]!)),
        focusedBorder: UnderlineInputBorder(borderSide: BorderSide(color: brandTeal, width: 2)),
      ),
      validator: (value) => (value == null || value.isEmpty) ? "Required" : null,
    );
  }

  Widget _buildDropdownField() {
    return DropdownButtonFormField<String>(
      value: selectedType,
      onChanged: (val) => setState(() => selectedType = val),
      decoration: InputDecoration(
        labelText: "Food Category",
        prefixIcon: Icon(Icons.category_outlined, color: brandTeal),
        border: UnderlineInputBorder(borderSide: BorderSide(color: Colors.grey[300]!)),
      ),
      items: [
        'Fruits', 'Vegetables', 'Grains and Legumes', 'Dairy', 'Meats and Fish',
        'Indian Dishes', 'Chinese Dishes', 'Italian Dishes', 'Arabian Dishes',
        'Nuts and Seeds'
      ].map((val) => DropdownMenuItem(value: val, child: Text(val))).toList(),
      validator: (value) => (value == null) ? "Please select a category" : null,
    );
  }

  void sendAddFoodsaint() async {
    try {
      SharedPreferences sh = await SharedPreferences.getInstance();
      String url = sh.getString('url').toString();
      String lid = sh.getString('lid').toString();
      final urls = Uri.parse("$url/user_add_food");

      final response = await http.post(urls, body: {
        'lid': lid,
        'name': nameControler.text,
        'gram': gramControler.text,
        'type': selectedType ?? '',
      });

      if (response.statusCode == 200 && jsonDecode(response.body)['status'] == 'ok') {
        Fluttertoast.showToast(msg: 'Meal Logged Successfully');
        Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) =>  DietHome()));
      }
    } catch (e) {
      Fluttertoast.showToast(msg: e.toString());
    }
  }
}
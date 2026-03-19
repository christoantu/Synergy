import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'dart:io';
import 'package:image_picker/image_picker.dart';

import 'logins.dart';

class SignUpForm extends StatefulWidget {
  const SignUpForm({super.key});

  @override
  State<SignUpForm> createState() => _SignUpFormState();
}

class _SignUpFormState extends State<SignUpForm> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  // Controllers
  final TextEditingController firstnameController = TextEditingController();
  final TextEditingController dobController = TextEditingController();
  final TextEditingController genderController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController placeController = TextEditingController();
  final TextEditingController districtController = TextEditingController();
  final TextEditingController pinController = TextEditingController();
  final TextEditingController postController = TextEditingController();
  final TextEditingController phoneNumberController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController bloodtypeController = TextEditingController();

  bool _obscurePassword = true;
  bool _isSubmitting = false;
  XFile? _image;

  // Dropdown Lists
  final List<String> _keralaDistricts = [
    'Alappuzha', 'Ernakulam', 'Idukki', 'Kannur', 'Kasaragod',
    'Kollam', 'Kottayam', 'Kozhikode', 'Malappuram', 'Palakkad',
    'Pathanamthitta', 'Thiruvananthapuram', 'Thrissur', 'Wayanad'
  ];

  final List<String> _bloodGroups = ['A+', 'A-', 'B+', 'B-', 'AB+', 'AB-', 'O+', 'O-'];
  final List<String> _genders = ['Male', 'Female', 'Other'];

  // Validation Logic
  String? _validateRequired(String? value, String fieldName) {
    if (value == null || value.isEmpty) return 'Please select $fieldName';
    return null;
  }

  String? _validateName(String? value) {
    if (value == null || value.isEmpty) return 'Please enter your name';
    if (!RegExp(r'^[a-zA-Z ]+$').hasMatch(value)) return 'Letters and spaces only';
    return null;
  }

  String? _validateEmail(String? value) {
    if (value == null || value.isEmpty) return 'Please enter your email';
    if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value)) return 'Invalid email';
    return null;
  }

  String? _validatePhone(String? value) {
    if (value == null || value.isEmpty) return 'Required';
    if (!RegExp(r'^[0-9]{10}$').hasMatch(value)) return 'Enter 10 digits';
    return null;
  }

  String? _validatePassword(String? value) {
    if (value == null || value.isEmpty) return 'Required';
    if (value.length < 6) return 'Min 6 characters';
    return null;
  }

  // Image Selection
  void _showPicker(context) {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext bc) {
        return SafeArea(
          child: Wrap(
            children: <Widget>[
              ListTile(
                leading: const Icon(Icons.photo_library),
                title: const Text('Photo Library'),
                onTap: () async {
                  final img = await ImagePicker().pickImage(source: ImageSource.gallery);
                  if (img != null) setState(() => _image = img);
                  Navigator.of(context).pop();
                },
              ),
              ListTile(
                leading: const Icon(Icons.photo_camera),
                title: const Text('Camera'),
                onTap: () async {
                  final img = await ImagePicker().pickImage(source: ImageSource.camera, imageQuality: 50);
                  if (img != null) setState(() => _image = img);
                  Navigator.of(context).pop();
                },
              ),
            ],
          ),
        );
      },
    );
  }

  // UPDATED: Date Selection logic to disable years after 2011
  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime(2011), // Set initial focus to the limit year
      firstDate: DateTime(1900),
      lastDate: DateTime(2011, 12, 31), // Users cannot select any date after 2011
    );
    if (picked != null) {
      setState(() => dobController.text = "${picked.toLocal()}".split(' ')[0]);
    }
  }

  Future<void> _submitForm() async {
    if (!_formKey.currentState!.validate() || _image == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(_image == null ? 'Please select a profile picture' : 'Fix form errors'), backgroundColor: Colors.red),
      );
      return;
    }

    setState(() => _isSubmitting = true);

    try {
      final sh = await SharedPreferences.getInstance();
      String url = sh.getString("url") ?? "";
      var request = http.MultipartRequest('POST', Uri.parse('$url/user_reg'));

      request.files.add(await http.MultipartFile.fromPath('image', _image!.path));
      request.fields.addAll({
        'name': firstnameController.text.trim(),
        'email': emailController.text.trim(),
        'gender': genderController.text,
        'phone': phoneNumberController.text.trim(),
        'password': passwordController.text,
        'dob': dobController.text,
        'place': placeController.text.trim(),
        'district': districtController.text,
        'pin': pinController.text.trim(),
        'post': postController.text.trim(),
        'bloodtype': bloodtypeController.text,
      });

      var response = await request.send();
      if (response.statusCode == 200) {
        final res = json.decode(await response.stream.bytesToString());
        if (res['status'] == 'ok') {
          Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => Ftnesslogin()));
        }
      }
    } catch (e) {
      debugPrint(e.toString());
    } finally {
      setState(() => _isSubmitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Create AI Diet Account"), centerTitle: true),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 25.0, vertical: 20),
          child: Column(
            children: [
              // Profile Image
              Center(
                child: GestureDetector(
                  onTap: () => _showPicker(context),
                  child: CircleAvatar(
                    radius: 60,
                    backgroundColor: Colors.green.withOpacity(0.1),
                    backgroundImage: _image != null ? FileImage(File(_image!.path)) : null,
                    child: _image == null ? const Icon(Icons.add_a_photo, size: 40, color: Colors.green) : null,
                  ),
                ),
              ),
              const SizedBox(height: 30),

              _buildTextField(controller: firstnameController, label: "Full Name", icon: Icons.person, validator: _validateName),
              const SizedBox(height: 15),

              _buildTextField(controller: emailController, label: "Email", icon: Icons.email, validator: _validateEmail, keyboardType: TextInputType.emailAddress),
              const SizedBox(height: 15),

              Row(
                children: [
                  Expanded(child: _buildTextField(controller: phoneNumberController, label: "Phone", icon: Icons.phone, validator: _validatePhone, keyboardType: TextInputType.phone)),
                  const SizedBox(width: 10),
                  Expanded(child: _buildDropdown(label: "Gender", icon: Icons.wc, items: _genders, controller: genderController)),
                ],
              ),
              const SizedBox(height: 15),

              Row(
                children: [
                  Expanded(child: _buildDropdown(label: "Blood Group", icon: Icons.bloodtype, items: _bloodGroups, controller: bloodtypeController)),
                  const SizedBox(width: 10),
                  Expanded(
                    child: InkWell(
                      onTap: () => _selectDate(context),
                      child: IgnorePointer(
                        child: _buildTextField(controller: dobController, label: "DOB", icon: Icons.calendar_month, validator: (v) => _validateRequired(v, "DOB")),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 15),

              _buildDropdown(label: "District (Kerala)", icon: Icons.map, items: _keralaDistricts, controller: districtController),
              const SizedBox(height: 15),

              Row(
                children: [
                  Expanded(child: _buildTextField(controller: placeController, label: "Place", icon: Icons.place, validator: (v) => _validateRequired(v, "Place"))),
                  const SizedBox(width: 10),
                  Expanded(child: _buildTextField(controller: postController, label: "Post Office", icon: Icons.local_post_office, validator: (v) => _validateRequired(v, "Post"))),
                ],
              ),
              const SizedBox(height: 15),

              _buildTextField(controller: pinController, label: "PIN Code", icon: Icons.pin_drop, validator: (v) => _validateRequired(v, "PIN"), keyboardType: TextInputType.number),
              const SizedBox(height: 15),

              _buildTextField(
                controller: passwordController,
                label: "Password",
                icon: Icons.lock,
                obscureText: _obscurePassword,
                validator: _validatePassword,
                suffixIcon: IconButton(
                  icon: Icon(_obscurePassword ? Icons.visibility : Icons.visibility_off),
                  onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
                ),
              ),
              const SizedBox(height: 30),

              SizedBox(
                width: double.infinity,
                height: 55,
                child: _isSubmitting
                    ? const Center(child: CircularProgressIndicator())
                    : ElevatedButton(
                  onPressed: _submitForm,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  child: const Text("SIGN UP", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  // Custom Dropdown Helper
  Widget _buildDropdown({required String label, required IconData icon, required List<String> items, required TextEditingController controller}) {
    return DropdownButtonFormField<String>(
      value: controller.text.isEmpty ? null : controller.text,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
      ),
      items: items.map((val) => DropdownMenuItem(value: val, child: Text(val))).toList(),
      onChanged: (value) => setState(() => controller.text = value!),
      validator: (value) => value == null ? 'Required' : null,
    );
  }

  // Custom TextField Helper
  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    bool obscureText = false,
    TextInputType keyboardType = TextInputType.text,
    Widget? suffixIcon,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      obscureText: obscureText,
      keyboardType: keyboardType,
      validator: validator,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon),
        suffixIcon: suffixIcon,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }
}
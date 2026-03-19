import 'dart:convert';
import 'package:aidiet/userhome.dart';
import 'package:aidiet/viewcomplaint.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class compl extends StatefulWidget {
  const compl({super.key, required this.title});
  final String title;

  @override
  State<compl> createState() => _complState();
}

class _complState extends State<compl> {
  TextEditingController complaintcontroller = TextEditingController();
  final _formkey = GlobalKey<FormState>();

  // Petzo Brand Color
  final Color brandTeal = const Color.fromARGB(255, 18, 82, 98);

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => DietHome()));
        return false;
      },
      child: Scaffold(
        backgroundColor: const Color(0xFFF8F9FA), // Subtle light grey
        appBar: AppBar(
          elevation: 0,
          backgroundColor: brandTeal,
          title: const Text('New Support Ticket',
              style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
          centerTitle: true,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.white),
            onPressed: () => Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => DietHome())),
          ),
        ),
        body: SingleChildScrollView(
          child: Column(
            children: [
              // Header Section
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 40, horizontal: 20),
                decoration: BoxDecoration(
                  color: brandTeal,
                  borderRadius: const BorderRadius.vertical(bottom: Radius.circular(30)),
                ),
                child: const Column(
                  children: [
                    Icon(Icons.help_outline_rounded, size: 60, color: Colors.white70),
                    SizedBox(height: 15),
                    Text(
                      "How can we help you today?",
                      textAlign: TextAlign.center,
                      style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.w600),
                    ),
                    SizedBox(height: 8),
                    Text(
                      "Our team will review your complaint and get back to you shortly.",
                      textAlign: TextAlign.center,
                      style: TextStyle(color: Colors.white60, fontSize: 13),
                    ),
                  ],
                ),
              ),

              Padding(
                padding: const EdgeInsets.all(24.0),
                child: Form(
                  key: _formkey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        "Describe your issue",
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black87),
                      ),
                      const SizedBox(height: 12),

                      // Input Container
                      Container(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(15),
                          boxShadow: [
                            BoxShadow(color: brandTeal.withOpacity(0.08), blurRadius: 15, offset: const Offset(0, 5)),
                          ],
                        ),
                        child: TextFormField(
                          maxLines: 6,
                          controller: complaintcontroller,
                          style: const TextStyle(fontSize: 15),
                          decoration: InputDecoration(
                            hintText: "Type your complaint here in detail...",
                            hintStyle: TextStyle(color: Colors.grey[400]),
                            prefixIcon: Padding(
                              padding: const EdgeInsets.only(bottom: 100), // Push icon to top
                              child: Icon(Icons.edit_note, color: brandTeal),
                            ),
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(15), borderSide: BorderSide.none),
                            filled: true,
                            fillColor: Colors.white,
                          ),
                          validator: (value) => (value == null || value.isEmpty) ? "Please enter your complaint." : null,
                        ),
                      ),

                      const SizedBox(height: 32),

                      // Submit Button
                      SizedBox(
                        width: double.infinity,
                        height: 55,
                        child: ElevatedButton(
                          onPressed: () {
                            if (_formkey.currentState!.validate()) {
                              sendcompliant();
                            }
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: brandTeal,
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                            elevation: 4,
                          ),
                          child: const Text(
                            'SUBMIT COMPLAINT',
                            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, letterSpacing: 1.1),
                          ),
                        ),
                      ),

                      const SizedBox(height: 20),
                      Center(
                        child: TextButton(
                          onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const ViewComplaints(title: "Home"))),
                          child: Text("View Previous Complaints", style: TextStyle(color: brandTeal, fontWeight: FontWeight.w600)),
                        ),
                      )
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

  void sendcompliant() async {
    try {
      SharedPreferences sh = await SharedPreferences.getInstance();
      String url = sh.getString('url').toString();
      String lid = sh.getString('lid').toString();
      final urls = Uri.parse(url + "/send_complaint");

      final response = await http.post(urls, body: {
        'complaint': complaintcontroller.text,
        'lid': lid,
      });

      if (response.statusCode == 200) {
        if (jsonDecode(response.body)['status'] == 'ok') {
          Fluttertoast.showToast(msg: 'Complaint Sent Successfully');
          Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const ViewComplaints(title: "Home")));
        } else {
          Fluttertoast.showToast(msg: 'Unable to send. Try again.');
        }
      }
    } catch (e) {
      Fluttertoast.showToast(msg: "Error: ${e.toString()}");
    }
  }
}
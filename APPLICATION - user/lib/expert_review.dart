import 'dart:convert';
import 'package:aidiet/userhome.dart'; // Ensure this matches your project structure
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';

class feedback extends StatefulWidget {
  const feedback({super.key, required this.title});
  final String title;

  @override
  State<feedback> createState() => _feedbackState();
}

class _feedbackState extends State<feedback> {
  final TextEditingController feedbackaintcontroller = TextEditingController();
  double _rating = 0;
  final _formkey = GlobalKey<FormState>();

  // Consistent Brand Color
  final Color brandTeal = const Color.fromARGB(255, 18, 82, 98);

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) =>  DietHome()),
        );
        return false;
      },
      child: Scaffold(
        backgroundColor: const Color(0xFFF8F9FA),
        appBar: AppBar(
          elevation: 0,
          backgroundColor: brandTeal,
          title: const Text('Rate Your Expert', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.white),
            onPressed: () => Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) =>  DietHome())),
          ),
        ),
        body: SingleChildScrollView(
          child: Column(
            children: [
              // Header Section
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 30),
                decoration: BoxDecoration(
                  color: brandTeal,
                  borderRadius: const BorderRadius.vertical(bottom: Radius.circular(30)),
                ),
                child: Column(
                  children: [
                    const Icon(Icons.stars_rounded, size: 80, color: Colors.amber),
                    const SizedBox(height: 10),
                    const Text(
                      "How was your experience?",
                      style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w500),
                    ),
                  ],
                ),
              ),

              Padding(
                padding: const EdgeInsets.all(20.0),
                child: Form(
                  key: _formkey,
                  child: Column(
                    children: [
                      const SizedBox(height: 20),
                      // Rating Section
                      const Text("Tap a star to rate", style: TextStyle(color: Colors.grey, fontSize: 14)),
                      const SizedBox(height: 10),
                      RatingBar.builder(
                        initialRating: _rating,
                        minRating: 1,
                        direction: Axis.horizontal,
                        allowHalfRating: true,
                        itemCount: 5,
                        itemPadding: const EdgeInsets.symmetric(horizontal: 4.0),
                        itemBuilder: (context, _) => const Icon(Icons.star, color: Colors.amber),
                        onRatingUpdate: (rating) => setState(() => _rating = rating),
                      ),

                      const SizedBox(height: 40),

                      // Feedback Input Card
                      Container(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(15),
                          boxShadow: [
                            BoxShadow(color: brandTeal.withOpacity(0.1), blurRadius: 10, offset: const Offset(0, 5)),
                          ],
                        ),
                        child: TextFormField(
                          maxLines: 5,
                          controller: feedbackaintcontroller,
                          decoration: InputDecoration(
                            hintText: "Write your review here...",
                            hintStyle: const TextStyle(color: Colors.grey),
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(15), borderSide: BorderSide.none),
                            contentPadding: const EdgeInsets.all(20),
                          ),
                          validator: (value) => (value == null || value.isEmpty) ? "Please enter your thoughts." : null,
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
                              if (_rating == 0) {
                                Fluttertoast.showToast(msg: "Please provide a star rating");
                              } else {
                                sendfeedbackiant();
                              }
                            }
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: brandTeal,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                            elevation: 5,
                          ),
                          child: const Text("SUBMIT REVIEW", style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold, letterSpacing: 1.2)),
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

  void sendfeedbackiant() async {
    try {
      SharedPreferences sh = await SharedPreferences.getInstance();
      String url = sh.getString('url').toString();
      String lid = sh.getString('lid').toString();
      String rid = sh.getString('eid').toString();
      final urls = Uri.parse("$url/send_feedback");

      final response = await http.post(urls, body: {
        'feedback': feedbackaintcontroller.text,
        'rating': _rating.toString(),
        'lid': lid,
        'eid': rid,
      });

      if (response.statusCode == 200) {
        if (jsonDecode(response.body)['status'] == 'ok') {
          Fluttertoast.showToast(msg: 'Review Sent Successfully');
          Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) =>  DietHome()));
        } else {
          Fluttertoast.showToast(msg: 'Error sending feedback');
        }
      }
    } catch (e) {
      Fluttertoast.showToast(msg: "Connection Error: ${e.toString()}");
    }
  }
}
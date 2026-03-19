import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import 'chat (1).dart';
import 'expert_review.dart';

class ViewExperts extends StatefulWidget {
  const ViewExperts({super.key, required this.title});
  final String title;

  @override
  State<ViewExperts> createState() => _ViewExpertsState();
}

class _ViewExpertsState extends State<ViewExperts> {
  // Matching your original theme color
  final Color brandTeal = const Color.fromARGB(255, 18, 82, 98);

  List<int> id_ = [];
  List<String> name_ = [];
  List<String> place_ = [];
  List<String> image_ = [];
  List<String> gender_ = [];
  List<String> LOGIN_ = [];
  List<String> filteredType_ = [];
  String selectedType = "All";
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    ViewExpertss();
  }

  void ViewExpertss() async {
    try {
      SharedPreferences sh = await SharedPreferences.getInstance();
      String urls = sh.getString('url').toString();
      String url = '$urls/user_view_expert';

      var data = await http.post(Uri.parse(url));
      var jsondata = json.decode(data.body);
      var arr = jsondata["data"];

      List<int> id = [];
      List<String> name = [];
      List<String> place = [];
      List<String> image = [];
      List<String> gender = [];
      List<String> LOGIN = [];

      for (int i = 0; i < arr.length; i++) {
        id.add(arr[i]['id']);
        name.add(arr[i]['name'].toString());
        place.add(arr[i]['place'].toString());
        gender.add(arr[i]['gender'].toString());
        LOGIN.add(arr[i]['LOGIN'].toString());
        image.add(sh.getString('imgurl').toString() + arr[i]['image']);
      }

      setState(() {
        id_ = id;
        name_ = name;
        place_ = place;
        gender_ = gender;
        image_ = image;
        LOGIN_ = LOGIN;
        filteredType_ = name;
        isLoading = false;
      });
    } catch (e) {
      setState(() => isLoading = false);
    }
  }

  void filterPetsByType(String type) {
    setState(() {
      selectedType = type;
      filteredType_ = (type == "All") ? name_ : name_.where((t) => t == type).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7F8),
      appBar: AppBar(
        elevation: 0,
        centerTitle: true,
        title: const Text('Expert Trainers',
            style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white, fontSize: 20)),
        backgroundColor: brandTeal,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(bottom: Radius.circular(20)),
        ),
      ),
      body: isLoading
          ? Center(child: CircularProgressIndicator(color: brandTeal))
          : Column(
        children: [
          _buildFilterBar(),
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              itemCount: filteredType_.length,
              itemBuilder: (context, index) {
                int originalIndex = name_.indexOf(filteredType_[index]);
                return _buildExpertListCard(originalIndex);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterBar() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text("Showing Experts", style: TextStyle(color: brandTeal, fontWeight: FontWeight.bold)),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: brandTeal.withOpacity(0.3)),
            ),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                value: selectedType,
                items: <String>["All", ...name_.toSet()].map((String value) {
                  return DropdownMenuItem<String>(value: value, child: Text(value, style: const TextStyle(fontSize: 13)));
                }).toList(),
                onChanged: (String? newValue) {
                  if (newValue != null) filterPetsByType(newValue);
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildExpertListCard(int index) {
    return Container(
      height: 140,
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(color: brandTeal.withOpacity(0.1), blurRadius: 10, offset: const Offset(0, 5)),
        ],
      ),
      child: Row(
        children: [
          // Left: Image with rounded corners
          Container(
            width: 120,
            height: 140,
            decoration: BoxDecoration(
              borderRadius: const BorderRadius.only(topLeft: Radius.circular(15), bottomLeft: Radius.circular(15)),
              image: DecorationImage(
                image: NetworkImage(image_[index]),
                fit: BoxFit.cover,
              ),
            ),
          ),
          // Right: Content
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(12.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(name_[index],
                          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: brandTeal)),
                      const SizedBox(height: 4),
                      Text(place_[index],
                          style: TextStyle(color: Colors.grey[600], fontSize: 13)),
                    ],
                  ),
                  Row(
                    children: [
                      _actionButton(
                          icon: Icons.chat,
                          color: brandTeal,
                          onTap: () async {
                            SharedPreferences sh = await SharedPreferences.getInstance();
                            sh.setString('clid', LOGIN_[index].toString());
                            Navigator.push(context, MaterialPageRoute(builder: (context) => const MyChatPage(title: '')));
                          }
                      ),
                      const SizedBox(width: 12),
                      _actionButton(
                          icon: Icons.reviews,
                          color: Colors.amber[700]!,
                          onTap: () async {
                            SharedPreferences sh = await SharedPreferences.getInstance();
                            sh.setString('eid', id_[index].toString());
                            Navigator.push(context, MaterialPageRoute(builder: (context) => const feedback(title: '')));
                          }
                      ),
                    ],
                  )
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _actionButton({required IconData icon, required Color color, required VoidCallback onTap}) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(icon, color: color, size: 20),
      ),
    );
  }
}
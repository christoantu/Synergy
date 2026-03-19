import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

import 'Add food.dart';
import 'userhome.dart';

class ViewFoodsfull extends StatefulWidget {
  const ViewFoodsfull({super.key, required this.title});
  final String title;

  @override
  State<ViewFoodsfull> createState() => _ViewFoodsfullState();
}

class _ViewFoodsfullState extends State<ViewFoodsfull> {
  // Brand Colors
  final Color brandTeal = const Color.fromARGB(255, 18, 82, 98);
  final Color accentOrange = const Color(0xFFFF8A65); // For calorie highlights

  List<int> id_ = [];
  List<String> type_ = [];
  List<String> date_ = [];
  List<String> gram_ = [];
  List<String> callorie_ = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchFoodLogs();
  }

  void fetchFoodLogs() async {
    try {
      SharedPreferences sh = await SharedPreferences.getInstance();
      String urls = sh.getString('url').toString();
      String url = '$urls/user_view_foodlo';
      String lid = sh.getString("lid").toString();

      var data = await http.post(Uri.parse(url), body: {"lid": lid});
      var jsondata = json.decode(data.body);

      var arr = jsondata["data"];
      List<int> id = [];
      List<String> date = [];
      List<String> type = [];
      List<String> gram = [];
      List<String> callorie = [];

      for (int i = 0; i < arr.length; i++) {
        id.add(arr[i]['id']);
        date.add(arr[i]['date'].toString());
        type.add(arr[i]['type']);
        gram.add(arr[i]['gram']);
        callorie.add(arr[i]['callorie']);
      }

      setState(() {
        id_ = id;
        date_ = date;
        type_ = type;
        gram_ = gram;
        callorie_ = callorie;
        isLoading = false;
      });
    } catch (e) {
      setState(() => isLoading = false);
      print("Error: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FB),
      appBar: AppBar(
        elevation: 0,
        backgroundColor: brandTeal,
        title: const Text('Food Journal',
            style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
        centerTitle: true,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(bottom: Radius.circular(20)),
        ),
      ),
      body: isLoading
          ? Center(child: CircularProgressIndicator(color: brandTeal))
          : id_.isEmpty
          ? _buildEmptyState()
          : ListView.builder(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
        itemCount: id_.length,
        itemBuilder: (context, index) {
          return _buildFoodLogCard(index);
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Navigator.push(context, MaterialPageRoute(builder: (context) => const AddFoods(title: '')));
        },
        backgroundColor: brandTeal,
        icon: const Icon(Icons.restaurant_menu, color: Colors.white),
        label: const Text("Log Meal", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.no_meals_outlined, size: 80, color: brandTeal.withOpacity(0.2)),
          const SizedBox(height: 16),
          Text("No meals logged today",
              style: TextStyle(color: brandTeal, fontSize: 16, fontWeight: FontWeight.w500)),
        ],
      ),
    );
  }

  Widget _buildFoodLogCard(int index) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(color: brandTeal.withOpacity(0.08), blurRadius: 15, offset: const Offset(0, 5)),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Icon/Image Placeholder
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: brandTeal.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(15),
                  ),
                  child: Icon(Icons.fastfood_rounded, color: brandTeal, size: 30),
                ),
                const SizedBox(width: 16),
                // Food Info
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(type_[index],
                          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black87)),
                      const SizedBox(height: 4),
                      Text(date_[index],
                          style: TextStyle(color: Colors.grey[500], fontSize: 13)),
                    ],
                  ),
                ),
                // Calorie Badge
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text("${callorie_[index]} kcal",
                        style: TextStyle(color: accentOrange, fontWeight: FontWeight.bold, fontSize: 16)),
                    Text("${gram_[index]}g",
                        style: TextStyle(color: Colors.grey[600], fontSize: 12)),
                  ],
                ),
              ],
            ),
            const Divider(height: 24),
            // Actions
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton.icon(
                  onPressed: () => _deleteLog(id_[index]),
                  icon: const Icon(Icons.delete_outline, color: Colors.redAccent, size: 20),
                  label: const Text("Remove", style: TextStyle(color: Colors.redAccent)),
                ),
              ],
            )
          ],
        ),
      ),
    );
  }

  void _deleteLog(int fid) async {
    try {
      SharedPreferences sh = await SharedPreferences.getInstance();
      String url = sh.getString('url').toString();
      final response = await http.post(Uri.parse('$url/delete_food_log'), body: {'wid': fid.toString()});

      if (response.statusCode == 200 && jsonDecode(response.body)['status'] == 'ok') {
        Fluttertoast.showToast(msg: 'Log Removed');
        fetchFoodLogs(); // Refresh the list
      }
    } catch (e) {
      Fluttertoast.showToast(msg: "Error: $e");
    }
  }
}
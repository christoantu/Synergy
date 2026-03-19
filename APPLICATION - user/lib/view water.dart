import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

import 'Add water.dart';
import 'userhome.dart';

class viewWaterfull extends StatefulWidget {
  const viewWaterfull({super.key, required this.title});
  final String title;

  @override
  State<viewWaterfull> createState() => _viewWaterfullState();
}

class _viewWaterfullState extends State<viewWaterfull> {
  final Color brandTeal = const Color.fromARGB(255, 18, 82, 98);
  final Color waterBlue = const Color(0xFF4FC3F7);

  List<int> id_ = [];
  List<String> type_ = [];
  List<String> date_ = [];
  List<String> alert_ = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    viewWaterfullData();
  }

  void viewWaterfullData() async {
    try {
      SharedPreferences sh = await SharedPreferences.getInstance();
      String urls = sh.getString('url').toString();
      String url = '$urls/user_view_waterlo';
      String lid = sh.getString("lid").toString();

      var data = await http.post(Uri.parse(url), body: {"lid": lid});
      var jsondata = json.decode(data.body);

      var arr = jsondata["data"];
      List<int> id = [];
      List<String> date = [];
      List<String> type = [];
      List<String> alert = [];

      for (int i = 0; i < arr.length; i++) {
        id.add(arr[i]['id']);
        date.add(arr[i]['date'].toString());
        type.add(arr[i]['type']);
        alert.add(arr[i]['alert']);
      }

      setState(() {
        id_ = id;
        date_ = date;
        type_ = type;
        alert_ = alert;
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
      backgroundColor: const Color(0xFFF0F4F8),
      appBar: AppBar(
        elevation: 0,
        backgroundColor: brandTeal,
        title: const Text('Hydration Tracker',
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
        padding: const EdgeInsets.all(16),
        itemCount: id_.length,
        itemBuilder: (context, index) {
          return _buildWaterLogCard(index);
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Navigator.push(context, MaterialPageRoute(builder: (context) => const AddWater(title: '')));
        },
        backgroundColor: brandTeal,
        icon: const Icon(Icons.water_drop, color: Colors.white),
        label: const Text("Log Water", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.opacity, size: 80, color: brandTeal.withOpacity(0.2)),
          const SizedBox(height: 16),
          Text("No logs found yet!", style: TextStyle(color: brandTeal, fontSize: 18, fontWeight: FontWeight.w500)),
        ],
      ),
    );
  }

  Widget _buildWaterLogCard(int index) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 4)),
        ],
      ),
      child: IntrinsicHeight(
        child: Row(
          children: [
            // Left Accent Bar
            Container(
              width: 6,
              decoration: BoxDecoration(
                color: waterBlue,
                borderRadius: const BorderRadius.only(topLeft: Radius.circular(15), bottomLeft: Radius.circular(15)),
              ),
            ),
            // Main Content
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(date_[index], style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.black87, fontSize: 16)),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(color: brandTeal.withOpacity(0.1), borderRadius: BorderRadius.circular(8)),
                          child: Text(type_[index], style: TextStyle(color: brandTeal, fontWeight: FontWeight.bold, fontSize: 12)),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        Icon(Icons.notifications_active_outlined, size: 16, color: Colors.orange[700]),
                        const SizedBox(width: 6),
                        Expanded(child: Text(alert_[index], style: TextStyle(color: Colors.grey[700], fontSize: 14))),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            // Delete Action
            IconButton(
              icon: const Icon(Icons.delete_outline, color: Colors.redAccent),
              onPressed: () => _showDeleteDialog(index),
            ),
            const SizedBox(width: 8),
          ],
        ),
      ),
    );
  }

  void _showDeleteDialog(int index) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Delete Log?"),
        content: const Text("Are you sure you want to remove this water log?"),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text("Cancel")),
          TextButton(
              onPressed: () {
                Navigator.pop(context);
                deleteLog(id_[index]);
              },
              child: const Text("Delete", style: TextStyle(color: Colors.red))
          ),
        ],
      ),
    );
  }

  void deleteLog(int wid) async {
    try {
      SharedPreferences sh = await SharedPreferences.getInstance();
      String url = sh.getString('url').toString();
      final response = await http.post(Uri.parse('$url/delete_water_log'), body: {'wid': wid.toString()});

      if (response.statusCode == 200 && jsonDecode(response.body)['status'] == 'ok') {
        Fluttertoast.showToast(msg: 'Deleted Successfully');
        viewWaterfullData(); // Refresh list instead of pushing back home
      }
    } catch (e) {
      Fluttertoast.showToast(msg: e.toString());
    }
  }
}
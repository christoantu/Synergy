import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:fluttertoast/fluttertoast.dart';

class ViewDietChartsPage extends StatefulWidget {
  const ViewDietChartsPage({Key? key}) : super(key: key);

  @override
  State<ViewDietChartsPage> createState() => _ViewDietChartsPageState();
}

class _ViewDietChartsPageState extends State<ViewDietChartsPage> {
  List<dynamic> dietCharts = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchDietCharts();
  }

  Future<void> fetchDietCharts() async {
    try {
      final pref = await SharedPreferences.getInstance();
      String? lid = pref.getString("lid");

      if (lid == null) {
        Fluttertoast.showToast(msg: "No session found. Please log in again.");
        setState(() {
          isLoading = false;
        });
        return;
      }

      String url = "${pref.getString("url") ?? ''}/view_diet_charts";
      var response = await http.post(
        Uri.parse(url),
        body: {'lid': lid},
      );

      if (response.statusCode == 200) {
        var jsonData = json.decode(response.body);
        String status = jsonData['status'];

        if (status == 'ok') {
          setState(() {
            dietCharts = jsonData['data'];
            isLoading = false;
            print('Fetched diet charts: $dietCharts');
          });
        } else {
          Fluttertoast.showToast(msg: "Error: ${jsonData['message']}");
          setState(() {
            isLoading = false;
          });
        }
      } else {
        Fluttertoast.showToast(msg: "Failed to load diet charts. Status code: ${response.statusCode}");
        setState(() {
          isLoading = false;
        });
      }
    } catch (e) {
      print("Error fetching diet charts: $e");
      Fluttertoast.showToast(msg: "An error occurred: $e");
      setState(() {
        isLoading = false;
      });
    }
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "$label: ",
            style: const TextStyle(
              fontWeight: FontWeight.w600,
              fontSize: 14,
              color: Colors.grey,
            ),
          ),
          Expanded(
            child: Text(
              value.isEmpty ? "Not specified" : value,
              style: const TextStyle(
                fontSize: 14,
                color: Colors.black87,
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Diet Plans"),
        centerTitle: true,
        backgroundColor: Colors.teal,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: isLoading
          ? const Center(
        child: CircularProgressIndicator(
          valueColor: AlwaysStoppedAnimation<Color>(Colors.teal),
        ),
      )
          : dietCharts.isEmpty
          ? const Center(
        child: Text(
          "No diet plans found.",
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
        ),
      )
          : ListView.builder(
        itemCount: dietCharts.length,
        itemBuilder: (BuildContext context, int index) {
          final chart = dietCharts[index];
          return Card(
            margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            elevation: 4,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header with ID and Type
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        "Plan #${chart['id'] ?? 'N/A'}",
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                          color: Colors.teal,
                        ),
                      ),
                      if (chart['type'] != null && chart['type'].isNotEmpty)
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: Colors.teal.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            chart['type'],
                            style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                              color: Colors.teal,
                            ),
                          ),
                        ),
                    ],
                  ),

                  const SizedBox(height: 12),

                  // Diet Plan
                  _buildInfoRow("Diet Plan", chart['dietplan'] ?? ''),

                  const SizedBox(height: 8),

                  // Exercise Plan
                  _buildInfoRow("Exercise Plan", chart['excersiseplan'] ?? ''),

                  const SizedBox(height: 8),

                  // Associated Diet Chart ID
                  _buildInfoRow("Diet Chart ID", chart['DIET_CHART_id']?.toString() ?? ''),

                  const SizedBox(height: 8),

                  // Additional information if available
                  if (chart['date'] != null)
                    _buildInfoRow("Date", chart['date'] ?? ''),

                  if (chart['health_condition'] != null)
                    _buildInfoRow("Health Condition", chart['health_condition'] ?? ''),

                  // Divider and actions
                  const SizedBox(height: 12),
                  const Divider(),

                  // Action buttons

                ],
              ),
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: fetchDietCharts,
        backgroundColor: Colors.teal,
        child: const Icon(Icons.refresh, color: Colors.white),
      ),
    );
  }

  void _showDeleteDialog(int? planId) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Delete Diet Plan"),
          content: const Text("Are you sure you want to delete this diet plan?"),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text("Cancel"),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                _deleteDietPlan(planId);
              },
              child: const Text(
                "Delete",
                style: TextStyle(color: Colors.red),
              ),
            ),
          ],
        );
      },
    );
  }

  void _deleteDietPlan(int? planId) async {
    try {
      final pref = await SharedPreferences.getInstance();
      String url = "${pref.getString("url") ?? ''}/delete_diet_plan";

      var response = await http.post(
        Uri.parse(url),
        body: {'plan_id': planId.toString()},
      );

      if (response.statusCode == 200) {
        var jsonData = json.decode(response.body);
        if (jsonData['status'] == 'ok') {
          Fluttertoast.showToast(msg: "Diet plan deleted successfully");
          fetchDietCharts(); // Refresh the list
        } else {
          Fluttertoast.showToast(msg: "Failed to delete diet plan");
        }
      } else {
        Fluttertoast.showToast(msg: "Failed to delete diet plan");
      }
    } catch (e) {
      Fluttertoast.showToast(msg: "Error deleting diet plan: $e");
    }
  }

  void _shareDietPlan(Map<String, dynamic> plan) {
    String shareText = """
Diet Plan #${plan['id']}

Diet Plan:
${plan['dietplan'] ?? 'Not specified'}

Exercise Plan:
${plan['excersiseplan'] ?? 'Not specified'}

Type: ${plan['type'] ?? 'Not specified'}
Health Condition: ${plan['health_condition'] ?? 'Not specified'}
""";

    // You can integrate with share_plus package for better sharing
    Fluttertoast.showToast(msg: "Copied to clipboard");

    // Copy to clipboard
    // Clipboard.setData(ClipboardData(text: shareText));
  }
}
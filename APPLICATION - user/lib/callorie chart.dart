import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:intl/intl.dart';

class CalorieChartPage extends StatefulWidget {
  const CalorieChartPage({super.key, required this.title});

  final String title;

  @override
  State<CalorieChartPage> createState() => _CalorieChartPageState();
}

class _CalorieChartPageState extends State<CalorieChartPage> {
  List<Map<String, dynamic>> allFoodData = []; // Store everything from server
  List<Map<String, dynamic>> filteredData = []; // Store what we actually show
  int totalCalories = 0;
  bool isLoading = true;

  // 0 = Today, 1 = Past 7 Days
  int _selectedFilter = 0;

  @override
  void initState() {
    super.initState();
    fetchCalorieData();
  }

  Future<void> fetchCalorieData() async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String baseUrl = prefs.getString('url') ?? '';
      String lid = prefs.getString('lid') ?? '';
      String url = '$baseUrl/user_view_take_calorie';

      var response = await http.post(
        Uri.parse(url),
        body: {'lid': lid},
      );

      if (response.statusCode == 200) {
        var jsonResponse = json.decode(response.body);
        if (jsonResponse['status'] == 'ok') {
          setState(() {
            allFoodData = List<Map<String, dynamic>>.from(jsonResponse['data']);
            _applyFilter(); // Filter the data locally
            isLoading = false;
          });
        } else {
          showToast("No data available");
          setState(() => isLoading = false);
        }
      }
    } catch (e) {
      showToast("Error: ${e.toString()}");
      setState(() => isLoading = false);
    }
  }

  void _applyFilter() {
    DateTime now = DateTime.now();
    DateTime today = DateTime(now.year, now.month, now.day);
    DateTime sevenDaysAgo = today.subtract(const Duration(days: 7));

    setState(() {
      if (_selectedFilter == 0) {
        // Filter for Today only
        filteredData = allFoodData.where((item) {
          DateTime itemDate = DateTime.parse(item['date']); // Ensure backend sends 'date'
          return itemDate.isAtSameMomentAs(today) ||
              (itemDate.isAfter(today.subtract(const Duration(seconds: 1))));
        }).toList();
      } else {
        // Filter for last 7 days
        filteredData = allFoodData.where((item) {
          DateTime itemDate = DateTime.parse(item['date']);
          return itemDate.isAfter(sevenDaysAgo);
        }).toList();
      }

      // Re-calculate total calories for the filtered set
      totalCalories = filteredData.fold(0, (sum, item) => sum + int.parse(item['callorie'].toString()));
    });
  }

  @override
  Widget build(BuildContext context) {
    String todayDate = DateFormat('yyyy-MM-dd').format(DateTime.now());

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
        backgroundColor: Colors.teal,
      ),
      body: Column(
        children: [
          // Filter Switcher
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 10),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _filterButton("Today", 0),
                const SizedBox(width: 10),
                _filterButton("Last 7 Days", 1),
              ],
            ),
          ),

          Expanded(
            child: isLoading
                ? const Center(child: CircularProgressIndicator())
                : filteredData.isEmpty
                ? const Center(child: Text("No Data for this period"))
                : _buildUI(todayDate),
          ),
        ],
      ),
    );
  }

  Widget _filterButton(String label, int index) {
    bool isSelected = _selectedFilter == index;
    return OutlinedButton(
      style: OutlinedButton.styleFrom(
        backgroundColor: isSelected ? Colors.teal : Colors.transparent,
        foregroundColor: isSelected ? Colors.white : Colors.teal,
        side: const BorderSide(color: Colors.teal),
      ),
      onPressed: () {
        setState(() {
          _selectedFilter = index;
          _applyFilter();
        });
      },
      child: Text(label),
    );
  }

  Widget _buildUI(String todayDate) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            _selectedFilter == 0 ? "Today's Date: $todayDate" : "Weekly Summary",
            style: const TextStyle(fontSize: 14, color: Colors.grey),
          ),
          Text(
            "Total: $totalCalories Calories",
            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 20),

          // Chart
          SizedBox(
            height: 200,
            child: PieChart(
              PieChartData(
                sections: generatePieSections(),
                centerSpaceRadius: 45,
                sectionsSpace: 3,
              ),
            ),
          ),

          const SizedBox(height: 20),
          const Text("History", style: TextStyle(fontWeight: FontWeight.bold)),
          const Divider(),

          // Filtered List
          Expanded(
            child: ListView.builder(
              itemCount: filteredData.length,
              itemBuilder: (context, index) {
                var foodItem = filteredData[index];
                return ListTile(
                  leading: const Icon(Icons.fastfood, color: Colors.orange),
                  title: Text("${foodItem['food']}"),
                  subtitle: Text("${foodItem['callorie']} cal | ${foodItem['gram']}g"),
                  trailing: Text("${foodItem['date']}", style: const TextStyle(fontSize: 12)),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  List<PieChartSectionData> generatePieSections() {
    final List<Color> colors = [Colors.blue, Colors.green, Colors.orange, Colors.purple, Colors.red, Colors.cyan];
    return List.generate(filteredData.length, (i) {
      final value = double.parse(filteredData[i]['callorie'].toString());
      return PieChartSectionData(
        color: colors[i % colors.length],
        value: value,
        title: '', // Keep it clean
        radius: 50,
      );
    });
  }

  void showToast(String message) {
    Fluttertoast.showToast(msg: message);
  }
}
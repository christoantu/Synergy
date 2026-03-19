import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

import 'fullworkout.dart';

class ViewWorkoutPage extends StatefulWidget {
  @override
  _ViewWorkoutPageState createState() => _ViewWorkoutPageState();
}

class _ViewWorkoutPageState extends State<ViewWorkoutPage> {

  // This function fetches the data from your Django view
  Future<List<dynamic>> fetchWorkouts() async {
    SharedPreferences sh = await SharedPreferences.getInstance();
    String url = sh.getString('url').toString();
    final urls = Uri.parse(url + "/user_view_workout");

    final response = await http.get(urls);

    if (response.statusCode == 200) {
      Map<String, dynamic> responseData = json.decode(response.body);
      if (responseData['status'] == 'ok') {
        return responseData['data']; // Returns the list 'l' from your Django code
      } else {
        throw Exception('Failed to load workouts');
      }
    } else {
      throw Exception('Server Error: ${response.statusCode}');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Available Workouts"),
        backgroundColor: Colors.blueAccent,
      ),
      body: FutureBuilder<List<dynamic>>(
        future: fetchWorkouts(),
        builder: (context, snapshot) {
          // 1. While waiting for data
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }

          // 2. If an error occurs (e.g., Server down)
          else if (snapshot.hasError) {
            return Center(
              child: Text("Error: ${snapshot.error}"),
            );
          }

          // 3. If data is empty
          else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(child: Text("No workouts found."));
          }

          // 4. When data is successfully received
          return ListView.builder(
            padding: EdgeInsets.all(10),
            itemCount: snapshot.data!.length,
            itemBuilder: (context, index) {
              final item = snapshot.data![index];
              return Card(
                elevation: 3,
                margin: EdgeInsets.symmetric(vertical: 8),
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundColor: Colors.blueAccent,
                    child: Text("${index + 1}", style: TextStyle(color: Colors.white)),
                  ),
                  title: Text(
                    item['workout'], // Matches 'workout' key in your Django loop
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                  ),
                  subtitle: Text("ID: ${item['id']}"),
                  trailing: Icon(Icons.arrow_forward_ios, size: 16),
                  onTap: () {
                    // You can add navigation to workout details here
                    // print(item['id']);
                    Navigator.push(context, MaterialPageRoute(builder: (context) => FullWorkoutPage(mainId: item['id'].toString(),)));
                  },
                ),
              );
            },
          );
        },
      ),
    );
  }
}
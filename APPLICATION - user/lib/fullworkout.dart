import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';

class FullWorkoutPage extends StatefulWidget {
  final String mainId;

  const FullWorkoutPage({Key? key, required this.mainId}) : super(key: key);

  @override
  _FullWorkoutPageState createState() => _FullWorkoutPageState();
}

class _FullWorkoutPageState extends State<FullWorkoutPage> {

  // 1. Fetch detailed workout list
  Future<List<dynamic>> fetchFullWorkouts() async {
    SharedPreferences sh = await SharedPreferences.getInstance();
    String url = sh.getString('url') ?? "";
    String lid = sh.getString('lid') ?? "";

    final response = await http.post(
      Uri.parse("${url}/user_view_full_workout"),
      body: {'mainid': widget.mainId, 'lid': lid},
    );

    if (response.statusCode == 200) {
      Map<String, dynamic> responseData = json.decode(response.body);
      return responseData['status'] == 'ok' ? responseData['data'] : [];
    } else {
      throw Exception('Server Error');
    }
  }

  // 2. Fetch users to show in the share sheet
  Future<List<dynamic>> fetchUsersToShare() async {
    SharedPreferences sh = await SharedPreferences.getInstance();
    String url = sh.getString('url') ?? "";
    String lid = sh.getString('lid') ?? "";

    final response = await http.post(
        Uri.parse("${url}/user_view_user"),
        body: {'lid': lid}
    );

    if (response.statusCode == 200) {
      Map<String, dynamic> data = json.decode(response.body);
      return data['data'] ?? [];
    }
    return [];
  }

// 3. Send the share command to the server
  Future<void> _shareWorkoutToServer(String workoutId, String toUserId) async {
    SharedPreferences sh = await SharedPreferences.getInstance();
    String url = sh.getString('url').toString();
    String lid = sh.getString('lid').toString();

    try {
      final response = await http.post(
        Uri.parse(url + "/user_share_workout"),
        body: {
          'workout_id': workoutId,
          'from_lid': lid,
          'to_customer_id': toUserId,
        },
      );

      if (response.statusCode == 200) {
        var data = jsonDecode(response.body);

        if (data['status'] == 'ok') {
          // Success message
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
                content: Text("Shared Successfully!"),
                backgroundColor: Colors.green
            ),
          );
        } else if (data['status'] == 'already existed') {
          // Handle the "already existed" case from Django
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
                content: Text("You have already shared this workout with this user."),
                backgroundColor: Colors.orange
            ),
          );
        } else {
          // General error message for other statuses
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text("Error: ${data['status']}")),
          );
        }
      }
    } catch (e) {
      print("Error sharing: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Connection Error")),
      );
    }
  }

  // 4. UI for User Selection (Share Sheet)
  void _showShareSheet(String workoutId) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (context) {
        return FutureBuilder<List<dynamic>>(
          future: fetchUsersToShare(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const SizedBox(height: 200, child: Center(child: CircularProgressIndicator()));
            }
            if (!snapshot.hasData || snapshot.data!.isEmpty) {
              return const Padding(padding: EdgeInsets.all(20), child: Text("No users found to share with."));
            }

            return Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Padding(
                  padding: EdgeInsets.all(16.0),
                  child: Text("Share with Friends", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                ),
                const Divider(),
                Flexible(
                  child: ListView.builder(
                    shrinkWrap: true,
                    itemCount: snapshot.data!.length,
                    itemBuilder: (context, index) {
                      final user = snapshot.data![index];
                      return ListTile(
                        leading: CircleAvatar(
                          backgroundColor: Colors.deepPurple,
                          child: Text(user['Name'][0].toString().toUpperCase(), style: const TextStyle(color: Colors.white)),
                        ),
                        title: Text(user['Name'] ?? "Unknown"),
                        subtitle: Text(user['Email'] ?? ""),
                        trailing: const Icon(Icons.send_rounded, color: Colors.deepPurple),
                        onTap: () {
                          Navigator.pop(context); // Close sheet immediately
                          _shareWorkoutToServer(workoutId, user['loginid'].toString());
                        },
                      );
                    },
                  ),
                ),
              ],
            );
          },
        );
      },
    );
  }

  Future<void> _launchVideo(String videoUrl) async {
    final Uri url = Uri.parse(videoUrl);
    if (!await launchUrl(url, mode: LaunchMode.externalApplication)) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Could not launch video")));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Workout Details"),
        backgroundColor: Colors.deepPurple,
        foregroundColor: Colors.white,
      ),
      body: FutureBuilder<List<dynamic>>(
        future: fetchFullWorkouts(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) return const Center(child: CircularProgressIndicator());
          if (snapshot.hasError) return Center(child: Text("Error: ${snapshot.error}"));
          if (!snapshot.hasData || snapshot.data!.isEmpty) return const Center(child: Text("No details found."));

          return ListView.builder(
            padding: const EdgeInsets.all(12),
            itemCount: snapshot.data!.length,
            itemBuilder: (context, index) {
              final item = snapshot.data![index];
              return Card(
                elevation: 3,
                margin: const EdgeInsets.only(bottom: 16),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ListTile(
                      title: Text(item['title'] ?? "No Title", style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                      trailing: IconButton(
                        icon: const Icon(Icons.share_outlined, color: Colors.deepPurple),
                        onPressed: () => _showShareSheet(item['id'].toString()),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16.0),
                      child: Text(item['description'] ?? "No description available.", style: TextStyle(color: Colors.grey[700])),
                    ),
                    const SizedBox(height: 10),
                    Padding(
                      padding: const EdgeInsets.all(12.0),
                      child: ElevatedButton.icon(
                        onPressed: () => _launchVideo(item['video'].toString()),
                        icon: const Icon(Icons.play_circle_fill, color: Colors.white),
                        label: const Text("Watch Tutorial", style: TextStyle(color: Colors.white)),
                        style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.deepPurple,
                            minimumSize: const Size(double.infinity, 48),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8))
                        ),
                      ),
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }
}
import 'package:aidiet/sent_complaint.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class ViewComplaints extends StatefulWidget {
  const ViewComplaints({super.key, required this.title});
  final String title;

  @override
  State<ViewComplaints> createState() => _ViewComplaintsState();
}

class _ViewComplaintsState extends State<ViewComplaints> {
  final Color brandTeal = const Color.fromARGB(255, 18, 82, 98);

  List<int> id_ = [];
  List<String> complaint_ = [];
  List<String> date_ = [];
  List<String> reply_ = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    viewComplaints();
  }

  void viewComplaints() async {
    try {
      SharedPreferences sh = await SharedPreferences.getInstance();
      String urls = sh.getString('url').toString();
      String url = '$urls/user_view_reply';
      String lid = sh.getString("lid").toString();
      var data = await http.post(Uri.parse(url), body: {"lid": lid});
      var jsondata = json.decode(data.body);

      var arr = jsondata["data"];
      List<int> id = [];
      List<String> date = [];
      List<String> complaint = [];
      List<String> reply = [];

      for (int i = 0; i < arr.length; i++) {
        id.add(arr[i]['id']);
        date.add(arr[i]['date'].toString());
        complaint.add(arr[i]['complaint']);
        reply.add(arr[i]['reply']);
      }

      setState(() {
        id_ = id;
        date_ = date;
        complaint_ = complaint;
        reply_ = reply;
        isLoading = false;
      });
    } catch (e) {
      setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        elevation: 0.5,
        backgroundColor: Colors.white,
        centerTitle: true,
        title: Text('My Tickets',
            style: TextStyle(fontWeight: FontWeight.w800, color: brandTeal, fontSize: 18)),
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new, color: brandTeal, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: isLoading
          ? Center(child: CircularProgressIndicator(color: brandTeal))
          : id_.isEmpty
          ? _buildEmptyState()
          : ListView.builder(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        itemCount: id_.length,
        itemBuilder: (context, index) => _buildModernCard(index),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(context, MaterialPageRoute(builder: (context) => const compl(title: '')));
        },
        backgroundColor: brandTeal,
        elevation: 4,
        child: const Icon(Icons.add, color: Colors.white, size: 30),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.inbox_outlined, size: 60, color: brandTeal.withOpacity(0.3)),
          const SizedBox(height: 12),
          Text("No active tickets",
              style: TextStyle(color: brandTeal.withOpacity(0.5), fontSize: 16, fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }

  Widget _buildModernCard(int index) {
    bool isPending = reply_[index].toLowerCase() == "pending" || reply_[index].isEmpty;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Row for Date and Status
          Row(
            children: [
              Text(date_[index],
                  style: const TextStyle(color: Colors.grey, fontSize: 12, fontWeight: FontWeight.w600)),
              const Spacer(),
              _buildStatusIndicator(isPending),
            ],
          ),
          const SizedBox(height: 10),

          // The Content Container
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: const Color(0xFFF9FAFB),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.grey.withOpacity(0.1)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Question Row
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(Icons.help_center_outlined, color: brandTeal, size: 18),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        complaint_[index],
                        style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w500, color: Colors.black87),
                      ),
                    ),
                  ],
                ),
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 15.0),
                  child: Divider(height: 1),
                ),
                // Answer Row
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(Icons.quickreply_outlined, color: isPending ? Colors.grey : Colors.green, size: 18),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        isPending ? "Our support team is currently reviewing your ticket." : reply_[index],
                        style: TextStyle(
                            fontSize: 14,
                            color: isPending ? Colors.grey[600] : brandTeal,
                            fontStyle: isPending ? FontStyle.italic : FontStyle.normal,
                            height: 1.4
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusIndicator(bool isPending) {
    return Row(
      children: [
        Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: isPending ? Colors.orange : Colors.green,
          ),
        ),
        const SizedBox(width: 6),
        Text(
          isPending ? "Pending" : "Resolved",
          style: TextStyle(
            color: isPending ? Colors.orange : Colors.green,
            fontSize: 12,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }
}
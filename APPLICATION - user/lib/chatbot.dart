// // import 'package:flutter/material.dart';
// // import 'dart:convert';
// // import 'package:http/http.dart' as http;
// // import 'package:shared_preferences/shared_preferences.dart';
// // import 'package:fluttertoast/fluttertoast.dart';
// //
// // void main() {
// //   runApp(const ChatApp());
// // }
// //
// // class ChatApp extends StatelessWidget {
// //   const ChatApp({Key? key}) : super(key: key);
// //
// //   @override
// //   Widget build(BuildContext context) {
// //     return MaterialApp(
// //       debugShowCheckedModeBanner: false,
// //       home: ChatScreen(),
// //     );
// //   }
// // }
// //
// // class ChatScreen extends StatefulWidget {
// //   @override
// //   _ChatScreenState createState() => _ChatScreenState();
// // }
// //
// // class _ChatScreenState extends State<ChatScreen> {
// //   final TextEditingController _controller = TextEditingController();
// //   List<Map<String, String>> _messages = [];
// //
// //   Future<void> sendMessage(String message) async {
// //     setState(() {
// //       _messages.add({"role": "user", "message": message});
// //     });
// //     _controller.clear();
// //
// //     try {
// //       SharedPreferences prefs = await SharedPreferences.getInstance();
// //       String? url = prefs.getString('url'); // Make sure 'url' is set in SharedPreferences
// //       if (url == null) {
// //         Fluttertoast.showToast(msg: "API URL not configured.");
// //         return;
// //       }
// //       final response = await http.post(
// //         Uri.parse('$url/chatbot_response'),
// //
// //         body: jsonEncode({'message': message}),
// //       );
// //
// //       if (response.statusCode == 200) {
// //         var data = jsonDecode(response.body);
// //         setState(() {
// //           _messages.add({"role": "bot", "message": data['response']});
// //         });
// //       } else {
// //         setState(() {
// //           _messages.add({
// //             "role": "bot",
// //             "message": "Something went wrong. Please try again later."
// //           });
// //         });
// //       }
// //     } catch (e) {
// //       setState(() {
// //         _messages.add({
// //           "role": "bot",
// //           "message": "Failed to connect to server. Check your internet."
// //         });
// //       });
// //     }
// //   }
// //
// //   @override
// //   Widget build(BuildContext context) {
// //     return Scaffold(
// //       appBar: AppBar(
// //         title: const Text('Air Quality Chatbot'),
// //         backgroundColor: Colors.teal,
// //       ),
// //       body: Column(
// //         children: [
// //           Expanded(
// //             child: ListView.builder(
// //               itemCount: _messages.length,
// //               itemBuilder: (context, index) {
// //                 final message = _messages[index];
// //                 final isUser = message['role'] == "user";
// //                 return Align(
// //                   alignment:
// //                   isUser ? Alignment.centerRight : Alignment.centerLeft,
// //                   child: Container(
// //                     margin: const EdgeInsets.symmetric(
// //                         vertical: 5, horizontal: 10),
// //                     padding: const EdgeInsets.all(12),
// //                     decoration: BoxDecoration(
// //                       color: isUser ? Colors.teal[100] : Colors.grey[300],
// //                       borderRadius: BorderRadius.circular(10),
// //                     ),
// //                     child: Text(
// //                       message['message'] ?? '',
// //                       style: const TextStyle(fontSize: 16),
// //                     ),
// //                   ),
// //                 );
// //               },
// //             ),
// //           ),
// //           Padding(
// //             padding: const EdgeInsets.all(10.0),
// //             child: Row(
// //               children: [
// //                 Expanded(
// //                   child: TextField(
// //                     controller: _controller,
// //                     decoration: const InputDecoration(
// //                       hintText: 'Type a message...',
// //                       border: OutlineInputBorder(),
// //                     ),
// //                   ),
// //                 ),
// //                 IconButton(
// //                   icon: const Icon(Icons.send, color: Colors.teal),
// //                   onPressed: () {
// //                     if (_controller.text.isNotEmpty) {
// //                       sendMessage(_controller.text);
// //                     }
// //                   },
// //                 ),
// //               ],
// //             ),
// //           ),
// //         ],
// //       ),
// //     );
// //   }
// // }
//
//
// import 'package:flutter/material.dart';
// import 'dart:convert';
// import 'package:http/http.dart' as http;
// import 'package:shared_preferences/shared_preferences.dart';
// import 'package:fluttertoast/fluttertoast.dart';
//
// void main() {
//   runApp(const ChatApp());
// }
//
// class ChatApp extends StatelessWidget {
//   const ChatApp({Key? key}) : super(key: key);
//
//   @override
//   Widget build(BuildContext context) {
//     return MaterialApp(
//       debugShowCheckedModeBanner: false,
//       home: ChatScreen(),
//     );
//   }
// }
//
// class ChatScreen extends StatefulWidget {
//   @override
//   _ChatScreenState createState() => _ChatScreenState();
// }
//
// class _ChatScreenState extends State<ChatScreen> {
//   final TextEditingController _controller = TextEditingController();
//   List<Map<String, String>> _messages = [];
//
//   Future<void> sendMessage(String message) async {
//     print(message);
//     print("kkkkkkkkkkkkkkkkkkk");
//     setState(() {
//       _messages.add({"role": "user", "message": message});
//     });
//     _controller.clear();
//
//     try {
//       SharedPreferences prefs = await SharedPreferences.getInstance();
//       String? url = prefs.getString('url'); // Ensure 'url' is set in SharedPreferences
//
//       if (url == null) {
//         Fluttertoast.showToast(msg: "API URL not configured.");
//         return;
//       }
//
//       final response = await http.post(
//         Uri.parse(url+'generate_gemini_response'),
//         // Uri.parse('$url/chatbot_response'),
//         // Ensure this endpoint is correct
//         headers: {
//           'Content-Type': 'application/json',
//         },
//         body: jsonEncode({'message': message}),
//       );
//
//       if (response.statusCode == 200) {
//         var data = jsonDecode(response.body);
//         if (data.containsKey('response')) {
//           setState(() {
//             _messages.add({"role": "bot", "message": data['response']});
//           });
//         } else {
//           setState(() {
//             _messages.add({
//               "role": "bot",
//               "message": "Unexpected response format."
//             });
//           });
//         }
//       } else {
//         setState(() {
//           _messages.add({
//             "role": "bot",
//             "message": "Something went wrong. Please try again later."
//           });
//         });
//       }
//     } catch (e) {
//       setState(() {
//         _messages.add({
//           "role": "bot",
//           "message": "Failed to connect to server. Check your internet."
//         });
//       });
//     }
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text(' Chatbot'),
//         backgroundColor: Colors.teal,
//       ),
//       body: Column(
//         children: [
//           Expanded(
//             child: ListView.builder(
//               itemCount: _messages.length,
//               itemBuilder: (context, index) {
//                 final message = _messages[index];
//                 final isUser = message['role'] == "user";
//                 return Align(
//                   alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
//                   child: Container(
//                     margin: const EdgeInsets.symmetric(vertical: 5, horizontal: 10),
//                     padding: const EdgeInsets.all(12),
//                     decoration: BoxDecoration(
//                       color: isUser ? Colors.teal[100] : Colors.grey[300],
//                       borderRadius: BorderRadius.circular(10),
//                     ),
//                     child: Text(
//                       message['message'] ?? '',
//                       style: const TextStyle(fontSize: 16),
//                     ),
//                   ),
//                 );
//               },
//             ),
//           ),
//           Padding(
//             padding: const EdgeInsets.all(10.0),
//             child: Row(
//               children: [
//                 Expanded(
//                   child: TextField(
//                     controller: _controller,
//                     decoration: const InputDecoration(
//                       hintText: 'Type a message...',
//                       border: OutlineInputBorder(),
//                     ),
//                   ),
//                 ),
//                 IconButton(
//                   icon: const Icon(Icons.send, color: Colors.teal),
//                   onPressed: () {
//                     if (_controller.text.isNotEmpty) {
//                       sendMessage(_controller.text);
//                     }
//                   },
//                 ),
//               ],
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }



import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:fluttertoast/fluttertoast.dart';

void main() {
  runApp(const ChatApp());
}

class ChatApp extends StatelessWidget {
  const ChatApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: ChatScreen(),
    );
  }
}

class ChatScreen extends StatefulWidget {
  @override
  _ChatScreenState createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController _controller = TextEditingController();
  List<Map<String, String>> _messages = [];

  Future<void> sendMessage(String message) async {
    setState(() {
      _messages.add({"role": "user", "message": message});
    });
    _controller.clear();

    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? url = prefs.getString('url'); // Ensure 'url' is set in SharedPreferences

      if (url == null) {
        Fluttertoast.showToast(msg: "API URL not configured.");
        return;
      }

      final response = await http.post(
        Uri.parse('$url/chatbot_response'),  // 🔥 Ensure this matches Django's endpoint
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode({'message': message}),
      );

      if (response.statusCode == 200) {
        var data = jsonDecode(response.body);
        if (data.containsKey('response')) {
          setState(() {
            _messages.add({"role": "bot", "message": data['response']});
          });
        } else {
          setState(() {
            _messages.add({
              "role": "bot",
              "message": "Unexpected response format."
            });
          });
        }
      } else {
        setState(() {
          _messages.add({
            "role": "bot",
            "message": "Error: ${response.body}"
          });
        });
      }
    } catch (e) {
      setState(() {
        _messages.add({
          "role": "bot",
          "message": "Failed to connect to server. Check your internet."
        });
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Chatbot'),
        backgroundColor: Colors.teal,
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              itemCount: _messages.length,
              itemBuilder: (context, index) {
                final message = _messages[index];
                final isUser = message['role'] == "user";
                return Align(
                  alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
                  child: Container(
                    margin: const EdgeInsets.symmetric(vertical: 5, horizontal: 10),
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: isUser ? Colors.teal[100] : Colors.grey[300],
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      message['message'] ?? '',
                      style: const TextStyle(fontSize: 16),
                    ),
                  ),
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(10.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _controller,
                    decoration: const InputDecoration(
                      hintText: 'Type a message...',
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.send, color: Colors.teal),
                  onPressed: () {
                    if (_controller.text.isNotEmpty) {
                      sendMessage(_controller.text);
                    }
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

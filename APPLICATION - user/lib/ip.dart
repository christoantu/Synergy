import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'logins.dart';

void main() {
  runApp(const Myipset());
}

class Myipset extends StatelessWidget {
  const Myipset({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Server Configuration',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.deepPurple,
          brightness: Brightness.light,
        ),
        useMaterial3: true,
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: Colors.grey[50],
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: Colors.grey[300]!),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: Colors.grey[300]!),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: Colors.deepPurple, width: 2),
          ),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            padding: EdgeInsets.symmetric(horizontal: 48, vertical: 16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            elevation: 2,
          ),
        ),
      ),
      home: const MyipsetPage(title: 'Server Configuration'),
    );
  }
}

class MyipsetPage extends StatefulWidget {
  const MyipsetPage({super.key, required this.title});

  final String title;

  @override
  State<MyipsetPage> createState() => _MyipsetPageState();
}

class _MyipsetPageState extends State<MyipsetPage> {
  final TextEditingController ipController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadSavedIP();
  }

  Future<void> _loadSavedIP() async {
    final sh = await SharedPreferences.getInstance();
    String? savedUrl = sh.getString("url");
    if (savedUrl != null) {
      // Extract IP from saved URL (format: http://IP:8000/Myapp/)
      String ip = savedUrl
          .replaceAll("http://", "")
          .replaceAll(":8000/", "");
      ipController.text = ip;
    }
  }

  String? _validateIP(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter an IP address';
    }

    // Basic IP validation regex
    final ipRegex = RegExp(
        r'^((25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\.){3}(25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)$'
    );

    if (!ipRegex.hasMatch(value)) {
      return 'Please enter a valid IP address';
    }

    return null;
  }

  Future<void> _saveAndContinue() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });

      try {
        String ip = ipController.text.trim();
        final sh = await SharedPreferences.getInstance();
        await sh.setString("url", "http://$ip:8000");
        await sh.setString("imgurl", "http://$ip:8000/");

        if (mounted) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => Ftnesslogin()),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Error saving configuration: $e'),
              backgroundColor: Colors.red,
            ),
          );
        }
      } finally {
        if (mounted) {
          setState(() {
            _isLoading = false;
          });
        }
      }
    }
  }

  @override
  void dispose() {
    ipController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.deepPurple,
        foregroundColor: Colors.white,
        title: Text(widget.title),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: <Widget>[
                  // Icon
                  Container(
                    padding: EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.deepPurple.withOpacity(0.1),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.dns_outlined,
                      size: 80,
                      color: Colors.deepPurple,
                    ),
                  ),

                  SizedBox(height: 32),

                  // Title
                  Text(
                    'Configure Server',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: Colors.grey[800],
                    ),
                  ),

                  SizedBox(height: 8),

                  // Subtitle
                  Text(
                    'Enter your server IP address to connect',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[600],
                    ),
                  ),

                  SizedBox(height: 48),

                  // IP Input Field
                  TextFormField(
                    controller: ipController,
                    keyboardType: TextInputType.numberWithOptions(decimal: true),
                    validator: _validateIP,
                    decoration: InputDecoration(
                      labelText: 'Server IP Address',
                      hintText: '192.168.1.100',
                      prefixIcon: Icon(Icons.computer),
                      helperText: 'Format: xxx.xxx.xxx.xxx',
                    ),
                  ),

                  SizedBox(height: 32),

                  // Info Card
                  Container(
                    padding: EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.blue[50],
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.blue[100]!),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.info_outline, color: Colors.blue[700], size: 20),
                        SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            'Port 8000 will be used automatically',
                            style: TextStyle(
                              fontSize: 13,
                              color: Colors.blue[900],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  SizedBox(height: 32),

                  // Connect Button
                  ElevatedButton(
                    onPressed: _isLoading ? null : _saveAndContinue,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.deepPurple,
                      foregroundColor: Colors.white,
                      disabledBackgroundColor: Colors.grey[300],
                      minimumSize: Size(double.infinity, 56),
                    ),
                    child: _isLoading
                        ? SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      ),
                    )
                        : Text(
                      'Connect to Server',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),

                  SizedBox(height: 16),

                  // Example IPs
                  TextButton.icon(
                    onPressed: () {
                      ipController.text = '192.168.1.1';
                    },
                    icon: Icon(Icons.tips_and_updates_outlined, size: 18),
                    label: Text('Use example IP'),
                    style: TextButton.styleFrom(
                      foregroundColor: Colors.grey[600],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
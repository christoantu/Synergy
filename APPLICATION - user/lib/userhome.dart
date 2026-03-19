import 'package:aidiet/view%20diat_chart.dart';
import 'package:aidiet/view%20experts.dart';
import 'package:aidiet/view%20food.dart';
import 'package:aidiet/view%20water.dart';
import 'package:aidiet/view_workout.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

// Navigation Imports
import 'Add water.dart';
import 'SharedWorkoutsPage.dart';
import 'bmi.dart';
import 'callorie chart.dart';
import 'calorie_recipe.dart';
import 'chatbot.dart';
import 'diet_rec.dart';
import 'logins.dart';
import 'viewcomplaint.dart';

class DietHome extends StatefulWidget {
  @override
  _DietHomeState createState() => _DietHomeState();
}

class _DietHomeState extends State<DietHome> {
  List<Map<String, dynamic>> foodData = [];
  int totalCalories = 0;
  bool isLoading = true;

  // Primary Theme Colors
  final Color primaryColor = Colors.deepPurple;
  final Color accentColor = Color(0xFF50C878); // Custom Emerald Green


  String userName = "Synergy";
  String userPhoto = "";
  String imgurl = "";
  bool profileLoading = true;
  @override
  void initState() {
    super.initState();
    fetchCalorieData();
    fetchProfile();
  }

  Future<void> fetchProfile() async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String baseUrl = prefs.getString('url') ?? '';
      String lid = prefs.getString('lid') ?? '';
      String imgurl = prefs.getString('imgurl') ?? '';

      // IMPORTANT: match your django url path
      String url = '$baseUrl/user_view_profile';

      var response = await http.post(
        Uri.parse(url),
        body: {'lid': lid},
      );

      if (response.statusCode == 200) {
        var data = jsonDecode(response.body);

        setState(() {
          userName = data['Name'] ?? "User";
          userPhoto = imgurl+data['Photo'] ?? "";
          profileLoading = false;
        });
      } else {
        setState(() => profileLoading = false);
      }
    } catch (e) {
      setState(() => profileLoading = false);
    }
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
            foodData = List<Map<String, dynamic>>.from(jsonResponse['data']);
            totalCalories = jsonResponse['total_calories'] ?? 0;
            isLoading = false;
          });
        } else {
          showToast("No data available");
          setState(() => isLoading = false);
        }
      }
    } catch (e) {
      showToast("Error connecting to server");
      setState(() => isLoading = false);
    }
  }

  void showToast(String message) {
    Fluttertoast.showToast(msg: message);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        iconTheme: IconThemeData(color: primaryColor),
        title: Text(
            "Synergy",
            style: TextStyle(fontWeight: FontWeight.w900, color: primaryColor, letterSpacing: 1.2)
        ),
        centerTitle: true,
        actions: [
          // IconButton(
          //   icon: Icon(Icons.notifications_none_rounded, color: primaryColor),
          //   onPressed: () {
          //
          //   },
          // ),
        ],
      ),
      drawer: _buildDrawer(context),
      body: isLoading
          ? Center(child: CircularProgressIndicator(color: primaryColor))
          : SingleChildScrollView(
        physics: BouncingScrollPhysics(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildModernHeader(),
            Padding(
              padding: EdgeInsets.fromLTRB(20, 30, 20, 10),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "Quick Actions",
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.black87),
                  ),
                  Icon(Icons.grid_view_rounded, color: Colors.grey, size: 20),
                ],
              ),
            ),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 20.0),
              child: Column(
                children: [
                  _buildActionGrid(context),
                  SizedBox(height: 30),
                  _buildTipCard(),
                  SizedBox(height: 100), // Space for FAB
                ],
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (context) => ChatScreen())),
        backgroundColor: primaryColor,
        elevation: 4,
        icon: Icon(Icons.auto_awesome_rounded, color: Colors.white),
        label: Text("ASK AI", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
      ),
    );
  }

  Widget _buildModernHeader() {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      padding: EdgeInsets.all(25),
      height: 180,
      width: double.infinity,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(30),
        gradient: LinearGradient(
          colors: [primaryColor, Colors.deepPurpleAccent],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: [
          BoxShadow(
            color: primaryColor.withOpacity(0.3),
            blurRadius: 20,
            offset: Offset(0, 10),
          )
        ],
      ),
      child: Stack(
        children: [
          Positioned(
            right: -20,
            top: -20,
            child: Icon(Icons.favorite, color: Colors.white.withOpacity(0.1), size: 150),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                "Welcome Back,",
                style: TextStyle(color: Colors.white.withOpacity(0.8), fontSize: 16),
              ),
              Text(
                "Fitness Tracker",
                style: TextStyle(color: Colors.white, fontSize: 26, fontWeight: FontWeight.bold),
              ),
              Spacer(),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 15, vertical: 8),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(15),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.local_fire_department, color: Colors.orangeAccent, size: 20),
                    SizedBox(width: 8),
                    Text(
                      "$totalCalories kcal consumed",
                      style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              )
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildActionGrid(BuildContext context) {
    return GridView.count(
      crossAxisCount: 2, // Changed to 2 for better readability
      shrinkWrap: true,
      mainAxisSpacing: 15,
      crossAxisSpacing: 15,
      childAspectRatio: 1.3,
      physics: NeverScrollableScrollPhysics(),
      children: [
        _buildActionCard("Calories", Icons.bolt_rounded, Colors.orange, () {
          Navigator.push(context, MaterialPageRoute(builder: (context) => CalorieChartPage(title: '')));
        }),
        _buildActionCard("Smart Diet", Icons.psychology_rounded, Colors.blue, () {
          Navigator.push(context, MaterialPageRoute(builder: (context) => SmartDietPage()));
        }),
        _buildActionCard("BMI Calc", Icons.scale_rounded, Colors.purple, () {
          Navigator.push(context, MaterialPageRoute(builder: (context) => BMIPage()));
        }),
        _buildActionCard("Recipe", Icons.restaurant_rounded, Colors.pink, () {
          Navigator.push(context, MaterialPageRoute(builder: (context) => RecipeCaloriePage()));
        }),
      ],
    );
  }

  Widget _buildActionCard(String title, IconData icon, Color color, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Colors.grey[100]!),
          boxShadow: [
            BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 10, offset: Offset(0, 5))
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: color, size: 28),
            ),
            SizedBox(height: 10),
            Text(
                title,
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.black87)
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTipCard() {
    return Container(
      padding: EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.green[50],
        borderRadius: BorderRadius.circular(25),
        border: Border.all(color: Colors.green[100]!),
      ),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(10),
            decoration: BoxDecoration(color: Colors.green, shape: BoxShape.circle),
            child: Icon(Icons.lightbulb_outline, color: Colors.white, size: 24),
          ),
          SizedBox(width: 15),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("Health Tip", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.green[900])),
                Text(
                  "Personalized meals help you reach your goals faster.",
                  style: TextStyle(color: Colors.green[800], fontSize: 13),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDrawer(BuildContext context) {
    return Drawer(
      backgroundColor: Colors.white,
      child: Column(
        children: <Widget>[
          Container(
            padding: EdgeInsets.fromLTRB(20, 60, 20, 30),
            width: double.infinity,
            decoration: BoxDecoration(
              color: primaryColor,
              borderRadius: BorderRadius.only(bottomRight: Radius.circular(50)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CircleAvatar(
                  radius: 35,
                  backgroundColor: Colors.white.withOpacity(0.2),
                  backgroundImage: userPhoto.isNotEmpty
                      ? NetworkImage(userPhoto)
                      : null,
                  child: userPhoto.isEmpty
                      ? Icon(Icons.person_rounded, size: 40, color: Colors.white)
                      : null,
                ),

                SizedBox(height: 15),

                Text(
                  profileLoading ? "Loading..." : userName,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                Text(
                  "Healthy Life, Happy Life",
                  style: TextStyle(color: Colors.white70),
                ),
              ],
            ),
          ),
          Expanded(
            child: ListView(
              padding: EdgeInsets.symmetric(vertical: 10),
              children: [
                _buildDrawerItem(Icons.home_rounded, 'Dashboard', () => Navigator.pop(context)),
                _buildDrawerItem(Icons.restaurant_menu_rounded, 'Diet Plan', () {
                  Navigator.push(context, MaterialPageRoute(builder: (context) => ViewDietChartsPage()));
                }),
                _buildDrawerItem(Icons.verified_user_rounded, 'Experts', () {
                  Navigator.push(context, MaterialPageRoute(builder: (context) => ViewExperts(title: '')));
                }),
                _buildDrawerItem(Icons.fitness_center_rounded, 'WorkOut', () {
                  Navigator.push(context, MaterialPageRoute(builder: (context) => ViewWorkoutPage()));
                }),
                _buildDrawerItem(Icons.share_location_rounded, 'Shared Workouts', () {
                  Navigator.push(context, MaterialPageRoute(builder: (context) => SharedWorkoutsPage()));
                }),
                _buildDrawerItem(Icons.water_drop_rounded, 'Water Tracker', () {
                  Navigator.push(context, MaterialPageRoute(builder: (context) => viewWaterfull(title: '')));
                }),
                _buildDrawerItem(Icons.fastfood_rounded, 'Food Database', () {
                  Navigator.push(context, MaterialPageRoute(builder: (context) => ViewFoodsfull(title: '')));
                }),
                _buildDrawerItem(Icons.message_rounded, 'Complaints', () {
                  Navigator.push(context, MaterialPageRoute(builder: (context) => ViewComplaints(title: '')));
                }),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Divider(),
                ),
                _buildDrawerItem(Icons.logout_rounded, 'Logout', () => _showLogoutDialog(context)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDrawerItem(IconData icon, String title, VoidCallback onTap) {
    return ListTile(
      leading: Icon(icon, color: primaryColor.withOpacity(0.7)),
      title: Text(title, style: TextStyle(fontWeight: FontWeight.w600, color: Colors.black87)),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      onTap: onTap,
    );
  }

  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text("Logout"),
        content: Text("Stay committed to your goals! Log out now?"),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: Text("Cancel", style: TextStyle(color: Colors.grey))),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
                backgroundColor: primaryColor,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))
            ),
            onPressed: () {
              Navigator.pop(context);
              Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => Ftnesslogin()));
            },
            child: Text("Logout", style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }
}
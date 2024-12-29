import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'login.dart'; // Import LoginPage for logout navigation

class CoursesPage extends StatefulWidget {
  @override
  _CoursesPageState createState() => _CoursesPageState();
}

class _CoursesPageState extends State<CoursesPage> {
  List<dynamic> courses = [];
  List<dynamic> filteredCourses = [];
  bool isLoading = true;
  bool isSearching = false;

  String searchQuery = '';
  List<String> selectedFaculty = [];
  List<String> selectedDegreeType = [];
  List<String> selectedLocation = [];
  String? expandedDropdown; // Track expanded dropdown

  final List<String> faculties = [
    'Engineering and Technology',
    'Science',
    'Life Sciences',
    'Business Studies',
    'Medical and Health Sciences',
    'Arts and Humanities',
    'Law',
    'Social Sciences',
    'Agriculture and Forestry'
  ];

  final List<String> degreeTypes = [
    'Bachelor of Science (B.Sc.)',
    'Bachelor of Arts (BA)',
    'Bachelor of Social Science (BSS)',
    'Bachelor of Education (BEd)',
    'Bachelor of Laws',
    'Bachelor of Business Administration (BBA)'
  ];

  final List<String> locations = [
    'Dhaka',
    'Chittagong',
    'Rajshahi',
    'Khulna',
    'Barisal',
    'Sylhet',
    'Rangpur',
    'Mymensingh',
    'Gazipur',
    'Narayanganj',
    'Comilla',
    'Jessore',
    'Faridpur',
    'Bogra',
    'Pabna',
    'Dinajpur',
    'Tangail',
    'Kushtia',
    'Feni',
    'Noakhali',
    'Cox\'s Bazar',
    'Habiganj',
    'Sylhet',
    'Jhenaidah',
    'Bagerhat',
    'Khagrachari',
    'Patuakhali',
    'Chandpur',
    'Chuadanga',
    'Narsingdi',
    'Brahmanbaria',
    'Moulvibazar',
    'Bagerhat',
    'Barisal',
    'Rajbari',
    'Satkhira',
    'Barguna',
    'Noakhali',
    'Sherpur',
    'Mymensingh',
    'Madaripur',
    'Jamalpur',
    'Lalmonirhat',
    'Pabna',
    'Tangail',
    'Cox\'s Bazar'
  ];

  FirebaseAuth _auth = FirebaseAuth.instance;

  @override
  void initState() {
    super.initState();
    loadCourses();
  }

  Future<void> loadCourses() async {
    final String response = await rootBundle.loadString('assets/unfinder.json');
    final data = json.decode(response);
    setState(() {
      courses = data['Sheet1'];
      filteredCourses = courses;
      isLoading = false;
    });
  }

  Future<void> applyFilters() async {
    setState(() {
      isSearching = true;
    });
    await Future.delayed(Duration(seconds: 2)); // Simulated progress delay

    setState(() {
      filteredCourses = courses.where((course) {
        bool matchQuery = course['Program Name']
                .toLowerCase()
                .contains(searchQuery.toLowerCase()) ||
            course['University Name']
                .toLowerCase()
                .contains(searchQuery.toLowerCase());

        bool matchFaculty = selectedFaculty.isEmpty ||
            selectedFaculty.contains(course['Faculty']);

        bool matchDegreeType = selectedDegreeType.isEmpty ||
            selectedDegreeType.contains(course['Degree Type']);

        bool matchLocation = selectedLocation.isEmpty ||
            selectedLocation.any((location) => course['University Location']
                .toLowerCase()
                .contains(location.toLowerCase()));

        return matchQuery && matchFaculty && matchDegreeType && matchLocation;
      }).toList();
      isSearching = false;
    });
  }

  void clearFilters() {
    setState(() {
      searchQuery = '';
      selectedFaculty.clear();
      selectedDegreeType.clear();
      selectedLocation.clear();
      filteredCourses = courses;
    });
  }

  Widget buildDropdownFilter(String title, List<String> options,
      List<String> selectedValues, String dropdownKey) {
    return ExpansionTile(
      key: Key(dropdownKey),
      title: Text(title,
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
      initiallyExpanded: expandedDropdown == dropdownKey,
      onExpansionChanged: (bool expanded) {
        setState(() {
          expandedDropdown = expanded ? dropdownKey : null;
        });
      },
      children: options.map((option) {
        return CheckboxListTile(
          activeColor: Colors.blue.shade700,
          value: selectedValues.contains(option),
          title: Text(option, style: TextStyle(color: Colors.white)),
          onChanged: (bool? value) {
            setState(() {
              if (value == true) {
                selectedValues.add(option);
              } else {
                selectedValues.remove(option);
              }
            });
          },
        );
      }).toList(),
    );
  }

  void _showCourseDetails(BuildContext context, dynamic course) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => CourseDetailPage(course: course),
      ),
    );
  }

  // Logout Functionality
  Future<void> _logout() async {
    await _auth.signOut();
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => LoginPage()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Explore Courses'), // Just "Explore Courses" here
        backgroundColor: Colors.blue.shade700,
        actions: [
          IconButton(
            icon: Icon(Icons.refresh),
            onPressed: clearFilters,
          ),
          IconButton(
            icon: Icon(Icons.logout),
            onPressed: _logout, // Logout button
          ),
        ],
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.blue.shade800, Colors.blue.shade200],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: isLoading
            ? Center(child: CircularProgressIndicator())
            : Column(
                children: [
                  Padding(
                    padding: EdgeInsets.all(12.0),
                    child: TextField(
                      style: TextStyle(color: Colors.white),
                      decoration: InputDecoration(
                        labelText: 'Search by Program or University Name',
                        labelStyle: TextStyle(color: Colors.white),
                        prefixIcon: Icon(Icons.search, color: Colors.white),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      onChanged: (value) {
                        setState(() {
                          searchQuery = value;
                        });
                      },
                    ),
                  ),
                  Expanded(
                    child: ListView(
                      children: [
                        buildDropdownFilter(
                            'Faculty', faculties, selectedFaculty, 'faculty'),
                        buildDropdownFilter('Degree Type', degreeTypes,
                            selectedDegreeType, 'degreeType'),
                        buildDropdownFilter('Location', locations,
                            selectedLocation, 'location'),
                        Padding(
                          padding: const EdgeInsets.all(14.0),
                          child: ElevatedButton(
                            onPressed: applyFilters,
                            child: Text('Search',
                                style: TextStyle(color: Colors.white)),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.blue.shade700,
                              padding: EdgeInsets.symmetric(
                                  horizontal: 20, vertical: 12),
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10)),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (isSearching)
                    Center(child: CircularProgressIndicator())
                  else
                    Expanded(
                      child: filteredCourses.isEmpty
                          ? Center(
                              child: Text(
                                'No university or course found.',
                                style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white),
                              ),
                            )
                          : ListView.builder(
                              itemCount: filteredCourses.length,
                              itemBuilder: (context, index) {
                                var course = filteredCourses[index];
                                return Card(
                                  elevation: 4,
                                  margin: EdgeInsets.symmetric(
                                      vertical: 8, horizontal: 10),
                                  child: ListTile(
                                    leading: Image.asset(
                                      course[
                                          'universityLogo'], // Use the logo path from JSON
                                      width: 40,
                                      height: 60,
                                    ),
                                    title: Text(
                                      course['Program Name'],
                                      style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 18,
                                          color: Colors.black),
                                    ),
                                    subtitle: Text(
                                        '${course['University Name']} | ${course['Degree Type']} | ${course['University Location']}',
                                        style: TextStyle(color: Colors.black)),
                                    trailing: Icon(Icons.arrow_forward,
                                        color: Colors.black),
                                    onTap: () =>
                                        _showCourseDetails(context, course),
                                  ),
                                );
                              },
                            ),
                    ),
                ],
              ),
      ),
    );
  }
}

class CourseDetailPage extends StatelessWidget {
  final dynamic course;

  CourseDetailPage({required this.course});

  void _launchURL(BuildContext context, String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Could not launch the URL: $url")));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(course['Program Name']),
        backgroundColor: Colors.blue.shade700,
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16.0),
        child: Card(
          elevation: 3,
          child: Padding(
            padding: EdgeInsets.all(12.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // Center the university logo at the top of the page
                Center(
                  child: Image.asset(
                    course['universityLogo'],
                    width: 100,
                    height: 100,
                  ),
                ),
                SizedBox(height: 20), // Add some space after the logo
                Text(course['Program Name'],
                    style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: Colors.blue.shade700)),
                Divider(),
                // The rest of the details should be left-aligned
                Padding(
                  padding: const EdgeInsets.only(left: 10.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('University: ${course['University Name']}',
                          style: TextStyle(fontSize: 16, color: Colors.black)),
                      Text('Location: ${course['University Location']}',
                          style: TextStyle(fontSize: 16, color: Colors.black)),
                      Text('Admission System: ${course['Admission System']}',
                          style: TextStyle(fontSize: 16, color: Colors.black)),
                      Text('Next Intake: ${course['Next Intake']}',
                          style: TextStyle(fontSize: 16, color: Colors.black)),
                      Text('Faculty: ${course['Faculty']}',
                          style: TextStyle(fontSize: 16, color: Colors.black)),
                      Text('Degree Type: ${course['Degree Type']}',
                          style: TextStyle(fontSize: 16, color: Colors.black)),
                    ],
                  ),
                ),
                SizedBox(height: 10),
                ElevatedButton(
                  onPressed: () =>
                      _launchURL(context, course['University Website']),
                  child: Text('Visit University Website'),
                  style: ElevatedButton.styleFrom(
                    primary: Colors.blue.shade100,
                    padding: EdgeInsets.symmetric(horizontal: 40, vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';

import '../global/global.dart';
import '../models/admin_leave_model.dart';
import '../models/attendance_model.dart';
import 'employee_home_screen.dart';
import 'package:http/http.dart' as http;

class AttendanceReport extends StatefulWidget {
  const AttendanceReport({Key? key}) : super(key: key);

  @override
  State<AttendanceReport> createState() => _AttendanceReportState();
}

class _AttendanceReportState extends State<AttendanceReport> {
  AttendanceModel fetchedAttendance = AttendanceModel(
      nepaliDate: 'nepaliDate',
      englishDate: 'englishDate',
      attendDateTime: 'attendDateTime',
      latitude: 'latitude',
      longitude: 'longitude',
      deviceId: 'deviceId',
      networkId: 'networkId',
      altitude: 'altitude',
      status: 'check-in', mobileNo: 'mobileNo');

  Future<List<AttendanceModel>> fetchAttendance() async {
    final token = sharedPreferences!.getString("token")!;
    final response = await http.get(
      Uri.parse('http://api.ssgroupm.com/Api/Attendence/GetAttendence'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
        'Authorization': 'Bearer $token',
      },
    );
    print(response);
    if (response.statusCode == 200) {
      List<dynamic> parsed =
          json.decode(response.body).cast<Map<String, dynamic>>();
      print(parsed);
      List<AttendanceModel> list = [];
      list = parsed.map((json) => AttendanceModel.fromJson(json)).toList();
      print(list);
      return list;
    } else {
      throw Exception('Failed to load attendance log');
    }
  }

  Future monthNepali() async {
    final token = sharedPreferences!.getString("token")!;
    var response = await http.get(
      Uri.parse("http://api.ssgroupm.com/Api/Attendence/GetAttendence/4"),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
        'Authorization': 'Bearer $token',
      },
    );
    print(response.statusCode);
    if (response.body.isNotEmpty) {
      print(json.decode(response.body));
    }
  }

  checkLocation() {
    double distanceInMeters =
        Geolocator.distanceBetween(27.619381, 85.316226, 27.619336, 85.316358);
    if(distanceInMeters<20){

    }else{
      showDialog<String>(
        context: context,
        builder: (BuildContext context) => AlertDialog(
          title: const Text("You are too far."),
          content: const Text(
              "Please remain with in 20 meter of the office to post attendance"),
          actions: [
            TextButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                child: const Text("Conform"))
          ],
        ),
      );
    }
    print(distanceInMeters);
  }

  Future lastAttendance() async {
    final token = sharedPreferences!.getString("token")!;
    final response = await http.get(
      Uri.parse('http://api.ssgroupm.com/Api/Attendence/GetLastAttendence'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
        'Authorization': 'Bearer $token',
      },
    );
    print(response);
    print(json.decode(response.body));
  }

  Future<List<AdminGetLeaveModel>> adminGetLeave() async {
    final token = sharedPreferences!.getString("token")!;
    final response = await http.get(
      Uri.parse('http://api.ssgroupm.com/Api/Leave/GetLeaveForAdmin'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
        'Authorization': 'Bearer $token',
      },
    );
    print(response.body);
    if (response.statusCode == 200) {
      List<dynamic> parsed =
          json.decode(response.body).cast<Map<String, dynamic>>();
      List<AdminGetLeaveModel> list = [];
      list = parsed.map((json) => AdminGetLeaveModel.fromJson(json)).toList();
      print(list);
      return list;
    } else {
      throw Exception('Failed to load attendance log');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Help',
          style: TextStyle(
            fontSize: 30,
            color: Colors.white,
          ),
        ),
        centerTitle: true,
        automaticallyImplyLeading: false,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () {
            Route newRoute =
                MaterialPageRoute(builder: (_) => const HomeScreen());
            Navigator.pushReplacement(context, newRoute);
          },
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: const [
            SizedBox(
              height: 300,
            ),

          Center(
            child: Text("The help feature will be added in the future."),
          )
            // ElevatedButton(
            //     onPressed: () {
            //       monthNepali();
            //     },
            //     child: const Text("send nepali month")),
            // ElevatedButton(
            //     onPressed: () {
            //       fetchAttendance();
            //     },
            //     child: const Text("fetch all Attendance Details")),
            // ElevatedButton(
            //     onPressed: () {
            //       lastAttendance();
            //     },
            //     child: const Text("fetch last Attendance")),
            // ElevatedButton(
            //     onPressed: () {
            //       adminGetLeave();
            //     },
            //     child: const Text("adminGetLeave")),
            // ElevatedButton(
            //     onPressed: () {
            //       checkLocation();
            //     },
            //     child: const Text("distance between")),
          ],
        ),
      ),
    );
  }
}

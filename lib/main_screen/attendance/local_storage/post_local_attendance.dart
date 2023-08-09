import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import '../../../global/global.dart';
import '../../../models/attendance_model.dart';
import '../../../models/offline_attendance_model.dart';
import '../../employee_home_screen.dart';
import 'offline_attendance_db.dart';


class PostLocalAttendance extends StatefulWidget {
  const PostLocalAttendance({Key? key}) : super(key: key);

  @override
  State<PostLocalAttendance> createState() => _PostLocalAttendanceState();
}

class _PostLocalAttendanceState extends State<PostLocalAttendance> {
  late List<OfflineAttendance> offlineAttendance;
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    refreshAttendances();
  }

  @override
  void dispose() {
    OfflineDB.instance.close();
    super.dispose();
  }

  Future refreshAttendances() async {
    setState(() {
      isLoading = true;
    });
    this.offlineAttendance = await OfflineDB.instance.readAllAttendance();
    setState(() {
      isLoading = false;
    });
  }

  Future updateAttendance() async {
    final token = sharedPreferences!.getString("token")!;
    for (int i = 0; i < offlineAttendance.length; i++) {
      AttendanceModel attendanceModel = AttendanceModel(
          nepaliDate: offlineAttendance[i].nepaliDate,
          englishDate: offlineAttendance[i].englishDate,
          attendDateTime: offlineAttendance[i].time,
          latitude: offlineAttendance[i].latitude,
          longitude: offlineAttendance[i].longitude,
          deviceId: offlineAttendance[i].deviceID,
          status: offlineAttendance[i].status,
          mobileNo: offlineAttendance[i].phone);
      if (offlineAttendance[i].status == 'check-in') {
        var response = await http.post(
            Uri.parse(
                "http://mis.godawarimun.gov.np/Api/Attendence/AttendUser"),
            headers: <String, String>{
              'Content-Type': 'application/json; charset=UTF-8',
              'Authorization': 'Bearer $token',
            },
            body: jsonEncode(attendanceModel));
        if (response.statusCode == 200) {
          await OfflineDB.instance.delete(offlineAttendance[i].id as int);
        }
      } else {
        var response = await http.post(
            Uri.parse("http://mis.godawarimun.gov.np/Api/Attendence/AttendBeforeLeave"),
            headers: <String, String>{
              'Content-Type': 'application/json; charset=UTF-8',
              'Authorization': 'Bearer $token',
            },
            body: jsonEncode(attendanceModel));
        if (response.statusCode == 200) {
          await OfflineDB.instance.delete(offlineAttendance[i].id as int);
        }
      }
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
                MaterialPageRoute(builder: (_) => const EmployeeHomeScreen());
            Navigator.pushReplacement(context, newRoute);
          },
        ),
      ),
      // body:  FutureBuilder<List<LeaveModel>>(
      //   future: approvedLeave(),
      //   builder: (context, AsyncSnapshot snapshot) {
      //     if (snapshot.connectionState == ConnectionState.waiting) {
      //       return const Center(
      //         child: CircularProgressIndicator(),
      //       );
      //     }
      //     if (snapshot.hasData) {
      //       List<LeaveModel> leaveList = snapshot.data;
      //       return ListView.builder(
      //           itemCount: snapshot.data.length,
      //           itemBuilder: (context, index) {
      //             return Card(
      //               margin: const EdgeInsets.all(8.0),
      //               shape: RoundedRectangleBorder(
      //                 borderRadius: BorderRadius.circular(10.0),
      //               ),
      //               child: Padding(
      //                 padding: const EdgeInsets.all(12.0),
      //                 child: InkWell(
      //                   child: Row(
      //                     mainAxisAlignment: MainAxisAlignment.spaceBetween,
      //                     children: [
      //                       Column(
      //                         crossAxisAlignment: CrossAxisAlignment.start,
      //                         children: [
      //                           Text(
      //                               "Leave Status:" + leaveList[index].status.toString()),
      //                           Text("Reason: " +
      //                               leaveList[index].leaveFor.toString())
      //                         ],
      //                       ),
      //                       Align(
      //                           alignment: Alignment.topRight,
      //                           child: Text("Date: " +
      //                               leaveList[index].leaveDate.toString()))
      //                     ],
      //                   ),
      //                   onTap: () {
      //                     Route newRoute = MaterialPageRoute(
      //                         builder: (_) => UserLeaveDetails(
      //                           leaveModel: leaveList[index],
      //                           status: 'All',
      //                         ));
      //                     Navigator.pushReplacement(context, newRoute);
      //                   },
      //                 ),
      //               ),
      //             );
      //           });
      //     } else {
      //       return const Center(
      //         child: Text("There are no approved leave request"),
      //       );
      //     }
      //   },
      // );
    );
  }
}

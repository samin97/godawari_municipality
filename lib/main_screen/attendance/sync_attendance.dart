import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../../global/widgets/error_dialog.dart';
import '../../global/global.dart';
import '../../local_db/repository/log_repository.dart';
import '../../models/attendance_model.dart';
import '../../models/local_storage_model.dart';
import '../employee_home_screen.dart';
import 'fetch_attendance.dart';

class SyncAttendance extends StatefulWidget {
  const SyncAttendance({Key? key}) : super(key: key);

  @override
  State<SyncAttendance> createState() => _SyncAttendanceState();
}

class _SyncAttendanceState extends State<SyncAttendance> {
  AttendanceModel fetchedAttendance = AttendanceModel(
      nepaliDate: 'nepaliDate',
      englishDate: 'englishDate',
      attendDateTime: 'attendDateTime',
      latitude: 'latitude',
      longitude: 'longitude',
      deviceId: 'deviceId',
      networkId: 'networkId',
      altitude: 'altitude',
      status: 'status', mobileNo: 'mobileNo');

  late AttendanceModel newAttendance = AttendanceModel(
      nepaliDate: 'nepaliDate',
      englishDate: 'englishDate',
      attendDateTime: 'attendDateTime',
      latitude: 'latitude',
      longitude: 'longitude',
      deviceId: 'deviceId',
      networkId: 'networkId',
      altitude: 'altitude',
      status: 'status', mobileNo: 'mobileNo');

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<dynamic>(
        future: LogRepository.getLogs(),
        builder: (context, AsyncSnapshot snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }
          if (snapshot.hasData) {
            List<dynamic> logList = snapshot.data;
            if (logList.isNotEmpty) {
              return Expanded(
                child: SizedBox(
                  height: 200.0,
                  child: ListView.builder(
                    itemCount: logList.length,
                    itemBuilder: (context, index) {
                      Log _log = logList[index];
                      FutureBuilder(
                        future: fetchAttendance(),
                        builder: (context, AsyncSnapshot<dynamic> snapshot) {
                          if (snapshot.connectionState ==
                              ConnectionState.waiting) {
                            return const Center(
                              child: CircularProgressIndicator(),
                            );
                          }
                          if (snapshot.hasData) {
                            List<dynamic> attendanceList = snapshot.data;
                            if (attendanceList.isNotEmpty) {
                              return ListView.builder(
                                itemCount: attendanceList.length,
                                itemBuilder: (context, index) {
                                  AttendanceModel _fetchedAttendance =
                                      attendanceList[index];
                                  if (_log.attendDateTime ==
                                      _fetchedAttendance.attendDateTime) {
                                    LogRepository.deleteLogs(
                                        _log.attendDateTime);
                                  } else {
                                    setState(
                                      () {
                                        newAttendance.nepaliDate =
                                            _log.nepaliDate;
                                        newAttendance.englishDate =
                                            _log.englishDate;
                                        newAttendance.attendDateTime =
                                            _log.attendDateTime!;
                                        newAttendance.latitude = _log.latitude;
                                        newAttendance.longitude =
                                            _log.longitude;
                                        newAttendance.deviceId = _log.deviceId!;
                                        newAttendance.networkId =
                                            _log.networkId;
                                        newAttendance.altitude = _log.altitude;
                                        newAttendance.status= _log.status;
                                      },
                                    );
                                    postAttendance();
                                  }
                                  return const Text("Attendance sync failed");
                                },
                              );
                            }
                          }
                          return const Text("Attendance sync failed");
                        },
                      );

                      return const Text("Attendance sync failed");
                    },
                  ),
                ),
              );
            }
          }
          Route newRoute =
              MaterialPageRoute(builder: (_) => const HomeScreen());
          Navigator.pushReplacement(context, newRoute);
          return const Text("No attendance log");
        });
  }

  Future postAttendance() async {
    final token = sharedPreferences!.getString("token")!;
    var response = await http.post(
        Uri.parse("http://mis.godawarimun.gov.np/Api/Attendence/AttendUser"),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode(newAttendance));

    if (response.statusCode == 200) {
      // var s = response.body.toString();
    } else {
      showDialog(
          context: context,
          builder: (c) {
            return const ErrorDialog(
              message: "Failed to attend",
            );
          });
    }
  }
}

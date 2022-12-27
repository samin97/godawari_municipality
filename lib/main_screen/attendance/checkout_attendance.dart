import 'dart:convert';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'dart:io' show Platform;
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:intl/intl.dart';
import 'package:nepali_utils/nepali_utils.dart';
import 'package:network_info_plus/network_info_plus.dart';
import 'package:http/http.dart' as http;
import 'package:sms_autofill/sms_autofill.dart';
import '../../global/components/location_api.dart';
import '../../global/global.dart';
import '../../global/widgets/error_dialog.dart';
import '../../local_db/db/sqlite_db.dart';
import '../../local_db/repository/log_repository.dart';
import '../../models/attendance_model.dart';
import '../../models/local_storage_model.dart';
import '../../models/location_permission_model.dart';
import '../home_screen.dart';

class AttendanceCheckOut extends StatefulWidget {
  const AttendanceCheckOut({Key? key}) : super(key: key);

  @override
  _AttendanceCheckOutState createState() => _AttendanceCheckOutState();
}

class _AttendanceCheckOutState extends State<AttendanceCheckOut> {
  Position? position;
  TextEditingController phoneNumberController = TextEditingController();
  late AttendanceModel attendanceModel = AttendanceModel(
      nepaliDate: "nepaliDate",
      englishDate: "englishDate",
      attendDateTime: "attendDateTime",
      latitude: "latitude",
      longitude: "longitude",
      deviceId: "deviceId",
      networkId: "networkId",
      altitude: "attitude",
      status: "status", mobileNo: 'mobileNo');
  // ignore: prefer_typing_uninitialized_variables
  var deviceInfo;
  bool hasAttended = false;

  String currentTime = "HH:mm:ss";

  @override
  void initState() {
    super.initState();
    lastAttendance();
    attendanceDetails();
  }

  Future<void> lastAttendance() async {
    final token = sharedPreferences!.getString("token")!;
    final response = await http.get(
      Uri.parse('http://mis.godawarimun.gov.np/Api/Attendence/GetLastAttendence'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
        'Authorization': 'Bearer $token',
      },
    );
    if (response.statusCode == 200) {
      AttendanceModel _lastAttendance =
          AttendanceModel.fromJson(jsonDecode(response.body));
      if (_lastAttendance.englishDate ==
          DateFormat('yyyy/MM/dd').format(DateTime.now())) {
        setState(() {
          hasAttended = true;
        });
      } else {
        setState(() {
          hasAttended = false;
        });
      }
    } else {
      showDialog(
          context: context,
          builder: (c) {
            return const ErrorDialog(
              message: "Attendance Failed",
            );
          });
    }
  }

  Future<void> attendanceDetails() async {
    //nepaliDate:
    NepaliDateTime currentNepaliTime = NepaliDateTime.now();
    var nepaliDate = NepaliDateFormat("yyyy/MM/dd");
    final String nepaliFormatted = nepaliDate.format(currentNepaliTime);
    //englishDate:
    final DateTime now = DateTime.now();
    final DateFormat formatter = DateFormat('yyyy/MM/dd');
    final String englishFormatted = formatter.format(now);
    //attendDateTime:

    String isoAttendDateTime = now.toIso8601String();
    //latitude, longitude and attitude:
    Position newPosition = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high);
    position = newPosition;
    //deviceId:
    final deviceInfoPlugin = DeviceInfoPlugin();

    if (Platform.isAndroid) {
      deviceInfo = await deviceInfoPlugin.androidInfo;
    } else if (Platform.isIOS) {
      deviceInfo = await deviceInfoPlugin.iosInfo;
    }

    //networkId:
    final info = NetworkInfo();
    var wifiGateway = await info.getWifiGatewayIP();

    setState(() {
      attendanceModel.nepaliDate = nepaliFormatted.trim();
      attendanceModel.englishDate = englishFormatted.trim();
      attendanceModel.attendDateTime = isoAttendDateTime.trim();
      attendanceModel.latitude = position?.latitude.toString();
      attendanceModel.longitude = position?.longitude.toString();
      attendanceModel.deviceId = deviceInfo.id.toString();
      attendanceModel.networkId = wifiGateway;
      attendanceModel.altitude = position?.altitude.toString();
      attendanceModel.status = "check-out";
      attendanceModel.mobileNo = phoneNumberController.text.trim();
    });
  }

  checkPhoneNumber() {
    if (phoneNumberController.text.isNotEmpty) {
      checkConnection();
    } else {
      showDialog<String>(
        context: context,
        builder: (BuildContext context) => AlertDialog(
          title: const Text("Phone number is not filled."),
          content: const Text("Please enter your correct phone number."),
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
  }

  Future checkConnection() async {
    var connectivityResult = await (Connectivity().checkConnectivity());
    if (connectivityResult == ConnectivityResult.mobile) {
      checkLocation();
    } else if (connectivityResult == ConnectivityResult.wifi) {
      checkLocation();
    } else {
      showDialog<String>(
        context: context,
        builder: (BuildContext context) => AlertDialog(
          title: const Text("You are offline."),
          content:
          const Text("Please make sure that you have internet connection."),
          actions: [
            TextButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                child: const Text("Conform"))
          ],
        ),
      );
      //localStorage();
    }
  }

  Future checkLocation() async {

    print(double.parse(sharedPreferences!.getString("latitude")!));
    print(double.parse(sharedPreferences!.getString("longitude")!));

    double distanceInMeters = Geolocator.distanceBetween(
      position?.latitude as double,
      position?.longitude as double,
      double.parse(sharedPreferences!.getString("latitude")!),
      double.parse(sharedPreferences!.getString("longitude")!),
    );
    print(distanceInMeters);
    if (distanceInMeters < double.parse(sharedPreferences!.getString("permittedDistance")!) ) {
      attendanceDetails();
      postAttendance();
    } else {
      showDialog<String>(
        context: context,
        builder: (BuildContext context) => AlertDialog(
          title: const Text("You are too far."),
          content: Text("Please remain with in " +
              sharedPreferences!.getString("permittedDistance")! +
              " meter of the office to post attendance"),
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
  }

  Future localStorage() async {
    if (sharedPreferences!.getString("logID") == null) {
      await sharedPreferences?.setString("logID", '1000');
    }
    var logID = sharedPreferences!.getString("logID");
    Log log = Log(
      id: logID,
      attendDateTime: attendanceModel.attendDateTime,
      nepaliDate: attendanceModel.nepaliDate,
      longitude: attendanceModel.longitude,
      latitude: attendanceModel.latitude,
      deviceId: attendanceModel.deviceId,
      englishDate: attendanceModel.englishDate,
      networkId: attendanceModel.networkId,
      altitude: attendanceModel.altitude,
      status: "check-out"

    );

    logID = (int.parse(logID!) + 1).toString();
    await sharedPreferences?.setString("logID", logID);
    setState(() {});
    SqliteMethods().init();
    LogRepository.addLogs(log);
  }

  Future postAttendance() async {
    final token = sharedPreferences!.getString("token")!;
    var response = await http.post(
        Uri.parse("http://mis.godawarimun.gov.np/Api/Attendence/AttendBeforeLeave"),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode(attendanceModel));

    if (response.statusCode == 200) {
      // var s = response.body.toString();
      Route newRoute = MaterialPageRoute(builder: (_) => const HomeScreen());
      Navigator.pushReplacement(context, newRoute);
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
  final double textSize = 16;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(22.0),
        child: Column(
          children: [
            Visibility(
                visible: !hasAttended,
                child: const Center(
                  child: Text("Please check in first"),
                )),
            Visibility(
              visible: hasAttended,
              child: Column(
                children: [
                  Row(
                    children: [
                      Expanded(
                          flex: 1,
                          child: Text(
                            "Nepali Date",
                            style: TextStyle(fontSize: textSize),
                          )),
                      Expanded(
                          flex: 1,
                          child: Text(
                            attendanceModel.nepaliDate!,
                            style: TextStyle(fontSize: textSize),
                          )),
                    ],
                  ),
                  Row(
                    children: [
                      Expanded(
                          flex: 1,
                          child: Text("English Date",
                              style: TextStyle(fontSize: textSize))),
                      Expanded(
                          flex: 1,
                          child: Text(attendanceModel.englishDate!,
                              style: TextStyle(fontSize: textSize))),
                    ],
                  ),
                  Row(
                    children: [
                      Expanded(
                          flex: 1,
                          child: Text("Attend Time",
                              style: TextStyle(fontSize: textSize))),
                      Expanded(
                          flex: 1,
                          child: Text(currentTime,
                              style: TextStyle(fontSize: textSize))),
                    ],
                  ),
                  Row(
                    children: [
                      Expanded(
                          flex: 1,
                          child: Text("Latitude",
                              style: TextStyle(fontSize: textSize))),
                      Expanded(
                          flex: 1,
                          child: Text(attendanceModel.latitude!,
                              style: TextStyle(fontSize: textSize))),
                    ],
                  ),
                  Row(
                    children: [
                      Expanded(
                          flex: 1,
                          child: Text("Longitude",
                              style: TextStyle(fontSize: textSize))),
                      Expanded(
                          flex: 1,
                          child: Text(attendanceModel.longitude!,
                              style: TextStyle(fontSize: textSize))),
                    ],
                  ),
                  Row(
                    children: [
                      Expanded(
                          flex: 1,
                          child: Text("Device Id",
                              style: TextStyle(fontSize: textSize))),
                      Expanded(
                          flex: 1,
                          child: Text(attendanceModel.deviceId,
                              style: TextStyle(fontSize: textSize))),
                    ],
                  ),
                  Row(
                    children: [
                      Expanded(
                          flex: 1,
                          child: Text("Network Id",
                              style: TextStyle(fontSize: textSize))),
                      Expanded(
                          flex: 1,
                          child: Text(attendanceModel.networkId!,
                              style: TextStyle(fontSize: textSize))),
                    ],
                  ),
                  Row(
                    children: [
                      Expanded(
                          flex: 1,
                          child: Text("Attitude",
                              style: TextStyle(fontSize: textSize))),
                      Expanded(
                          flex: 1,
                          child: Text(attendanceModel.altitude!,
                              style: TextStyle(fontSize: textSize))),
                    ],
                  ),
                  Row(
                    children: [
                      Expanded(
                          flex: 1,
                          child: Text("Status",
                              style: TextStyle(fontSize: textSize))),
                      Expanded(
                          flex: 1,
                          child: Text(attendanceModel.status!,
                              style: TextStyle(fontSize: textSize))),
                    ],
                  ),
                  Row(
                    children: [
                      Expanded(
                          flex: 1,
                          child: Text("Phone Number",
                              style: TextStyle(fontSize: textSize))),
                      Expanded(
                        flex: 1,
                        child: PhoneFieldHint(
                          controller: phoneNumberController,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(
                    height: 20,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      ElevatedButton(
                          onPressed: () {
                            attendanceDetails();
                          },
                          child: const Text("Update Information")),
                      ElevatedButton(
                          onPressed: () {
                            showDialog<String>(
                              context: context,
                              builder: (BuildContext context) => AlertDialog(
                                title: const Text("Are you sure?"),
                                content: const Text(
                                    "Please check out after you have finished work."),
                                actions: [
                                  TextButton(
                                      onPressed: () {
                                        checkPhoneNumber();
                                      },
                                      child: const Text("Conform"))
                                ],
                              ),
                            );
                          },
                          child: const Text("Post Attendance")),
                    ],
                  ),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}

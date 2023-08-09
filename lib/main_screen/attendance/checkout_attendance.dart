import 'dart:convert';
import 'package:connectivity_plus/connectivity_plus.dart';

import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:intl/intl.dart';
import 'package:nepali_utils/nepali_utils.dart';
import 'package:network_info_plus/network_info_plus.dart';
import 'package:http/http.dart' as http;
import '../../global/global.dart';
import '../../global/widgets/error_dialog.dart';
import '../../models/attendance_model.dart';
import '../../models/local_storage_model.dart';
import '../../models/work_check_time.dart';
import '../employee_home_screen.dart';
import '../settings/update_device_id.dart';

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
      status: "status",
      mobileNo: 'mobileNo');

  // ignore: prefer_typing_uninitialized_variables
  var deviceInfo;
  bool hasAttended = false;
  DateTime timeNow = DateTime.now();
  final DateFormat timeFormat = DateFormat('HH:mm:ss');
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
      Uri.parse(
          'http://mis.godawarimun.gov.np/Api/Attendence/GetLastAttendence'),
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

    currentTime = timeFormat.format(timeNow);
    String isoAttendDateTime = now.toIso8601String();
    //latitude, longitude and attitude:
    Position newPosition = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high);
    position = newPosition;
    //deviceId:
    deviceInfo = sharedPreferences!.getString("userUUID")!;

    //networkId:
    final info = NetworkInfo();
    var wifiGateway = await info.getWifiGatewayIP();

    setState(() {
      attendanceModel.nepaliDate = nepaliFormatted.trim();
      attendanceModel.englishDate = englishFormatted.trim();
      attendanceModel.attendDateTime = isoAttendDateTime.trim();
      attendanceModel.latitude = position?.latitude.toString();
      attendanceModel.longitude = position?.longitude.toString();
      attendanceModel.deviceId = deviceInfo;
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

  Future<void> checkTime() async {
    final token = sharedPreferences!.getString("token")!;
    final response = await http.get(
      Uri.parse('http://mis.godawarimun.gov.np/Api/Attendence/GetWorkingHour'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
        'Authorization': 'Bearer $token',
      },
    );
    if (response.statusCode == 200) {
      WorkCheckTime _workCheckTime =
      WorkCheckTime.fromJson(jsonDecode(response.body));
      print(currentTime);
      String defaultDate = "0001-01-01 ";
      String _currentTime = currentTime;
      String allowedTime = _workCheckTime.upasthitHunaPauneSamayaSimaAaanyaDin;
      DateTime dt1 = DateTime.parse(defaultDate + _currentTime);
      DateTime dt2 = DateTime.parse(defaultDate + allowedTime);
      if ((dt1.compareTo(dt2) > 0)) {
        checkLocation();
      } else {
        showDialog<String>(
          context: context,
          builder: (BuildContext context) => AlertDialog(
            title: const Text("उपस्थित हुन पाउने समय सिमा ।"),
            content: const Text("माफ गर्नुहोला । तपाई ढिलो आउनुभयो।"),
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
    } else {
      throw Exception('Failed to load attendance');
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
          title: const Text("तपाईं अफलाइन हुनुहुन्छ ।"),
          content: const Text(
              "तपाईंको मोबार्इल सेटमा इन्टरनेट जडान भए/नभएको सुनिश्चित गर्नुहोस् ।"),
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
    if (attendanceModel.deviceId != sharedPreferences!.getString("deviceId")!) {
      return showDialog<String>(
        context: context,
        builder: (BuildContext context) => AlertDialog(
          title: Text(
              "तपाईंको मोबाइल सेट भेरिफाई हुन बाँकी छ "),
          content: Text("भेरिफाईकोलागि अनुरोध गर्न याँहा Click गर्नुहोस् ।"),
          actions: [
            TextButton(
                onPressed: () {
                  Route newRoute = MaterialPageRoute(builder: (_) => const UpdateDeviceID());
                  Navigator.pushReplacement(context, newRoute);
                },
                child: const Text("Conform"))
          ],
        ),
      );
    }
    ;
    print(double.parse(sharedPreferences!.getString("latitude")!));
    print(double.parse(sharedPreferences!.getString("longitude")!));
    double distanceInMeters = Geolocator.distanceBetween(
      position?.latitude as double,
      position?.longitude as double,
      double.parse(sharedPreferences!.getString("latitude")!),
      double.parse(sharedPreferences!.getString("longitude")!),
    );
    print(double.parse(sharedPreferences!.getString("permittedDistance")!));

    print(distanceInMeters);
    bool dif = distanceInMeters <
        double.parse(sharedPreferences!.getString("permittedDistance")!);
    print(dif);
    if (distanceInMeters <
        double.parse(sharedPreferences!.getString("permittedDistance")!)) {
      attendanceDetails();
      postAttendance();
    } else {
      showDialog<String>(
        context: context,
        builder: (BuildContext context) => AlertDialog(
          title: Text(
              "तपाईं कार्यालयबाट लगभग " + distanceInMeters.toStringAsFixed(2) +
                  " मिटर टाढा हुनुहुन्छ."),
          content: Text("तपार्इ कार्यालयबाट " +
              sharedPreferences!.getString("permittedDistance")! +
              "मिटर भित्रबाट मात्र हाजिर गर्न सक्नहुन्छ ।"),
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


  Future postAttendance() async {
    final token = sharedPreferences!.getString("token")!;
    var response = await http.post(
        Uri.parse(
            "http://mis.godawarimun.gov.np/Api/Attendence/AttendBeforeLeave"),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode(attendanceModel));

    if (response.statusCode == 200) {
      // var s = response.body.toString();
      Route newRoute = MaterialPageRoute(builder: (_) => const EmployeeHomeScreen());
      Navigator.pushReplacement(context, newRoute);
    } else {
      showDialog(
          context: context,
          builder: (c) {
            return const ErrorDialog(
              message: "हाजिर गर्न असमर्थन हुनुभयो । पुनःप्रयास गर्नुहोला ।",
            );
          });
    }
  }

  final double textSize = 20;

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
                  child: Text("कृपया पहिले उपस्थिति पेश गर्नुहोस् ।"),
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
                  // Row(
                  //   children: [
                  //     Expanded(
                  //         flex: 1,
                  //         child: Text("Phone Number",
                  //             style: TextStyle(fontSize: textSize))),
                  //     Expanded(
                  //       flex: 1,
                  //       child: PhoneFieldHint(
                  //         controller: phoneNumberController,
                  //       ),
                  //     ),
                  //   ],
                  // ),
                  const SizedBox(
                    height: 20,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      // ElevatedButton(
                      //     onPressed: () {
                      //       attendanceDetails();
                      //     },
                      //     child: const Text("Update Information")),
                      ElevatedButton(
                          onPressed: () {
                            showDialog<String>(
                              context: context,
                              builder: (BuildContext context) => AlertDialog(
                                title:
                                    const Text("के तपाईं पक्का हुनुहुन्छ ? "),
                                content: const Text(
                                    "के तपाईं कार्यालयबाट बाहिरिदै हो ?"),
                                actions: [
                                  TextButton(
                                      onPressed: () {
                                        // checkPhoneNumber();
                                        checkConnection();
                                      },
                                      child: const Text("Conform"))
                                ],
                              ),
                            );
                          },
                          child: const Text("हाजिर गर्नुहोस्")),
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

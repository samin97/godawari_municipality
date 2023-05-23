
import 'dart:io' show Platform;
import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:intl/intl.dart';
import 'package:nepali_utils/nepali_utils.dart';
import 'package:network_info_plus/network_info_plus.dart';

import '../public_home/employee_login.dart';
import '../../global/global.dart';
import '../../global/widgets/app_button.dart';
import '../../global/widgets/error_dialog.dart';
import '../../models/attendance_model.dart';
import '../../models/offline_attendance_model.dart';
import 'local_storage/offline_attendance_db.dart';

class OfflineHome extends StatefulWidget {
  const OfflineHome({Key? key}) : super(key: key);

  @override
  State<OfflineHome> createState() => _OfflineHomeState();
}

class _OfflineHomeState extends State<OfflineHome> {
  Position? position;
  var dropdownValue;

  @override
  void initState() {
    super.initState();
    handleLocationPermission();

    attendanceDetails();
    dropdownValue = "select";
  }

  String? value;

  final statusType = ['check-in', 'check-out'];

  DropdownMenuItem<String> buildMenuItems(String statusType) =>
      DropdownMenuItem(
        value: statusType,
        child: Text(statusType),
      );

  Future<void> handleLocationPermission() async {
    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      LocationPermission serviceEnabled = await Geolocator.requestPermission();

      print("location");
      print(serviceEnabled);
    }
    if (permission == LocationPermission.deniedForever) {
      showDialog(
          context: context,
          builder: (c) {
            return const ErrorDialog(
              message: "Location denied forever.",
            );
          });
    }
    print(permission == LocationPermission.whileInUse);
  }

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

  DateTime timeNow = DateTime.now();
  final DateFormat timeFormat = DateFormat('HH:mm:ss');
  var deviceInfo;
  bool hasAttended = false;
  String currentTime = "HH:mm:ss";

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
    print(position?.latitude);
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
      attendanceModel.status = value;
      attendanceModel.mobileNo = phoneNumberController.text.trim();
    });
  }

  checkStatus() {
    print(value);
    if (value == 'check-in' || value == 'check-out') {
      attendanceDetails();
      addAttendance();
      // checkPhoneNumber();
    } else {
      showDialog<String>(
        context: context,
        builder: (BuildContext context) =>
            AlertDialog(
              title: const Text("Status not selected."),
              content: const Text("Please select your stats of attendance."),
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

  checkPhoneNumber() {
    if (phoneNumberController.text.isNotEmpty) {
      attendanceDetails();
      addAttendance();
    } else {
      showDialog<String>(
        context: context,
        builder: (BuildContext context) =>
            AlertDialog(
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


  Future addAttendance() async {
    final offlineAttendance = OfflineAttendance(
        nepaliDate: attendanceModel.nepaliDate as String,
        englishDate: attendanceModel.englishDate as String,
        time: attendanceModel.attendDateTime,
        status: attendanceModel.status as String,
        longitude: attendanceModel.longitude as String,
        latitude: attendanceModel.latitude as String,
        deviceID: attendanceModel.deviceId,
        phone: attendanceModel.mobileNo as String);
    print(offlineAttendance.nepaliDate);
    await OfflineDB.instance.create(offlineAttendance);
    showDialog<String>(
      context: context,
      builder: (BuildContext context) =>
          AlertDialog(
            title: const Text("Attendance Saved."),
            content: const Text("Your attendance has been recorded locally."),
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


  Future<bool> _onWillPop() async {
    return false;
  }

  Future logoutNow() async {
    await sharedPreferences?.remove("email");
    Route newRoute = MaterialPageRoute(builder: (_) => const Login());
    Navigator.pushReplacement(context, newRoute);
  }

  final double textSize = 18;

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: _onWillPop,
      child: Scaffold(
        appBar: AppBar(
          title: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Offline Attendance',
                style: TextStyle(
                  fontSize: 30,
                  color: Colors.white,
                ),
              ),
            ],
          ),
          centerTitle: true,
          automaticallyImplyLeading: true,
        ),
        body: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(8.0, 18, 8, 2),
            child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                crossAxisAlignment: CrossAxisAlignment.stretch,
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
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        flex: 1,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            SizedBox(height: 12,),
                            Text(
                              'Status : ',
                              style: TextStyle(
                                fontSize: 18,
                                color: Colors.black,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Expanded(
                        flex: 1,
                        child: Container(
                          margin: EdgeInsets.all(0),
                          padding: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 0),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(5),
                            border: Border.all(color: Colors.black),
                          ),
                          child: DropdownButtonHideUnderline(
                            child: DropdownButton(
                              value: value,
                              hint: Text(
                                "select status",
                                style: TextStyle(fontSize: 18),
                              ),
                              dropdownColor: Colors.white,
                              isExpanded: true,
                              items: statusType.map(buildMenuItems).toList(),
                              onChanged: (value) =>
                                  setState(
                                        () {
                                      this.value = value as String?;
                                    },
                                  ),
                            ),
                          ),
                        ),
                      ),
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
                            checkStatus();
                          },
                          child: const Text("Post Attendance")),
                    ],
                  ),
                  const Divider(
                    height: 1,
                  ),
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: AppButton(
                      textColour: Colors.black54,
                      textSize: 20,
                      backgroundColor: const Color(0xFFDADADA),
                      borderColor: const Color(0xFFC4C4C4),
                      text: 'बाहिरिनुहोस्',
                      onTap: () {
                        logoutNow();
                      },
                      icon: const Icon(Icons.logout,
                          size: 30, color: Color(0xFF10599e)),
                    ),
                  ),
                ]),
          ),
        ),
      ),
    );
  }
}


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

import '../../global/components/is_holiday.dart';
import '../../global/components/location_api.dart';
import '../../global/global.dart';
import '../../global/widgets/error_dialog.dart';
import '../../models/attendance_model.dart';
import '../../models/location_permission_model.dart';
import '../home_screen.dart';
import 'attendance_category.dart';


class OvertimeAttendance extends StatefulWidget {
  const OvertimeAttendance({Key? key}) : super(key: key);

  @override
  State<OvertimeAttendance> createState() => _OvertimeAttendanceState();
}

class _OvertimeAttendanceState extends State<OvertimeAttendance> {
  Position? position;
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
  DateTime timeNow = DateTime.now();
  final DateFormat timeFormat = DateFormat('HH:mm:ss');
  var deviceInfo;
  bool hasAttended = false;
  String currentTime="HH:mm:ss";

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
      attendanceModel.status = "check-in";
    });
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

  checkLocation() {

    LocationModel locationModel = LocationModel();
    locationModel = fetchLocation() as LocationModel;

    double distanceInMeters = Geolocator.distanceBetween(
        position?.latitude as double,
        position?.longitude as double,
        double.parse(locationModel.latitude.toString()),
        double.parse(locationModel.latitude.toString()));
    if (distanceInMeters < double.parse(locationModel.meters!.toString())) {
      postAttendance();
    } else {
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
  }

  Future postAttendance() async {
    final token = sharedPreferences!.getString("token")!;
    var response = await http.post(
        Uri.parse("http://mis.godawarimun.gov.np/Api/Attendence/OtAttendBeforeLeave"),
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

  @override
  void initState() {
    super.initState();
    attendanceDetails();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "OT attendance",
          style: TextStyle(fontSize: 30, color: Colors.white),
        ),
        centerTitle: true,
        automaticallyImplyLeading: false,
        leading: IconButton(
            onPressed: () {
              Route newRoute =
                  MaterialPageRoute(builder: (_) => const AttendanceCategory());
              Navigator.pushReplacement(context, newRoute);
            },
            icon: const Icon(
              Icons.arrow_back,
              color: Colors.white,
            )),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Visibility(
                visible: !isHoliday(),
                child: const Center(
                  child: Text("Today is not a holiday."),
                )),
            Visibility(
              visible: isHoliday(),
              child: Column(
                children: [
                  Row(
                    children: [
                      const Expanded(flex: 1, child: Text("Nepali Date")),
                      Expanded(
                          flex: 1, child: Text(attendanceModel.nepaliDate!)),
                    ],
                  ),
                  Row(
                    children: [
                      const Expanded(flex: 1, child: Text("English Date")),
                      Expanded(
                          flex: 1, child: Text(attendanceModel.englishDate!)),
                    ],
                  ),
                  Row(
                    children: [
                      const Expanded(flex: 1, child: Text("Attend Time")),
                      Expanded(flex: 1, child: Text(currentTime)),
                    ],
                  ),
                  Row(
                    children: [
                      const Expanded(flex: 1, child: Text("Latitude")),
                      Expanded(flex: 1, child: Text(attendanceModel.latitude!)),
                    ],
                  ),
                  Row(
                    children: [
                      const Expanded(flex: 1, child: Text("Longitude")),
                      Expanded(
                          flex: 1, child: Text(attendanceModel.longitude!)),
                    ],
                  ),
                  Row(
                    children: [
                      const Expanded(flex: 1, child: Text("Device Id")),
                      Expanded(flex: 1, child: Text(attendanceModel.deviceId)),
                    ],
                  ),
                  Row(
                    children: [
                      const Expanded(flex: 1, child: Text("Network Id")),
                      Expanded(
                          flex: 1, child: Text(attendanceModel.networkId!)),
                    ],
                  ),
                  Row(
                    children: [
                      const Expanded(flex: 1, child: Text("Attitude")),
                      Expanded(flex: 1, child: Text(attendanceModel.altitude!)),
                    ],
                  ),
                  Row(
                    children: [
                      const Expanded(flex: 1, child: Text("Status")),
                      Expanded(flex: 1, child: Text(attendanceModel.status!)),
                    ],
                  ),
                  ElevatedButton(
                      onPressed: () {
                        attendanceDetails();
                      },
                      child: const Text("Set Attendance Details")),
                  ElevatedButton(
                      onPressed: () {
                        showDialog<String>(
                          context: context,
                          builder: (BuildContext context) => AlertDialog(
                            title: const Text("Are you sure?"),
                            content: const Text(
                                "You can only do this once per day."),
                            actions: [
                              TextButton(
                                  onPressed: () {
                                    checkConnection();
                                  },
                                  child: const Text("Conform"))
                            ],
                          ),
                        );
                      },
                      child: const Text("Post Attendance")),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}



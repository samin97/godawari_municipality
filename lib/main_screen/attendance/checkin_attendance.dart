import 'dart:convert';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'dart:io' show Platform;
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:intl/intl.dart';
import 'package:municpality_app/main_screen/settings/update_device_id.dart';
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
import '../../models/offline_attendance_model.dart';
import '../home_screen.dart';
import 'local_storage/offline_attendance_db.dart';

class AttendanceCheckIn extends StatefulWidget {
  const AttendanceCheckIn({Key? key}) : super(key: key);

  @override
  _AttendanceCheckInState createState() => _AttendanceCheckInState();
}

class _AttendanceCheckInState extends State<AttendanceCheckIn> {
  Position? position;
  late List<OfflineAttendance> offlineAttendance;
  bool isLoading = false;
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

  @override
  void initState() {
    super.initState();
    lastAttendance();
    attendanceDetails();
    refreshOfflineAttendances();
  }
  @override
  void dispose() {
    OfflineDB.instance.close();
    super.dispose();
  }

  Future refreshOfflineAttendances() async {
    setState(() {
      isLoading = true;
    });
    this.offlineAttendance = await OfflineDB.instance.readAllAttendance();
    setState(() {
      isLoading = false;
    });
  }

  Future updateOfflineAttendance() async {
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
        print('offline attendance done');
        print(response.statusCode);
        if (response.statusCode == 200) {
          await OfflineDB.instance.delete(offlineAttendance[i].id as int);
          print('offline attendance done');
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
    print(response.body);
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
      throw Exception('Failed to load attendance');
    }
    print(hasAttended);
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
      attendanceModel.mobileNo = phoneNumberController.text.trim();
    });
  }

  checkPhoneNumber() {
    if (phoneNumberController.text.isNotEmpty) {
      checkConnection();
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

  Future checkConnection() async {
    var connectivityResult = await (Connectivity().checkConnectivity());
    if (connectivityResult == ConnectivityResult.mobile) {
      checkLocation();
    } else if (connectivityResult == ConnectivityResult.wifi) {
      checkLocation();
    } else {
      showDialog<String>(
        context: context,
        builder: (BuildContext context) =>
            AlertDialog(
              title: const Text("तपाईं अफलाइन हुनुहुन्छ।"),
              content: const Text(
                  "तपाईको मोबार्इल सेटमा इन्टरनेट जडान भए/नभएको सुनिश्चित गर्नुहोस् ।"),
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
        builder: (BuildContext context) =>
            AlertDialog(
              title: Text(
                  "तपाइको मोबाइल सेट भेरिफाई हुन बाँकी छ "),
              content: Text("भेरिफाईकोलागि अनुरोध गर्न याँहा Conform गर्नुहोस् ।"),
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
    };
    print(position?.latitude);
    print(position?.longitude);
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
        builder: (BuildContext context) =>
            AlertDialog(
              title: Text(
                  "तपार्इ कार्यालयबाट लगभग " + distanceInMeters.toStringAsFixed(2) +
                      " मिटर टाढा हुनुहुन्छ."),
              content: Text("तपार्इ कार्यालयबाट " +
                  sharedPreferences!.getString("permittedDistance")! +
                  "म िटर भित्रबाट मात्र हाजिर गर्न सक्नहुन्छ ।"),
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
        Uri.parse("http://mis.godawarimun.gov.np/Api/Attendence/AttendUser"),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode(attendanceModel));

    if (response.statusCode == 200) {
      refreshOfflineAttendances();
      updateOfflineAttendance();
      // var s = response.body.toString();
      Route newRoute = MaterialPageRoute(builder: (_) => const HomeScreen());
      Navigator.pushReplacement(context, newRoute);
    } else {
      print(response.body);
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
                visible: hasAttended,
                child: const Center(
                  child: Text("तपाईको आजको उपस्थिति पेश गरिसक्नुभएको छ ।"),
                )),
            Visibility(
              visible: !hasAttended,
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
                              builder: (BuildContext context) =>
                                  AlertDialog(
                                    title: const Text("के तपाईं पक्का हुनुहुन्छ ?"),
                                    content: const Text(
                                        "हाजिरि गर्दाखेरीः  दिनमा एकपटकमात्र तपाई आफ्नो हाजिरी गर्न सक्नुहुन्छ ।"),
                                    actions: [
                                      TextButton(
                                          onPressed: () {
                                            Navigator.pop(context);
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

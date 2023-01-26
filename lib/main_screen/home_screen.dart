import 'dart:convert';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:geolocator/geolocator.dart';
import 'package:intl/intl.dart';
import 'package:local_auth/local_auth.dart';
import 'package:nepali_utils/nepali_utils.dart';
import 'package:network_info_plus/network_info_plus.dart';
import 'package:smart_attendance/main_screen/report/report_category.dart';
import 'package:smart_attendance/main_screen/settings/settings.dart';
import 'package:smart_attendance/main_screen/settings/update_device_id.dart';
import 'package:smart_attendance/main_screen/test_dummy.dart';
import '../authenticate/login.dart';
import '../global/widgets/app_button.dart';
import '../global/widgets/error_dialog.dart';
import '../global/global.dart';
import '../local_db/repository/log_repository.dart';
import '../models/attendance_model.dart';
import '../models/local_storage_model.dart';
import 'package:http/http.dart' as http;
import '../models/work_check_time.dart';
import 'attendance/attendance_category.dart';
import 'event/event_screen.dart';
import 'kaaj/user/kaaj.dart';
import 'leave/admin/leave_status_screen.dart';
import 'leave/user/leave_category.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  Position? position;
  bool hasEnabledLocation = false;
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
    mobileNo: 'mobileNo',
  );
  String status = "check-in";
  String url = "http://mis.godawarimun.gov.np/Api/Attendence/AttendUser";
  bool isFingerPrint = false;

  @override
  void initState() {
    super.initState();
    attendanceDetails();
    handleLocationPermission();
  }

  checkHoliday() {
    String today = DateFormat('EEEE').format(DateTime.now());
    if (today.toLowerCase() == "saturday") {
      showDialog<String>(
        context: context,
        builder: (BuildContext context) => AlertDialog(
          title: const Text("It is Saturday."),
          content: const Text("Today is a holiday."),
          actions: [
            TextButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                child: const Text("OK"))
          ],
        ),
      );
    } else {
      if (isFingerPrint == false) {
        Route newRoute =
            MaterialPageRoute(builder: (_) => const AttendanceCategory());
        Navigator.pushReplacement(context, newRoute);
      } else {
        _checkBio();
      }
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
    final deviceInfo = await deviceInfoPlugin.deviceInfo;
    //networkId:
    final info = NetworkInfo();
    var wifiGateway = await info.getWifiGatewayIP();

    setState(() {
      attendanceModel.nepaliDate = nepaliFormatted.trim();
      attendanceModel.englishDate = englishFormatted.trim();
      attendanceModel.attendDateTime = isoAttendDateTime.trim();
      attendanceModel.latitude = position?.latitude.toString();
      attendanceModel.longitude = position?.longitude.toString();
      attendanceModel.deviceId = deviceInfo.toString();
      attendanceModel.networkId = wifiGateway;
      attendanceModel.altitude = position?.altitude.toString();
      attendanceModel.status = status;
    });
  }

  Future checkConnection() async {
    var connectivityResult = await (Connectivity().checkConnectivity());
    if (connectivityResult == ConnectivityResult.mobile) {
      checkTime();
    } else if (connectivityResult == ConnectivityResult.wifi) {
      checkTime();
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

  Future<void> checkTime() async {
    final token = sharedPreferences!.getString("token")!;
    final response = await http.get(
      Uri.parse('http://mis.godawarimun.gov.np/Api/Attendence/GetWorkingHour'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
        'Authorization': 'Bearer $token',
      },
    );
    if (status == "check-in") {
      print(status);
      if (response.statusCode == 200) {
        WorkCheckTime _workCheckTime =
            WorkCheckTime.fromJson(jsonDecode(response.body));

        String currentTime = "HH:mm:ss";
        final DateFormat timeFormat = DateFormat('HH:mm:ss');
        DateTime timeNow = DateTime.now();
        currentTime = timeFormat.format(timeNow);
        String defaultDate = "0001-01-01 ";
        String _currentTime = currentTime;
        String allowedTime = _workCheckTime.upasthitHunaPauneSamaya;
        DateTime dt1 = DateTime.parse(defaultDate + _currentTime);
        DateTime dt2 = DateTime.parse(defaultDate + allowedTime);
        if ((dt1.compareTo(dt2) < 0)) {
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
    } else {
      print(status);
      checkLocation();
    }
  }

  Future checkLocation() async {
    if (attendanceModel.deviceId != sharedPreferences!.getString("deviceId")!) {
      return showDialog<String>(
        context: context,
        builder: (BuildContext context) => AlertDialog(
          title: Text("तपाईंको मोबाइल सेट भेरिफाई हुन बाँकी छ "),
          content: Text("भेरिफाईकोलागि अनुरोध गर्न याँहा Click गर्नुहोस् ।"),
          actions: [
            TextButton(
                onPressed: () {
                  Route newRoute =
                      MaterialPageRoute(builder: (_) => const UpdateDeviceID());
                  Navigator.pushReplacement(context, newRoute);
                },
                child: const Text("Conform"))
          ],
        ),
      );
    }

    print(double.parse(sharedPreferences!.getString("latitude")!));
    print(double.parse(sharedPreferences!.getString("longitude")!));
    double distanceInMeters = Geolocator.distanceBetween(
      position?.latitude as double,
      position?.longitude as double,
      double.parse(sharedPreferences!.getString("latitude")!),
      double.parse(sharedPreferences!.getString("longitude")!),
    );
    if (distanceInMeters <
        double.parse(sharedPreferences!.getString("permittedDistance")!)) {
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
        status: "check-in");
    setState(() async {
      logID = (int.parse(logID!) + 1) as String;
      await sharedPreferences?.setString("logID", logID!);
    });
    LogRepository.addLogs(log);
  }

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
          status = "check-out";
          url =
              "http://mis.godawarimun.gov.np/Api/Attendence/AttendBeforeLeave";
        });
      } else {
        setState(() {
          status = "check-in";
          url = "http://mis.godawarimun.gov.np/Api/Attendence/AttendUser";
        });
      }
    } else {
      showDialog(
          context: context,
          builder: (c) {
            return const ErrorDialog(
              message: "Cannot attend currently.",
            );
          });
    }
  }

  Future postAttendance() async {
    final token = sharedPreferences!.getString("token")!;
    var response = await http.post(Uri.parse(url),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode(attendanceModel));

    if (response.statusCode == 200) {
      const snackBar = SnackBar(content: Text("Attendance posted"));
      ScaffoldMessenger.of(context).showSnackBar(snackBar);
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

  bool? _hasBioSensor;
  LocalAuthentication bioAuthentication = LocalAuthentication();

  Future<void> _checkBio() async {
    try {
      _hasBioSensor = await bioAuthentication.canCheckBiometrics;
      if (_hasBioSensor!) {
        _getAuth();
      } else {
        const snackBar = SnackBar(
            content:
                Text("Device does not support fingerprint authentication"));
        ScaffoldMessenger.of(context).showSnackBar(snackBar);
      }
    } on PlatformException catch (e) {
      print(e);
    }
  }

  Future<void> _getAuth() async {
    lastAttendance();
    bool isAuth = false;
    try {
      isAuth = await bioAuthentication.authenticate(
          localizedReason: 'Scan your finger for $status attendance');
      const AuthenticationOptions(
          biometricOnly: true, useErrorDialogs: true, stickyAuth: true);
      if (isAuth) {
        attendanceDetails();
        checkConnection();
      } else {
        const snackBar =
            SnackBar(content: Text("Fingerprint authentication failed"));
        ScaffoldMessenger.of(context).showSnackBar(snackBar);
      }
    } on PlatformException catch (e) {
      print(e);
    }
  }

  Future logoutNow() async {
    await sharedPreferences?.remove("email");
    Route newRoute = MaterialPageRoute(builder: (_) => const Login());
    Navigator.pushReplacement(context, newRoute);
  }

  Future<bool> _onWillPop() async {
    return false;
  }

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
                'Welcome',
                style: TextStyle(
                  fontSize: 30,
                  color: Colors.white,
                ),
              ),
              IconButton(
                  onPressed: () {
                    Route newRoute = MaterialPageRoute(
                        builder: (_) => const SettingsScreen());
                    Navigator.pushReplacement(context, newRoute);
                  },
                  icon: const Icon(
                    Icons.settings,
                    color: Colors.white,
                  )),
            ],
          ),
          centerTitle: true,
          automaticallyImplyLeading: false,
        ),
        body: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(8.0, 18, 8, 2),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Flexible(
                      flex: 2,
                      child: CircleAvatar(
                        radius: 54,
                        backgroundColor: const Color(0xFF32659F),
                        child: CircleAvatar(
                            radius: 70,
                            backgroundColor: Colors.transparent,
                            backgroundImage:
                                AssetImage("images/userProfile.png")),
                      ),
                    ),
                    Flexible(
                      flex: 4,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Name : ' +
                                  sharedPreferences!.getString("firstName")!,
                              style: const TextStyle(
                                fontSize: 15,
                                color: Colors.black54,
                              ),
                            ),
                            const SizedBox(
                              height: 10,
                            ),
                            Text(
                              'Role : ' + sharedPreferences!.getString("role")!,
                              style: const TextStyle(
                                fontSize: 15,
                                color: Colors.black54,
                              ),
                            ),

                            const SizedBox(
                              height: 10,
                            ),
                            Text(
                              'Validation : ' +
                                  sharedPreferences!.getString("username")!,
                              style: const TextStyle(
                                fontSize: 15,
                                color: Colors.black54,
                              ),
                            ),
                            const SizedBox(
                              height: 10,
                            ),
                            // const Text(
                            //   'Permission : ',
                            //   //+ sharedPreferences?.getString("permission") ??'null',
                            //   style: TextStyle(
                            //     fontSize: 15,
                            //     color: Colors.black54,
                            //   ),
                            // ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
                const Divider(
                  thickness: 4,
                ),
                Column(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(12.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          Flexible(
                            flex: 3,
                            child: AppButton(
                              textColour: Colors.black54,
                              backgroundColor: const Color(0xFFDADADA),
                              borderColor: const Color(0xFFC4C4C4),
                              text: 'हाजिरी',
                              onTap: () {
                                handleLocationPermission();
                                isFingerPrint = false;
                                checkHoliday();
                              },
                              icon: const Icon(Icons.co_present,
                                  size: 40, color: Color(0xFF10599e)),
                            ),
                          ),
                          const Spacer(
                            flex: 1,
                          ),
                          Flexible(
                            flex: 3,
                            child: AppButton(
                              textColour: Colors.black54,
                              backgroundColor: const Color(0xFFDADADA),
                              borderColor: const Color(0xFFC4C4C4),
                              text: 'फिङ्गरप्रिन्ट ',
                              onTap: () {
                                handleLocationPermission();
                                isFingerPrint = true;
                                checkHoliday();
                              },
                              icon: const Icon(Icons.fingerprint,
                                  size: 40, color: Color(0xFF10599e)),
                            ),
                          ),
                          const Spacer(
                            flex: 1,
                          ),
                          Flexible(
                            flex: 3,
                            child: AppButton(
                              textColour: Colors.black54,
                              backgroundColor: const Color(0xFFDADADA),
                              borderColor: const Color(0xFFC4C4C4),
                              text: 'इभेन्ट',
                              onTap: () {
                                Route newRoute = MaterialPageRoute(
                                    builder: (_) => const EventListScreen());
                                Navigator.pushReplacement(context, newRoute);
                              },
                              icon: const Icon(Icons.event,
                                  size: 40, color: Color(0xFF10599e)),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(12.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          Flexible(
                            flex: 3,
                            child: AppButton(
                              textColour: Colors.black54,
                              backgroundColor: const Color(0xFFDADADA),
                              borderColor: const Color(0xFFC4C4C4),
                              text: 'बिदा',
                              onTap: () {
                                Route newRoute = MaterialPageRoute(
                                    builder: (_) => const LeaveCategory());
                                Navigator.pushReplacement(context, newRoute);
                              },
                              icon: const Icon(Icons.work_off,
                                  size: 40, color: Color(0xFF10599e)),
                            ),
                          ),
                          const Spacer(
                            flex: 1,
                          ),
                          Flexible(
                            flex: 3,
                            child: AppButton(
                              textColour: Colors.black54,
                              backgroundColor: const Color(0xFFDADADA),
                              borderColor: const Color(0xFFC4C4C4),
                              text: 'काज',
                              onTap: () {
                                Route newRoute = MaterialPageRoute(
                                    builder: (_) => const Kaaj());
                                Navigator.pushReplacement(context, newRoute);
                              },
                              icon: const Icon(Icons.insert_drive_file_outlined,
                                  size: 40, color: Color(0xFF10599e)),
                            ),
                          ),
                          const Spacer(
                            flex: 1,
                          ),
                          Flexible(
                            flex: 3,
                            child: AppButton(
                              textColour: Colors.black54,
                              backgroundColor: const Color(0xFFDADADA),
                              borderColor: const Color(0xFFC4C4C4),
                              textSize: 12,
                              text: 'हाजिरी प्रतिवेदन',
                              onTap: () {
                                Route newRoute = MaterialPageRoute(
                                    builder: (_) => const ReportCategory());
                                Navigator.pushReplacement(context, newRoute);
                              },
                              icon: const Icon(Icons.document_scanner,
                                  size: 30, color: Color(0xFF10599e)),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Visibility(
                      visible: ((sharedPreferences!.getString("role")!)
                                  .toLowerCase() ==
                              "munadmin" ||
                          (sharedPreferences!.getString("role")!)
                                  .toLowerCase() ==
                              "wardadmin"),
                      child: Padding(
                        padding: const EdgeInsets.all(12.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            const Spacer(flex: 2),
                            Flexible(
                              flex: 3,
                              child: AppButton(
                                textColour: Colors.black54,
                                backgroundColor: const Color(0xFFDADADA),
                                borderColor: const Color(0xFFC4C4C4),
                                text: 'बिदा (एडमिन)',
                                onTap: () {
                                  Route newRoute = MaterialPageRoute(
                                      builder: (_) => const LeaveStatus());
                                  Navigator.pushReplacement(context, newRoute);
                                },
                                icon: const Icon(
                                  Icons.leave_bags_at_home,
                                  size: 30,
                                  color: Color(0xFF10599e),
                                ),
                              ),
                            ),
                            const Spacer(flex: 1),
                            // Flexible(
                            //   flex: 3,
                            //   child: AppButton(
                            //     textColour: Colors.black54,
                            //     backgroundColor: const Color(0xFFDADADA),
                            //     borderColor: const Color(0xFFC4C4C4),
                            //     text: 'काज (एडमिन)',
                            //     onTap: () {
                            //       // Route newRoute = MaterialPageRoute(
                            //       //     builder: (_) => const LeaveStatus());
                            //       // Navigator.pushReplacement(context, newRoute);
                            //     },
                            //     icon: const Icon(
                            //       Icons.account_balance_outlined,
                            //       size: 30,
                            //       color: Color(0xFF10599e),
                            //     ),
                            //   ),
                            // ),
                            Flexible(
                              flex: 3,
                              child: AppButton(
                                textColour: Colors.black54,
                                backgroundColor: const Color(0xFFDADADA),
                                borderColor: const Color(0xFFC4C4C4),
                                text: 'मद्दत',
                                onTap: () {
                                  Route newRoute = MaterialPageRoute(
                                      builder: (_) => const AttendanceReport());
                                  Navigator.pushReplacement(context, newRoute);
                                },
                                icon: const Icon(Icons.developer_mode,
                                    size: 30, color: Color(0xFF10599e)),
                              ),
                            ),

                            const Spacer(flex: 2),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

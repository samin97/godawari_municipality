import 'dart:convert';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:geolocator/geolocator.dart';
import 'package:intl/intl.dart';
import 'package:local_auth/local_auth.dart';
import 'package:municpality_app/main_screen/report/report_category.dart';
import 'package:municpality_app/main_screen/test_dummy.dart';
import 'package:nepali_utils/nepali_utils.dart';
import 'package:network_info_plus/network_info_plus.dart';
import '../authenticate/login.dart';
import '../global/widgets/app_button.dart';
import '../global/widgets/error_dialog.dart';
import '../global/global.dart';
import '../global/components/location_api.dart';
import '../local_db/repository/log_repository.dart';
import '../models/attendance_model.dart';
import '../models/local_storage_model.dart';
import 'package:http/http.dart' as http;

import '../models/location_permission_model.dart';
import 'attendance/attendance_category.dart';
import 'event/event_screen.dart';
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
    var nepaliDate = NepaliDateFormat("yyyy.MMMM.dd");
    final String nepaliFormatted = nepaliDate.format(currentNepaliTime);
    //englishDate:
    final DateTime now = DateTime.now();
    final DateFormat formatter = DateFormat('yyyy-MM-dd');
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
        locationModel.latitude as double,
        locationModel.latitude as double);
    if (distanceInMeters < locationModel.meters!.toDouble()) {
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
          status = "check-out";
          url = "http://mis.godawarimun.gov.np/Api/Attendence/AttendBeforeLeave";
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Welcome',
          style: TextStyle(
            fontSize: 30,
            color: Colors.white,
          ),
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
                      backgroundColor: Colors.blue,
                      child: CircleAvatar(
                        radius: 50,
                        backgroundColor: Colors.transparent,
                        backgroundImage: NetworkImage(
                            "https://myrepublica.nagariknetwork.com/uploads/media/Governmentlogo_20200312190212.jpg"),
                      ),
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
                            'Email : ' +
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
                            backgroundColor: const Color(0xFF80DEEA),
                            borderColor: const Color(0xFF80DEEA),
                            text: 'Attendance',
                            onTap: () {
                              handleLocationPermission();
                              isFingerPrint = false;
                              checkHoliday();
                            },
                            icon: const Icon(Icons.co_present,
                                color: Color(0xFF10599e)),
                          ),
                        ),
                        const Spacer(
                          flex: 1,
                        ),
                        Flexible(
                          flex: 3,
                          child: AppButton(
                            textColour: Colors.black54,
                            backgroundColor: const Color(0xFF80DEEA),
                            borderColor: const Color(0xFF80DEEA),
                            text: 'Fingerprint ',
                            onTap: () {
                              handleLocationPermission();
                              isFingerPrint = true;
                              checkHoliday();
                            },
                            icon: const Icon(Icons.fingerprint,
                                color: Color(0xFF10599e)),
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
                            backgroundColor: const Color(0xFF80DEEA),
                            borderColor: const Color(0xFF80DEEA),
                            text: 'Leave',
                            onTap: () {
                              Route newRoute = MaterialPageRoute(
                                  builder: (_) => const LeaveCategory());
                              Navigator.pushReplacement(context, newRoute);
                            },
                            icon: const Icon(Icons.work_off,
                                color: Color(0xFF10599e)),
                          ),
                        ),
                        const Spacer(
                          flex: 1,
                        ),
                        Flexible(
                          flex: 3,
                          child: AppButton(
                            textColour: Colors.black54,
                            backgroundColor: const Color(0xFF80DEEA),
                            borderColor: const Color(0xFF80DEEA),
                            text: 'Report',
                            onTap: () {
                              Route newRoute = MaterialPageRoute(
                                  builder: (_) => const ReportCategory());
                              Navigator.pushReplacement(context, newRoute);
                            },
                            icon: const Icon(Icons.document_scanner,
                                color: Color(0xFF10599e)),
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
                            backgroundColor: const Color(0xFF80DEEA),
                            borderColor: const Color(0xFF80DEEA),
                            text: 'Event',
                            onTap: () {
                              Route newRoute = MaterialPageRoute(
                                  builder: (_) => const EventListScreen());
                              Navigator.pushReplacement(context, newRoute);
                            },
                            icon: const Icon(Icons.event,
                                color: Color(0xFF10599e)),
                          ),
                        ),
                        const Spacer(
                          flex: 1,
                        ),
                        Flexible(
                          flex: 3,
                          child: AppButton(
                            textColour: Colors.black54,
                            backgroundColor: const Color(0xFF80DEEA),
                            borderColor: const Color(0xFF80DEEA),
                            text: 'Help',
                            onTap: () {
                              Route newRoute = MaterialPageRoute(
                                  builder: (_) => const AttendanceReport());
                              Navigator.pushReplacement(context, newRoute);
                            },
                            icon: const Icon(Icons.developer_mode,
                                color: Color(0xFF10599e)),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Visibility(
                    visible: ((sharedPreferences!.getString("role")!)
                                .toLowerCase() ==
                            "munadmin" ||
                        (sharedPreferences!.getString("role")!).toLowerCase() ==
                            "wardadmin"),
                    child: Padding(
                      padding: const EdgeInsets.all(12.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          const Spacer(flex: 1),
                          Flexible(
                            flex: 2,
                            child: AppButton(
                              textColour: Colors.black54,
                              backgroundColor: const Color(0xFF80DEEA),
                              borderColor: const Color(0xFF80DEEA),
                              text: 'Admin leave',
                              onTap: () {
                                Route newRoute = MaterialPageRoute(
                                    builder: (_) => const LeaveStatus());
                                Navigator.pushReplacement(context, newRoute);
                              },
                              icon: const Icon(
                                Icons.leave_bags_at_home,
                                color: Color(0xFF10599e),
                              ),
                            ),
                          ),
                          const Spacer(flex: 1),
                        ],
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(12.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        const Spacer(flex: 1),
                        Flexible(
                          flex: 1,
                          child: AppButton(
                            textColour: Colors.black54,
                            backgroundColor: const Color(0xFF80DEEA),
                            borderColor: const Color(0xFF80DEEA),
                            text: 'Logout',
                            onTap: () {
                              logoutNow();
                            },
                            icon: const Icon(Icons.logout,
                                color: Color(0xFF10599e)),
                          ),
                        ),
                        const Spacer(flex: 1),
                      ],
                    ),
                  ),
                ],
              )
            ],
          ),
        ),
      ),
    );
  }
}

import 'dart:convert';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:smart_attendance/main_screen/settings/settings.dart';
import 'dart:io' show Platform;
import '../../global/global.dart';
import '../../models/device_id_response.dart';
import '../home_screen.dart';

class UpdateDeviceID extends StatefulWidget {
  const UpdateDeviceID({Key? key}) : super(key: key);

  @override
  State<UpdateDeviceID> createState() => _UpdateDeviceIDState();
}

class _UpdateDeviceIDState extends State<UpdateDeviceID> {
  void initState() {
    super.initState();
    fetchDeviceID();
  }

  String deviceID = "device ID";
  late var deviceInfo;

  Future<void> fetchDeviceID() async {
    final deviceInfoPlugin = DeviceInfoPlugin();

    if (Platform.isAndroid) {
      deviceInfo = await deviceInfoPlugin.androidInfo;
    } else if (Platform.isIOS) {
      deviceInfo = await deviceInfoPlugin.iosInfo;
    }
    setState(() {
      deviceID = deviceInfo.id.toString();
    });
  }

  Future checkDeviceID() async {
    var url=  "http://mis.godawarimun.gov.np/Api/Attendence/GetDeviceId?deviceId=";
    url = url + deviceID;
    print(url);
    final token = sharedPreferences!.getString("token")!;
    var response = await http.get(
      Uri.parse(url),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
        'Authorization': 'Bearer $token',
      },
    );
    if (response.statusCode == 200) {
      DeviceIdResponse deviceIdResponse =
          DeviceIdResponse.fromJson(jsonDecode(response.body));
      await sharedPreferences?.setString("deviceId", deviceIdResponse.deviceId);
      await sharedPreferences?.setString("username", deviceIdResponse.username);
      await sharedPreferences?.setString(
          "firstName", deviceIdResponse.firstName);
      print(sharedPreferences!.getString("deviceId")!);

      if (deviceID == sharedPreferences!.getString("deviceId")!) {
         conformDeviceID();
      } else {
        usedDeviceID();
      }
    } else {}
  }

  showLoaderDialog(BuildContext context) {
    AlertDialog alert = AlertDialog(
      content: Row(
        children: [
          CircularProgressIndicator(),
          Container(
              margin: EdgeInsets.only(left: 7), child: Text("Loading...")),
        ],
      ),
    );
    showDialog(
      barrierDismissible: true,
      context: context,
      builder: (BuildContext context) {
        return alert;
      },
    );
  }

  Future conformDeviceID() async {
    final token = sharedPreferences!.getString("token")!;
    var url =
        'http://mis.godawarimun.gov.np/Api/Attendence/UpdateDeviceId?deviceId=';
    url = url + deviceID;
    var response = await http.post(
      Uri.parse(url),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
        'Authorization': 'Bearer $token',
      },
    );
    print(response.statusCode);
    print(response.body);
    if (response.statusCode == 200) {
      const snackBar = SnackBar(
        content: Text('Device ID has been changed.'),
      );
      ScaffoldMessenger.of(context).showSnackBar(snackBar);
      Route newRoute = MaterialPageRoute(builder: (_) => const HomeScreen());
      Navigator.pushReplacement(context, newRoute);
    } else if (response.statusCode == 191) {
      usedDeviceID();
    } else {
      deviceIDChangeFailed();
    }
  }

  usedDeviceID() {
    showDialog<String>(
      context: context,
      builder: (BuildContext context) => AlertDialog(
        title: Text("तपाइको मोबाइल सेट " +
            sharedPreferences!.getString("firstName")! +
            " , " +
            sharedPreferences!.getString("username")! +
            " भेरिफाई भएको छ ।"),
        content: Text("सच्याउन पर्ने भए एडमिनलाई सम्पर्क गर्नुहोला ।"),
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

  deviceIDChangeFailed() {
    showDialog<String>(
      context: context,
      builder: (BuildContext context) => AlertDialog(
        title: const Text("मोबाइल सेटको ID परिवर्तन हुन सकेन ।"),
        //Failed to change device ID
        content: const Text(
            "मोबाइल सेटको ID परिवर्तन गर्न असमर्थ । फेरि प्रायस गर्नुहोसा ।"),
        //Unable to change the Device ID. Please try again.
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

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: _onWillPop,
      child: Scaffold(
        appBar: AppBar(
          centerTitle: true,
          title: const Text("मोबाइल सेट भेरिफाइ"),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.white),
            onPressed: () {
              Route newRoute =
                  MaterialPageRoute(builder: (_) => const SettingsScreen());
              Navigator.pushReplacement(context, newRoute);
            },
          ),
          automaticallyImplyLeading: false,
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(30),
          child: Column(
            children: [
              Container(),
              const SizedBox(
                height: 40,
              ),
              Column(
                children: [
                  Text("हाल संचालनमा रहोको मोबाइल सेटको विवरण निम्नानुसार छः ",
                      style: TextStyle(fontSize: 20)),
                  Row(
                    children: [
                      Text("मोबाइल सेटको विवरण:",
                          style: TextStyle(fontSize: 18)),
                      Text(deviceID, style: TextStyle(fontSize: 18)),
                    ],
                  ),
                  const SizedBox(
                    height: 10,
                  ),
                  Text("नयाँ मोबाइल सेट परिवर्तन भएको हो ?",
                      style: TextStyle(fontSize: 20)),
                  const SizedBox(
                    height: 20,
                  ),
                  ElevatedButton(
                      onPressed: () {
                        const snackBar = SnackBar(
                          content: Text('मोबाइल सेटको ID परिवर्तन भइरहेको छ ।'),
                        );

                        // Find the ScaffoldMessenger in the widget tree
                        // and use it to show a SnackBar.
                        ScaffoldMessenger.of(context).showSnackBar(snackBar);
                        checkDeviceID();
                      },
                      child: const Text("पेश गर्नुहोस्")),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

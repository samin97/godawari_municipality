import 'package:flutter/material.dart';
import 'package:smart_attendance/main_screen/public_home/public_home_screen.dart';
import 'package:smart_attendance/main_screen/settings/update_device_id.dart';

import '../../global/global.dart';
import '../../global/widgets/app_button.dart';
import '../employee_home_screen.dart';
import 'change_password.dart';


class SettingsScreen extends StatefulWidget {
  const SettingsScreen({Key? key}) : super(key: key);

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  Future logoutNow() async {
    await sharedPreferences?.remove("email");
    Route newRoute = MaterialPageRoute(builder: (_) => const PublicHomeScreen(
      pageIndex: 4,
    ));
    Navigator.pushReplacement(context, newRoute);
  }
  Future<bool> _onWillPop() async{
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

              IconButton(
                icon: const Icon(Icons.arrow_back, color: Colors.white),
                onPressed: () {
                  Route newRoute =
                  MaterialPageRoute(builder: (_) => const EmployeeHomeScreen());
                  Navigator.pushReplacement(context, newRoute);
                },
              ),
              const Text(
                'Settings',
                style: TextStyle(
                  fontSize: 30,
                  color: Colors.white,
                ),
              ),
              const SizedBox(width: 50,)
            ],
          ),
          centerTitle: true,
          automaticallyImplyLeading: false,
        ),
        body: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Padding(
                padding: EdgeInsets.all(12.0),
                child: Text("Accounts", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 42),),
              ),
              Padding(
                padding: const EdgeInsets.all(12.0),
                child: InkWell(
                  onTap: () {
                    Route newRoute =
                    MaterialPageRoute(builder: (_) => const ChangePassword());
                    Navigator.pushReplacement(context, newRoute);
                  },
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: const [
                      Text("पासवर्ड परिवर्तन गर्नुहोस्", style: TextStyle(fontSize: 20),),
                      Icon(
                        Icons.arrow_forward_ios,
                        color: Colors.grey,
                      )
                    ],
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(12.0),
                child: InkWell(
                  onTap: () {
                    Route newRoute =
                    MaterialPageRoute(builder: (_) => const UpdateDeviceID());
                    Navigator.pushReplacement(context, newRoute);
                  },
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: const [
                      Text("मोबाइल सेट भेरिफाइ गर्नुहोस्", style: TextStyle(fontSize: 20),),
                      Icon(
                        Icons.arrow_forward_ios,
                        color: Colors.grey,
                      )
                    ],
                  ),
                ),
              ),
              const Divider(
                thickness: 2,
              ),

              Padding(
                padding: const EdgeInsets.all(12.0),
                child: AppButton(
                  textColour: Colors.black54,
                  textSize: 22,
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
            ],
          ),
        ),
      ),
    );
  }
}

import 'dart:convert';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:smart_attendance/main_screen/settings/settings.dart';

import '../../global/global.dart';
import '../../global/widgets/error_dialog.dart';
import '../../models/login_model.dart';
import '../employee_home_screen.dart';

class ChangePassword extends StatefulWidget {
  const ChangePassword({Key? key}) : super(key: key);

  @override
  State<ChangePassword> createState() => _ChangePasswordState();
}

class _ChangePasswordState extends State<ChangePassword> {
  TextEditingController passwordController = TextEditingController();
  TextEditingController conformPasswordController = TextEditingController();

  formValidation() {
    if (passwordController.text.isNotEmpty &&
        conformPasswordController.text.isNotEmpty) {
      if (passwordController.text == conformPasswordController.text) {
        checkConnection();
      } else {
        showDialog(
            context: context,
            builder: (c) {
              return const ErrorDialog(
                message: "पासवर्डहरु मिलेन ।",
              );
            });
      }
    } else {
      showDialog(
          context: context,
          builder: (c) {
            return const ErrorDialog(
              message: "कृपया दुबै पासवर्ड भर्नुहोस् ।",
            );
          });
    }
  }

  Future checkConnection() async {
    var connectivityResult = await (Connectivity().checkConnectivity());
    if (connectivityResult == ConnectivityResult.mobile) {
      loginNow();
    } else if (connectivityResult == ConnectivityResult.wifi) {
      showLoaderDialog(context);
      loginNow();
    } else {
      showDialog<String>(
        context: context,
        builder: (BuildContext context) => AlertDialog(
          title: const Text("तपाईं अफलाइन हुनुहुन्छ ।"),
          content: const Text("तपाईं अफलाइन हुनुहुन्छ । तपाईंको इन्टरनेटमा कनेक्सन चेक गर्नुहोस् ।"),
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

  passwordChangeFailed() {
    showDialog<String>(
      context: context,
      builder: (BuildContext context) => AlertDialog(
        title: const Text("पासवर्ड परिवर्तन हुन सकेन ।"),
        content: const Text("पासवर्ड परिवर्तन हुन सकेन । पुनःप्रयास गर्नुहोस ।"),
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

  Future loginNow() async {
    LoginModel user = LoginModel(username: '', password: '');
    setState(() {
      user.username = sharedPreferences!.getString("username");
      user.password = passwordController.text;
    });
    var response = await http.post(
        Uri.parse("http://mis.godawarimun.gov.np/Api/Auth/ChangePassword"),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8'
        },
        body: jsonEncode(user));

    if (response.statusCode == 200) {
      const snackBar = SnackBar(
        content: Text('Password has been changed.'),
      );
      ScaffoldMessenger.of(context).showSnackBar(snackBar);
      Route newRoute = MaterialPageRoute(builder: (_) => const HomeScreen());
      Navigator.pushReplacement(context, newRoute);
    } else {
      passwordChangeFailed();
    }
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
          title: const Text("पासवर्ड परिवर्तन"),
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
                  TextField(
                    decoration: InputDecoration(
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(5.0),
                        ),
                        hintText: 'नया पासवर्ड'),
                    controller: passwordController,
                    obscureText: true,
                  ),
                  const SizedBox(
                    height: 10,
                  ),
                  TextField(
                    decoration: InputDecoration(
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(5.0),
                      ),
                      hintText: 'पुन नयाँ पासवर्ड',
                    ),
                    controller: conformPasswordController,
                    obscureText: true,
                  ),
                  const SizedBox(
                    height: 20,
                  ),
                  ElevatedButton(
                      onPressed: () {
                        const snackBar = SnackBar(
                          content: Text('changing password'),
                        );

                        // Find the ScaffoldMessenger in the widget tree
                        // and use it to show a SnackBar.
                        ScaffoldMessenger.of(context).showSnackBar(snackBar);
                        formValidation();
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

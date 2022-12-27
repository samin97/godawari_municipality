import 'dart:convert';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:municpality_app/main_screen/attendance/offline_home.dart';
import '../global/widgets/error_dialog.dart';
import '../global/global.dart';
import '../main_screen/home_screen.dart';
import '../models/login_model.dart';
import '../models/login_response_model.dart';

class Login extends StatefulWidget {
  const Login({Key? key}) : super(key: key);

  @override
  State<Login> createState() => _LoginState();
}

class _LoginState extends State<Login> {
  TextEditingController usernameController = TextEditingController();
  TextEditingController passwordController = TextEditingController();

  offlineLogin() {
    if (usernameController.text.isNotEmpty &&
        passwordController.text.isNotEmpty) {
      checkIfOffline();
    } else {
      showDialog(
          context: context,
          builder: (c) {
            return const ErrorDialog(
              message: "Please write email/password",
            );
          });
    }
  }

  loginOffline() {
    if (usernameController.text == sharedPreferences!.getString("username")! &&
        passwordController.text == sharedPreferences!.getString("password")!) {
      Route newRoute = MaterialPageRoute(builder: (_) => const OfflineHome());
      Navigator.pushReplacement(context, newRoute);
      const snackBar = SnackBar(
        content: Text('Logging in offline'),
      );
      ScaffoldMessenger.of(context).showSnackBar(snackBar);
    } else {
      failedSignIn();
    }
  }

  Future checkIfOffline() async {
    var connectivityResult = await (Connectivity().checkConnectivity());
    if (connectivityResult == ConnectivityResult.mobile) {
      showDialog<String>(
        context: context,
        builder: (BuildContext context) => AlertDialog(
          title: const Text("You are online."),
          content: const Text("Please login through online."),
          actions: [
            TextButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                child: const Text("Conform"))
          ],
        ),
      );
    } else if (connectivityResult == ConnectivityResult.wifi) {
      showDialog<String>(
        context: context,
        builder: (BuildContext context) => AlertDialog(
          title: const Text("You are online."),
          content: const Text("Please login through online."),
          actions: [
            TextButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                child: const Text("Conform"))
          ],
        ),
      );
    } else {
      loginOffline();
      //localStorage();
    }
  }

  formValidation() {
    if (usernameController.text.isNotEmpty &&
        passwordController.text.isNotEmpty) {
      checkConnection();
    } else {
      showDialog(
          context: context,
          builder: (c) {
            return const ErrorDialog(
              message: "Please write email/password",
            );
          });
    }
  }

  Future checkConnection() async {
    var connectivityResult = await (Connectivity().checkConnectivity());
    if (connectivityResult == ConnectivityResult.mobile) {
      loginNow();
    } else if (connectivityResult == ConnectivityResult.wifi) {
      loginNow();
    } else {
      showDialog<String>(
        context: context,
        builder: (BuildContext context) => AlertDialog(
          title: const Text("You are offline."),
          content: const Text("Internet connection is required to login."),
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

  failedSignIn() {
    showDialog<String>(
      context: context,
      builder: (BuildContext context) => AlertDialog(
        title: const Text("Sign in failed."),
        content: const Text("User name or password is entered incorrectly."),
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
      user.username = usernameController.text;
      user.password = passwordController.text;
    });
    var response = await http.post(
        Uri.parse("http://mis.godawarimun.gov.np/Api/Auth/Authenticate"),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8'
        },
        body: jsonEncode(user));

    if (response.statusCode == 200) {
      showLoaderDialog(context);
      LoginResponseModel userDetails =
          LoginResponseModel.fromJson(jsonDecode(response.body));
      print(userDetails.meters);
      await sharedPreferences?.setString(
          "token", userDetails.tokenString as String);
      await sharedPreferences?.setString(
          "username", userDetails.username!);
      await sharedPreferences?.setString(
          "firstName", userDetails.firstName ?? "First Name");
      await sharedPreferences?.setString(
          "nepaliName", userDetails.nepaliName ?? "nepali name");
      await sharedPreferences?.setString(
          "latitude", userDetails.latitude ?? "latitude");
      await sharedPreferences?.setString(
          "longitude", userDetails.longitude ?? "longitude");
      await sharedPreferences?.setString("deviceId", userDetails.deviceId ?? 'deviceID');
      await sharedPreferences?.setString(
          "permittedDistance", userDetails.meters ?? "meters");
      await sharedPreferences?.setString("role", userDetails.role ?? "role");

      await sharedPreferences?.setString("password", passwordController.text);
      await sharedPreferences?.setString("username", usernameController.text);
      print(sharedPreferences!.getString("password")!);
      print(sharedPreferences!.getString("username")!);
      print(userDetails);
      Route newRoute = MaterialPageRoute(builder: (_) => const HomeScreen());
      Navigator.pushReplacement(context, newRoute);
    } else {
      failedSignIn();
    }
  }

  Future<bool> _onWillPop() async {
    return (await showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Are you sure?'),
            content: const Text('Do you want to exit an App'),
            actions: <Widget>[
              TextButton(
                onPressed: () => Navigator.of(context).pop(false),
                child: const Text('No'),
              ),
              TextButton(
                onPressed: () => Navigator.of(context).pop(true),
                child: const Text('Yes'),
              ),
            ],
          ),
        )) ??
        false;
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: _onWillPop,
      child: Scaffold(
        appBar: AppBar(
          centerTitle: true,
          title: const Text("Login"),
          automaticallyImplyLeading: false,
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(30),
          child: Column(
            children: [
              Container(),
              Image.asset(
                'images/logo.jpg',
                fit: BoxFit.contain,
                height: 120,
              ),
              const SizedBox(
                height: 30,
              ),
              Column(
                children: [
                  TextField(
                    decoration: InputDecoration(
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(5.0),
                        ),
                        hintText: 'User ID'),
                    controller: usernameController,
                  ),
                  const SizedBox(
                    height: 10,
                  ),
                  TextField(
                    decoration: InputDecoration(
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(5.0),
                      ),
                      hintText: 'Password',
                    ),
                    controller: passwordController,
                    obscureText: true,
                  ),
                  const SizedBox(
                    height: 20,
                  ),
                  ElevatedButton(
                      onPressed: () {
                        const snackBar = SnackBar(
                          content: Text('Logging in'),
                        );
                        ScaffoldMessenger.of(context).showSnackBar(snackBar);
                        formValidation();
                      },
                      child: const Text("Log In")),
                  const Divider(
                    thickness: 4,
                  ),
                  ElevatedButton(
                      onPressed: () {
                        offlineLogin();
                      },
                      child: const Text("Offline login")),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}












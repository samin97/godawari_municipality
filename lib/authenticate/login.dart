import 'dart:convert';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
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
      showLoaderDialog(context);
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
      LoginResponseModel userDetails =
          LoginResponseModel.fromJson(jsonDecode(response.body));
      await sharedPreferences?.setString("token", userDetails.tokenString);
      await sharedPreferences?.setString("username", userDetails.username);
      await sharedPreferences?.setString("firstName", userDetails.firstName);
      await sharedPreferences?.setString("nepaliName", userDetails.nepaliName);
      await sharedPreferences?.setString("latitude", userDetails.latitude);
      await sharedPreferences?.setString("longitude", userDetails.longitude);
      await sharedPreferences?.setString("permittedDistance", "20");
      await sharedPreferences?.setString("role", userDetails.role);
      print(userDetails);
      Route newRoute = MaterialPageRoute(builder: (_) => const HomeScreen());
      Navigator.pushReplacement(context, newRoute);
    } else {
      failedSignIn();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
              'images/logo.png',
              fit: BoxFit.contain,
              height: 52,
            ),
            const SizedBox(
              height: 20,
            ),
            Column(
              children: [
                TextField(
                  decoration: InputDecoration(
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(20.0),
                      ),
                      hintText: 'User Name'),
                  controller: usernameController,
                ),
                const SizedBox(
                  height: 10,
                ),
                TextField(
                  decoration: InputDecoration(
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(20.0),
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
              ],
            ),
          ],
        ),
      ),
    );
  }
}

import 'dart:convert';
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
      loginNow();
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
      await sharedPreferences?.setString("role", userDetails.role);
      Route newRoute = MaterialPageRoute(builder: (_) => const HomeScreen());
      Navigator.pushReplacement(context, newRoute);
    } else {
      showDialog(
          context: context,
          builder: (c) {
            return const ErrorDialog(
              message: "Login Failed",
            );
          });
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
              const CircleAvatar(
              radius: 50,
              backgroundColor: Colors.transparent,
              backgroundImage: NetworkImage(
                  "https://myrepublica.nagariknetwork.com/uploads/media/Governmentlogo_20200312190212.jpg"),
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
                        ), hintText: 'User Name'),
                    controller: usernameController,
                  ),
                  const SizedBox(
                    height: 10,
                  ),
                  TextField(
                    decoration:  InputDecoration(
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

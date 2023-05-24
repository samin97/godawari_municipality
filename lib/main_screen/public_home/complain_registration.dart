import 'dart:convert';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';

import 'package:http/http.dart' as http;
import 'package:smart_attendance/models/complain_model.dart';

import '../../global/widgets/error_dialog.dart';
import '../landing_screen.dart';

class ComplainRegistration extends StatefulWidget {
  const ComplainRegistration({Key? key}) : super(key: key);

  @override
  State<ComplainRegistration> createState() => _ComplainRegistrationState();
}

class _ComplainRegistrationState extends State<ComplainRegistration> {
  TextEditingController senderNameController = TextEditingController();
  TextEditingController phoneController = TextEditingController();
  TextEditingController emailController = TextEditingController();
  TextEditingController topicController = TextEditingController();
  TextEditingController detailsController = TextEditingController();

  formValidation() {
    if (senderNameController.text.isNotEmpty &&
        phoneController.text.isNotEmpty &&
        topicController.text.isNotEmpty &&
        detailsController.text.isNotEmpty) {
      checkConnection();
    } else {
      showDialog(
          context: context,
          builder: (c) {
            return const ErrorDialog(
              message: "Please fill all details",
            );
          });
    }
  }

  Future checkConnection() async {
    var connectivityResult = await (Connectivity().checkConnectivity());
    if (connectivityResult == ConnectivityResult.mobile) {
      sendComplain();
    } else if (connectivityResult == ConnectivityResult.wifi) {
      sendComplain();
    } else {
      showDialog<String>(
        context: context,
        builder: (BuildContext context) => AlertDialog(
          title: const Text("You are offline."),
          content:
              const Text("Internet connection is required to send gunaso."),
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

  failedPost() {
    showDialog<String>(
      context: context,
      builder: (BuildContext context) => AlertDialog(
        title: const Text("Failed to send gunso."),
        content: const Text("Please try again later."),
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

  Future sendComplain() async {
    ComplainModel complainModel = ComplainModel(
        pathaunekoName: "pathaunekoName",
        phoneNo: "phoneNo",
        email: "email",
        gunasoKoBisaya: "gunasoKoBisaya",
        gunasoKoBibaran: "gunasoKoBibaran");
    setState(() {
      complainModel.pathaunekoName = senderNameController.text;
      complainModel.phoneNo = phoneController.text;
      complainModel.email = emailController.text;
      complainModel.gunasoKoBisaya = topicController.text;
      complainModel.gunasoKoBibaran = detailsController.text;
    });
    var response = await http.post(
        Uri.parse("http://mis.godawarimun.gov.np/Api/Auth/Authenticate"),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8'
        },
        body: jsonEncode(complainModel));

    if (response.statusCode == 200) {
      showLoaderDialog(context);

      const snackBar = SnackBar(
        content: Text('Complain sent.'),
      );
      ScaffoldMessenger.of(context).showSnackBar(snackBar);
    } else {
      failedPost();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            const Text(
              'Grievance registration',
              style: TextStyle(
                fontSize: 30,
                color: Colors.white,
              ),
            ),
            SizedBox(width: 10,)
          ],
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () {
            Route newRoute =
            MaterialPageRoute(builder: (_) => const LandingScreen());
            Navigator.pushReplacement(context, newRoute);
          },
        ),

        centerTitle: true,
        automaticallyImplyLeading: false,
      ),
      body: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(
                "Any personal information that could identify you will be removed or changed before files are shared with other researchers or results are made public. Your information is take to contact you if necessary. Please feel free to submit your grievance in the form below.",
                textAlign: TextAlign.justify,
              ),
            ),
            TextField(
              decoration: InputDecoration(
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(5.0),
                  ),
                  hintText: 'Your name'),
              controller: senderNameController,
            ),
            const SizedBox(
              height: 10,
            ),
            TextField(
              decoration: InputDecoration(
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(5.0),
                  ),
                  hintText: 'Email'),
              controller: emailController,
            ),
            const SizedBox(
              height: 10,
            ),
            TextField(
              decoration: InputDecoration(
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(5.0),
                  ),
                  hintText: 'Phone number'),
              controller: phoneController,
            ),
            const SizedBox(
              height: 20,
            ),
            TextField(
              decoration: InputDecoration(
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(5.0),
                  ),
                  hintText: 'Gunaso ko bisaya'),
              controller: topicController,
            ),
            const SizedBox(
              height: 10,
            ),
            TextField(
              keyboardType: TextInputType.multiline,
              maxLines: 4,
              decoration: InputDecoration(
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(5.0),
                  ),
                  hintText: 'Gunaso ko bibaran'),
              controller: detailsController,
            ),
            const SizedBox(
              height: 10,
            ),
            ElevatedButton(
                onPressed: () {
                  const snackBar = SnackBar(
                    content: Text('Sending complain'),
                  );
                  ScaffoldMessenger.of(context).showSnackBar(snackBar);
                  formValidation();
                },
                child: const Text("Send")),

            // ElevatedButton(
            //     onPressed: () {
            //       offlineLogin();
            //     },
            //     child: const Text("Offline login")),
          ],
        ),
      ),
    );
  }
}

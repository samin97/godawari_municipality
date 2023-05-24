import 'package:flutter/material.dart';

class AboutApp extends StatefulWidget {
  const AboutApp({Key? key}) : super(key: key);

  @override
  State<AboutApp> createState() => _AboutAppState();
}

class _AboutAppState extends State<AboutApp> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              'About App',
              style: TextStyle(
                fontSize: 30,
                color: Colors.white,
              ),
            ),
          ],
        ),
        centerTitle: true,
        automaticallyImplyLeading: false,
      ),
      body: Column(mainAxisAlignment: MainAxisAlignment.start, children: [
        Padding(
          padding: const EdgeInsets.all(20.0),
          child: Text(
            "This is an initiation for the digital service in the Municipality. This is designed for official and public use. "
            "Office employees will be able to perform different activities using the given credentials and public users will be able to find public events published by Godawari Municipality and Grievance registration for now."
            "The personal information of the grievance registrant will be kept secret and unpublished. Further, we are working on the integration of other services in this App. Any suggestions, feedback, or grievances will be highly appreciated. Thank you.  ",
            textAlign: TextAlign.justify,
          ),
        ),
      ]),
    );
  }
}

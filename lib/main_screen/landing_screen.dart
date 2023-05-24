import 'package:flutter/material.dart';
import 'package:smart_attendance/main_screen/public_home/public_home_screen.dart';

class LandingScreen extends StatefulWidget {
  const LandingScreen({Key? key}) : super(key: key);

  @override
  State<LandingScreen> createState() => _LandingScreenState();
}

class _LandingScreenState extends State<LandingScreen> {
  Future<bool> _onWillPop() async {
    return false;
  }

  double h1 = 120;
  double w1 = 120;

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
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
                ],
              ),
              centerTitle: true,
              automaticallyImplyLeading: false,
            ),
            body: Column(mainAxisAlignment: MainAxisAlignment.start, children: [
              SizedBox(height: 20),
              Row(mainAxisAlignment: MainAxisAlignment.spaceEvenly, children: [
                Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: InkWell(
                    onTap: () {
                      Route newRoute = MaterialPageRoute(
                          builder: (_) => const PublicHomeScreen(
                                pageIndex: 0,
                              ));
                      Navigator.pushReplacement(context, newRoute);
                    },
                    child: Card(
                      child: Container(
                        height: h1,
                        width: w1,
                        child: Padding(
                          padding: const EdgeInsets.all(10.0),
                          child: Column(
                            children: [
                              Icon(
                                Icons.event,
                                size: 80,
                                color: Colors.blueAccent,
                              ),
                              Text("इभेन्टस्")
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: InkWell(
                    onTap: () {
                      Route newRoute = MaterialPageRoute(
                          builder: (_) => const PublicHomeScreen(
                                pageIndex: 1,
                              ));
                      Navigator.pushReplacement(context, newRoute);
                    },
                    child: Card(
                      child: Container(
                        height: h1,
                        width: w1,
                        child: Padding(
                          padding: const EdgeInsets.all(10.0),
                          child: Column(
                            children: [
                              Icon(
                                Icons.question_answer_outlined,
                                size: 80,
                                color: Colors.blueAccent,
                              ),
                              Text("गुनासो दर्ता")
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ]),
              SizedBox(height: 20),
              Row(mainAxisAlignment: MainAxisAlignment.spaceEvenly, children: [
                Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: InkWell(
                    onTap: () {
                      Route newRoute = MaterialPageRoute(
                          builder: (_) => const PublicHomeScreen(
                                pageIndex: 2,
                              ));
                      Navigator.pushReplacement(context, newRoute);
                    },
                    child: Card(
                      child: Container(
                        height: h1,
                        width: w1,
                        child: Padding(
                          padding: const EdgeInsets.all(10.0),
                          child: Column(
                            children: [
                              Icon(
                                Icons.home_repair_service_outlined,
                                size: 80,
                                color: Colors.blueAccent,
                              ),
                              Text("नगरिक बडापत्र")
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: InkWell(
                    onTap: () {
                      Route newRoute = MaterialPageRoute(
                          builder: (_) => const PublicHomeScreen(
                                pageIndex: 3,
                              ));
                      Navigator.pushReplacement(context, newRoute);
                    },
                    child: Card(
                      child: Container(
                        height: h1,
                        width: w1,
                        child: Padding(
                          padding: const EdgeInsets.all(10.0),
                          child: Column(
                            children: [
                              Icon(
                                Icons.login_outlined,
                                size: 80,
                                color: Colors.blueAccent,
                              ),
                              Text("लगिन")
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ]),
              SizedBox(
                height: 20,
              ),
              Row(mainAxisAlignment: MainAxisAlignment.spaceEvenly, children: [
                Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: InkWell(
                    onTap: () {
                      Route newRoute = MaterialPageRoute(
                          builder: (_) => const PublicHomeScreen(
                                pageIndex: 4,
                              ));
                      Navigator.pushReplacement(context, newRoute);
                    },
                    child: Card(
                      child: Container(
                        height: h1,
                        width: w1,
                        child: Padding(
                          padding: const EdgeInsets.all(10.0),
                          child: Column(
                            children: [
                              Icon(
                                Icons.info_outline,
                                size: 80,
                                color: Colors.blueAccent,
                              ),
                              Text("एपको बारेमा")
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ])
            ])),
        onWillPop: _onWillPop);
  }
}

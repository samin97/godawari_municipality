import 'package:flutter/material.dart';
import 'package:smart_attendance/main_screen/kaaj/user/request_kaaj.dart';
import '../../employee_home_screen.dart';
import 'get_approved_kaaj.dart';
import 'get_canceled_kaaj.dart';

class Kaaj extends StatefulWidget {
  const Kaaj({Key? key}) : super(key: key);

  @override
  _KaajState createState() => _KaajState();
}

class _KaajState extends State<Kaaj> {

  Future<bool> _onWillPop() async{
    return false;
  }
  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: _onWillPop,
      child: DefaultTabController(
          length: 2,
          child: Scaffold(
            appBar: AppBar(
              automaticallyImplyLeading: false,
              title: const Text(
                'काज',
                style: TextStyle(
                  fontSize: 30,
                  color: Colors.white,
                ),
              ),
              centerTitle: true,
              leading: IconButton(
                icon: const Icon(Icons.arrow_back, color: Colors.white),
                onPressed: () {
                  Route newRoute =
                      MaterialPageRoute(builder: (_) => const HomeScreen());
                  Navigator.pushReplacement(context, newRoute);
                },
              ),
              bottom: const TabBar(
                tabs: [
                  Tab(
                    icon: Icon(
                      Icons.check,
                      color: Colors.white,
                    ),
                    text: "स्वीकृत काज",
                  ),
                  Tab(
                    icon: Icon(
                      Icons.cancel,
                      color: Colors.white,
                    ),
                    text: "अस्वीकृत काज",
                  ),
                ],
                indicatorColor: Colors.white38,
                indicatorWeight: 7,
              ),
            ),
            body: const TabBarView(
              children: [
                ApprovedKaaj(),
                CanceledKaaj(),
              ],
            ),
            floatingActionButton: FloatingActionButton(
              onPressed: () {
                Route newRoute =
                    MaterialPageRoute(builder: (_) => const RequestKaaj());
                Navigator.pushReplacement(context, newRoute);
              },
              child: RichText(
                text: const TextSpan(
                  children: [
                    TextSpan(
                      text: "नयाँ  ",
                    ),
                    WidgetSpan(
                      child: Icon(Icons.add, size: 14),
                    ),
                  ],
                ),
              ),
            ),
          )),
    );
  }
}

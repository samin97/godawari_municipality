
import 'package:flutter/material.dart';

import '../home_screen.dart';
import 'checkin_attendance.dart';
import 'checkout_attendance.dart';

class AttendanceCategory extends StatefulWidget {
  const AttendanceCategory({Key? key}) : super(key: key);

  @override
  _AttendanceCategoryState createState() => _AttendanceCategoryState();
}

class _AttendanceCategoryState extends State<AttendanceCategory> {


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
                'Attendance',
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
                    icon: Icon(Icons.login_sharp, color: Colors.white,),
                    text: "Check-in",
                  ),
                  Tab(
                    icon: Icon(Icons.logout_sharp, color: Colors.white,),
                    text: "Checkout",
                  )
                ],
                indicatorColor: Colors.white38,
                indicatorWeight: 7,

              ),
            ),
            body: Container(
              decoration: const BoxDecoration(
              ),
              child:   TabBarView(
                children: [
                  AttendanceCheckIn(),
                  AttendanceCheckOut()
                ],
              ),
            ),
          )
      ),
    );
  }
}
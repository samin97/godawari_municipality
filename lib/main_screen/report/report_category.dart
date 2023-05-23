
import 'package:flutter/material.dart';
import 'package:smart_attendance/main_screen/report/yearly_report.dart';

import '../employee_home_screen.dart';
import 'monthly_report.dart';

class ReportCategory extends StatefulWidget {
  const ReportCategory({Key? key}) : super(key: key);

  @override
  _ReportCategoryState createState() => _ReportCategoryState();
}

class _ReportCategoryState extends State<ReportCategory> {
  @override
  Future<bool> _onWillPop() async{
    return false;
  }
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: _onWillPop,
      child: DefaultTabController(
          length: 2,
          child: Scaffold(
            appBar: AppBar(
              automaticallyImplyLeading: false,
              title: const Text(
                'हाजिरीको प्रतिवेदन',
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
                      Icons.calendar_month_outlined,
                      color: Colors.white,
                    ),
                    text: "मासिक विवरण ",
                  ),
                  Tab(
                    icon: Icon(
                      Icons.calendar_month_outlined,
                      color: Colors.white,
                    ),
                    text: "बार्षिक विवरण",
                  )
                ],
                indicatorColor: Colors.white38,
                indicatorWeight: 7,
              ),
            ),
            body: Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.white70,
                    Colors.white,
                  ],
                ),
              ),
              child:   TabBarView(
                children: [
                  ReportMonth(),
                  ReportYear(),
                ],
              ),
            ),
          )),
    );
  }
}

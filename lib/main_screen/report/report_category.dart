
import 'package:flutter/material.dart';
import 'package:municpality_app/main_screen/report/yearly_report.dart';

import '../home_screen.dart';
import 'monthly_report.dart';

class ReportCategory extends StatefulWidget {
  const ReportCategory({Key? key}) : super(key: key);

  @override
  _ReportCategoryState createState() => _ReportCategoryState();
}

class _ReportCategoryState extends State<ReportCategory> {
  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
        length: 2,
        child: Scaffold(
          appBar: AppBar(
            automaticallyImplyLeading: false,
            title: const Text(
              'Report',
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
                  text: "Monthly",
                ),
                Tab(
                  icon: Icon(
                    Icons.calendar_month_outlined,
                    color: Colors.white,
                  ),
                  text: "Yearly",
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
            child:  const TabBarView(
              children: [
                ReportMonth(),
                ReportYear(),
              ],
            ),
          ),
        ));
  }
}

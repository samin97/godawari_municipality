
import 'package:flutter/material.dart';
import 'package:smart_attendance/main_screen/leave/user/post_leave.dart';
import 'package:smart_attendance/main_screen/leave/user/rejected_leave.dart';
import '../../home_screen.dart';
import 'all_leave.dart';
import 'approved_leave.dart';

class LeaveCategory extends StatefulWidget {
  const LeaveCategory({Key? key}) : super(key: key);

  @override
  _LeaveCategoryState createState() => _LeaveCategoryState();
}

class _LeaveCategoryState extends State<LeaveCategory> {
  Future<bool> _onWillPop() async{
    return false;
  }
  @override
  Widget build(BuildContext context) {
    return WillPopScope(

      onWillPop: _onWillPop,
      child: DefaultTabController(
          length: 3,
          child: Scaffold(
            appBar: AppBar(
              automaticallyImplyLeading: false,
              title: const Text(
                'बिदा विवरण',
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
                      Icons.all_inbox_rounded,
                      color: Colors.white,
                    ),
                    text: "सबै बिदाहरु",
                  ),
                  Tab(
                    icon: Icon(
                      Icons.check,
                      color: Colors.white,
                    ),
                    text: "स्वीकृत बिदाहरु",
                  ),
                  Tab(
                    icon: Icon(
                      Icons.cancel_outlined,
                      color: Colors.white,
                    ),
                    text: "अस्वीकृत बिदाहरु",
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
                  AllLeave(),
                  ApprovedLeave(),
                  CanceledLeave(),
                ],
              ),
            ),
            floatingActionButton: FloatingActionButton(
              onPressed: () {
                Route newRoute =
                    MaterialPageRoute(builder: (_) => const LeaveForm());
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

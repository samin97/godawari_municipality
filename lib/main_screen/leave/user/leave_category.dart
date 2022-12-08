
import 'package:flutter/material.dart';
import 'package:municpality_app/main_screen/leave/user/post_leave.dart';
import 'package:municpality_app/main_screen/leave/user/rejected_leave.dart';
import '../../home_screen.dart';
import 'all_leave.dart';
import 'approved_leave.dart';

class LeaveCategory extends StatefulWidget {
  const LeaveCategory({Key? key}) : super(key: key);

  @override
  _LeaveCategoryState createState() => _LeaveCategoryState();
}

class _LeaveCategoryState extends State<LeaveCategory> {
  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
        length: 3,
        child: Scaffold(
          appBar: AppBar(
            automaticallyImplyLeading: false,
            title: const Text(
              'Leave',
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
                  text: "All",
                ),
                Tab(
                  icon: Icon(
                    Icons.check,
                    color: Colors.white,
                  ),
                  text: "Approved",
                ),
                Tab(
                  icon: Icon(
                    Icons.cancel_outlined,
                    color: Colors.white,
                  ),
                  text: "Canceled",
                )
              ],
              indicatorColor: Colors.white38,
              indicatorWeight: 7,
            ),
          ),
          body: Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topRight,
                end: Alignment.bottomLeft,
                colors: [
                  Colors.white,
                  Colors.indigoAccent,
                ],
              ),
            ),
            child:  const TabBarView(
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
                    text: "New ",
                  ),
                  WidgetSpan(
                    child: Icon(Icons.add, size: 14),
                  ),
                ],
              ),
            ),
          ),
        ));
  }
}

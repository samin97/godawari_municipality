import 'package:flutter/material.dart';
import 'package:municpality_app/main_screen/kaaj/user/get_approved_kaaj.dart';
import 'package:municpality_app/main_screen/kaaj/user/request_kaaj.dart';
import '../../home_screen.dart';

class Kaaj extends StatefulWidget {
  const Kaaj({Key? key}) : super(key: key);

  @override
  _KaajState createState() => _KaajState();
}

class _KaajState extends State<Kaaj> {
  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
        length: 2,
        child: Scaffold(
          appBar: AppBar(
            automaticallyImplyLeading: false,
            title: const Text(
              'Kaaj',
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
                  text: "Request Kaaj",
                ),
                Tab(
                  icon: Icon(
                    Icons.check,
                    color: Colors.white,
                  ),
                  text: "Approved Kaaj",
                ),
              ],
              indicatorColor: Colors.white38,
              indicatorWeight: 7,
            ),
          ),
          body: const TabBarView(
            children: [
              ApprovedKaaj(),
              ApprovedKaaj(),
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

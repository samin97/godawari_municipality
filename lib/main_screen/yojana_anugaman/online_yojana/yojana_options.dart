import 'package:flutter/material.dart';
import 'package:smart_attendance/main_screen/yojana_anugaman/online_yojana/yojana_main.dart';
import '../../employee_home_screen.dart';
import '../../public_home/employee_login.dart';
import '../yojana_report/yojana_report.dart';
import 'online_draft_list.dart';
class YojanaOptions extends StatefulWidget {
  const YojanaOptions({Key? key}) : super(key: key);

  @override
  State<YojanaOptions> createState() => _YojanaOptionsState();
}

class _YojanaOptionsState extends State<YojanaOptions> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            IconButton(
                onPressed: () {
                  Route newRoute =
                  MaterialPageRoute(builder: (_) => const YojanaMain());
                  Navigator.pushReplacement(context, newRoute);
                },
                icon: const Icon(
                  Icons.arrow_back,
                  color: Colors.white,
                )),
            const Text(
              "Yojana Options",
              style: TextStyle(color: Colors.white, fontSize: 24),
            ),
            const SizedBox(
              width: 10,
            )
          ],
        ),
      ),
      body: Column(
        children: [

          Padding(
            padding: const EdgeInsets.all(12.0),
            child: InkWell(
              onTap: () {
                Route newRoute =
                MaterialPageRoute(builder: (_) => const OnlineDraftList());
                Navigator.pushReplacement(context, newRoute);
              },
              child: Container(
                padding: EdgeInsets.all(20),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.black45),
                  borderRadius: BorderRadius.circular(5)
                ),
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text("Your Drafts", style: TextStyle(fontSize: 20),),
                    Icon(
                      Icons.arrow_forward_ios,
                      color: Colors.grey,
                    )
                  ],
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: InkWell(
              onTap: () {
                Route newRoute =
                MaterialPageRoute(builder: (_) => const YojanaReportList());
                Navigator.pushReplacement(context, newRoute);
              },
              child: Container(
                padding: EdgeInsets.all(20),
                decoration: BoxDecoration(
                    border: Border.all(color: Colors.black45),
                    borderRadius: BorderRadius.circular(5)
                ),
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text("Report", style: TextStyle(fontSize: 20),),
                    Icon(
                      Icons.arrow_forward_ios,
                      color: Colors.grey,
                    )
                  ],
                ),
              ),
            ),
          ),


        ],
      ),
    );
  }
}



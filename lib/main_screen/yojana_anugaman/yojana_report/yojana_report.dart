import 'package:flutter/material.dart';
import 'package:smart_attendance/main_screen/yojana_anugaman/yojana_report/pending_report.dart';
import 'package:smart_attendance/main_screen/yojana_anugaman/yojana_report/yojana_report_card.dart';
import 'package:smart_attendance/main_screen/yojana_anugaman/yojana_report/yojana_report_details.dart';
import 'package:smart_attendance/main_screen/yojana_anugaman/yojana_report/your_report.dart';

import '../../../global/provider/fetch_yojana.dart';
import '../../../models/yojana_report_model.dart';
import '../online_yojana/yojana_options.dart';

class YojanaReportList extends StatefulWidget {
  const YojanaReportList({Key? key}) : super(key: key);

  @override
  State<YojanaReportList> createState() => _YojanaReportListState();
}

class _YojanaReportListState extends State<YojanaReportList> {


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
                "Yojana report",
                style: TextStyle(color: Colors.white, fontSize: 24),
              ),
              centerTitle: true,
              leading: IconButton(
                  onPressed: () {
                    Route newRoute =
                    MaterialPageRoute(builder: (_) => const YojanaOptions());
                    Navigator.pushReplacement(context, newRoute);
                  },
                  icon: const Icon(
                    Icons.arrow_back,
                    color: Colors.white,
                  )),
              bottom: const TabBar(
                tabs: [
                  Tab(
                    icon: Icon(Icons.document_scanner_rounded, color: Colors.white,),
                    text: "Your reports",
                  ),
                  Tab(
                    icon: Icon(Icons.pending_actions, color: Colors.white,),
                    text: "Pending reports",
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
                  YourReports(),
                  PendingReports()
                ],
              ),
            ),
          )
      ),
    );
  }



}

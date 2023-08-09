import 'package:flutter/material.dart';
import 'package:smart_attendance/main_screen/yojana_anugaman/yojana_report/yojana_report_card.dart';
import 'package:smart_attendance/main_screen/yojana_anugaman/yojana_report/yojana_report_details.dart';

import '../../../global/provider/fetch_yojana.dart';
import '../../../models/yojana_report_model.dart';
class YourReports extends StatefulWidget {
  const YourReports({Key? key}) : super(key: key);

  @override
  State<YourReports> createState() => _YourReportsState();
}

class _YourReportsState extends State<YourReports> {
  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.max,
        children: [
          FutureBuilder<List<YojanaReportModel>>(
            future: fetchYojanaReport(),
            builder: (context, AsyncSnapshot snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(
                  child: CircularProgressIndicator(),
                );
              }
              print(snapshot.hasData);
              if (snapshot.hasData) {
                print(snapshot);
                List<YojanaReportModel> yojanaList = snapshot.data;

                return ListView.builder(
                    shrinkWrap: true,
                    physics:  const NeverScrollableScrollPhysics(),

                    itemCount: snapshot.data?.length ?? 0,
                    itemBuilder: (context, index) {
                      return InkWell(
                          onTap: () {
                            Route newRoute = MaterialPageRoute(
                                builder: (_) => YojanaReportDetails(
                                    id: yojanaList[index].id!
                                ));
                            Navigator.pushReplacement(context, newRoute);
                          },
                          child: YojanaReportCard( yojanaReportModel: yojanaList[index],));
                    });
              } else {
                return const Center(
                  child: Text("There is no yojana report assigned to you."),
                );
              }
            },
          ),
          SizedBox(height: 20,)
        ],
      ),
    );
  }
}

import 'package:flutter/material.dart';

import '../../../models/yojana_report_model.dart';
class YojanaReportCard extends StatefulWidget {

  final YojanaReportModel yojanaReportModel;
  const YojanaReportCard({Key? key, required this.yojanaReportModel}) : super(key: key);

  @override
  State<YojanaReportCard> createState() => _YojanaReportCardState();
}

class _YojanaReportCardState extends State<YojanaReportCard> {
  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.all(5),
      elevation: 1,
      child: Padding(
        padding: const EdgeInsets.symmetric(
            horizontal: 8, vertical: 4),
        child: Column(
          children: [
            const SizedBox(
              height: 10,
            ),

            Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                const Text("परामर्शदाताको प्रतिनिधि : "),
                Text(widget.yojanaReportModel.consultantReprisintive.toString())
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                const Text("योजनाको id : "),
                Text(widget.yojanaReportModel.budgetId.toString())
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                const Text("क्रम सङ्ख्या : "),
                Text(widget.yojanaReportModel.id.toString())
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                const Text("ख्रर्च शीर्षक न. : "),
                Text(widget.yojanaReportModel.budgetId.toString())
              ],
            ),
            //assignOfflineYojana(yojanaList[index]),
          ],
        ),
      ),
    );
  }
}


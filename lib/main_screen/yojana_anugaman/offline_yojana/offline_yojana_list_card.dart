import 'package:flutter/material.dart';

import '../../../models/yojana_details_model.dart';
class OfflineYojanaCard extends StatefulWidget {
  final YojanaModel yojanaModel;

  const OfflineYojanaCard({Key? key, required this.yojanaModel}) : super(key: key);

  @override
  State<OfflineYojanaCard> createState() => _OfflineYojanaCardState();
}

class _OfflineYojanaCardState extends State<OfflineYojanaCard> {

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
                const Text("योजनाको नाम : "),
                Text(widget.yojanaModel.activityName.toString())
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                const Text("क्रम सङ्ख्या : "),
                Text(widget.yojanaModel.serialNo.toString())
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                const Text("ख्रर्च शीर्षक न. : "),
                Text(widget.yojanaModel.karchaSrishak.toString())
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                const Text("ख्रर्च उपशीर्षक न. : "),
                Text(widget.yojanaModel
                    .kharchaUpaSirshak
                    .toString())
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                const Text("संकेत न. : "),
                Text(widget.yojanaModel.sanketNo.toString())
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                const Text("श्रोत : "),
                Text(widget.yojanaModel.sourceOfFund.toString())
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                const Text("खबजेटको किसिम : "),
                Text(widget.yojanaModel
                    .budgetBiniyojanType
                    .toString())
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                const Text("बार्षिक बजेट रु : "),
                Text(widget.yojanaModel.yearlyBudget.toString())
              ],
            ),
            //assignOfflineYojana(yojanaList[index]),
          ],
        ),
      ),
    );
  }
}


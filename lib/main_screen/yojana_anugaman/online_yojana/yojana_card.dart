import 'package:flutter/material.dart';

import '../../../local_db/entities/offline_yojana_list.dart';
import '../../../local_db/isarServices.dart';
import '../../../models/yojana_details_model.dart';
class YojanaCard extends StatefulWidget {
  final YojanaModel yojanaModel;

  const YojanaCard({Key? key, required this.yojanaModel}) : super(key: key);
  @override
  State<YojanaCard> createState() => _YojanaCardState();
}

class _YojanaCardState extends State<YojanaCard> {
  final service = IsarService();

  @override
  void initState() {
    // TODO: implement initState
    service.saveOfflineYojanas(OfflineYojana()
      ..yojanaId = widget.yojanaModel.id
      ..activityName = widget.yojanaModel.activityName.toString()
      ..serialNo = widget.yojanaModel.serialNo.toString()
      ..karchaSrishak = widget.yojanaModel.karchaSrishak.toString()
      ..kharchaUpaSirshak = widget.yojanaModel.kharchaUpaSirshak.toString()
      ..sanketNo = widget.yojanaModel.sanketNo.toString()
      ..sourceOfFund = widget.yojanaModel.sourceOfFund.toString()
      ..budgetBiniyojanType = widget.yojanaModel.budgetBiniyojanType.toString()
      ..planningProgram = widget.yojanaModel.planningProgram.toString()
      ..yearly = widget.yojanaModel.yearlyBudget.toString());
    super.initState();
  }


  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.all(5),
      elevation: 1,
      child: Padding(
        padding: const EdgeInsets.symmetric(
            horizontal: 8, vertical: 8),
        child: Column(
          children: [
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
                const Text("संचालन हुने वार्ड : "),
                Text("वार्ड 15" ?? widget.yojanaModel.activityName.toString())
              ],
            ),

            Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                const Text("बार्षिक बजेट: "),
                Text(widget.yojanaModel.yearlyBudget.toString())
              ],
            ),

          ]
        ),
      ),
    );
  }
}

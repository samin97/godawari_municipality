import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:smart_attendance/main_screen/yojana_anugaman/online_yojana/yojana_data_entry.dart';
import 'package:smart_attendance/main_screen/yojana_anugaman/online_yojana/yojana_main.dart';
import 'package:http/http.dart' as http;
import '../../../global/global.dart';
import '../../../models/add_member_model.dart';
import '../../../models/yojana_details_model.dart';


class YojanaDetails extends StatefulWidget {
  final YojanaModel yojanaModel;

  const YojanaDetails({Key? key, required this.yojanaModel}) : super(key: key);

  @override
  State<YojanaDetails> createState() => _YojanaDetailsState();
}

class _YojanaDetailsState extends State<YojanaDetails> {

  @override
  void initState() {
    super.initState();
    setState(() {
      yojanaMemberURL = yojanaMemberURL + widget.yojanaModel.id.toString();
    });
  }

  String yojanaMemberURL =
      "http://mis.godawarimun.gov.np/Api/Anugaman/GetUserByAnugamanId/";

  Future<List<AddMemberModel>> fetchMembers() async {
    final token = sharedPreferences!.getString("token")!;
    print(yojanaMemberURL);
    final response = await http.get(
      Uri.parse(yojanaMemberURL),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
        'Authorization': 'Bearer $token',
      },
    );
    print(response.statusCode);
    if (response.statusCode == 200) {
      List<dynamic> parsed =
      json.decode(response.body).cast<Map<String, dynamic>>();
      print(parsed);

      List<AddMemberModel> list =
      parsed.map((json) => AddMemberModel.fromJson(json)).toList();
      return list;

    } else {
      throw Exception('Failed to load members list');
    }
  }
  List<AddMemberModel> addMembersList = [];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar:AppBar(
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
              "Yojana Details",
              style: TextStyle(color: Colors.white, fontSize: 24),
            ),
            const SizedBox(
              width: 10,
            )
          ],
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 20),
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
            ), Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                const Text("संचालन हुने वार्ड : "),
                Text("वार्ड 15" ?? widget.yojanaModel.activityName.toString())
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

            ElevatedButton(
                onPressed: () async {
                 addMembersList = await fetchMembers();
                  Route newRoute = MaterialPageRoute(
                      builder: (_) =>
                          YojanaDataEntry(yojanaModel: widget.yojanaModel, addMemberList: addMembersList,));
                  Navigator.pushReplacement(context, newRoute);
                },
                child: const Text("Add yojana entry")),
            //assignOfflineYojana(yojanaList[index]),
          ],
        ),
      ),
    );
  }
}

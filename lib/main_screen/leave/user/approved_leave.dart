import 'dart:convert';
import 'package:flutter/material.dart';
import '../../../global/global.dart';
import 'package:http/http.dart' as http;

import '../../../models/leave_model.dart';
import 'leave_details.dart';

class ApprovedLeave extends StatefulWidget {
  const ApprovedLeave({Key? key}) : super(key: key);

  @override
  State<ApprovedLeave> createState() => _ApprovedLeaveState();
}

class _ApprovedLeaveState extends State<ApprovedLeave> {
  Future<List<LeaveModel>> approvedLeave() async {
    final token = sharedPreferences!.getString("token")!;
    final response = await http.get(
      Uri.parse('http://mis.godawarimun.gov.np/Api/Leave/GetApprovedLeave'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
        'Authorization': 'Bearer $token',
      },
    );
    if (response.statusCode == 200) {
      List<dynamic> parsed =
          json.decode(response.body).cast<Map<String, dynamic>>();
      List<LeaveModel> list = [];
      list = parsed.map((json) => LeaveModel.fromJson(json)).toList();
      return list;
    } else {
      throw Exception('Failed to load leave log');
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<LeaveModel>>(
      future: approvedLeave(),
      builder: (context, AsyncSnapshot snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        }
        if (snapshot.hasData) {
          List<LeaveModel> leaveList = snapshot.data;
          return ListView.builder(
              itemCount: snapshot.data.length,
              itemBuilder: (context, index) {
                return Card(
                  margin: const EdgeInsets.all(8.0),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10.0),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(12.0),
                    child: InkWell(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text("Reason: " +
                                  leaveList[index].leaveFor.toString())
                            ],
                          ),
                          Align(
                              alignment: Alignment.topRight,
                              child: Text("Date: " +
                                  leaveList[index].leaveDate.toString()))
                        ],
                      ),
                      onTap: () {
                        Route newRoute = MaterialPageRoute(
                            builder: (_) => UserLeaveDetails(
                                  leaveModel: leaveList[index],
                                  status: 'Approved',
                                ));
                        Navigator.pushReplacement(context, newRoute);
                      },
                    ),
                  ),
                );
              });
        } else {
          return const Center(
            child: Text("There are no approved leave request"),
          );
        }
      },
    );
  }
}

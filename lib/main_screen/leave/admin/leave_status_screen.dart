import 'dart:convert';
import 'package:flutter/material.dart';
import '../../../global/global.dart';
import '../../../models/admin_leave_model.dart';
import 'package:http/http.dart' as http;
import '../../employee_home_screen.dart';
import 'leave_status_details.dart';

class LeaveStatus extends StatefulWidget {
  const LeaveStatus({Key? key}) : super(key: key);

  @override
  State<LeaveStatus> createState() => _LeaveStatusState();
}

class _LeaveStatusState extends State<LeaveStatus> {
  Future<List<AdminGetLeaveModel>> adminGetLeave() async {
    final token = sharedPreferences!.getString("token")!;
    final response = await http.get(
      Uri.parse('http://mis.godawarimun.gov.np/Api/Leave/GetLeaveForAdmin'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
        'Authorization': 'Bearer $token',
      },
    );
    if (response.statusCode == 200) {
      List<dynamic> parsed =
          json.decode(response.body).cast<Map<String, dynamic>>();
      List<AdminGetLeaveModel> list = [];
      list = parsed.map((json) => AdminGetLeaveModel.fromJson(json)).toList();
      return list;
    } else {
      throw Exception('Failed to load leave log');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Admin Leave',
          style: TextStyle(
            fontSize: 30,
            color: Colors.white,
          ),
        ),
        centerTitle: true,
        automaticallyImplyLeading: false,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () {
            Route newRoute =
                MaterialPageRoute(builder: (_) => const EmployeeHomeScreen());
            Navigator.pushReplacement(context, newRoute);
          },
        ),
      ),
      body: FutureBuilder<List<AdminGetLeaveModel>>(
        future: adminGetLeave(),
        builder: (context, AsyncSnapshot snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }
          if (snapshot.hasData) {
            List<AdminGetLeaveModel> leaveList = snapshot.data;
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
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text("Requested by: " +
                                        leaveList[index].requestedBy.toString()),
                                    Text("Reason: " +
                                        leaveList[index].leaveFor.toString())
                                  ],
                                ),

                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text("Start Date: " +
                                        leaveList[index].leaveDate.toString()),
                                    Text("End Date: " +
                                        leaveList[index].leaveTo.toString()),
                                  ],
                                )
                              ],
                            ),


                          ],
                        ),
                        onTap: () {
                          Route newRoute = MaterialPageRoute(
                              builder: (_) => LeaveStatusDetails(
                                    adminGetLeaveModel: leaveList[index],
                                  ));
                          Navigator.pushReplacement(context, newRoute);
                        },
                      ),
                    ),
                  );
                });
          } else {
            return const Center(
              child: Text("There are no leave request"),
            );
          }
        },
      ),
    );
  }
}

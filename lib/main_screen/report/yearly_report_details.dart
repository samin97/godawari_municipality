import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:municpality_app/main_screen/report/report_category.dart';
import '../../global/global.dart';
import '../../models/monthly_report_model.dart';


class YearlyReport extends StatefulWidget {

  final String? value;

  const YearlyReport({Key? key, required this.value}) : super(key: key);

  @override
  State<YearlyReport> createState() => _YearlyReportState();
}

class _YearlyReportState extends State<YearlyReport> {

  String url = "http://mis.godawarimun.gov.np/Api/Attendence/GetAttendence/";
  Future<List<MonthlyReportModel>> fetchAttendance() async {
    final token = sharedPreferences!.getString("token")!;
    final response = await http.get(
      Uri.parse(url),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
        'Authorization': 'Bearer $token',
      },
    );
    if (response.statusCode == 200) {
      List<dynamic> parsed =
      json.decode(response.body).cast<Map<String, dynamic>>();
      List<MonthlyReportModel> list = [];
      list = parsed.map((json) => MonthlyReportModel.fromJson(json)).toList();
      return list;
    } else {
      throw Exception('Failed to load attendance log');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: const Text(
          'Monthly Report Details',
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
            MaterialPageRoute(builder: (_) => const ReportCategory());
            Navigator.pushReplacement(context, newRoute);
          },
        ),
      ),
      body: FutureBuilder<List<MonthlyReportModel>>(
        future: fetchAttendance(),
        builder: (context, AsyncSnapshot snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }
          if (snapshot.hasData) {
            List<MonthlyReportModel> attendanceList = snapshot.data;
            return ListView.builder(
                itemCount: snapshot.data.length,
                itemBuilder: (context, index) {
                  return Card(
                    elevation: 0,
                    child: Column(
                      children: [
                        const SizedBox(height: 10,),

                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [

                            Column(
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: [
                                const Text("Date"),
                                Text(attendanceList[index].date.toString())
                              ],
                            ),
                            Column(
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: [
                                const Text("Check In"),
                                Text(attendanceList[index].checkInTime.toString())
                              ],
                            ),
                            Column(
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: [
                                const Text("Check Out"),
                                Text(attendanceList[index].checkOutTime.toString())
                              ],
                            ),
                            Column(
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: [
                                const Text("Remarks"),
                                Text(attendanceList[index].remarks.toString())
                              ],
                            ),
                          ],
                        )
                      ],
                    ),
                  );
                });
          } else {
            return Center(
              child: Text("There is no information about the month of " + widget.value.toString()),
            );
          }
        },
      ),
    );
  }
}

import 'dart:convert';

import 'package:flutter/material.dart';

import 'package:http/http.dart' as http;
import 'package:smart_attendance/main_screen/public_home/citizen_chart_details.dart';
import 'package:smart_attendance/models/citizen_chart_model.dart';

import '../landing_screen.dart';

class CitizenChart extends StatefulWidget {
  const CitizenChart({Key? key}) : super(key: key);

  @override
  State<CitizenChart> createState() => _CitizenChartState();
}

class _CitizenChartState extends State<CitizenChart> {



  Future<List<CitizenChartModel>> approvedLeave() async {
    var url = "http://mis.godawarimun.gov.np/Api/WadaPatra/GetWadaPatra?sakha=";

    if (value == null) {
      url = url;
    } else {
      url = url + value!;
    }
    final response = await http.get(
      Uri.parse(url),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
    );
    if (response.statusCode == 200) {
      List<dynamic> parsed =
          json.decode(response.body).cast<Map<String, dynamic>>();

      List<CitizenChartModel> list = [];

      list = parsed.map((json) => CitizenChartModel.fromJson(json)).toList();

      return list;
    } else {
      throw Exception('Failed to load event log');
    }
  }

  String? value;

  final sakhaList = ['test','DUMMY'];

  DropdownMenuItem<String> buildMenuItems(String leaveFor) => DropdownMenuItem(
        value: leaveFor,
        child: Text(leaveFor),
      );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            const Text(
              'Citizen Chart',
              style: TextStyle(
                fontSize: 30,
                color: Colors.white,
              ),

            ),
            SizedBox(width: 10,)
          ],
        ),

        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () {
            Route newRoute =
            MaterialPageRoute(builder: (_) => const LandingScreen());
            Navigator.pushReplacement(context, newRoute);
          },
        ),
        centerTitle: true,
        automaticallyImplyLeading: false,
      ),
      body: Column(
        children: [
          Container(
            margin:const EdgeInsets.symmetric(horizontal: 12,vertical: 10),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 2),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(5),
              border: Border.all(color: Colors.black),
            ),
            child: DropdownButtonHideUnderline(
              child: DropdownButton(
                value: value,
                hint: const Text(
                  "शाखा/उप-शाखा छान्नुहोस्",
                  style: TextStyle(fontSize: 20, color: Colors.black),
                ),
                dropdownColor: Colors.white,
                isExpanded: true,
                items: sakhaList.map(buildMenuItems).toList(),
                onChanged: (value) => setState(
                  () {
                    this.value = value as String?;
                    approvedLeave();
                  },
                ),
              ),
            ),
          ),
          FutureBuilder<List<CitizenChartModel>>(
            future: approvedLeave(),
            builder: (context, AsyncSnapshot snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(
                  child: CircularProgressIndicator(),
                );
              }
              if (snapshot.hasData) {
                List<CitizenChartModel> chartList = snapshot.data;
                return ListView.builder(
                    shrinkWrap: true,
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
                                    Text("सेवाको किसिम : " +
                                        chartList[index].sewaKisim.toString()),
                                    Text("जिम्मेवारी अधिकारी : " +
                                        chartList[index]
                                            .jimbebarAdhakari
                                            .toString()),
                                    Text("शुल्क/दस्तुर  : NRs." +
                                        chartList[index].sewaSulkhaRs.toString()),
                                    Text("लाग्ने समय : " +
                                        chartList[index].lagneSamaya.toString()),
                                  ],
                                ),
                                Align(child: Text("View Details"),alignment: Alignment.bottomRight)
                              ],
                            ),
                            onTap: () {
                              Route newRoute = MaterialPageRoute(
                                  builder: (_) => CitizenChartDetails(
                                        model: chartList[index],
                                      ));
                              Navigator.pushReplacement(context, newRoute);
                            },
                          ),
                        ),
                      );
                    });
              } else {
                return const Center(
                  child: Text("There are no current public event."),
                );
              }
            },
          ),
        ],
      ),
    );
  }
}

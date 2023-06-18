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

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
  }

  var sakhaList = [''];
  Future getSakhaList() async {
    var url = "http://mis.godawarimun.gov.np/Api/WadaPatra/GetSakha";

    final response = await http.get(
      Uri.parse(url),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
    );
    if (response.statusCode == 200) {
      var jsonData = json.decode(response.body);
      print(jsonData);
      setState(() {
        sakhaList = jsonData;
      });

    } else {
      throw Exception('Failed to load event log');
    }
  }

  Future<List<CitizenChartModel>> getSakha() async {
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

  Future<List<String>> getAllCategory() async {
    var baseUrl = "http://mis.godawarimun.gov.np/Api/WadaPatra/GetSakha";

    http.Response response = await http.get(Uri.parse(baseUrl));

    if (response.statusCode == 200) {
      List<String> items = [];
      var jsonData = json.decode(response.body) as List;
      for (var element in jsonData) {
        items.add(element["sakhaName"]);
      }
      return items;
    } else {
      throw response.statusCode;
    }
  }



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

            child: Column(
              children: [
                FutureBuilder<List<String>>(
                  future: getAllCategory(),
                  builder: (context, snapshot) {
                    if (snapshot.hasData) {
                      var data = snapshot.data!;
                      return DropdownButtonHideUnderline(
                        child: DropdownButton(
                          dropdownColor: Colors.white,
                          isExpanded: true,
                          hint: const Text(
                            "शाखा/उप-शाखा छान्नुहोस्",
                            style: TextStyle(fontSize: 20, color: Colors.black),
                          ),
                          // Initial Value
                          value: value,

                          // Down Arrow Icon
                          icon: const Icon(Icons.keyboard_arrow_down),

                          // Array list of items
                          items: data.map((String items) {
                            return DropdownMenuItem(
                              value: items,
                              child: Text(items),
                            );
                          }).toList(),
                          // After selecting the desired option,it will
                          // change button value to selected value
                          onChanged: (value) {
                            setState(() {
                              this.value = value as String?;
                              getSakha();
                            });
                          },
                        ),
                      );
                    } else {
                      return const CircularProgressIndicator();
                    }
                  },
                ),
              ],
            ),
          ),
          FutureBuilder<List<CitizenChartModel>>(
            future: getSakha(),
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
                                Expanded(
                                  child: Column(
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
                                ),
                                SizedBox(width: 6,),
                                Align(child: Text("थप विवरण"),alignment: Alignment.bottomRight)
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

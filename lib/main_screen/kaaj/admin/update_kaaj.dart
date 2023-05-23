import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:smart_attendance/main_screen/kaaj/admin/update_kaaj_details.dart';
import '../../../global/global.dart';
import '../../../models/admin_kaaj_model.dart';
import 'package:http/http.dart' as http;
import '../../employee_home_screen.dart';

class UpdateKaaj extends StatefulWidget {
  const UpdateKaaj({Key? key}) : super(key: key);

  @override
  State<UpdateKaaj> createState() => _UpdateKaajState();
}

class _UpdateKaajState extends State<UpdateKaaj> {
  Future<List<AdminGetKaajModel>> adminGetKaaj() async {
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
      List<AdminGetKaajModel> list = [];
      list = parsed.map((json) => AdminGetKaajModel.fromJson(json)).toList();
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
          'Admin Kaaj',
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
                MaterialPageRoute(builder: (_) => const HomeScreen());
            Navigator.pushReplacement(context, newRoute);
          },
        ),
      ),
      body: FutureBuilder<List<AdminGetKaajModel>>(
        future: adminGetKaaj(),
        builder: (context, AsyncSnapshot snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }
          if (snapshot.hasData) {
            List<AdminGetKaajModel> kaajList = snapshot.data;
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
                                Flexible(
                                    flex: 3,
                                    child: Align(
                                        alignment: Alignment.topRight,
                                        child: Text("Bhraman Start Date: " +
                                            kaajList[index]
                                                .bhramanStartDate
                                                .toString()))),
                                Flexible(
                                    flex: 3,
                                    child: Align(
                                        alignment: Alignment.topRight,
                                        child: Text("Bhraman End Date: " +
                                            kaajList[index]
                                                .bhramanEndDate
                                                .toString())))
                              ],
                            ),
                            Text("Place For Visit: " +
                                kaajList[index].placeForVisit.toString()),
                          ],
                        ),
                        onTap: () {
                          Route newRoute = MaterialPageRoute(
                              builder: (_) => UpdateKaajDetails(
                                    adminGetKaajModel: kaajList[index],
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

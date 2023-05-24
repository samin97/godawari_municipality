import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:smart_attendance/main_screen/landing_screen.dart';
import 'package:smart_attendance/main_screen/public_home/public_event_details.dart';
import 'package:smart_attendance/models/public_event_model.dart';

import 'package:http/http.dart' as http;

class PublicEvents extends StatefulWidget {
  const PublicEvents({Key? key}) : super(key: key);

  @override
  State<PublicEvents> createState() => _PublicEventsState();
}

class _PublicEventsState extends State<PublicEvents> {
  Future<List<PublicEventModel>> approvedLeave() async {
    final response = await http.get(
      Uri.parse('http://mis.godawarimun.gov.np/Api/Event/GetPublicEvent'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
    );
    if (response.statusCode == 200) {
      List<dynamic> parsed =
          json.decode(response.body).cast<Map<String, dynamic>>();
      print(parsed);
      List<PublicEventModel> list = [];
      print(list);
      list = parsed.map((json) => PublicEventModel.fromJson(json)).toList();
      print(list);
      return list;
    } else {
      throw Exception('Failed to load event log');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            const Text(
              'Our public events',
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
      body: FutureBuilder<List<PublicEventModel>>(
        future: approvedLeave(),
        builder: (context, AsyncSnapshot snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }
          if (snapshot.hasData) {
            List<PublicEventModel> eventList = snapshot.data;
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
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            FadeInImage.assetNetwork(
                              placeholder: 'images/noImage.jpg',
                              image: 'http://mis.godawarimun.gov.np/uploads/' +
                                  eventList[index].photo.toString(),
                              width: 50,
                              height: 50,
                            ),
                            SizedBox(
                              width: 10,
                            ),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text("Title : " +
                                    eventList[index].name.toString()),
                                Text("Date : " +
                                    eventList[index].startDate.toString()),
                                Text("Details : " +
                                    eventList[index]
                                        .shortDescription
                                        .toString()),
                              ],
                            ),
                          ],
                        ),
                        onTap: () {
                          Route newRoute = MaterialPageRoute(
                              builder: (_) => PublicEventDetails(
                                    eventModel: eventList[index],
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
    );
  }
}

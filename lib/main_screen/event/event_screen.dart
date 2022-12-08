import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../global/global.dart';
import '../../models/event_model.dart';
import '../home_screen.dart';
import 'event_details.dart';

class EventListScreen extends StatefulWidget {
  const EventListScreen({Key? key}) : super(key: key);

  @override
  State<EventListScreen> createState() => _EventListScreenState();
}

class _EventListScreenState extends State<EventListScreen> {
  String url = "http://mis.godawarimun.gov.np/Api/Event/GetEvent";

  Future<List<EventModel>> fetchEvents() async {
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
      print(parsed);
      List<EventModel> list = [];
      list = parsed.map((json) => EventModel.fromJson(json)).toList();
      print(list);
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
          'Event List',
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
                MaterialPageRoute(builder: (_) => const HomeScreen());
            Navigator.pushReplacement(context, newRoute);
          },
        ),
      ),
      body: FutureBuilder<List<EventModel>>(
        future: fetchEvents(),
        builder: (context, AsyncSnapshot snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }
          if (snapshot.hasData) {
            List<EventModel> eventList = snapshot.data;
            print(eventList);
            return ListView.builder(
                itemCount: snapshot.data.length,
                itemBuilder: (context, index) {
                  return InkWell(
                    child: Card(
                      margin: const EdgeInsets.all(8.0),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10.0),
                      ),
                      elevation: 0,
                      child: Padding(
                        padding: const EdgeInsets.all(12.0),
                        child: Column(
                          children: [
                            const SizedBox(
                              height: 10,
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: [
                                Column(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  children: [
                                    const Text("ID : "),
                                    Text(eventList[index].id.toString()),
                                    Text(eventList[index].name.toString()),
                                    Text(eventList[index]
                                        .shortDescription
                                        .toString()),
                                  ],
                                ),
                                Column(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  children: const [
                                    //image
                                  ],
                                ),
                              ],
                            )
                          ],
                        ),
                      ),
                    ),
                    onTap: () {
                      Route newRoute = MaterialPageRoute(
                          builder: (_) =>
                              EventDetails(eventModel: eventList[index]));
                    },
                  );
                });
          } else {
            return const Center(
              child: Text("There is no ongoing event that is related to you."),
            );
          }
        },
      ),
    );
  }
}

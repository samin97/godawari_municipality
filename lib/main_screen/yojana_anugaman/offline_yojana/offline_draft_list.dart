import 'dart:convert';
import 'dart:developer';

import 'package:flutter/material.dart';

import '../../../local_db/entities/yojana_draft.dart';
import '../../../local_db/isarServices.dart';
import 'offline_draft details.dart';
import 'offline_settings.dart';


class OfflineDraftList extends StatefulWidget {
  const OfflineDraftList({Key? key}) : super(key: key);

  @override
  State<OfflineDraftList> createState() => _OfflineDraftListState();
}

class _OfflineDraftListState extends State<OfflineDraftList> {
  final service = IsarService();

  printdata(List<int> image1) {
    print(image1);
  }


  deleteAllDraft(BuildContext context) {

    // set up the buttons
    Widget cancelButton = TextButton(
      child: const Text("Cancel"),
      onPressed:  () {

        Navigator.of(context).pop();
      },
    );
    Widget continueButton = TextButton(
      child: const Text("Continue"),
      onPressed:  () {
        Navigator.of(context).pop();
        service.deleteAllDraft();
      },
    );

    // set up the AlertDialog
    AlertDialog alert = AlertDialog(
      title: const Text("Delete all draft"),
      content: const Text("Do you want to delete all draft?"),
      actions: [
        cancelButton,
        continueButton,
      ],
    );

    // show the dialog
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return alert;
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            IconButton(
                onPressed: () {
                  Route newRoute =
                      MaterialPageRoute(builder: (_) => const OfflineSettings());
                  Navigator.pushReplacement(context, newRoute);
                },
                icon: const Icon(
                  Icons.arrow_back,
                  color: Colors.black,
                )),
            const Text(
              "Drafts",
              style: TextStyle(color: Colors.white, fontSize: 24),
            ),
            IconButton(
                onPressed: () {
                  deleteAllDraft(context);
                },
                icon: const Icon(
                  Icons.delete,
                  color: Colors.white,
                )),
          ],
        ),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(
            child: StreamBuilder<List<YojanaDraft>>(
              stream: service.listenToYojana(),
              builder: (context, AsyncSnapshot snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(
                    child: CircularProgressIndicator(),
                  );
                }
                if (snapshot.hasData) {
                  print(snapshot.hasData);
                  List<YojanaDraft> yojanaList = snapshot.data;

                  return ListView.builder(
                      shrinkWrap: true,
                      itemCount: snapshot.data?.length ?? 0,
                      itemBuilder: (context, index) {
                        return InkWell(
                          onTap: () {
                            Route newRoute =
                            MaterialPageRoute(builder: (_) =>  OfflineDraftDetails(draftModel: yojanaList[index], service: service,));
                            Navigator.pushReplacement(context, newRoute);
                          },
                          child: Card(
                            margin: const EdgeInsets.all(5),
                            elevation: 1,
                            child: Padding(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 8, vertical: 4),
                              child: Column(children: [
                                Row(
                                  children: [
                                    const Text("Activity name :"),
                                    Text(yojanaList[index].activityName.toString()),
                                  ],
                                ),
                                Row(
                                  children: [
                                    const Text("Yojana Date :"),
                                    Text(yojanaList[index].yojanaDate.toString()),
                                  ],
                                ),
                                Row(
                                  children: [
                                    const Text("Description :"),
                                    Text(yojanaList[index].description.toString()),
                                  ],
                                ),
                                Row(
                                  children: [
                                    const Text("counselorRepresentative :"),
                                    Text(yojanaList[index]
                                        .counselorRepresentative
                                        .toString()),
                                  ],
                                ),
                              ]),
                            ),
                          ),
                        );
                      });
                } else {
                  return const Center(
                    child: Text("You do not have any drafts"),
                  );
                }
              },
            ),
          )
        ],
      ),
    );
  }
}

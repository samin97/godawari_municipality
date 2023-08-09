import 'package:flutter/material.dart';
import 'dart:convert';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../../../local_db/entities/yojana_draft.dart';
import '../../../local_db/isarServices.dart';
import '../online_yojana/online_draft_list.dart';
import 'offline_draft_list.dart';

class OfflineDraftDetails extends StatefulWidget {
  final YojanaDraft draftModel;
  final IsarService service;

  const OfflineDraftDetails(
      {Key? key, required this.draftModel, required this.service})
      : super(key: key);

  @override
  State<OfflineDraftDetails> createState() => _OfflineDraftDetailsState();
}

class _OfflineDraftDetailsState extends State<OfflineDraftDetails> {

  String base64image1 = "noImage";
  String base64image2 = "noImage";
  String base64image3 = "noImage";
  String? yojanaTypeSelected;
  String? yojanaDate;
  String? latitude;
  String? longitude;
  int? yojanaID;
  TextEditingController description = TextEditingController();
  TextEditingController description2 = TextEditingController();
  TextEditingController previousSuggestion = TextEditingController();
  TextEditingController quality = TextEditingController();
  TextEditingController counselorRepresentative = TextEditingController();
  TextEditingController counselorRepresentativePhone = TextEditingController();
  TextEditingController condition = TextEditingController();
  TextEditingController progress = TextEditingController();

  @override
  void initState() {
    setState(() {
      progress.text = widget.draftModel.yojanaTypeSelected;
      yojanaID = widget.draftModel.yojanaId;
      yojanaDate = widget.draftModel.yojanaDate;
      description.text = widget.draftModel.description;
      description2.text = widget.draftModel.description2;
      previousSuggestion.text = widget.draftModel.previousSuggestion;
      counselorRepresentative.text = widget.draftModel.counselorRepresentative;
      counselorRepresentativePhone.text =
          widget.draftModel.counselorRepresentativePhone;
      condition.text = widget.draftModel.condition;
      latitude = widget.draftModel.latitude;
      longitude = widget.draftModel.longitude;
      base64image1 = widget.draftModel.image1;
      base64image2 = widget.draftModel.image2;
      base64image3 = widget.draftModel.image3;
    });
    super.initState();
  }

  final _formKey = GlobalKey<FormState>();

  DropdownMenuItem<String> buildYojanaMenuItems(String yojanaType) =>
      DropdownMenuItem(
        value: yojanaType,
        child: Text(yojanaType),
      );
  final yojanaType = [
    'सुरू नभएको',
    'सुरू मात्र भएको',
    'काम भइरहेको',
    'सम्पन्न हुन लागेको',
    'सम्पन्न भएको'
  ];

  DropdownMenuItem<String> buildQualityMenuItems(String qualityType) =>
      DropdownMenuItem(
        value: qualityType,
        child: Text(qualityType),
      );
  final qualityType = ['कमजोर', 'राम्रो', 'धेरै राम्रो'];

  deleteDraft(BuildContext context) {
    // set up the buttons
    Widget cancelButton = TextButton(
      child: const Text("Cancel"),
      onPressed: () {
        Navigator.of(context).pop();
      },
    );
    Widget continueButton = TextButton(
      child: const Text("Continue"),
      onPressed: () {
        widget.service.deleteDraft(widget.draftModel.id);
      },
    );

    // set up the AlertDialog
    AlertDialog alert = AlertDialog(
      title: const Text("Delete all draft"),
      content: const Text("Do you want to delete this draft?"),
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
                  Route newRoute = MaterialPageRoute(
                      builder: (_) => const OfflineDraftList());
                  Navigator.pushReplacement(context, newRoute);
                },
                icon: const Icon(
                  Icons.arrow_back,
                  color: Colors.black,
                )),
            const Text(
              "Draft Details",
              style: TextStyle(color: Colors.white, fontSize: 24),
            ),
            IconButton(
                onPressed: () {
                  deleteDraft(context);
                },
                icon: const Icon(
                  Icons.delete,
                  color: Colors.white,
                )),
          ],
        ),
      ),
      body: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(12.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    Text(
                      "तपाइ ${widget.draftModel.activityName} अनुगमन गर्दै हुनुहुन्छ",
                      style: const TextStyle(fontSize: 20),
                    ),
                    const SizedBox(
                      height: 16,
                    ),
                    Text(
                      "Date :${widget.draftModel.yojanaDate}",
                      style: const TextStyle(fontSize: 20),
                    ),
                    const SizedBox(
                      height: 16,
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 2),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(5),
                        border: Border.all(color: Colors.black),
                      ),
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton(
                          value: yojanaTypeSelected,
                          hint: const Text(
                            "योजना अनुगमनको प्रकार छान्नुहोस्",
                            style: TextStyle(fontSize: 20, color: Colors.black),
                          ),
                          dropdownColor: Colors.white,
                          isExpanded: true,
                          items: yojanaType.map(buildYojanaMenuItems).toList(),
                          onChanged: (value) => setState(
                                () {
                              yojanaTypeSelected = value as String?;
                              progress.text = value as String;
                            },
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(
                      height: 16,
                    ),
                    TextField(
                      keyboardType: TextInputType.multiline,
                      maxLines: 3,
                      style: const TextStyle(fontSize: 20, color: Colors.black),
                      decoration: const InputDecoration(
                        focusedBorder: OutlineInputBorder(
                          borderSide:
                          BorderSide(color: Colors.black, width: 1.0),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderSide:
                          BorderSide(color: Colors.black, width: 1.0),
                        ),
                        hintText: 'अनुगमनमा देख्नुभएको अवस्थाको विवरण ',
                        hintStyle: TextStyle(fontSize: 20, color: Colors.black),
                      ),
                      controller: description,
                    ),
                    const SizedBox(
                      height: 16,
                    ),
                    TextField(
                      decoration: InputDecoration(
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(5.0),
                          ),
                          hintStyle: const TextStyle(fontSize: 20),
                          hintText: 'अघिल्लो सुझाव उपरको सुनुवाइ'),
                      controller: previousSuggestion,
                    ),
                    const SizedBox(
                      height: 16,
                    ),
                    const SizedBox(
                      height: 16,
                    ),
                    TextField(
                      keyboardType: TextInputType.multiline,
                      maxLines: 3,
                      style: const TextStyle(fontSize: 20, color: Colors.black),
                      decoration: const InputDecoration(
                        focusedBorder: OutlineInputBorder(
                          borderSide:
                          BorderSide(color: Colors.black, width: 1.0),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderSide:
                          BorderSide(color: Colors.black, width: 1.0),
                        ),
                        hintText: 'थप विवरण ',
                        hintStyle: TextStyle(fontSize: 20, color: Colors.black),
                      ),
                      controller: description2,
                    ),
                    const SizedBox(
                      height: 16,
                    ),
                    TextField(
                      decoration: InputDecoration(
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(5.0),
                          ),
                          hintStyle: const TextStyle(fontSize: 20),
                          hintText: 'गपरामर्शदाताको प्रतिनिधि'),
                      controller: counselorRepresentative,
                    ),
                    const SizedBox(
                      height: 16,
                    ),
                    TextField(
                      decoration: InputDecoration(
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(5.0),
                          ),
                          hintStyle: const TextStyle(fontSize: 20),
                          hintText: 'परामर्शदाताको प्रतिनिधिको फोन नं.'),
                      controller: counselorRepresentativePhone,
                    ),
                    const SizedBox(
                      height: 16,
                    ),
                    TextFormField(
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return "कैफियत is not allowed to be empty";
                        }
                        return null;
                      },
                      keyboardType: TextInputType.multiline,
                      maxLines: 3,
                      style: const TextStyle(fontSize: 20, color: Colors.black),
                      decoration: const InputDecoration(
                        focusedBorder: OutlineInputBorder(
                          borderSide:
                          BorderSide(color: Colors.black, width: 1.0),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderSide:
                          BorderSide(color: Colors.black, width: 1.0),
                        ),
                        hintText: 'कैफियत ',
                        hintStyle: TextStyle(fontSize: 20, color: Colors.black),
                      ),
                      controller: condition,
                    ),
                  ],
                ),
              ),
              Row(
                children: [
                  Expanded(
                    child: Column(
                      children: [
                        if (widget.draftModel.image1 != "noImage") ...[
                          Container(
                            height: 300,
                            decoration: BoxDecoration(
                                image: DecorationImage(
                                    image: MemoryImage(base64Decode(
                                        widget.draftModel.image1)))),
                          ),
                        ],
                      ],
                    ),
                  ),
                  Expanded(
                    child: Column(
                      children: [
                        if (widget.draftModel.image2 != "noImage") ...[
                          Container(
                            height: 300,
                            decoration: BoxDecoration(
                                image: DecorationImage(
                                    image: MemoryImage(base64Decode(
                                        widget.draftModel.image2)))),
                          ),
                        ] else
                          ...[],
                      ],
                    ),
                  ),
                  Expanded(
                    child: Column(
                      children: [
                        if (widget.draftModel.image3 != "noImage") ...[
                          Container(
                            height: 300,
                            decoration: BoxDecoration(
                                image: DecorationImage(
                                    image: MemoryImage(base64Decode(
                                        widget.draftModel.image3)))),
                          ),
                        ]
                      ],
                    ),
                  ),
                ],
              ),
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  const SizedBox(
                    height: 16,
                  ),
                  ElevatedButton(
                      onPressed: () async {
                        if (_formKey.currentState!.validate()) {
                          widget.service.saveYojanaDraft(YojanaDraft()
                            ..activityName = widget.draftModel.activityName!
                            ..yojanaDate = yojanaDate!
                            ..yojanaId = widget.draftModel.yojanaId
                            ..yojanaTypeSelected = yojanaTypeSelected.toString()
                            ..description = description.text
                            ..previousSuggestion = previousSuggestion.text
                            ..description2 = description2.text
                            ..counselorRepresentative =
                                counselorRepresentative.text
                            ..counselorRepresentativePhone =
                                counselorRepresentativePhone.text
                            ..condition = condition.text
                            ..longitude = longitude!
                            ..latitude = latitude!
                            ..image1 = base64image1
                            ..image2 = base64image2
                            ..image3 = base64image3);
                          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                              content: Text(
                                  "Yojana '${widget.draftModel.activityName}' has be saved as draft")));
                          Route newRoute = MaterialPageRoute(
                              builder: (_) => const OfflineDraftList());
                          Navigator.pushReplacement(context, newRoute);
                        }
                      },
                      child: const Text("Save as draft")),
                  const SizedBox(
                    height: 16,
                  ),
                ],
              ),
              const SizedBox(
                height: 16,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

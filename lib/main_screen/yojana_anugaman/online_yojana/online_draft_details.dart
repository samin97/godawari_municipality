import 'dart:convert';
import 'dart:developer';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import '../../../global/global.dart';
import '../../../global/widgets/error_dialog.dart';
import '../../../local_db/entities/yojana_draft.dart';
import '../../../local_db/isarServices.dart';
import '../../../models/post_anugaman_model.dart';
import 'online_draft_list.dart';

class OnlineDraftDetails extends StatefulWidget {
  final YojanaDraft draftModel;
  final IsarService service;

  const OnlineDraftDetails(
      {Key? key, required this.draftModel, required this.service})
      : super(key: key);

  @override
  State<OnlineDraftDetails> createState() => _OnlineDraftDetailsState();
}

class _OnlineDraftDetailsState extends State<OnlineDraftDetails> {
  late String base64image1 = "noImage";
  late String base64image2 = "noImage";
  late String base64image3 = "noImage";
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

  conformSubmit(BuildContext context) {
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
        Navigator.of(context).pop();
        postNow();
      },
    );

    // set up the AlertDialog
    AlertDialog alert = AlertDialog(
      title: const Text("Submit?"),
      content: const Text("Do you want to submit this draft?"),
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
                      builder: (_) => const OnlineDraftList());
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
                              builder: (_) => const OnlineDraftList());
                          Navigator.pushReplacement(context, newRoute);
                        }
                      },
                      child: const Text("Save as draft")),
                  const SizedBox(
                    height: 16,
                  ),
                  ElevatedButton(
                      onPressed: () {
                        checkConnection();
                      },
                      child: const Text("पेश गर्नुहोस्"))
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

  Future checkConnection() async {
    var connectivityResult = await (Connectivity().checkConnectivity());
    if (connectivityResult == ConnectivityResult.mobile ||
        connectivityResult == ConnectivityResult.wifi) {
      conformSubmit(context);
    } else {
      showDialog<String>(
        context: context,
        builder: (BuildContext context) => AlertDialog(
          title: const Text("तपाईं अफलाइन हुनुहुन्छ ।"),
          content: const Text(
              "तपाईंको मोबार्इल सेटमा इन्टरनेट जडान भए/नभएको सुनिश्चित गर्नुहोस् ।"),
          actions: [
            TextButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                child: const Text("Conform"))
          ],
        ),
      );
      //localStorage();
    }
  }

  Future postNow() async {
    final token = sharedPreferences!.getString("token")!;
    PostAnugamanModel anugamanModel = PostAnugamanModel(
        budgetId: widget.draftModel.yojanaId,
        monitoringDateNep: widget.draftModel.yojanaDate,
        whatYouSaw: description.text,
        responseOfPreviousFeedback: previousSuggestion.text,
        progressStatus: progress.text,
        quality: quality.text,
        additionalNote: description2.text,
        consultantReprisintive: counselorRepresentative.text,
        reprisintivePhone: counselorRepresentativePhone.text,
        overAllRemarks: condition.text,
        image1: widget.draftModel.image1,
        image2: widget.draftModel.image2,
        image3: widget.draftModel.image3,
        latitude: widget.draftModel.latitude,
        longitude: widget.draftModel.longitude, userAssigneds: []);
    print(anugamanModel);
    print(anugamanModel.image1);
    var response = await http.post(
        Uri.parse(
            "http://mis.godawarimun.gov.np/Api/Anugaman/PostAnugamanData"),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode(anugamanModel));

    if (response.statusCode == 200) {
      // var s = response.body.toString();
      print(response.statusCode);
      widget.service.deleteDraft(widget.draftModel.id);
      Route newRoute =
          MaterialPageRoute(builder: (_) => const OnlineDraftList());
      Navigator.pushReplacement(context, newRoute);
    } else {
      print(response.body);
      showDialog(
          context: context,
          builder: (c) {
            return const ErrorDialog(
              message: "Failed to post yojana",
            );
          });
    }
  }
}

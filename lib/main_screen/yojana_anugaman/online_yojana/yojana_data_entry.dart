import 'dart:convert';
import 'dart:io';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:geolocator/geolocator.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:nepali_date_picker/nepali_date_picker.dart';
import 'package:nepali_utils/nepali_utils.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/services.dart';
import 'package:smart_attendance/main_screen/yojana_anugaman/online_yojana/yojana_details.dart';
import 'package:smart_attendance/main_screen/yojana_anugaman/online_yojana/yojana_main.dart';
import 'package:smart_attendance/models/add_member_model.dart';

import '../../../global/global.dart';
import '../../../global/widgets/button_widget.dart';
import '../../../global/widgets/error_dialog.dart';
import '../../../local_db/entities/yojana_draft.dart';
import '../../../local_db/isarServices.dart';
import '../../../models/post_anugaman_model.dart';
import '../../../models/yojana_details_model.dart';

class YojanaDataEntry extends StatefulWidget {
  final YojanaModel yojanaModel;
  final List<AddMemberModel> addMemberList;

  const YojanaDataEntry(
      {Key? key, required this.yojanaModel, required this.addMemberList})
      : super(key: key);

  @override
  State<YojanaDataEntry> createState() => _YojanaDataEntryState();
}

class _YojanaDataEntryState extends State<YojanaDataEntry> {
  @override
  void initState() {
    handleLocationPermission();
    getCurrenntLocation();
    super.initState();
  }

  getCurrenntLocation() async {
    Position newPosition = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high);
    setState(() {
      latitude = newPosition.latitude.toString();
      longitude = newPosition.longitude.toString();
    });
  }

  Future<void> handleLocationPermission() async {
    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      LocationPermission serviceEnabled = await Geolocator.requestPermission();

      print("location");
      print(serviceEnabled);
    }
    if (permission == LocationPermission.deniedForever) {
      showDialog(
          context: context,
          builder: (c) {
            return const ErrorDialog(
              message: "Location denied forever.",
            );
          });
    }
    print(permission == LocationPermission.whileInUse);
  }

  NepaliDateTime? selectedDate;
  NepaliDateTime? leaveEndDate;

  String base64image1 = "noImage";
  String base64image2 = "noImage";
  String base64image3 = "noImage";
  String? latitude;
  String? longitude;
  String? yojanaTypeSelected;
  String? qualitySelected;

  String? yojanaDate;
  TextEditingController description = TextEditingController();

  TextEditingController description2 = TextEditingController();

  TextEditingController previousSuggestion = TextEditingController();

  TextEditingController qualityComment = TextEditingController();

  TextEditingController counselorRepresentative = TextEditingController();

  TextEditingController counselorRepresentativePhone = TextEditingController();

  TextEditingController condition = TextEditingController();
  bool? selectedMembers = false;

  String getStartDateText() {
    if (selectedDate == null) {
      return 'मिति छान्नुहोस्';
    } else {
      return DateFormat('dd/MM/yyyy').format(selectedDate!);
    }
  }

  Future pickDate(BuildContext context) async {
    NepaliDateTime? _selectedDateTime = await showAdaptiveDatePicker(
      context: context,
      initialDate: selectedDate ?? NepaliDateTime.now(),
      firstDate: NepaliDateTime(2079, 1, 1),
      lastDate: NepaliDateTime(2099, 12, 12),
      dateOrder: DateOrder.dmy,
      language: NepaliUtils().language,
      initialDatePickerMode: DatePickerMode.day,
    );
    if (_selectedDateTime == null) return;
    setState(() {
      var nepaliDate = NepaliDateFormat("dd/MM/yyyy");
      final String nepaliFormatted = nepaliDate.format(_selectedDateTime);
      print(nepaliFormatted);
      yojanaDate = nepaliFormatted;
      selectedDate = _selectedDateTime;
    });
  }

  bool showLoading = false;
  bool addMembers = false;
  String toggleMembers = "Add Members";

  File? yojanaImage1;
  final yojanaImagePicker1 = ImagePicker();

  Future getImageYojana1() async {
    final pickedFile = await yojanaImagePicker1.pickImage(
        source: ImageSource.camera, imageQuality: 70);

    if (pickedFile != null) {
      yojanaImage1 = File(pickedFile.path);
      Uint8List image1 = await pickedFile.readAsBytes();
      setState(() {
        base64image1 = base64Encode(image1);
      });
    }
  }

  File? yojanaImage2;
  final yojanaImagePicker2 = ImagePicker();

  Future getImageYojana2() async {
    final pickedFile = await yojanaImagePicker2.pickImage(
        source: ImageSource.camera, imageQuality: 70);

    if (pickedFile != null) {
      yojanaImage2 = File(pickedFile.path);
      Uint8List image2 = await pickedFile.readAsBytes();
      setState(() {
        base64image2 = base64Encode(image2);
      });
    }
  }

  File? yojanaImage3;
  final yojanaImagePicker3 = ImagePicker();

  Future getImageYojana3() async {
    final pickedFile = await yojanaImagePicker3.pickImage(
        source: ImageSource.camera, imageQuality: 70);

    if (pickedFile != null) {
      yojanaImage3 = File(pickedFile.path);
      Uint8List image3 = await pickedFile.readAsBytes();
      setState(() {
        base64image3 = base64Encode(image3);
      });
    }
  }

  validate() {
    if ((leaveEndDate != null) && (selectedDate != null)) {
      print(yojanaTypeSelected);
      if (yojanaTypeSelected != null) {
        if (yojanaImage1 != null) {
          //todo uploadImage();
        } else {
          showDialog(
              context: this.context,
              builder: (c) {
                return const ErrorDialog(
                  message: "अनुरोध पत्र समाबेश गर्नुहोला । ",
                );
              });
        }
      } else {
        showDialog(
            context: this.context,
            builder: (c) {
              return const ErrorDialog(
                message: "छुट्टीको कारण छान्नुहोस् ।",
              );
            });
      }
    } else {
      showDialog(
          context: this.context,
          builder: (c) {
            return const ErrorDialog(
              message: " कृपाय छुट्टी सुरू तथा समाप्त हुने मिति छान्नुहोला ",
            );
          });
    }
  }

  Future<bool> _onWillPop() async {
    return false;
  }

  final service = IsarService();

  final _formKey = GlobalKey<FormState>();
  PostAnugamanModel? anugamanModel;

  List<String> whatYouSawList = [];
  String text1 = "स्वस्वीकृत लागत अनुमान वमोजिम ";
  String text2 = "सार्वजनिक परीक्षण";
  String text3 = "स्वजनसहभागिता";
  String text4 = "आयोजना स्थलमा सूचना पाटी सबैले देख्ने ठाउमा";
  String text5 = "लग बुक";
  String text6 = "अन्य";

  bool bool1 = false;
  bool bool2 = false;
  bool bool3 = false;
  bool bool4 = false;
  bool bool5 = false;
  bool bool6 = false;

  Future postNow() async {
    setState(() {
      if (bool1) {
        whatYouSawList.add(text1+"भएको");
      }else{
        whatYouSawList.add(text1+"नभएको");
      }
      ;
      if (bool2) {
        whatYouSawList.add(text2+"भएको");
      }else{
        whatYouSawList.add(text2+"नभएको");
      }
      ;
      if (bool3) {
        whatYouSawList.add(text3+"नभएको");
      }else{
        whatYouSawList.add(text3+"नभएको");
      }
      ;
      if (bool4) {
        whatYouSawList.add(text4+"राखेको");
      }else{
        whatYouSawList.add(text4+"नभएको");
      }
      ;
      if (bool5) {
        whatYouSawList.add(text5+"राखेको");
      }else{
        whatYouSawList.add(text5+"नभएको");
      }
      ;
      if (bool6) {
        whatYouSawList.add(text6);
      }
      ;
    });
    List<UserAssigned> userAssigned = [];

    for (int i = 0; i < widget.addMemberList.length; i++) {
      UserAssigned temp = UserAssigned(id: widget.addMemberList[i].id.toString(), isAssigned: widget.addMemberList[i].isAssigned);
      userAssigned.add(temp);
    }
    print(userAssigned);
    print(":add members");

    print(addMembers);

    final token = sharedPreferences!.getString("token")!;

    PostAnugamanModel anugamanModel = PostAnugamanModel(
      budgetId: widget.yojanaModel.id,
      monitoringDateNep: yojanaDate,
      whatYouSaw: description.text,
      whatYouSawList: whatYouSawList,
      responseOfPreviousFeedback: previousSuggestion.text,
      progressStatus: yojanaTypeSelected,
      quality: qualitySelected,
      remarksOnQuality: qualityComment.text,
      additionalNote: description2.text,
      consultantReprisintive: counselorRepresentative.text,
      reprisintivePhone: counselorRepresentativePhone.text,
      overAllRemarks: condition.text,
      image1: base64image1,
      image2: base64image2,
      image3: base64image3,
      latitude: latitude,
      longitude: longitude,
      isGroup: addMembers,
      userAssigneds: userAssigned,
    );
    var response = await http.post(
        Uri.parse(
            "http://mis.godawarimun.gov.np/Api/Anugaman/PostAnugamanData"),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode(anugamanModel));

    if (response.statusCode == 200) {
      Route newRoute = MaterialPageRoute(builder: (_) => const YojanaMain());
      Navigator.pushReplacement(context, newRoute);
      print(response.statusCode);
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
                      builder: (_) =>
                          YojanaDetails(yojanaModel: widget.yojanaModel));
                  Navigator.pushReplacement(context, newRoute);
                },
                icon: const Icon(
                  Icons.arrow_back,
                  color: Colors.white,
                )),
            const Text(
              "Yojana Entry",
              style: TextStyle(color: Colors.white, fontSize: 24),
            ),
            const SizedBox(
              width: 10,
            )
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
                      "तपाइ ${widget.yojanaModel.activityName} अनुगमन गर्दै हुनुहुन्छ",
                      style: const TextStyle(fontSize: 16),
                    ),
                    const SizedBox(
                      height: 16,
                    ),
                    ButtonHeaderWidget(
                      title: 'अनुगमनको मिति',
                      text: getStartDateText(),
                      onClicked: () => pickDate(context),
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
                            style: TextStyle(fontSize: 16, color: Colors.black),
                          ),
                          dropdownColor: Colors.white,
                          isExpanded: true,
                          items: yojanaType.map(buildYojanaMenuItems).toList(),
                          onChanged: (value) => setState(
                            () {
                              yojanaTypeSelected = value as String?;
                            },
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(
                      height: 16,
                    ),
                  ],
                ),
              ),
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    width: MediaQuery.of(context).size.width / 2,
                    height: MediaQuery.of(context).size.width / 2,
                    decoration: BoxDecoration(
                      border: Border.all(
                        width: 1,
                      ),
                      color: Colors.grey[100],
                    ),
                    child: InkWell(
                      onTap: () {
                        getImageYojana1();
                      },
                      child: Container(
                          child: yojanaImage1 == null
                              ? const Center(
                                  child: Icon(
                                    Icons.image_search,
                                    size: 60,
                                  ),
                                )
                              : Center(
                                  child: Image.file(
                                  File(yojanaImage1!.path).absolute,
                                  fit: BoxFit.cover,
                                ))),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 16,),
              CheckboxListTile(
                title: Text(text1),
                value: bool1,
                onChanged: (value) {
                  setState(() {
                    bool1 = value ?? false;
                  });
                },
              ),
              CheckboxListTile(
                title: Text(text2),
                value: bool2,
                onChanged: (value) {
                  setState(() {
                    bool2 = value ?? false;
                  });
                },
              ),CheckboxListTile(
                title: Text(text3),
                value: bool3,
                onChanged: (value) {
                  setState(() {
                    bool3 = value ?? false;
                  });
                },
              ),
              CheckboxListTile(
                title: Text(text4),
                value: bool4,
                onChanged: (value) {
                  setState(() {
                    bool4 = value ?? false;
                  });
                },
              ),CheckboxListTile(
                title: Text(text5),
                value: bool5,
                onChanged: (value) {
                  setState(() {
                    bool5 = value ?? false;
                  });
                },
              ),
              CheckboxListTile(
                title: Text(text6),
                value: bool6,
                onChanged: (value) {
                  setState(() {
                    bool6 = value ?? false;
                  });
                },
              ),
              Padding(
                padding: const EdgeInsets.all(12.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    const SizedBox(
                      height: 16,
                    ),
                    TextField(
                      keyboardType: TextInputType.multiline,
                      maxLines: 3,
                      style: const TextStyle(fontSize: 16, color: Colors.black),
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
                        hintStyle: TextStyle(fontSize: 16, color: Colors.black),
                      ),
                      controller: description,
                    ),
                    const SizedBox(
                      height: 16,
                    ),
                    TextField(
                      keyboardType: TextInputType.multiline,
                      maxLines: 2,
                      decoration: InputDecoration(
                          border: OutlineInputBorder(
                            borderSide:
                                BorderSide(color: Colors.black, width: 1.5),
                            borderRadius: BorderRadius.circular(5.0),
                          ),
                          hintStyle: const TextStyle(
                              fontSize: 16, color: Colors.black),
                          hintText: 'अघिल्लो सुझाव उपरको सुनुवाइ'),
                      controller: previousSuggestion,
                    ),
                    const SizedBox(
                      height: 16,
                    ),
                    TextField(
                      keyboardType: TextInputType.multiline,
                      maxLines: 3,
                      style: const TextStyle(fontSize: 16, color: Colors.black),
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
                        hintStyle: TextStyle(fontSize: 16, color: Colors.black),
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
                          hintStyle: const TextStyle(
                              fontSize: 16, color: Colors.black),
                          hintText: 'परामर्शदाताको प्रतिनिधि'),
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
                        hintStyle:
                            const TextStyle(fontSize: 16, color: Colors.black),
                        hintText: 'परामर्शदाताको प्रतिनिधिको फोन नं.',
                      ),
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
                      style: const TextStyle(fontSize: 16, color: Colors.black),
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
                        hintStyle: TextStyle(fontSize: 16, color: Colors.black),
                      ),
                      controller: condition,
                    ),
                  ],
                ),
              ),
              const SizedBox(
                height: 16,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Container(
                    width: MediaQuery.of(context).size.width / 2.5,
                    height: MediaQuery.of(context).size.width / 2.5,
                    decoration: BoxDecoration(
                      border: Border.all(
                        width: 1,
                      ),
                      color: Colors.grey[100],
                    ),
                    child: InkWell(
                      onTap: () {
                        getImageYojana2();
                      },
                      child: Container(
                          child: yojanaImage2 == null
                              ? const Center(
                                  child: Icon(
                                    Icons.image_search,
                                    size: 60,
                                  ),
                                )
                              : Center(
                                  child: Image.file(
                                  File(yojanaImage2!.path).absolute,
                                  fit: BoxFit.cover,
                                ))),
                    ),
                  ),
                  Container(
                    width: MediaQuery.of(context).size.width / 2.5,
                    height: MediaQuery.of(context).size.width / 2.5,
                    decoration: BoxDecoration(
                      border: Border.all(
                        width: 1,
                      ),
                      color: Colors.grey[100],
                    ),
                    child: InkWell(
                      onTap: () {
                        getImageYojana3();
                      },
                      child: Container(
                          child: yojanaImage3 == null
                              ? const Center(
                                  child: Icon(
                                    Icons.image_search,
                                    size: 60,
                                  ),
                                )
                              : Center(
                                  child: Image.file(
                                  File(yojanaImage3!.path).absolute,
                                  fit: BoxFit.cover,
                                ))),
                    ),
                  ),
                ],
              ),
              const SizedBox(
                height: 16,
              ),
              ElevatedButton(
                  onPressed: () {
                    if (addMembers == false) {
                      setState(() {
                        addMembers = true;
                        toggleMembers = "Remove Members";
                      });
                    } else {
                      setState(() {
                        addMembers = false;
                        toggleMembers = "Add Members";
                      });
                    }
                  },
                  child: Text(toggleMembers)),
              Visibility(
                  visible: addMembers,
                  child: Column(
                    children: [
                      Visibility(
                        visible: widget.addMemberList.isNotEmpty,
                        child: Column(
                          children: [
                            const SizedBox(
                              height: 16,
                            ),
                            const Text("Select members to add to yojana"),
                            const SizedBox(
                              height: 16,
                            ),
                            SizedBox(
                              height: widget.addMemberList.length * 60,
                              child: ListView.builder(
                                shrinkWrap: true,
                                itemCount: widget.addMemberList.length,
                                itemBuilder: (context, index) {
                                  return CheckboxListTile(
                                    title: Text(widget.addMemberList[index].name
                                        .toString()),
                                    value:
                                        widget.addMemberList[index].isAssigned,
                                    onChanged: (value) {
                                      setState(() {
                                        widget.addMemberList[index].isAssigned =
                                            value ?? false;
                                      });
                                    },
                                  );
                                },
                              ),
                            ),
                          ],
                        ),
                      ),
                      Visibility(
                        visible: widget.addMemberList.isEmpty,
                        child: Column(
                          children: [
                            const SizedBox(
                              height: 16,
                            ),
                            const Text(
                                "There are no other members to add to yojana"),
                            const SizedBox(
                              height: 16,
                            ),
                          ],
                        ),
                      ),
                    ],
                  )),
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  ElevatedButton(
                      onPressed: () async {
                        if (_formKey.currentState!.validate()) {
                          service.saveYojanaDraft(YojanaDraft()
                            ..activityName = widget.yojanaModel.activityName!
                            ..yojanaDate = yojanaDate!
                            ..yojanaId = widget.yojanaModel.id
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
                                  "New yojana '${widget.yojanaModel.activityName}' has be saved as draft")));
                          Route newRoute = MaterialPageRoute(
                              builder: (_) => const YojanaMain());
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
}

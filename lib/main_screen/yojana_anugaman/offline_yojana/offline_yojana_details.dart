import 'dart:convert';
import 'dart:io';
import 'package:geolocator/geolocator.dart';
import 'package:nepali_date_picker/nepali_date_picker.dart';
import 'package:nepali_utils/nepali_utils.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/services.dart';

import '../../../global/widgets/button_widget.dart';
import '../../../global/widgets/error_dialog.dart';
import '../../../local_db/entities/yojana_draft.dart';
import '../../../local_db/isarServices.dart';
import '../../../models/yojana_details_model.dart';
import '../../attendance/offline_home.dart';

class OfflineYojanaDetail extends StatefulWidget {
  final YojanaModel yojanaModel;

  const OfflineYojanaDetail({Key? key, required this.yojanaModel}) : super(key: key);


  @override
  State<OfflineYojanaDetail> createState() => _OfflineYojanaDetailState();
}

class _OfflineYojanaDetailState extends State<OfflineYojanaDetail> {


  NepaliDateTime? selectedDate;

  String base64image1 = "noImage";
  String base64image2 = "noImage";
  String base64image3 = "noImage";
  String? latitude;
  String? longitude;
  String? yojanaTypeSelected;
  String? yojanaDate;
  TextEditingController description = TextEditingController();
  TextEditingController description2 = TextEditingController();
  TextEditingController previousSuggestion = TextEditingController();
  TextEditingController counselorRepresentative = TextEditingController();
  TextEditingController counselorRepresentativePhone = TextEditingController();
  TextEditingController condition = TextEditingController();

  @override
  void initState() {
    handleLocationPermission();
    getCurrenntLocation();
    super.initState();
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

  getCurrenntLocation() async {
    Position newPosition = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high);
    setState(() {
      latitude = newPosition.latitude.toString();
      longitude = newPosition.longitude.toString();
    });
  }

  String getStartDateText() {
    if (selectedDate == null) {
      return 'मिति छान्नुहोस्';
    } else {
      return DateFormat('MM/dd/yyyy').format(selectedDate!);
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
    });
  }

  bool showLoading = false;

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
    if ((selectedDate != null)) {
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
                  MaterialPageRoute(builder: (_) => const OfflineHome());
                  Navigator.pushReplacement(context, newRoute);
                },
                icon: const Icon(
                  Icons.arrow_back,
                  color: Colors.white,
                )),
            const Text(
              "Yojana Details",
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
                      style: const TextStyle(fontSize: 20),
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
                            style: TextStyle(fontSize: 20, color: Colors.black),
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
                      keyboardType: TextInputType.multiline,
                      maxLines: 2,
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
                  Container(
                    width: MediaQuery.of(context).size.width / 3,
                    height: MediaQuery.of(context).size.width / 3,
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
                  Container(
                    width: MediaQuery.of(context).size.width / 3,
                    height: MediaQuery.of(context).size.width / 3,
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
                    width: MediaQuery.of(context).size.width / 3,
                    height: MediaQuery.of(context).size.width / 3,
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
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  const SizedBox(
                    height: 16,
                  ),
                  ElevatedButton(
                      onPressed: () async {if (_formKey.currentState!.validate()) {
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
                              builder: (_) => const OfflineHome());
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




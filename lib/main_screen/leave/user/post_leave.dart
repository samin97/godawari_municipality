import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:nepali_date_picker/nepali_date_picker.dart';
import 'package:nepali_utils/nepali_utils.dart';
import 'package:path/path.dart';
import '../../../global/global.dart';
import '../../../global/widgets/button_widget.dart';
import 'package:image_picker/image_picker.dart';
import 'package:modal_progress_hud_nsn/modal_progress_hud_nsn.dart';
import 'package:http/http.dart' as http;
import 'dart:io';
import '../../../global/widgets/error_dialog.dart';
import '../../employee_home_screen.dart';
import 'leave_category.dart';

class LeaveForm extends StatefulWidget {
  const LeaveForm({Key? key}) : super(key: key);

  @override
  State<LeaveForm> createState() => _LeaveFormState();
}

class _LeaveFormState extends State<LeaveForm> {
  final leaveFor = [
    'बिरामी विदा',
    'सुत्केरी विदा',
    'बेतलवी विदा',
    'घर विदा',
    'पर्व विदा',
    'अवकाशीय विदा',
    'अन्य',
    'प्रसुती विदा',
    'प्रसुती स्याहार विदा',
    'किरिया विदा',
    'अध्ययन विदा',
    'असाधारण विदा',
    'सट्टा विदा',
    'पर्व/भैपरी आउने',
  ];

  NepaliDateTime? leaveStartDate;
  NepaliDateTime? leaveEndDate;

  String? value;
  TextEditingController description = TextEditingController();

  String getStartDateText() {
    if (leaveStartDate == null) {
      return 'विदा  सुरु मिति';
    } else {
      return DateFormat('MM/dd/yyyy').format(leaveStartDate!);
    }
  }

  String getEndDateText() {
    if (leaveEndDate == null) {
      return 'विदा  समप्त मिति';
    } else {
      return DateFormat('MM/dd/yyyy').format(leaveEndDate!);
    }
  }

  Future pickLeaveStartDate(BuildContext context) async {
    NepaliDateTime? _selectedDateTime = await showAdaptiveDatePicker(
      context: context,
      initialDate: leaveStartDate ?? NepaliDateTime.now(),
      firstDate: NepaliDateTime(2079, 1, 1),
      lastDate: NepaliDateTime(2099, 12, 12),
      dateOrder: DateOrder.dmy,
      language: NepaliUtils().language,
      initialDatePickerMode: DatePickerMode.day,
    );
    if (_selectedDateTime == null) return;
    setState(() => leaveStartDate = _selectedDateTime);
  }

  Future pickLeaveEndDate(BuildContext context) async {
    NepaliDateTime? _selectedDateTime = await showAdaptiveDatePicker(
      context: context,
      initialDate: leaveEndDate ?? NepaliDateTime.now(),
      firstDate: NepaliDateTime(2079, 1, 1),
      lastDate: NepaliDateTime(2099, 12, 12),
      dateOrder: DateOrder.dmy,
      language: NepaliUtils().language,
      initialDatePickerMode: DatePickerMode.day,
    );
    if (_selectedDateTime == null) return;
    setState(() => leaveEndDate = _selectedDateTime);
  }

  File? aanurodhPatraImage;
  final aanurodhPatraPicker = ImagePicker();

  bool showLoading = false;

  Future getImageAanurodhPatra() async {
    final pickedFile = await aanurodhPatraPicker.pickImage(
        source: ImageSource.gallery, imageQuality: 70);

    if (pickedFile != null) {
      aanurodhPatraImage = File(pickedFile.path);
      setState(() {});
    }
  }

  validate() {
    if ((leaveEndDate != null) && (leaveStartDate != null)) {
      print(value);
      if (value != null) {
        if (aanurodhPatraImage != null) {
          uploadImage();
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

  Future<void> uploadImage() async {
    setState(() {
      showLoading = true;
    });

    final token = sharedPreferences!.getString("token")!;
    print(leaveStartDate);
    print(leaveEndDate);
    var uri = Uri.parse('http://mis.godawarimun.gov.np/Api/Leave/RequestLeave');

    var request = http.MultipartRequest("POST", (uri));
    Map<String, String> headers = {
      "Accept": "application/json",
      "Authorization": "Bearer $token"
    };
    var nepaliDate = NepaliDateFormat("yyyy/MM/dd");
    var nepaliDate1 = NepaliDateFormat("yyyy/MM/dd");
    final String formattedLeaveStartDate = nepaliDate.format(leaveStartDate!);
    final String formattedLeaveEndDate = nepaliDate1.format(leaveEndDate!);
    request.fields['LeaveDate'] = formattedLeaveStartDate;
    request.fields['LeaveTo'] = formattedLeaveEndDate;
    request.fields['LeaveFor'] = value.toString();
    request.fields['Description'] = description.text;
    print(formattedLeaveStartDate);
    print(formattedLeaveEndDate);
    if (formattedLeaveEndDate == formattedLeaveStartDate) {
      print('same');
    }

    if (aanurodhPatraImage != null) {
      var aanurodhPatraStream = http.ByteStream(aanurodhPatraImage!.openRead());
      var aanurodhPatraLength = await aanurodhPatraImage!.length();

      var multipartAanurodhPatra = http.MultipartFile(
          'AanurodhPatra', aanurodhPatraStream, aanurodhPatraLength,
          filename: basename(aanurodhPatraImage!.path));

      request.files.add(multipartAanurodhPatra);
    }
    request.headers.addAll(headers);
    var response = await request.send();
    print(response.statusCode);

    if (response.statusCode == 200) {
      // var s = response.body.toString();
      ScaffoldMessenger.of(this.context)
          .showSnackBar(const SnackBar(content: Text("Successfully Posted")));
      Route newRoute = MaterialPageRoute(builder: (_) => const EmployeeHomeScreen());
      Navigator.pushReplacement(this.context, newRoute);
    } else {
      showDialog(
          context: this.context,
          builder: (c) {
            return const ErrorDialog(
              message:
                  "विवरण पेश गर्न असमर्थन हुनुभयो । कृपया पुनःप्रयास गर्नुहोला । ",
            );
          });
    }
    if (response.statusCode == 200) {
      setState(() {
        showLoading = false;
      });
    } else {
      setState(() {
        showLoading = false;
      });
    }
  }

  Future<bool> _onWillPop() async {
    return false;
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: _onWillPop,
      child: ModalProgressHUD(
        inAsyncCall: showLoading,
        child: Scaffold(
          backgroundColor: Colors.white,
          appBar: AppBar(
            title: const Text(
              'विदा सम्बन्धि अनुरोध फारम',
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
                    MaterialPageRoute(builder: (_) => const LeaveCategory());
                Navigator.pushReplacement(context, newRoute);
              },
            ),
          ),
          body: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(18.0),
              child: Column(
                children: [
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      Flexible(
                        child: ButtonHeaderWidget(
                          title: 'Leave Start Date',
                          text: getStartDateText(),
                          onClicked: () => pickLeaveStartDate(context),
                        ),
                      ),
                      const SizedBox(
                        width: 10,
                      ),
                      Flexible(
                        child: ButtonHeaderWidget(
                          title: 'Leave End Date',
                          text: getEndDateText(),
                          onClicked: () => pickLeaveEndDate(context),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      Flexible(
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 2),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(5),
                            border: Border.all(color: Colors.black),
                          ),
                          child: DropdownButtonHideUnderline(
                            child: DropdownButton(
                              value: value,
                              hint: const Text(
                                "विदाको कारण",
                                style: TextStyle(
                                    fontSize: 20, color: Colors.black),
                              ),
                              dropdownColor: Colors.white,
                              isExpanded: true,
                              items: leaveFor.map(buildMenuItems).toList(),
                              onChanged: (value) => setState(
                                () {
                                  this.value = value as String?;
                                },
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    keyboardType: TextInputType.multiline,
                    maxLines: 6,
                    style: const TextStyle(fontSize: 20, color: Colors.black),
                    decoration: const InputDecoration(
                      focusedBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.black, width: 1.0),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.black, width: 1.0),
                      ),
                      hintText: 'विदाको विवरण',
                      hintStyle: TextStyle(fontSize: 20, color: Colors.black),
                    ),
                    controller: description,
                  ),
                  const SizedBox(
                    height: 12,
                  ),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
                    decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(5),
                        color: Colors.white,
                        border: Border.all(color: Colors.black, width: 1)),
                    child: const Text("विदा सम्बन्धिको पत्र अपलोड गर्नुहोस् :",
                        style: TextStyle(fontSize: 20)),
                  ),
                  const SizedBox(
                    height: 12,
                  ),
                  Container(
                    height: 150,
                    width: 150,
                    decoration: BoxDecoration(
                      border: Border.all(
                        width: 1,
                      ),
                      color: Colors.grey[100],
                    ),
                    child: InkWell(
                      onTap: () {
                        getImageAanurodhPatra();
                      },
                      child: Container(
                          child: aanurodhPatraImage == null
                              ? const Center(
                                  child: Icon(
                                    Icons.image_search,
                                    size: 60,
                                  ),
                                )
                              : Center(
                                  child: Image.file(
                                  File(aanurodhPatraImage!.path).absolute,
                                  height: 150,
                                  width: 150,
                                  fit: BoxFit.cover,
                                ))),
                    ),
                  ),
                  const SizedBox(
                    height: 12,
                  ),
                  ElevatedButton(
                      onPressed: () {
                        validate();
                      },
                      child: const Text("पेश गर्नुहोस्"))
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  DropdownMenuItem<String> buildMenuItems(String leaveFor) => DropdownMenuItem(
        value: leaveFor,
        child: Text(leaveFor),
      );
}

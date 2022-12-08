
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
import '../../home_screen.dart';
import 'leave_category.dart';

class LeaveForm extends StatefulWidget {
  const LeaveForm({Key? key}) : super(key: key);

  @override
  State<LeaveForm> createState() => _LeaveFormState();
}

class _LeaveFormState extends State<LeaveForm> {
  final leaveFor = [
    'Sick leave',
    'Maternal Leave',
    'Unpaid leave',
    'Religious observance',
    'Vacation leave',
    'Others'
  ];
  NepaliDateTime? selectedDate;
  String? value;
  TextEditingController description = TextEditingController();

  String getText() {
    if (selectedDate == null) {
      return 'Leave Date';
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
    setState(() => selectedDate = _selectedDateTime);
  }

  File? image;
  final _picker = ImagePicker();
  bool showLoading = false;

  Future getImage() async {
    final pickedFile =
        await _picker.pickImage(source: ImageSource.gallery, imageQuality: 70);

    if (pickedFile != null) {
      image = File(pickedFile.path);
      setState(() {});
    }
  }

  Future<void> uploadImage() async {
    setState(() {
      showLoading = true;
    });

    var stream = http.ByteStream(image!.openRead());
    final token = sharedPreferences!.getString("token")!;

    var length = await image!.length();
    var uri = Uri.parse('http://mis.godawarimun.gov.np/Api/Leave/RequestLeave');

    var request = http.MultipartRequest("POST", (uri));
    Map<String, String> headers = {
      "Accept": "application/json",
      "Authorization": "Bearer $token"
    };
    var nepaliDate = NepaliDateFormat("yyyy/MM/dd");
    final String nepaliFormatted = nepaliDate.format(selectedDate!);
    print(nepaliFormatted);

    request.fields['LeaveDate'] = nepaliFormatted;
    request.fields['LeaveFor'] = value.toString();
    request.fields['Description'] = description.text;

    var multipart = http.MultipartFile('Signature', stream, length,
        filename: basename(image!.path));

    request.files.add(multipart);
    request.headers.addAll(headers);

    var response = await request.send();

    if (response.statusCode == 200) {
      // var s = response.body.toString();
      ScaffoldMessenger.of(this.context)
          .showSnackBar(const SnackBar(content: Text("Successfully Posted")));
      Route newRoute = MaterialPageRoute(builder: (_) => const HomeScreen());
      Navigator.pushReplacement(this.context, newRoute);
    } else {
      showDialog(
          context: this.context,
          builder: (c) {
            return const ErrorDialog(
              message: "Failed to request leave.",
            );
          });
    }
    if (response.statusCode == 200) {
      setState(() {
        showLoading = false;
      });
      print("Image uploaded");
    } else {
      setState(() {
        showLoading = false;
      });
      print('Failed');
    }
  }

  @override
  Widget build(BuildContext context) {
    return ModalProgressHUD(
      inAsyncCall: showLoading,
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          title: const Text(
            'Leave Form',
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
                        title: 'Leave Date',
                        text: getText(),

                        onClicked: () => pickDate(context),
                      ),
                    ),
                    const SizedBox(
                      width: 10,
                    ),
                    Flexible(
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 2),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Colors.black),
                        ),
                        child: DropdownButtonHideUnderline(
                          child: DropdownButton(
                            value: value,
                            hint: const Text("Leave For"),
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
                  decoration:  const InputDecoration(
                      border: OutlineInputBorder(),
                      hintText: 'Leave Description'),
                  controller: description,
                ),
                const SizedBox(
                  height: 12,
                ),
                Container(
                  height: 150,
                  width: 150,
                  color: Colors.grey[100],
                  child: InkWell(
                    onTap: () {
                      getImage();
                    },
                    child: Container(
                        child: image == null
                            ? const Center(
                                child: Icon(Icons.image_search, size: 60,),
                              )
                            : Center(
                                child: Image.file(
                                File(image!.path).absolute,
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
                      uploadImage();
                    },
                    child: const Text("Submit"))
              ],
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

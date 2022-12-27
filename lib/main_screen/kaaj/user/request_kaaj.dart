import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:municpality_app/main_screen/kaaj/user/kaaj.dart';
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

class RequestKaaj extends StatefulWidget {
  const RequestKaaj({Key? key}) : super(key: key);

  @override
  State<RequestKaaj> createState() => _RequestKaajState();
}

class _RequestKaajState extends State<RequestKaaj> {
  NepaliDateTime? bhramanStartDate;
  NepaliDateTime? bhramanEndDate;
  TextEditingController description = TextEditingController();
  TextEditingController placeForVisit = TextEditingController();
  TextEditingController peskiRakam = TextEditingController();

  String getStartDateText() {
    if (bhramanStartDate == null) {
      return 'Bhraman Start Date';
    } else {
      return DateFormat('MM/dd/yyyy').format(bhramanStartDate!);
    }
  }

  String getEndDateText() {
    if (bhramanEndDate == null) {
      return 'Bhraman End Date';
    } else {
      return DateFormat('MM/dd/yyyy').format(bhramanEndDate!);
    }
  }

  Future pickBhramanStartDate(BuildContext context) async {
    NepaliDateTime? _selectedDateTime = await showAdaptiveDatePicker(
      context: context,
      initialDate: bhramanStartDate ?? NepaliDateTime.now(),
      firstDate: NepaliDateTime(2079, 1, 1),
      lastDate: NepaliDateTime(2099, 12, 12),
      dateOrder: DateOrder.dmy,
      language: NepaliUtils().language,
      initialDatePickerMode: DatePickerMode.day,
    );
    if (_selectedDateTime == null) return;
    setState(() => bhramanStartDate = _selectedDateTime);
  }

  Future pickBhramanEndDate(BuildContext context) async {
    NepaliDateTime? _selectedDateTime = await showAdaptiveDatePicker(
      context: context,
      initialDate: bhramanEndDate ?? NepaliDateTime.now(),
      firstDate: NepaliDateTime(2079, 1, 1),
      lastDate: NepaliDateTime(2099, 12, 12),
      dateOrder: DateOrder.dmy,
      language: NepaliUtils().language,
      initialDatePickerMode: DatePickerMode.day,
    );
    if (_selectedDateTime == null) return;
    setState(() => bhramanEndDate = _selectedDateTime);
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

  Future<void> uploadImage() async {
    setState(() {
      showLoading = true;
    });

    var aanurodhPatraStream = http.ByteStream(aanurodhPatraImage!.openRead());
    final token = sharedPreferences!.getString("token")!;

    var aanurodhPatraLength = await aanurodhPatraImage!.length();
    var uri = Uri.parse('http://mis.godawarimun.gov.np/Api/Leave/Requestkaaj');

    var request = http.MultipartRequest("POST", (uri));
    Map<String, String> headers = {
      "Accept": "application/json",
      "Authorization": "Bearer $token"
    };
    var nepaliDate = NepaliDateFormat("yyyy/MM/dd");
    final String formattedBhramanStartDate =
        nepaliDate.format(bhramanStartDate!);
    final String formattedBhramanEndDate = nepaliDate.format(bhramanEndDate!);
    request.fields['BhramanStartDate'] = formattedBhramanStartDate;
    request.fields['BhramanEndDate'] = formattedBhramanEndDate;
    request.fields['PlaceForVisit'] = placeForVisit.text;
    request.fields['PeskiRakam'] = peskiRakam.text;
    request.fields['Description'] = description.text;

    var multipartAanurodhPatra = http.MultipartFile(
        'AanurodhPatra', aanurodhPatraStream, aanurodhPatraLength,
        filename: basename(aanurodhPatraImage!.path));

    request.files.add(multipartAanurodhPatra);
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
              message: "Failed to request Kaaj.",
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
            'Kaaj Form',
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
              Route newRoute = MaterialPageRoute(builder: (_) => const Kaaj());
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
                        title: 'Bhraman Start Date',
                        text: getStartDateText(),
                        onClicked: () => pickBhramanStartDate(context),
                      ),
                    ),
                    const SizedBox(
                      width: 10,
                    ),
                    Flexible(
                      child: ButtonHeaderWidget(
                        title: 'Bhraman End Date',
                        text: getEndDateText(),
                        onClicked: () => pickBhramanEndDate(context),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: const BorderRadius.all(Radius.circular(10), ),
                    border: Border.all(
                      color: Colors.black,
                      width: 1,
                    ),
                  ),
                  padding: const EdgeInsets.all(8.0),
                  child: TextFormField(
                    keyboardType: TextInputType.multiline,
                    decoration: const InputDecoration(
                        border: InputBorder.none,
                        hintText: 'Place For Visit'),
                    controller: placeForVisit,
                  ),
                ),
                const SizedBox(height: 12),
                Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: const BorderRadius.all(Radius.circular(10), ),
                    border: Border.all(
                      color: Colors.black,
                      width: 1,
                    ),
                  ),
                  padding: const EdgeInsets.all(8.0),
                  child: TextFormField(
                    keyboardType: TextInputType.multiline,
                    decoration: const InputDecoration(
                        border: InputBorder.none,
                        hintText: 'Peski Rakam'),
                    controller: peskiRakam,
                  ),
                ),

                const SizedBox(height: 12),
                Container(
                  decoration:  BoxDecoration(
                    color: Colors.white,
                    borderRadius: const BorderRadius.all(Radius.circular(10)
                    ),
                      border: Border.all(
                        color: Colors.black,
                        width: 1,
                      )
                  ),

                  padding: const EdgeInsets.all(8.0),
                  child: TextField(
                    keyboardType: TextInputType.multiline,
                    maxLines: 6,
                    decoration: const InputDecoration(
                        border: InputBorder.none,
                        hintText: 'Kaaj Description'),
                    controller: description,
                  ),
                ),
                const SizedBox(
                  height: 12,
                ),
                const Text("Aanurodh Patra Image:"),
                const SizedBox(
                  height: 12,
                ),
                Container(
                  height: 350,
                  width: 300,
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

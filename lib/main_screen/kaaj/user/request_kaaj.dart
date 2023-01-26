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
import 'kaaj.dart';

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
      return 'काजको सुरू मिति ';
    } else {
      return DateFormat('MM/dd/yyyy').format(bhramanStartDate!);
    }
  }

  String getEndDateText() {
    if (bhramanEndDate == null) {
      return 'काज सकिने मिति ';
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

  validate() {
    if ((bhramanStartDate != null) && (bhramanEndDate != null)) {
      if (description.text.isNotEmpty &&
          peskiRakam.text.isNotEmpty &&
          placeForVisit.text.isNotEmpty) {
        uploadImage();
      } else {
        showDialog(
            context: this.context,
            builder: (c) {
              return const ErrorDialog(
                message: "काजको लागि सबै विवरणहरू भर्नुहोला । ",
              );
            });
      }
    } else {
      showDialog(
          context: this.context,
          builder: (c) {
            return const ErrorDialog(
              message: "कृपाय काजको सुरू तथा समाप्त हुने मिति छान्नुहोला । ",
            );
          });
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
              message: "काजको विवरण पेश गर्न असमर्थन हुनुभयो । कृपया पुनःप्रयास गर्नुहोला । ",
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
              'काज सम्बन्धी फारम',
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
                    MaterialPageRoute(builder: (_) => const Kaaj());
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
                  TextField(
                    keyboardType: TextInputType.multiline,
                    maxLines: 1,
                    style: const TextStyle(fontSize: 20, color: Colors.black),
                    decoration: const InputDecoration(
                      focusedBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.black, width: 1.0),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.black, width: 1.0),
                      ),
                      hintText: 'काजको भ्रमन गरिने ठाँउको ठेगान',
                      hintStyle: TextStyle(fontSize: 20, color: Colors.black),
                    ),
                    controller: placeForVisit,
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    keyboardType: TextInputType.multiline,
                    maxLines: 1,
                    style: const TextStyle(fontSize: 20, color: Colors.black),
                    decoration: const InputDecoration(
                      focusedBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.black, width: 1.0),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.black, width: 1.0),
                      ),
                      hintText: 'पेश्की रकम',
                      hintStyle: TextStyle(fontSize: 20, color: Colors.black),
                    ),
                    controller: peskiRakam,
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
                      hintText: 'काजको थप विवरण',
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
                    child: const Text("काज सम्बन्धिको पत्र अपलोड गर्नुहोस् : ",
                        style: TextStyle(fontSize: 20)),
                  ),
                  const SizedBox(
                    height: 12,
                  ),
                  Container(
                    height: 175,
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
                                    size: 30,
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

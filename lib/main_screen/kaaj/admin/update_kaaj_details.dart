import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:smart_attendance/main_screen/kaaj/admin/update_kaaj.dart';
import '../../../global/global.dart';
import 'package:http/http.dart' as http;
import '../../../global/widgets/app_button.dart';
import '../../../models/admin_kaaj_model.dart';
import '../../../models/new_leave_status_model.dart';

class UpdateKaajDetails extends StatefulWidget {
  final AdminGetKaajModel adminGetKaajModel;

  const UpdateKaajDetails({Key? key, required this.adminGetKaajModel})
      : super(key: key);

  @override
  State<UpdateKaajDetails> createState() => _UpdateKaajDetailsState();
}

class _UpdateKaajDetailsState extends State<UpdateKaajDetails> {
  // ignore: prefer_typing_uninitialized_variables
  var dropdownValue;

  @override
  void initState() {
    dropdownValue = "select";
    super.initState();
  }

  String? value;
  final statusType = ['Canceled', 'Approved'];

  DropdownMenuItem<String> buildMenuItems(String statusType) =>
      DropdownMenuItem(
        value: statusType,
        child: Text(statusType),
      );

  Future statusChange() async {
    final token = sharedPreferences!.getString("token")!;

    NewStatus newStatus = NewStatus(id: 0, status: 'pending');
    setState(() {
      newStatus.id = widget.adminGetKaajModel.id;
      newStatus.status = value!;
    });

    final response = await http.post(
        Uri.parse('http://mis.godawarimun.gov.np/Api/Leave/ChangeStatus'),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode(newStatus));

    print(response.statusCode);
    print(response);
    print(json.decode(response.body));
    Route newRoute =
    MaterialPageRoute(builder: (_) => const UpdateKaaj());
    Navigator.pushReplacement(context, newRoute);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text(
            'Admin Kaaj',
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
              MaterialPageRoute(builder: (_) => const UpdateKaaj());
              Navigator.pushReplacement(context, newRoute);
            },
          ),
        ),
        body: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(12.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Flexible(
                        flex: 3,
                        child: Text(
                          "Bhraman Start Date : " +
                              widget.adminGetKaajModel.bhramanStartDate
                                  .toString(),
                          style: const TextStyle(
                            fontSize: 18,
                            color: Colors.black,
                          ),
                        )),
                    const Spacer(flex: 3,)
                  ],
                ),

                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Flexible(
                        flex: 3,
                        child: Text(
                          "Bhraman End Date : " +
                              widget.adminGetKaajModel.bhramanEndDate
                                  .toString(),
                          style: const TextStyle(
                            fontSize: 18,
                            color: Colors.black,
                          ),
                        )),
                    const Spacer(flex: 3,)
                  ],
                ),
                const SizedBox(height: 10),
                Text(
                  "Place For Visit : " +
                      widget.adminGetKaajModel.placeForVisit .toString(),
                  style: const TextStyle(
                    fontSize: 18,
                    color: Colors.black,
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  "Peski Rakam : " +
                      widget.adminGetKaajModel.peskiRakam.toString(),
                  style: const TextStyle(
                    fontSize: 18,
                    color: Colors.black,
                  ),
                ),
                const Divider(
                  thickness: 3,
                ),
                const SizedBox(height: 10),
                const Text(
                  "Description : ",
                  style: TextStyle(
                    fontSize: 18,
                    color: Colors.black,
                  ),
                ),
                Text(
                  widget.adminGetKaajModel.description.toString(),
                  style: const TextStyle(
                    fontSize: 18,
                    color: Colors.black,
                  ),
                ),
                const Divider(
                  thickness: 3,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    const Flexible(
                      child: Text(
                        'Status : ',
                        style: TextStyle(
                          fontSize: 25,
                          color: Colors.black,
                        ),
                      ),
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
                            hint: Text(
                                widget.adminGetKaajModel.status.toString()),
                            dropdownColor: Colors.white,
                            isExpanded: true,
                            items: statusType.map(buildMenuItems).toList(),
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
                const SizedBox(
                  height: 10,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    const Spacer(flex: 1),
                    Flexible(
                      flex: 2,
                      child: AppButton(
                        textColour: Colors.black54,
                        backgroundColor: const Color(0xFF80DEEA),
                        borderColor: const Color(0xFF80DEEA),
                        text: 'Conform',
                        onTap: () {
                          statusChange();
                        },
                        icon: const Icon(Icons.check),
                      ),
                    ),
                    const Spacer(flex: 1),
                  ],
                ),
              ],
            ),
          ),
        ));
  }
}

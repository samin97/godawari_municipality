import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:smart_attendance/main_screen/yojana_anugaman/yojana_report/yojana_report.dart';

import '../../../global/global.dart';
import '../../../models/yojana_report_model.dart';

class YojanaReportDetails extends StatefulWidget {
  final int id;

  const YojanaReportDetails({Key? key, required this.id}) : super(key: key);

  @override
  State<YojanaReportDetails> createState() => _YojanaReportDetailsState();
}

class _YojanaReportDetailsState extends State<YojanaReportDetails> {
  @override
  void initState() {
    print("image");
    super.initState();
  }

  Future<YojanaReportModel> fetchYojanaDetailReport() async {
    final token = sharedPreferences!.getString("token")!;

    var yojanaReportURL =
        "http://mis.godawarimun.gov.np/Api/Anugaman/GetUserAnugamanById/${widget.id}";
    final response = await http.get(
      Uri.parse(yojanaReportURL),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      YojanaReportModel _yojanaReportModel =
          YojanaReportModel.fromJson(jsonDecode(response.body));

      return _yojanaReportModel;
    } else {
      throw Exception('Failed to load attendance log');
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
                      builder: (_) => const YojanaReportList());
                  Navigator.pushReplacement(context, newRoute);
                },
                icon: const Icon(
                  Icons.arrow_back,
                  color: Colors.black,
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
        child: Column(
          children: [
            FutureBuilder<YojanaReportModel>(
              future: fetchYojanaDetailReport(),
              builder: (context, AsyncSnapshot snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(
                    child: CircularProgressIndicator(),
                  );
                }
                if (snapshot.hasData) {
                  YojanaReportModel yojanaReportDetails = snapshot.data;
                  print(yojanaReportDetails.image1);

                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(left: 20.0,top: 30),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "तपाइ ${yojanaReportDetails.budgetId} अनुगमन गर्दै हुनुहुन्छ",
                              style: const TextStyle(fontSize: 16),
                            ),
                            const SizedBox(
                              height: 16,
                            ),
                            Text(
                              "Date :${yojanaReportDetails.monitoringDateNep}",
                              style: const TextStyle(fontSize: 16),
                            ),
                            const SizedBox(
                              height: 16,
                            ),
                            Text(
                              "योजना अनुगमनको प्रकार:${yojanaReportDetails.progressStatus}",
                              style: const TextStyle(fontSize: 16),
                            ),
                            const SizedBox(
                              height: 16,
                            ),
                            Text(
                              "गुणस्तरः :${yojanaReportDetails.quality}",
                              style: const TextStyle(fontSize: 16),
                            ),
                            const SizedBox(
                              height: 16,
                            ),
                            Text(
                              "अनुगमनमा देख्नुभएको अवस्थाको विवरण :",
                              style: const TextStyle(fontSize: 16),
                            ),
                            Text(
                              "${yojanaReportDetails.whatYouSaw}",
                              style: const TextStyle(fontSize: 16),
                            ),
                            const SizedBox(
                              height: 16,
                            ),
                            Text(
                              "थप विवरण :${yojanaReportDetails.additionalNote}",
                              style: const TextStyle(fontSize: 16),
                            ),
                            const SizedBox(
                              height: 16,
                            ),
                            Text(
                              "परामर्शदाताको प्रतिनिधि :${yojanaReportDetails.consultantReprisintive}",
                              style: const TextStyle(fontSize: 16),
                            ),
                            const SizedBox(
                              height: 16,
                            ),
                            Text(
                              "परामर्शदाताको प्रतिनिधिको फोन नं.:${yojanaReportDetails.reprisintivePhone ?? ""}",
                              style: const TextStyle(fontSize: 16),
                            ),
                            const SizedBox(
                              height: 16,
                            ),
                            Text(
                              "गुणस्तरमाथिको तपाइको कैफियत :${yojanaReportDetails.remarksOnQuality}",
                              style: const TextStyle(fontSize: 16),
                            ),
                            const SizedBox(
                              height: 16,
                            ),
                            Text(
                              "कैफियत :${yojanaReportDetails.overAllRemarks}",
                              style: const TextStyle(fontSize: 16),
                            ),
                            const SizedBox(
                              height: 16,
                            ),
                            const SizedBox(
                              height: 16,
                            ),
                          ],
                        ),
                      ),
                      Row(
                        children: [
                          Expanded(
                            child: Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Column(
                                children: [
                                  if (yojanaReportDetails.image1 !=
                                      "noImage") ...[
                                    Container(
                                      height: 300,
                                      decoration: BoxDecoration(
                                          image: DecorationImage(
                                              image: MemoryImage(base64Decode(
                                        yojanaReportDetails.image1 ??
                                            "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",
                                      )))),
                                    ),
                                  ],
                                ],
                              ),
                            ),
                          ),
                          Expanded(
                            child: Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Column(
                                children: [
                                  if (yojanaReportDetails.image2 !=
                                      "noImage") ...[
                                    Container(
                                      height: 300,
                                      decoration: BoxDecoration(
                                          image: DecorationImage(
                                              image: MemoryImage(base64Decode(
                                                  yojanaReportDetails.image2 ??
                                                      "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")))),
                                    ),
                                  ] else
                                    ...[],
                                ],
                              ),
                            ),
                          ),
                          Expanded(
                            child: Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Column(
                                children: [
                                  if (yojanaReportDetails.image3 !=
                                      "noImage") ...[
                                    Container(
                                      height: 300,
                                      decoration: BoxDecoration(
                                          image: DecorationImage(
                                              image: MemoryImage(base64Decode(
                                                  yojanaReportDetails.image3 ??
                                                      "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")))),
                                    ),
                                  ]
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(
                        height: 16,
                      ),
                    ],
                  );
                } else {
                  return const Center(
                    child: Text("There is no yojana assigned to you yet"),
                  );
                }
              },
            ),
          ],
        ),
      ),
    );
  }
}

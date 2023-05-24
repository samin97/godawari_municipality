import 'package:flutter/material.dart';
import 'package:smart_attendance/main_screen/public_home/public_home_screen.dart';
import 'package:smart_attendance/models/citizen_chart_model.dart';

class CitizenChartDetails extends StatefulWidget {
  final CitizenChartModel model;

  const CitizenChartDetails({Key? key, required this.model}) : super(key: key);

  @override
  State<CitizenChartDetails> createState() => _CitizenChartDetailsState();
}

class _CitizenChartDetailsState extends State<CitizenChartDetails> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text(
            'Citizen chart details',
            style: const TextStyle(
              fontSize: 30,
              color: Colors.white,
            ),
          ),
          centerTitle: true,
          automaticallyImplyLeading: false,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.white),
            onPressed: () {
              Route newRoute = MaterialPageRoute(
                  builder: (_) => const PublicHomeScreen(
                        pageIndex: 2,
                      ));
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
                const SizedBox(height: 10),
                Text(
                  "शाखा/उप-शाखाको नाम  : " + widget.model.sakhaName.toString(),
                  style: const TextStyle(
                    fontSize: 18,
                    color: Colors.black,
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  "सेवाको किसिम : " + widget.model.sewaKisim.toString(),
                  style: const TextStyle(
                    fontSize: 18,
                    color: Colors.black,
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  "शुल्क रू : NRs." + widget.model.sewaSulkhaRs.toString(),
                  style: const TextStyle(
                    fontSize: 18,
                    color: Colors.black,
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  "लाग्ने समय : " + widget.model.lagneSamaya.toString(),
                  style: const TextStyle(
                    fontSize: 18,
                    color: Colors.black,
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  "जिम्मेवारी अधिकारी : " +
                      widget.model.jimbebarAdhakari.toString(),
                  style: const TextStyle(
                    fontSize: 18,
                    color: Colors.black,
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  "गुनासो सुन्ने अधिकारी: " + widget.model.gunashoKoAdhakari.toString(),
                  style: const TextStyle(
                    fontSize: 18,
                    color: Colors.black,
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  "आवसेक कागजात तथा प्रकृया  : " + widget.model.awasekKagajat.toString(),
                  style: const TextStyle(
                    fontSize: 18,
                    color: Colors.black,
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  "कैफियत : " + widget.model.remarks.toString() ?? "",
                  style: const TextStyle(
                    fontSize: 18,
                    color: Colors.black,
                  ),
                ),
                const SizedBox(height: 10),
              ],
            ),
          ),
        ));
  }
}

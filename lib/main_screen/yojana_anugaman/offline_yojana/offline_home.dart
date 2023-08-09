import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';

import '../../../global/widgets/error_dialog.dart';
import '../../../local_db/entities/offline_yojana_list.dart';
import '../../../local_db/isarServices.dart';
import '../../../models/yojana_details_model.dart';
import 'offline_settings.dart';
import 'offline_yojana_details.dart';
import 'offline_yojana_list_card.dart';


class OfflineHome extends StatefulWidget {
  const OfflineHome({Key? key}) : super(key: key);

  @override
  State<OfflineHome> createState() => _OfflineHomeState();
}

class _OfflineHomeState extends State<OfflineHome> {
  final service = IsarService();


  @override
  void initState() {
    super.initState();
    _determinePosition();
    handleLocationPermission();
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
              message: "Location denied forever. Please change in the settings",
            );
          });
    }
    print(permission == LocationPermission.whileInUse);
  }

  /// Determine the current position of the device.
  ///
  /// When the location services are not enabled or permissions
  /// are denied the `Future` will return an error.
  Future<Position> _determinePosition() async {
    bool serviceEnabled;
    LocationPermission permission;

    // Test if location services are enabled.
    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      // Location services are not enabled don't continue
      // accessing the position and request users of the
      // App to enable the location services.
      return Future.error('Location services are disabled.');
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        // Permissions are denied, next time you could try
        // requesting permissions again (this is also where
        // Android's shouldShowRequestPermissionRationale
        // returned true. According to Android guidelines
        // your App should show an explanatory UI now.
        return Future.error('Location permissions are denied');
      }
    }

    if (permission == LocationPermission.deniedForever) {
      // Permissions are denied forever, handle appropriately.
      return Future.error(
          'Location permissions are permanently denied, we cannot request permissions.');
    }

    // When we reach here, permissions are granted and we can
    // continue accessing the position of the device.
    return await Geolocator.getCurrentPosition();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              "Offline Home",
              style: TextStyle(color: Colors.white, fontSize: 24),
            ),
            IconButton(
                onPressed: () {
                  Route newRoute = MaterialPageRoute(
                      builder: (_) => const OfflineSettings());
                  Navigator.pushReplacement(context, newRoute);
                },
                icon: const Icon(
                  Icons.settings,
                  color: Colors.white,
                )),
          ],
        ),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(
            child: StreamBuilder<List<OfflineYojana>>(
              stream: service.listenToOfflineYojana(),
              builder: (context, AsyncSnapshot snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(
                    child: CircularProgressIndicator(),
                  );
                }
                if (snapshot.hasData) {
                  List<OfflineYojana> offlineYojanaList = snapshot.data;

                  return ListView.builder(
                      shrinkWrap: true,
                      itemCount: snapshot.data?.length ?? 0,
                      itemBuilder: (context, index) {
                        return InkWell(
                            onTap: () {
                              Route newRoute = MaterialPageRoute(
                                  builder: (_) => OfflineYojanaDetail(
                                    yojanaModel: YojanaModel(
                                      id: offlineYojanaList[index].yojanaId,
                                        activityName:
                                        offlineYojanaList[index].activityName,
                                        budgetBiniyojanType:
                                        offlineYojanaList[index]
                                            .budgetBiniyojanType,
                                        karchaSrishak:
                                        offlineYojanaList[index].karchaSrishak,
                                        kharchaUpaSirshak: offlineYojanaList[index]
                                            .kharchaUpaSirshak,
                                        planningProgram: offlineYojanaList[index]
                                            .planningProgram,
                                        sanketNo: offlineYojanaList[index].sanketNo,
                                        serialNo: offlineYojanaList[index].serialNo,
                                        sourceOfFund:
                                        offlineYojanaList[index].sourceOfFund,
                                        yearlyBudget: offlineYojanaList[index].yearly)
                                  ));
                              Navigator.pushReplacement(context, newRoute);
                            },
                            child: OfflineYojanaCard(
                                yojanaModel: YojanaModel(
                                    id: offlineYojanaList[index].yojanaId,
                                    activityName:
                                        offlineYojanaList[index].activityName,
                                    budgetBiniyojanType:
                                        offlineYojanaList[index]
                                            .budgetBiniyojanType,
                                    karchaSrishak:
                                        offlineYojanaList[index].karchaSrishak,
                                    kharchaUpaSirshak: offlineYojanaList[index]
                                        .kharchaUpaSirshak,
                                    planningProgram: offlineYojanaList[index]
                                        .planningProgram,
                                    sanketNo: offlineYojanaList[index].sanketNo,
                                    serialNo: offlineYojanaList[index].serialNo,
                                    sourceOfFund:
                                        offlineYojanaList[index].sourceOfFund,
                                    yearlyBudget: offlineYojanaList[index].yearly)));
                      });
                } else {
                  return const Center(
                    child: Text(
                        "There is no record of offline yojana assigned to you yet"),
                  );
                }
              },
            ),
          )
        ],
      ),
    );
  }
}

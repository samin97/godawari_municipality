import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:smart_attendance/main_screen/employee_home_screen.dart';
import 'package:smart_attendance/main_screen/yojana_anugaman/online_yojana/yojana_list.dart';
import 'package:smart_attendance/main_screen/yojana_anugaman/online_yojana/yojana_options.dart';

import '../../../global/widgets/error_dialog.dart';
import '../../../local_db/isarServices.dart';


class YojanaMain extends StatefulWidget {
  const YojanaMain({Key? key}) : super(key: key);

  @override
  State<YojanaMain> createState() => _YojanaMainState();
}

class _YojanaMainState extends State<YojanaMain> {

  final service = IsarService();

  @override
  void initState() {
    super.initState();
    _determinePosition();
    handleLocationPermission();
    service.deleteAllOfflineYojana();
  }

  Future<bool> _onWillPop() async {
    return false;
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
    return WillPopScope(
      onWillPop: _onWillPop,
      child: Scaffold(
        appBar: AppBar(
          title: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [

              IconButton(
                  onPressed: () {
                    Route newRoute =
                    MaterialPageRoute(builder: (_) => const EmployeeHomeScreen());
                    Navigator.pushReplacement(context, newRoute);
                  },
                  icon: const Icon(
                    Icons.arrow_back,
                    color: Colors.white,
                  )),
              const Text(
                'Yojana Anugaman',
                style: TextStyle(
                  fontSize: 30,
                  color: Colors.white,
                ),
              ),
              IconButton(
                  onPressed: () {
                    Route newRoute = MaterialPageRoute(
                        builder: (_) => const YojanaOptions());
                    Navigator.pushReplacement(context, newRoute);
                  },
                  icon: const Icon(
                    Icons.more_vert,
                    color: Colors.white,
                  )),
            ],
          ),
          centerTitle: true,
          automaticallyImplyLeading: false,
        ),
        body: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Yojana list',style: TextStyle(fontSize: 20),),
              YojanaList(),

            ],
          ),
        ),
      ),
    );
  }
}

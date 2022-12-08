import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../global/global.dart';
import '../../models/location_permission_model.dart';

Future<LocationModel> fetchLocation() async {
  final token = sharedPreferences!.getString("token")!;
  final response = await http.get(
    Uri.parse('http://mis.godawarimun.gov.np/Api/Attendence/GetAttendenceArea'),
    headers: <String, String>{
      'Content-Type': 'application/json; charset=UTF-8',
      'Authorization': 'Bearer $token',
    },
  );
  if (response.statusCode == 200) {

    LocationModel location = LocationModel.fromJson(jsonDecode(response.body));
    return location;
  } else {
    throw Exception('Failed to load attendance log');
  }
}
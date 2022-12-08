import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../global/global.dart';
import '../../models/attendance_model.dart';

Future<List<AttendanceModel>> fetchAttendance() async {
  final token = sharedPreferences!.getString("token")!;
  final response = await http.get(
    Uri.parse('http://mis.godawarimun.gov.np/Api/Attendence/GetAttendence'),
    headers: <String, String>{
      'Content-Type': 'application/json; charset=UTF-8',
      'Authorization': 'Bearer $token',
    },
  );
  if (response.statusCode == 200) {
    List<dynamic> parsed = json.decode(response.body).cast<Map<String, dynamic>>();
    List<AttendanceModel> list =[];
    list = parsed.map((json) => AttendanceModel.fromJson(json)).toList();
    return list;
  } else {
    throw Exception('Failed to load attendance log');
  }
}
final String tableAttendance = 'offlineAttendance';

class AttendanceFields {
  static final List<String> values = [
    /// Add all fields
    id,
    nepaliDate,
    englishDate,
    time,
    status,
    longitude,
    latitude,
    deviceID,
    phone
  ];

  static final String id = '_id';
  static final String nepaliDate = 'nepaliDate';
  static final String englishDate = 'englishDate';
  static final String time = 'time';
  static final String status = 'status';
  static final String longitude = 'longitude';
  static final String latitude = 'latitude';
  static final String deviceID = 'deviceID';
  static final String phone = 'phone';
}

class OfflineAttendance {
  final int? id;
  final String nepaliDate;
  final String englishDate;
  final String time;
  final String status;
  final String longitude;
  final String latitude;
  final String deviceID;
  final String phone;

  const OfflineAttendance({
    this.id,
    required this.nepaliDate,
    required this.englishDate,
    required this.time,
    required this.status,
    required this.longitude,
    required this.latitude,
    required this.deviceID,
    required this.phone,
  });

  OfflineAttendance copy({
    int? id,
    String? nepaliDate,
    String? englishDate,
    String? time,
    String? status,
    String? longitude,
    String? latitude,
    String? deviceID,
    String? phone,
  }) =>
      OfflineAttendance(
        id: id ?? this.id,
        nepaliDate: nepaliDate ?? this.nepaliDate,
        englishDate: englishDate ?? this.englishDate,
        time: time ?? this.time,
        status: status ?? this.status,
        longitude: longitude ?? this.longitude,
        latitude: latitude ?? this.latitude,
        deviceID: deviceID ?? this.deviceID,
        phone: phone ?? this.phone,
      );

  static OfflineAttendance fromJson(Map<String, Object?> json) =>
      OfflineAttendance(
        id: json[AttendanceFields.id] as int?,
        nepaliDate: json[AttendanceFields.nepaliDate] as String,
        englishDate: json[AttendanceFields.englishDate] as String,
        time: json[AttendanceFields.time] as String,
        status: json[AttendanceFields.status] as String,
        longitude: json[AttendanceFields.longitude] as String,
        latitude: json[AttendanceFields.latitude] as String,
        deviceID: json[AttendanceFields.deviceID] as String,
        phone: json[AttendanceFields.phone] as String,
      );

  Map<String, Object?> toJson() => {
        AttendanceFields.id: id,
        AttendanceFields.nepaliDate: nepaliDate,
        AttendanceFields.englishDate: englishDate,
        AttendanceFields.time: time,
        AttendanceFields.status: status,
        AttendanceFields.longitude: longitude,
        AttendanceFields.latitude: latitude,
        AttendanceFields.deviceID: deviceID,
        AttendanceFields.phone: phone,
      };
}

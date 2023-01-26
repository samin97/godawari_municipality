import 'dart:convert';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

import '../../../models/offline_attendance_model.dart';

class OfflineDB {
  static final OfflineDB instance = OfflineDB._init();
  static Database? _database;

  OfflineDB._init();

  Future<Database> get database async {
    if (_database != null) return _database!;

    _database = await _initDB('attendance.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);

    return await openDatabase(path, version: 1, onCreate: _createDB);
  }

  Future _createDB(Database db, int version) async {
    final idType = 'INTEGER PRIMARY KEY AUTOINCREMENT';
    final textType = 'TEXT NOT NULL';

    await db.execute('''
      CREATE TABLE $tableAttendance(
      ${AttendanceFields.id} $idType,
      ${AttendanceFields.nepaliDate} $textType,      
      ${AttendanceFields.englishDate} $textType,      
      ${AttendanceFields.time} $textType,      
      ${AttendanceFields.status} $textType,      
      ${AttendanceFields.longitude} $textType,      
      ${AttendanceFields.latitude} $textType,      
      ${AttendanceFields.deviceID} $textType,      
      ${AttendanceFields.phone} $textType       
      )
    ''');
  }

  Future<OfflineAttendance> create(OfflineAttendance offlineAttendance) async {
    final db = await instance.database;
    final id = await db.insert(tableAttendance, offlineAttendance.toJson());
    print('attendance added');
    return offlineAttendance.copy(id: id);

  }

  Future<OfflineAttendance> readAttendance(int id) async {
    final db = await instance.database;
    final maps = await db.query(
      tableAttendance,
      columns: AttendanceFields.values,
      where: '${AttendanceFields.id}= ?',
      whereArgs: [id],
    );
    if (maps.isNotEmpty) {
      return OfflineAttendance.fromJson(maps.first);
    } else {
      throw Exception('ID $id not found');
    }
  }

  Future<List<OfflineAttendance>> readAllAttendance() async {
    final db = await instance.database;
    final orderBy = '${AttendanceFields.id} ASC';
    final result = await db.query(tableAttendance, orderBy: orderBy);
    return result.map((json) => OfflineAttendance.fromJson(json)).toList();
  }

  Future<int> update(OfflineAttendance offlineAttendance) async {
    final db = await instance.database;
    return db.update(
      tableAttendance,
      offlineAttendance.toJson(),
      where: '${AttendanceFields.id} = ?',
      whereArgs: [offlineAttendance.id],
    );
  }

  Future<int> delete(int id) async {
    final db = await instance.database;

    return await db.delete(
      tableAttendance,
      where: '${AttendanceFields.id} = ?',
      whereArgs: [id],
    );
  }

  Future close() async {
    final db = await instance.database;
    db.close();
  }
}

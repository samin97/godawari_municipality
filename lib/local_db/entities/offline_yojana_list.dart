
import 'dart:typed_data';

import 'package:isar/isar.dart';

part 'offline_yojana_list.g.dart';

@Collection()


class OfflineYojana{
  Id id = Isar.autoIncrement;
  late int yojanaId;
  late String activityName;
  late String serialNo;
  late String karchaSrishak;
  late String kharchaUpaSirshak;
  late String sanketNo;
  late String sourceOfFund;
  late String budgetBiniyojanType;
  late String planningProgram;
  late String yearly;
}
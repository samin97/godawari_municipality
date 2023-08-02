

import 'package:isar/isar.dart';

part 'yojana_draft.g.dart';

@Collection()


class YojanaDraft{
  Id id = Isar.autoIncrement;
  late int yojanaId;
  late String activityName;
  late String yojanaDate;
  late String yojanaTypeSelected;
  late String description;
  late String previousSuggestion;
  late String description2;
  late String counselorRepresentative;
  late String counselorRepresentativePhone;
  late String latitude;
  late String longitude;
  late String condition;
  late String image1;
  late String image2;
  late String image3;

}

import 'dart:convert';

AddMemberModel addMemberModelFromJson(String str) => AddMemberModel.fromJson(json.decode(str));

String addMemberModelToJson(AddMemberModel data) => json.encode(data.toJson());

class AddMemberModel {
  String? id;
  String? name;
  bool? isAssigned;

  AddMemberModel({
     this.id,
     this.name,
     this.isAssigned,
  });

  factory AddMemberModel.fromJson(Map<String, dynamic> json) => AddMemberModel(
    id: json["id"],
    name: json["name"],
    isAssigned: json["include"],
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "name": name,
    "include": isAssigned,
  };
}
import 'dart:convert';

import 'package:flutter/foundation.dart';

class ShapeTable {
  int? sId;
  String? shapeName;
  Uint8List? shapeImage;
  bool isSelected;


  ShapeTable({
    this.sId,
    this.shapeName,
    this.shapeImage,
    this.isSelected=false
  });

  factory ShapeTable.fromRawJson(String str) =>
      ShapeTable.fromJson(json.decode(str));

  String toRawJson() => json.encode(toJson());

  factory ShapeTable.fromJson(Map<String, dynamic> json) => ShapeTable(
    sId: json["sId"],
    shapeName: json["ShapeName"],
    shapeImage: json["ShapeImage"],
    isSelected: json["isSelected"]??false,
  );

  Map<String, dynamic> toJson() =>
      {
        "sId": sId,
        "ShapeName": shapeName,
        "ShapeImage": shapeImage,
        "isSelected": isSelected,
      };
}













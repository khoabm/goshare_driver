import 'dart:convert';

import 'package:flutter/widgets.dart';

class DriverPersonalInformationModel {
  final int ratingNum;
  final double rating;
  final double dailyIncome;
  final DateTime? dueDate;
  DriverPersonalInformationModel({
    required this.ratingNum,
    required this.rating,
    required this.dailyIncome,
    this.dueDate,
  });

  DriverPersonalInformationModel copyWith({
    int? ratingNum,
    double? rating,
    double? dailyIncome,
    ValueGetter<DateTime?>? dueDate,
  }) {
    return DriverPersonalInformationModel(
      ratingNum: ratingNum ?? this.ratingNum,
      rating: rating ?? this.rating,
      dailyIncome: dailyIncome ?? this.dailyIncome,
      dueDate: dueDate?.call() ?? this.dueDate,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'ratingNum': ratingNum,
      'rating': rating,
      'dailyIncome': dailyIncome,
      'dueDate': dueDate?.millisecondsSinceEpoch,
    };
  }

  factory DriverPersonalInformationModel.fromMap(Map<String, dynamic> map) {
    return DriverPersonalInformationModel(
      ratingNum: map['ratingNum']?.toInt() ?? 0,
      rating: map['rating']?.toDouble() ?? 0.0,
      dailyIncome: map['dailyIncome']?.toDouble() ?? 0.0,
      dueDate: map['dueDate'] != null
          ? DateTime.fromMillisecondsSinceEpoch(
              DateTime.parse(map['dueDate']).millisecondsSinceEpoch,
            )
          : null,
    );
  }

  String toJson() => json.encode(toMap());

  factory DriverPersonalInformationModel.fromJson(String source) =>
      DriverPersonalInformationModel.fromMap(json.decode(source));

  @override
  String toString() {
    return 'DriverPersonalInformationModel(ratingNum: $ratingNum, rating: $rating, dailyIncome: $dailyIncome, dueDate: $dueDate)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is DriverPersonalInformationModel &&
        other.ratingNum == ratingNum &&
        other.rating == rating &&
        other.dailyIncome == dailyIncome &&
        other.dueDate == dueDate;
  }

  @override
  int get hashCode {
    return ratingNum.hashCode ^
        rating.hashCode ^
        dailyIncome.hashCode ^
        dueDate.hashCode;
  }
}

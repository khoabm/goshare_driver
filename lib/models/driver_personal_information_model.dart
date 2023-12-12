import 'dart:convert';

class DriverPersonalInformationModel {
  final int ratingNum;
  final double rating;
  final double dailyIncome;
  DriverPersonalInformationModel({
    required this.ratingNum,
    required this.rating,
    required this.dailyIncome,
  });

  DriverPersonalInformationModel copyWith({
    int? ratingNum,
    double? rating,
    double? dailyIncome,
  }) {
    return DriverPersonalInformationModel(
      ratingNum: ratingNum ?? this.ratingNum,
      rating: rating ?? this.rating,
      dailyIncome: dailyIncome ?? this.dailyIncome,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'ratingNum': ratingNum,
      'rating': rating,
      'dailyIncome': dailyIncome,
    };
  }

  factory DriverPersonalInformationModel.fromMap(Map<String, dynamic> map) {
    return DriverPersonalInformationModel(
      ratingNum: map['ratingNum']?.toInt() ?? 0,
      rating: map['rating']?.toDouble() ?? 0.0,
      dailyIncome: map['dailyIncome']?.toDouble() ?? 0.0,
    );
  }

  String toJson() => json.encode(toMap());

  factory DriverPersonalInformationModel.fromJson(String source) =>
      DriverPersonalInformationModel.fromMap(json.decode(source));

  @override
  String toString() =>
      'DriverPersonalInformationModel(ratingNum: $ratingNum, rating: $rating, dailyIncome: $dailyIncome)';

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is DriverPersonalInformationModel &&
        other.ratingNum == ratingNum &&
        other.rating == rating &&
        other.dailyIncome == dailyIncome;
  }

  @override
  int get hashCode =>
      ratingNum.hashCode ^ rating.hashCode ^ dailyIncome.hashCode;
}

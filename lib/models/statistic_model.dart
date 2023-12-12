import 'dart:convert';

class StatisticModel {
  final int month;
  final double monthTotal;
  final double weekAverage;
  final double compareToLastMonth;
  StatisticModel({
    required this.month,
    required this.monthTotal,
    required this.weekAverage,
    required this.compareToLastMonth,
  });

  StatisticModel copyWith({
    int? month,
    double? monthTotal,
    double? weekAverage,
    double? compareToLastMonth,
  }) {
    return StatisticModel(
      month: month ?? this.month,
      monthTotal: monthTotal ?? this.monthTotal,
      weekAverage: weekAverage ?? this.weekAverage,
      compareToLastMonth: compareToLastMonth ?? this.compareToLastMonth,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'month': month,
      'monthTotal': monthTotal,
      'weekAverage': weekAverage,
      'compareToLastMonth': compareToLastMonth,
    };
  }

  factory StatisticModel.fromMap(Map<String, dynamic> map) {
    return StatisticModel(
      month: map['month']?.toInt() ?? 0,
      monthTotal: map['monthTotal']?.toDouble() ?? 0.0,
      weekAverage: map['weekAverage']?.toDouble() ?? 0.0,
      compareToLastMonth: map['compareToLastMonth']?.toDouble() ?? 0.0,
    );
  }

  String toJson() => json.encode(toMap());

  factory StatisticModel.fromJson(String source) =>
      StatisticModel.fromMap(json.decode(source));

  @override
  String toString() {
    return 'StatisticModel(month: $month, monthTotal: $monthTotal, weekAverage: $weekAverage, compareToLastMonth: $compareToLastMonth)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is StatisticModel &&
        other.month == month &&
        other.monthTotal == monthTotal &&
        other.weekAverage == weekAverage &&
        other.compareToLastMonth == compareToLastMonth;
  }

  @override
  int get hashCode {
    return month.hashCode ^
        monthTotal.hashCode ^
        weekAverage.hashCode ^
        compareToLastMonth.hashCode;
  }
}

import 'dart:convert';

class TripType {
  final int value;
  TripType({
    required this.value,
  });

  const TripType._(this.value);

  static const selfBook = TripType._(0);
  static const bookForDepWithApp = TripType._(1);
  static const bookForDepNoApp = TripType._(2);

  TripType copyWith({
    int? value,
  }) {
    return TripType(
      value: value ?? this.value,
    );
  }

  Map<String, int> toMap() {
    return {
      'selfBook': selfBook.value,
      'bookForDepWithApp': bookForDepWithApp.value,
      'bookForDepNoApp': bookForDepNoApp.value,
    };
  }

  factory TripType.fromMap(Map<String, int> map) {
    int? value = map['value'];
    if (value != null) {
      switch (value) {
        case 0:
          return selfBook;
        case 1:
          return bookForDepWithApp;
        case 2:
          return bookForDepNoApp;
        default:
          throw Exception('Invalid value for TripType');
      }
    } else {
      throw Exception('Value key not found in map');
    }
  }

  String toJson() => json.encode(toMap());

  factory TripType.fromJson(String source) =>
      TripType.fromMap(json.decode(source));

  @override
  String toString() => 'TripType(value: $value)';

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is TripType && other.value == value;
  }

  @override
  int get hashCode => value.hashCode;
}

class TripType {
  final int value;

  const TripType._(this.value);

  static const selfBook = TripType._(0);
  static const bookForDepWithApp = TripType._(1);
  static const bookForDepNoApp = TripType._(2);
}

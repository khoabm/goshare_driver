import 'dart:convert';

import 'package:goshare_driver/models/trip_model.dart';

class EndTripModel {
  final String id;
  final String passengerId;
  final String driverId;
  final String startLocationId;
  final String endLocationId;
  // int startTime;
  // int endTime;
  // int pickupTime;
  final double distance;
  final double price;
  final String cartypeId;
  final int status;
  // int createTime;
  // int updatedTime;
  final int paymentMethod;
  final String bookerId;
  String? note;
  // Driver driver;
  final Passenger passenger;
  final Booker booker;
  final EndLocation endLocation;
  final StartLocation startLocation;
  final CarType cartype;
  final int type;
  final double systemCommission;
  EndTripModel({
    required this.id,
    required this.passengerId,
    required this.driverId,
    required this.startLocationId,
    required this.endLocationId,
    required this.distance,
    required this.price,
    required this.cartypeId,
    required this.status,
    required this.paymentMethod,
    required this.bookerId,
    this.note,
    required this.passenger,
    required this.booker,
    required this.endLocation,
    required this.startLocation,
    required this.cartype,
    required this.type,
    required this.systemCommission,
  });

  EndTripModel copyWith({
    String? id,
    String? passengerId,
    String? driverId,
    String? startLocationId,
    String? endLocationId,
    double? distance,
    double? price,
    String? cartypeId,
    int? status,
    int? paymentMethod,
    String? bookerId,
    String? note,
    Passenger? passenger,
    Booker? booker,
    EndLocation? endLocation,
    StartLocation? startLocation,
    CarType? cartype,
    int? type,
    double? systemCommission,
  }) {
    return EndTripModel(
      id: id ?? this.id,
      passengerId: passengerId ?? this.passengerId,
      driverId: driverId ?? this.driverId,
      startLocationId: startLocationId ?? this.startLocationId,
      endLocationId: endLocationId ?? this.endLocationId,
      distance: distance ?? this.distance,
      price: price ?? this.price,
      cartypeId: cartypeId ?? this.cartypeId,
      status: status ?? this.status,
      paymentMethod: paymentMethod ?? this.paymentMethod,
      bookerId: bookerId ?? this.bookerId,
      note: note ?? this.note,
      passenger: passenger ?? this.passenger,
      booker: booker ?? this.booker,
      endLocation: endLocation ?? this.endLocation,
      startLocation: startLocation ?? this.startLocation,
      cartype: cartype ?? this.cartype,
      type: type ?? this.type,
      systemCommission: systemCommission ?? this.systemCommission,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'passengerId': passengerId,
      'driverId': driverId,
      'startLocationId': startLocationId,
      'endLocationId': endLocationId,
      'distance': distance,
      'price': price,
      'cartypeId': cartypeId,
      'status': status,
      'paymentMethod': paymentMethod,
      'bookerId': bookerId,
      'note': note,
      'passenger': passenger.toMap(),
      'booker': booker.toMap(),
      'endLocation': endLocation.toMap(),
      'startLocation': startLocation.toMap(),
      'cartype': cartype.toMap(),
      'type': type,
      'systemCommission': systemCommission,
    };
  }

  factory EndTripModel.fromMap(Map<String, dynamic> map) {
    return EndTripModel(
      id: map['id'] ?? '',
      passengerId: map['passengerId'] ?? '',
      driverId: map['driverId'] ?? '',
      startLocationId: map['startLocationId'] ?? '',
      endLocationId: map['endLocationId'] ?? '',
      distance: map['distance']?.toDouble() ?? 0.0,
      price: map['price']?.toDouble() ?? 0.0,
      cartypeId: map['cartypeId'] ?? '',
      status: map['status']?.toInt() ?? 0,
      paymentMethod: map['paymentMethod']?.toInt() ?? 0,
      bookerId: map['bookerId'] ?? '',
      note: map['note'],
      passenger: Passenger.fromMap(map['passenger']),
      booker: Booker.fromMap(map['booker']),
      endLocation: EndLocation.fromMap(map['endLocation']),
      startLocation: StartLocation.fromMap(map['startLocation']),
      cartype: CarType.fromMap(map['cartype']),
      type: map['type']?.toInt() ?? 0,
      systemCommission: map['systemCommission']?.toDouble() ?? 0.0,
    );
  }

  String toJson() => json.encode(toMap());

  factory EndTripModel.fromJson(String source) =>
      EndTripModel.fromMap(json.decode(source));

  @override
  String toString() {
    return 'EndTripModel(id: $id, passengerId: $passengerId, driverId: $driverId, startLocationId: $startLocationId, endLocationId: $endLocationId, distance: $distance, price: $price, cartypeId: $cartypeId, status: $status, paymentMethod: $paymentMethod, bookerId: $bookerId, note: $note, passenger: $passenger, booker: $booker, endLocation: $endLocation, startLocation: $startLocation, cartype: $cartype, type: $type, systemCommission: $systemCommission)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is EndTripModel &&
        other.id == id &&
        other.passengerId == passengerId &&
        other.driverId == driverId &&
        other.startLocationId == startLocationId &&
        other.endLocationId == endLocationId &&
        other.distance == distance &&
        other.price == price &&
        other.cartypeId == cartypeId &&
        other.status == status &&
        other.paymentMethod == paymentMethod &&
        other.bookerId == bookerId &&
        other.note == note &&
        other.passenger == passenger &&
        other.booker == booker &&
        other.endLocation == endLocation &&
        other.startLocation == startLocation &&
        other.cartype == cartype &&
        other.type == type &&
        other.systemCommission == systemCommission;
  }

  @override
  int get hashCode {
    return id.hashCode ^
        passengerId.hashCode ^
        driverId.hashCode ^
        startLocationId.hashCode ^
        endLocationId.hashCode ^
        distance.hashCode ^
        price.hashCode ^
        cartypeId.hashCode ^
        status.hashCode ^
        paymentMethod.hashCode ^
        bookerId.hashCode ^
        note.hashCode ^
        passenger.hashCode ^
        booker.hashCode ^
        endLocation.hashCode ^
        startLocation.hashCode ^
        cartype.hashCode ^
        type.hashCode ^
        systemCommission.hashCode;
  }
}

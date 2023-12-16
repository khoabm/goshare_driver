import 'dart:convert';
import 'package:flutter/widgets.dart';

class Trip {
  final String id;
  final String passengerId;
  final String driverId;
  final String startLocationId;
  final String endLocationId;
  final DateTime startTime;
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
  Trip({
    required this.id,
    required this.passengerId,
    required this.driverId,
    required this.startLocationId,
    required this.endLocationId,
    required this.startTime,
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
  });

  Trip copyWith({
    String? id,
    String? passengerId,
    String? driverId,
    String? startLocationId,
    String? endLocationId,
    DateTime? startTime,
    double? distance,
    double? price,
    String? cartypeId,
    int? status,
    int? paymentMethod,
    String? bookerId,
    ValueGetter<String?>? note,
    Passenger? passenger,
    Booker? booker,
    EndLocation? endLocation,
    StartLocation? startLocation,
    CarType? cartype,
    int? type,
  }) {
    return Trip(
      id: id ?? this.id,
      passengerId: passengerId ?? this.passengerId,
      driverId: driverId ?? this.driverId,
      startLocationId: startLocationId ?? this.startLocationId,
      endLocationId: endLocationId ?? this.endLocationId,
      startTime: startTime ?? this.startTime,
      distance: distance ?? this.distance,
      price: price ?? this.price,
      cartypeId: cartypeId ?? this.cartypeId,
      status: status ?? this.status,
      paymentMethod: paymentMethod ?? this.paymentMethod,
      bookerId: bookerId ?? this.bookerId,
      note: note?.call() ?? this.note,
      passenger: passenger ?? this.passenger,
      booker: booker ?? this.booker,
      endLocation: endLocation ?? this.endLocation,
      startLocation: startLocation ?? this.startLocation,
      cartype: cartype ?? this.cartype,
      type: type ?? this.type,
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
    };
  }

  factory Trip.fromMap(Map<String, dynamic> map) {
    return Trip(
      id: map['id'] ?? '',
      passengerId: map['passengerId'] ?? '',
      driverId: map['driverId'] ?? '',
      startLocationId: map['startLocationId'] ?? '',
      endLocationId: map['endLocationId'] ?? '',
      startTime: DateTime.fromMillisecondsSinceEpoch(
        DateTime.parse(map['startTime']).millisecondsSinceEpoch,
      ),
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
    );
  }

  String toJson() => json.encode(toMap());

  factory Trip.fromJson(String source) => Trip.fromMap(json.decode(source));

  @override
  String toString() {
    return 'Trip(id: $id, passengerId: $passengerId, driverId: $driverId, startLocationId: $startLocationId, endLocationId: $endLocationId, distance: $distance, price: $price, cartypeId: $cartypeId, status: $status, paymentMethod: $paymentMethod, bookerId: $bookerId, note: $note, passenger: $passenger, booker: $booker, endLocation: $endLocation, startLocation: $startLocation, cartype: $cartype, type: $type)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is Trip &&
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
        other.type == type;
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
        type.hashCode;
  }
}

class Passenger {
  final String id;
  final String name;
  final String phone;
  final String? avatarUrl;
  Passenger({
    required this.id,
    required this.name,
    required this.phone,
    this.avatarUrl,
  });
  //final "guardianId": "{string}",
  //"status": {int},
  //"createTime": "{timestamp}",
  //"updatedTime": "{timestamp}",
  //"gender": {int},
  //"birth": "{timestamp}",
  //"car": {},
  //"guardian": {}

  Passenger copyWith({
    String? id,
    String? name,
    String? phone,
    ValueGetter<String?>? avatarUrl,
  }) {
    return Passenger(
      id: id ?? this.id,
      name: name ?? this.name,
      phone: phone ?? this.phone,
      avatarUrl: avatarUrl?.call() ?? this.avatarUrl,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'phone': phone,
      'avatarUrl': avatarUrl,
    };
  }

  factory Passenger.fromMap(Map<String, dynamic> map) {
    return Passenger(
      id: map['id'] ?? '',
      name: map['name'] ?? '',
      phone: map['phone'] ?? '',
      avatarUrl: map['avatarUrl'],
    );
  }

  String toJson() => json.encode(toMap());

  factory Passenger.fromJson(String source) =>
      Passenger.fromMap(json.decode(source));
}

class Booker {
  final String id;
  final String name;
  final String phone;
  final String? avatarUrl;
  Booker({
    required this.id,
    required this.name,
    required this.phone,
    this.avatarUrl,
  });

  Booker copyWith({
    String? id,
    String? name,
    String? phone,
    ValueGetter<String?>? avatarUrl,
  }) {
    return Booker(
      id: id ?? this.id,
      name: name ?? this.name,
      phone: phone ?? this.phone,
      avatarUrl: avatarUrl?.call() ?? this.avatarUrl,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'phone': phone,
      'avatarUrl': avatarUrl,
    };
  }

  factory Booker.fromMap(Map<String, dynamic> map) {
    return Booker(
      id: map['id'] ?? '',
      name: map['name'] ?? '',
      phone: map['phone'] ?? '',
      avatarUrl: map['avatarUrl'],
    );
  }

  String toJson() => json.encode(toMap());

  factory Booker.fromJson(String source) => Booker.fromMap(json.decode(source));
}

class EndLocation {
  final String id;
  final String userId;
  final String address;
  final double latitude;
  final double longitude;
  EndLocation({
    required this.id,
    required this.userId,
    required this.address,
    required this.latitude,
    required this.longitude,
  });

  EndLocation copyWith({
    String? id,
    String? userId,
    String? address,
    double? latitude,
    double? longitude,
  }) {
    return EndLocation(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      address: address ?? this.address,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'userId': userId,
      'address': address,
      'latitude': latitude,
      'longitude': longitude,
    };
  }

  factory EndLocation.fromMap(Map<String, dynamic> map) {
    return EndLocation(
      id: map['id'] ?? '',
      userId: map['userId'] ?? '',
      address: map['address'] ?? '',
      latitude: map['latitude']?.toDouble() ?? 0.0,
      longitude: map['longitude']?.toDouble() ?? 0.0,
    );
  }

  String toJson() => json.encode(toMap());

  factory EndLocation.fromJson(String source) =>
      EndLocation.fromMap(json.decode(source));
}

class StartLocation {
  final String id;
  final String userId;
  final String address;
  final double latitude;
  final double longitude;
  StartLocation({
    required this.id,
    required this.userId,
    required this.address,
    required this.latitude,
    required this.longitude,
  });

  StartLocation copyWith({
    String? id,
    String? userId,
    String? address,
    double? latitude,
    double? longitude,
  }) {
    return StartLocation(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      address: address ?? this.address,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'userId': userId,
      'address': address,
      'latitude': latitude,
      'longitude': longitude,
    };
  }

  factory StartLocation.fromMap(Map<String, dynamic> map) {
    return StartLocation(
      id: map['id'] ?? '',
      userId: map['userId'] ?? '',
      address: map['address'] ?? '',
      latitude: map['latitude']?.toDouble() ?? 0.0,
      longitude: map['longitude']?.toDouble() ?? 0.0,
    );
  }

  String toJson() => json.encode(toMap());

  factory StartLocation.fromJson(String source) =>
      StartLocation.fromMap(json.decode(source));
}

class CarType {
  final int capacity;
  CarType({
    required this.capacity,
  });

  CarType copyWith({
    int? capacity,
  }) {
    return CarType(
      capacity: capacity ?? this.capacity,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'capacity': capacity,
    };
  }

  factory CarType.fromMap(Map<String, dynamic> map) {
    return CarType(
      capacity: map['capacity']?.toInt() ?? 0,
    );
  }

  String toJson() => json.encode(toMap());

  factory CarType.fromJson(String source) =>
      CarType.fromMap(json.decode(source));
}

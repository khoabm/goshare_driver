import 'dart:async';
import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fpdart/fpdart.dart';
import 'package:goshare_driver/core/constants/constants.dart';
import 'package:goshare_driver/core/failure.dart';
import 'package:goshare_driver/core/type_def.dart';
import 'package:goshare_driver/core/utils/http_utils.dart';
import 'package:goshare_driver/models/transaction_model.dart';
import 'package:shared_preferences/shared_preferences.dart';

final moneyTopupRepositoryProvider = Provider(
  (ref) => MoneyTopupRepository(
    baseUrl: Constants.apiBaseUrl,
  ),
);

class BalanceResult {
  final String? balance;
  final String? error;

  BalanceResult({this.balance, this.error});
}

class TransactionResult {
  final String? id;
  final String? tripId;
  final int? amount;
  final String? paymentMethod;
  final String? externalTransactionId;
  final String? status;
  final String? type;
  final String? createTime;

  TransactionResult(
      {this.id,
      this.tripId,
      this.amount,
      this.paymentMethod,
      this.externalTransactionId,
      this.status,
      this.type,
      this.createTime});
}

class MoneyTopupRepository {
  final String baseUrl;

  MoneyTopupRepository({required this.baseUrl});

  Future<BalanceResult> getBalance() async {
    try {
      final SharedPreferences prefs = await SharedPreferences.getInstance();
      final accessToken = prefs.getString('driverAccessToken');

      final client = HttpClientWithAuth(accessToken ?? '');
      final res = await client.get(
        Uri.parse('$baseUrl/wallet'),
        headers: {
          'Content-Type': 'application/json',
        },
      );
      if (res.statusCode == 200) {
        return BalanceResult(balance: res.body);
      } else {
        return BalanceResult(error: "Fail to get balance");
      }
    } catch (_) {
      return BalanceResult(error: "Fail to get balance");
    }
  }

  FutureEither<WalletTransactionModel> getWalletTransaction(
    String sortBy,
    int page,
    int pageSize,
  ) async {
    try {
      final SharedPreferences prefs = await SharedPreferences.getInstance();
      final accessToken = prefs.getString('driverAccessToken');
      final client = HttpClientWithAuth(accessToken ?? '');
      final response = await client.get(
        Uri.parse(
            '$baseUrl/wallettransaction?sortBy=$sortBy&page=$page&pageSize=$pageSize'),
        headers: {
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        Map<String, dynamic> walletTransactionData = json.decode(response.body);
        print(walletTransactionData.toString());
        WalletTransactionModel walletTransaction =
            WalletTransactionModel.fromMap(walletTransactionData);

        return right(walletTransaction);
      } else if (response.statusCode == 429) {
        return left(Failure('Too many request'));
      } else if (response.statusCode == 401) {
        return left(UnauthorizedFailure('Unauthorized'));
      } else {
        return left(Failure('Co loi xay ra'));
      }
    } catch (e) {
      return left(Failure(e.toString()));
    }
  }

  Future<List<TransactionResult>> getTransaction() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final accessToken = prefs.getString('driverAccessToken');
    final client = HttpClientWithAuth(accessToken ?? '');
    String baseUrl = Constants.apiBaseUrl;
    final response = await client.get(Uri.parse('$baseUrl/wallettransaction'));

    if (response.statusCode == 200) {
      final decodedData = json.decode(response.body) as List<dynamic>;

      print(decodedData);
      return decodedData.map((item) {
        final id = item['id'] as String?;
        final tripId = item['tripId'] as String?;
        final amount = item['amount'] as int?;
        final paymentMethod = item['paymentMethod'] as String?;
        final externalTransactionId = item['externalTransactionId'] as String?;
        final status = item['status'] as String?;
        final type = item['type'] as String?;
        final createTime = item['createTime'] as String?;

        return TransactionResult(
          id: id,
          tripId: tripId,
          amount: amount,
          paymentMethod: paymentMethod,
          externalTransactionId: externalTransactionId,
          status: status,
          type: type,
          createTime: createTime,
        );
      }).toList();
    } else {
      throw Exception('Failed to load transactions');
    }
  }

  Future<String> moneyTopup(int amount) async {
    try {
      final SharedPreferences prefs = await SharedPreferences.getInstance();
      final accessToken = prefs.getString('driverAccessToken');
      final client = HttpClientWithAuth(accessToken ?? '');
      final response = await client.post(
        Uri.parse('$baseUrl/payment/topup'),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: jsonEncode({'amount': amount, 'method': 0}),
      );

      if (response.statusCode == 200) {
        return response.body;
      } else {
        return "Top up fail";
      }
    } catch (e) {
      return "Top up fail";
    }
  }
}

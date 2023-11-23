import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:shared_preferences/shared_preferences.dart';
import 'package:signalr_core/signalr_core.dart';

final hubConnectionProvider = FutureProvider<HubConnection>((ref) async {
  try {
    print('hubConnection');
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final accessToken = prefs.getString('driverAccessToken');
    print(accessToken);

    return HubConnectionBuilder()
        .withUrl(
          "https://goshareapi.azurewebsites.net/goshareHub?access_token=$accessToken",
        )
        .withAutomaticReconnect()
        .build();
  } catch (e) {
    print(e.toString());
    rethrow; // Re-throw the exception
  }
});

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:signalr_core/signalr_core.dart';

final hubConnectionProvider = Provider<HubConnection>((ref) {
  return HubConnectionBuilder()
      .withUrl(
          "https://goshareapi.azurewebsites.net/goshareHub?userId=7b0ae9e0-013b-4213-9e33-3321fda277b3")
      .build();
});
// final hubConnectionProvider = Provider<HubConnection>((ref) {
//   return HubConnectionBuilder()
//       .withUrl("https://goshareapi.azurewebsites.net/goshareHub")
//       .build();
// });

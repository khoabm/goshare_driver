import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:goshare_driver/common/loader.dart';
import 'package:goshare_driver/core/constants/route_constants.dart';
import 'package:goshare_driver/features/auth/controllers/log_in_controller.dart';
import 'package:goshare_driver/features/auth/screens/sign_in_screen.dart';

import 'package:goshare_driver/firebase_options.dart';
import 'package:goshare_driver/router.dart';
import 'package:goshare_driver/theme/pallet.dart';
import 'package:image_picker_platform_interface/image_picker_platform_interface.dart';
import 'package:image_picker_android/image_picker_android.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  final ImagePickerPlatform imagePickerImplementation =
      ImagePickerPlatform.instance;
  if (imagePickerImplementation is ImagePickerAndroid) {
    imagePickerImplementation.useAndroidPhotoPicker = true;
  }
  runApp(
    const ProviderScope(
      child: MyApp(),
    ),
  );
}

class MyApp extends ConsumerStatefulWidget {
  const MyApp({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _MyAppState();
}

// This widget is the root of your application.
class _MyAppState extends ConsumerState<MyApp> with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    requestPermission();

    initInfor();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    if (state == AppLifecycleState.paused ||
        state == AppLifecycleState.detached) {
      if (ref.watch(userProvider.notifier).state != null) {
        ref.watch(LoginControllerProvider.notifier).driverDeactivate(context);
      }
    }
  }

  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();
  //request notification permission
  void requestPermission() async {
    FirebaseMessaging messaging = FirebaseMessaging.instance;
    NotificationSettings settings = await messaging.requestPermission(
      alert: true,
      announcement: false,
      badge: true,
      carPlay: false,
      criticalAlert: false,
      provisional: false,
      sound: true,
    );

    if (settings.authorizationStatus == AuthorizationStatus.authorized) {
      print("Granted permission.");
    } else if (settings.authorizationStatus ==
        AuthorizationStatus.provisional) {
      print("Granted provisional permission.");
    } else {
      print("Not Granted permission.");
    }
  }

  initInfor() {
    var androidInitialize =
        const AndroidInitializationSettings('@mipmap/ic_launcher');
    var iosInitialize = const DarwinInitializationSettings();
    var initializationSettings =
        InitializationSettings(android: androidInitialize, iOS: iosInitialize);
    flutterLocalNotificationsPlugin.initialize(initializationSettings);

    FirebaseMessaging.onMessage.listen((RemoteMessage message) async {
      BigTextStyleInformation bigTextStyleInformation = BigTextStyleInformation(
        message.notification!.body.toString(),
        htmlFormatBigText: true,
        contentTitle: message.notification!.title.toString(),
        htmlFormatContentTitle: true,
      );
      AndroidNotificationDetails androidPlatformChannelSpecifics =
          AndroidNotificationDetails(
        'dbfood',
        'dbfood',
        importance: Importance.max,
        styleInformation: bigTextStyleInformation,
        priority: Priority.max,
        playSound: false,
      );
      NotificationDetails platformChannelSpecifics = NotificationDetails(
        android: androidPlatformChannelSpecifics,
        iOS: const DarwinNotificationDetails(),
      );
      await flutterLocalNotificationsPlugin.show(0, message.notification?.title,
          message.notification?.body, platformChannelSpecifics,
          payload: message.data['body']);
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: "Goshare Driver",
      debugShowCheckedModeBanner: false,
      home: FutureBuilder<String>(
        future: ref
            .watch(LoginControllerProvider.notifier)
            .getUserData(context, ref), // Replace with your actual token
        builder: (BuildContext context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const SplashScreen(); // Show a loading spinner while waiting
          } else {
            final initialLocation = snapshot.data != null &&
                    snapshot.data!.isNotEmpty
                ? RouteConstants.dashBoardUrl
                : RouteConstants
                    .loginUrl; // Replace 'login' with your actual login route

            return MaterialApp.router(
              title: "Go Share Driver",
              debugShowCheckedModeBanner: false,
              routerConfig: AppRouter().createRouter(initialLocation),
              theme: ThemeData(
                colorScheme: ThemeData().colorScheme.copyWith(
                      primary: Pallete.primaryColor,
                    ),
                primaryColor: Pallete.primaryColor,
                scaffoldBackgroundColor: Pallete.primaryColor,
                fontFamily: 'Raleway',
                textTheme: Theme.of(context).textTheme.apply(
                      displayColor: Pallete.primaryColor,
                      bodyColor: Pallete.primaryColor,
                    ),
              ),
            );
          }
        },
      ),
    );
  }
}

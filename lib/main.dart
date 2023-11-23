import 'package:drivers_app/pages/dashboard.dart';
import 'package:drivers_app/pages/home_page.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'authentication/login_screen.dart';


Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: FirebaseOptions(
      apiKey: "AIzaSyByupk_LXb0kN_Z1vTEi4be1ug8xb53zac",
      appId: "1:1066026920128:android:26555f4d8a6db2c6ae2525",
      messagingSenderId: "1066026920128",
      projectId: "taxi-dispatch-21caf",
      storageBucket: "taxi-dispatch-21caf.appspot.com"
    ),
  );

  await Permission.locationWhenInUse.isDenied.then((valueOfPermission) {
    if(valueOfPermission) {
      Permission.locationWhenInUse.request();
    }
  });

  await Permission.notification.isDenied.then((valueOfPermission) {
    if(valueOfPermission) {
      Permission.notification.request();
    }
  });

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: '21880284 Drivers App',
      debugShowCheckedModeBanner: false,
      theme: ThemeData.dark().copyWith(
        scaffoldBackgroundColor: Colors.black,
      ),
      home: FirebaseAuth.instance.currentUser == null? LoginScreen() : Dashboard(),
    );
  }
}

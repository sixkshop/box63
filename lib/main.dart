import 'package:Sixk_Control/pages/device_setting.dart';
import 'package:Sixk_Control/pages/home.dart';
import 'package:Sixk_Control/pages/lighting.dart';
import 'package:Sixk_Control/pages/rotation.dart';
import 'package:Sixk_Control/pages/time.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
//test1
void main() {
  runApp(
      MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: HomePage(),
      title: "Sixk",
      routes: {
        "/device_setting_page": (context) => DeviceSettingPage(),
        "/rotation_page": (context) => RotaionPage(),
        "/lighting_page": (context) => LightingPage(),
        "/time_page": (context) => TimePage(),
      },
      builder: EasyLoading.init(),
      theme: ThemeData(brightness: Brightness.dark),

    );
  }//
}

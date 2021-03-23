library my_prj.globals;

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_reactive_ble/flutter_reactive_ble.dart';

QualifiedCharacteristic args;

bool isDada = true;

bool rotation = false;
String tempRotation = "";
IconData tempRotationIcon = Icons.rotate_right;

String motorStatus = "";
String motorDirection = "";
String motorSpeed = "";

//Device page
String lightStatus = "";
String lightMode = "";
int lightModeNum = 0;
String lightColor = "";
String lightColorHex = "0xffFFFFFF";
String lightColor1 = "";
String lightColorHex1 = "0xffFFFFFF";
String lightColor2 = "";
String lightColorHex2 = "0xffFFFFFF";
String lightColor3 = "";
String lightColorHex3 = "0xffFFFFFF";
String lightColor4 = "";
String lightColorHex4 = "0xffFFFFFF";

//Light page
Color currentColor = Colors.white;
Color currentColor1 = Colors.white;
Color currentColor2 = Colors.white;
Color currentColor3 = Colors.white;
Color currentColor4 = Colors.white;

bool statusLight = true;
String tempStatus = "on";
bool statusLight1 = true;
String tempStatus1 = "on";

int tempLighMode = 0;
String tempLighColor = "";
String tempSpeed = "";
int tempLighMode1 = 0;
String tempLighColor1 = "";
String tempSpeed1 = "";
int tempLighMode2 = 0;
String tempLighColor2 = "";
String tempSpeed2 = "";
int tempLighMode3 = 0;
String tempLighColor3 = "";
String tempSpeed3 = "";
int tempLighMode4 = 0;
String tempLighColor4 = "";
String tempSpeed4 = "";

String r = "";
String g = "";
String b = "";
String r1 = "";
String g1 = "";
String b1 = "";
String r2 = "";
String g2 = "";
String b2 = "";
String r3 = "";
String g3 = "";
String b3 = "";
String r4 = "";
String g4 = "";
String b4 = "";

String SM = "s";

List sm = [
  "n", //0
  "s", //1
  "m", //2
  "m", //3
  "m", //4
  "n", //5
  "n", //6
  "n", //7
  "s", //8
  "s", //9
  "s", //10
  "m", //11
  "m", //12
  "m", //13
  "n", //14
  "n", //15
  "n", //16
  "n", //17
  "n", //18
  "n", //19
  "m", //20
  "m", //21
  "m", //22
  "n", //23
  "n", //24
  "n", //25
  "m", //26
  "n", //27
  "s", //28
  "s", //29
  "s", //30
  "m", //31
  "m", //32
  "m", //33
  "m", //34
  "m", //35
  "m", //36
  "m", //37
  "m", //38
  "m", //39
  "m" //40
];

List radio = [
  false, //0
  false, //1
  true, //2
  true, //3
  true, //4
  true, //5
  true, //6
  true, //7
  true, //8
  true, //9
  true, //10
  true, //11
  true, //12
  true, //13
  true, //14
  true, //15
  true, //16
  true, //17
  true, //18
  true, //19
  true, //20
  true, //21
  true, //22
  true, //23
  true, //24
  true, //25
  false, //26
  false, //27
  false, //28
  false, //29
  false, //30
  false, //31
  true, //32
  true, //33
  true, //34
  true, //35
  true, //36
  true, //37
  true, //38
  true, //39
  true //40
];

List modeSelect = [
  "Off", //0
  "2q", //1
  "2F", //2
  "2G", //3
  "2H", //4
  "2J", //5
  "2K", //6
  "2L", //7
  "2w", //8
  "2y", //9
  "2t", //10
  "2s", //11
  "2p", //12
  "2a", //13
  "2g", //14
  "2d", //15
  "2f", //16
  "2o", //17
  "2u", //18
  "2i", //19
  "2W", //20
  "2m", //21
  "2Q", //22
  "2n", //23
  "2v", //24
  "2b", //25
  "2E", //26
  "2R", //27
  "2h", //28
  "2j", //29
  "2k", //30
  "2T", //31
  "2Z", //32
  "2X", //33
  "2C", //34
  "2P", //35
  "2I", //36
  "2O", //37
  "2D", //38
  "2A", //39
  "2S" //40
];
List modeSelectNum = [
  0,
  1,
  2,
  3,
  4,
  5,
  6,
  7,
  8,
  9,
  10,
  11,
  12,
  13,
  14,
  15,
  16,
  17,
  18,
  19,
  20,
  21,
  22,
  23,
  24,
  25,
  26,
  27,
  28,
  29,
  30,
  31,
  32,
  33,
  34,
  35,
  36,
  37,
  38,
  39,
  40
];
List modeNameList = [
  "Off", //0
  "Normal", //1
  "Normal Loop", //2 Slow
  "Normal Loop", //3 Medium
  "Normal Loop", //4 Fast
  "Normal Loop [Random Colors]", //5 Slow
  "Normal Loop [Random Colors]", //6 Medium
  "Normal Loop [Random Colors]", //7 Fast
  "Breathing", //8 Slow
  "Breathing", //9 Medium
  "Breathing", //10 Fast
  "Breathing Loop", //11 Slow
  "Breathing Loop", //12 Medium
  "Breathing Loop", //13 Fast
  "Breathing Loop [Random Colors]", //14 Slow
  "Breathing Loop [Random Colors]", //15 Medium
  "Breathing Loop [Random Colors]", //16 Fast
  "Gradient", //17 Slow
  "Gradient", //18 Medium
  "Gradient", //19 Fast
  "Siren Loop", //20 Slow
  "Siren Loop", //21 Medium
  "Siren Loop", //22 Fast
  "Siren Loop [Random Colors]", //23 Slow
  "Siren Loop [Random Colors]", //24 Medium
  "Siren Loop [Random Colors]", //25 Fast
  "Flash Bang Loop", //26
  "Flash Bang Loop [Random Colors]", //27
  "Broken Light", //28
  "Camera Flashing", //29
  "Thunderbolt", //30
  "Multiple Normal", //31
  "Multiple Normal Loop", //32 Slow
  "Multiple Normal Loop", //33 Medium
  "Multiple Normal Loop", //34 Fast
  "Multiple Breathing", //35 Slow
  "Multiple Breathing", //36 Medium
  "Multiple Breathing", //37 Fast
  "Multiple Breathing Loop", //38 Slow
  "Multiple Breathing Loop", //39 Medium
  "Multiple Breathing Loop", //40 Fast
];

//time Page
String startTime = "00:00";
String endTime = "00:00";
List startTimeHrMi;

List endTimeHrMi;

bool statusTime = false;
String tempStatusTime = "";

List<bool> isCheckedDay = [false, false, false, false, false, false, false];
List<String> days = [
  "Monday",
  "Tuesday",
  "Wednesday",
  "Thursday",
  "Friday",
  "Saturday",
  "Sunday"
];
List<String> daysShort = ["MON", "TUE", "WED", "THU", "FRI", "SAT", "SUN"];

int listIndex = 0;

int lightChoose =0;
bool radioBool = false;
int lightSpeedValue = 0;

// String showSMode;
String subShowMode = "";
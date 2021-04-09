import 'dart:async';

import 'package:Sixk_Control/pages/lighting.dart';
import 'package:Sixk_Control/pages/rotation.dart';
import 'package:Sixk_Control/pages/time.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutter_reactive_ble/flutter_reactive_ble.dart';
import 'package:color_convert/color_convert.dart';
import 'package:Sixk_Control/pages/globals.dart' as globals;

Uuid _UART_UUID = Uuid.parse("0000ffe0-0000-1000-8000-00805f9b34fb");
Uuid _UART_TX = Uuid.parse("0000ffe1-0000-1000-8000-00805f9b34fb");

class DeviceSettingPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _DeviceSettingPageState();
  }
}

class _DeviceSettingPageState extends State<DeviceSettingPage> {

  bool mustPop =false;
  String textDirection = globals.motorDirection;

  // String textSpeed = double.parse(globals.motorSpeed.trim()).round().toString();
  // String textSpeed = (((int.parse(globals.motorSpeed.trim())-550)/3)/10).round().toString();
  // String textSpeed = (((int.parse(globals.motorSpeed)*10)*3)+550).toString();
  // String textSpeed = globals.motorSpeed;
  String textSpeed = "";

  String textLightMode = "";

  bool colorVi = false;
  bool allVisible = false;
  bool firstOpen = true;
  final flutterReactiveBle = FlutterReactiveBle();

  // Stream<List<int>> _receivedDataStream;
  QualifiedCharacteristic _txCharacteristic;
  QualifiedCharacteristic _rxCharacteristic;
  String abc = "";

  // String motorStatus = "";
  // String motorDirection = "";
  // String motorSpeed = "";
  // String lightStatus = "";
  // String lightMode = "";
  // String lightColor = "";
  // String lightColorHex = "0xffFFFFFF";
  // String lightColor1 = "";
  // String lightColorHex1 = "0xffFFFFFF";
  // String lightColor2 = "";
  // String lightColorHex2 = "0xffFFFFFF";
  // String lightColor3 = "";
  // String lightColorHex3 = "0xffFFFFFF";
  // String lightColor4 = "";
  // String lightColorHex4 = "0xffFFFFFF";
  StreamSubscription subscriptionDEVICEPAGE;

  bool checkM = false;
  bool checkL = false;
  bool checkL1 = false;
  bool checkL2 = false;
  bool checkL3 = false;
  bool checkL4 = false;
  bool checkT = false;

  // String multiSingle = "single";
  bool cardVisible1 = true;
  bool cardVisible2 = false;

  String textTime = "";
  String textDay = "";
  String timeOnOff = "off";

  void refreshScreen() {
    // print("REFRESH");

    setState(() {});
  }

  void _sendData(command, args) async {
    final mtu = await flutterReactiveBle.requestMtu(
        deviceId: args.deviceId, mtu: 250);
    await flutterReactiveBle.writeCharacteristicWithResponse(args,
        value: command
            .toString()
            .codeUnits);
    print(command);

    // value: _dataToSendText.text.codeUnits);
  }

  void _receiveDataDEVICEPAGE(args) async {
    if(!mustPop) {
      print("iosTESTBUILD1");
      _txCharacteristic = QualifiedCharacteristic(
          serviceId: Uuid.parse("FFE0"),
          characteristicId: Uuid.parse("FFE1"),
          deviceId: args.deviceId);

      Stream<List<int>> _receivedDataStream =
          flutterReactiveBle.subscribeToCharacteristic(_txCharacteristic);

      // print(_receivedDataStream);
      print("_txCharacteristic=$_txCharacteristic");
      print("iosTESTBUILD2");

      //     // final response = await flutterReactiveBle.readCharacteristic(_txCharacteristic);
      // print("response=$response");

      subscriptionDEVICEPAGE = _receivedDataStream.listen((data) async {
        // flutterReactiveBle.subscribeToCharacteristic(_txCharacteristic).listen((data) {
        print("iosTESTBUILD3");
        // onNewReceivedData(data);
        // print(String.fromCharCodes(data));
        var s = String.fromCharCodes(data);
        // print("sxx=$s");
        var parts0 = s.split('@');
        var xx = data.toString().trim();
        print('PAGE=DEVICE / Recieve=$s');
        print('PAGE=DEVICE / Recieve=$data');

        // print('PAGE=DEVICE');
        if ((xx != "[10]") &&
            (xx != "[13, 10]") &&
            (xx != "[57, 48, 13, 10]") &&
            (xx != "[48, 48, 13, 10]") &&
            (xx != "[48, 13, 10]")) {
          // fix bug รับค่าเปล่าจากไหนไม่รู้
          // subscription.cancel();
          // print("subscription.cancel FIRST");
          // var l_parts = parts.length;
          // print("length=$l_parts");
          print(parts0);
          // subscriptionDEVICEPAGE.cancel();
          // print("subscription.cancel();");
          try {
            if (parts0[0] == "m") {
              var parts = parts0[1].split(',');
              checkM = true;
              globals.motorStatus = parts[0].trim();
              globals.motorDirection = parts[1].trim();
              if (globals.motorDirection == "cc") {
                if (globals.motorStatus == "off") {
                  globals.motorDirection = "Clockwise";
                  globals.tempRotationIcon = Icons.rotate_right;
                  textDirection = "-";
                  globals.motorSpeed = "0";
                } else {
                  globals.motorDirection = "Clockwise";
                  globals.tempRotationIcon = Icons.rotate_right;
                  globals.motorSpeed = parts[2].trim();
                  textSpeed = (double.parse(parts[2].trim()) - globals.motorMin)
                      .toString();
                }
              } else {
                if (globals.motorStatus == "off") {
                  globals.motorDirection = "Anticlockwise";
                  globals.tempRotationIcon = Icons.rotate_left;
                  textDirection = "-";
                  globals.motorSpeed = "0";
                } else {
                  // print("HHHHHHHHHHHHHHHHHHHHHHHHHH");
                  globals.motorDirection = "Anticlockwise";
                  globals.tempRotationIcon = Icons.rotate_left;
                  // (((double.parse(globals.motorSpeed) - 550) / 3) / 10).toString();
                  globals.motorSpeed = parts[2].trim();
                  textSpeed = (double.parse(parts[2].trim()) - globals.motorMin)
                      .toString();
                }
              }
            } else if (parts0[0] == "l") {
              var parts = parts0[1].split('/');
              checkL = true;

              // (int.parse(parts[0]) != 0)
              //     ? lightStatus = "on"
              //     : lightStatus = "off";
              print("parts[0]=${parts[0]}");
              if (int.parse(parts[0]) != 0) {
                globals.lightStatus = "on";
                globals.statusLight = true;
                colorVi = true;
              } else {
                globals.lightStatus = "off";
                globals.statusLight = false;
                colorVi = false;
              }

              globals.lightMode = globals.modeNameList[int.parse(parts[0])];
              print("lightMode=${globals.lightMode}");
              (globals.lightMode == "Off") ? globals.lightMode = "-" : null;

              if (globals.sm[int.parse(parts[0])] == "s") {
                globals.SM = "s";
                cardVisible1 = false;
                cardVisible2 = true;
              } else if (globals.sm[int.parse(parts[0])] == "m") {
                globals.SM = "m";
                cardVisible1 = true;
                cardVisible2 = false;
              } else {
                globals.SM = "n";
                cardVisible1 = false;
                cardVisible2 = false;
              }
              if (globals.radio[int.parse(parts[0])]) {
                globals.radioBool = true;
              } else {
                globals.radioBool = false;
              }
              int index = int.parse(parts[0]);

              if ((index == 0) ||
                  (index == 2) ||
                  // (index == 4) ||
                  (index == 5) ||
                  // (index == 7) ||
                  (index == 8) ||
                  // (index == 10) ||
                  (index == 11) ||
                  // (index == 13) ||
                  (index == 14) ||
                  // (index == 16) ||
                  (index == 17) ||
                  // (index == 19) ||
                  (index == 20) ||
                  // (index == 22) ||
                  (index == 23) ||
                  // (index == 25) ||
                  (index == 32) ||
                  // (index == 34) ||
                  (index == 35) ||
                  // (index == 37) ||
                  (index == 38)
              // ||(index == 40)
              ) {
                globals.lightChoose = index + 1;
                globals.lightSpeedValue = -1;
              }

              if ((index == 0) ||
                  // (index == 2) ||
                  (index == 4) ||
                  // (index == 5) ||
                  (index == 7) ||
                  // (index == 8) ||
                  (index == 10) ||
                  // (index == 11) ||
                  (index == 13) ||
                  // (index == 14) ||
                  (index == 16) ||
                  // (index == 17) ||
                  (index == 19) ||
                  // (index == 20) ||
                  (index == 22) ||
                  // (index == 23) ||
                  (index == 25) ||
                  // (index == 32) ||
                  (index == 34) ||
                  // (index == 35) ||
                  (index == 37) ||
                  //   ||(index == 38)
                  (index == 40)) {
                globals.lightChoose = index - 1;
                globals.lightSpeedValue = 1;
              }


              // print(" globals.SM = ${globals.SM}");
              // if (parts[0] == "33") {
              //   globals.SM = "s";
              //   cardVisible1 = false;
              //   cardVisible2 = true;
              // } else {
              //   globals.SM = "m";
              //   cardVisible1 = true;
              //   cardVisible2 = false;
              // }
              globals.lightColor = parts[1];
              var rgb = globals.lightColor.split(',');

              globals.lightColorHex = convert.rgb
                  .hex(int.parse(rgb[0]), int.parse(rgb[1]), int.parse(rgb[2]));
              globals.lightColorHex = "0xff${globals.lightColorHex}";
              print(globals.lightColorHex);
            } else if (parts0[0] == "q") {
              var parts = parts0[1].split('/');
              checkL1 = true;

              (int.parse(parts[0]) != 0)
                  ? globals.lightStatus = "on"
                  : globals.lightStatus = "off";

              // lightMode = modeNameList[int.parse(parts[0])];
              globals.lightColor1 = parts[1].trim();
              // print(lightColor1);
              var rgb = globals.lightColor1.split(',');

              globals.lightColorHex1 = convert.rgb
                  .hex(int.parse(rgb[0]), int.parse(rgb[1]), int.parse(rgb[2]));
              globals.lightColorHex1 = "0xff${globals.lightColorHex1}";
            } else if (parts0[0] == "w") {
              var parts = parts0[1].split('/');
              checkL2 = true;

              // (int.parse(parts[0]) != 0) ? lightStatus = "on" : lightStatus = "off";

              // lightMode = modeNameList[int.parse(parts[0])];
              globals.lightColor2 = parts[1].trim();
              // print(lightColor1);
              var rgb = globals.lightColor2.split(',');

              globals.lightColorHex2 = convert.rgb
                  .hex(int.parse(rgb[0]), int.parse(rgb[1]), int.parse(rgb[2]));
              globals.lightColorHex2 = "0xff${globals.lightColorHex2}";
            } else if (parts0[0] == "e") {
              var parts = parts0[1].split('/');
              checkL3 = true;

              // (int.parse(parts[0]) != 0) ? lightStatus = "on" : lightStatus = "off";

              // lightMode = modeNameList[int.parse(parts[0])];
              globals.lightColor3 = parts[1].trim();
              // print(lightColor1);
              var rgb = globals.lightColor3.split(',');

              globals.lightColorHex3 = convert.rgb
                  .hex(int.parse(rgb[0]), int.parse(rgb[1]), int.parse(rgb[2]));
              globals.lightColorHex3 = "0xff${globals.lightColorHex3}";
            } else if (parts0[0] == "r") {
              var parts = parts0[1].split('/');
              checkL4 = true;

              // (int.parse(parts[0]) != 0) ? lightStatus = "on" : lightStatus = "off";

              // lightMode = modeNameList[int.parse(parts[0])];
              globals.lightColor4 = parts[1].trim();
              // print(lightColor1);
              var rgb = globals.lightColor4.split(',');

              globals.lightColorHex4 = convert.rgb
                  .hex(int.parse(rgb[0]), int.parse(rgb[1]), int.parse(rgb[2]));
              globals.lightColorHex4 = "0xff${globals.lightColorHex4}";
            } else
            if ((xx.indexOf("115, 115, 70, 105, 110, 105, 115, 104") == 1) || (xx.indexOf("115, 24, 15, 22, 110, 105, 115, 104, 13, 10") == 1)){// แก้บีคปิด recievedata หน้า  device page ไม่ได้ ทำให้รับข้อมูลซ้อนกัน
              //ssFinish
              print("ssFinish from time turn off");
            } else {
              try {
                //time
                checkT = true;
                var parts = parts0[0].split('/');
                var pp = parts0[0];

                textTime = parts.join(" - ");
                textTime = textTime.substring(0, 13).trim();

                var partDay = parts0[0].split('/');

                textDay = "";
                if (partDay[2].trim() == "1111111") {
                  textDay = "Everyday";
                  for (var i = 0; i <= 6; i++) {
                    globals.isCheckedDay[i] = true;
                  }
                } else {
                  for (var i = 0; i <= 6; i++) {
                    if (partDay[2].substring(i, i + 1).trim() == "1") {
                      textDay = textDay + globals.daysShort[i];
                      globals.isCheckedDay[i] = true;
                      if (i != 6) {
                        textDay = textDay + ",";
                      }
                    } else {
                      globals.isCheckedDay[i] = false;
                    }
                  }
                }

                if (pp.toString().trim() == "00:00/00:00/0000000") {
                  print("QQ");
                  timeOnOff = "off";
                  textDay = "-";
                  textTime = "-";
                  globals.statusTime = false;
                } else {
                  print("WW");
                  timeOnOff = "on";
                  globals.statusTime = true;
                }

                globals.startTime = partDay[0];
                globals.endTime = partDay[1];

                // print(now.toString().substring(11,13));
                // print(now.toString().substring(14,16));
                // print(now.toString());
                // print(now.weekday);

                // print(textDay);
              } on Exception catch (_) {
                print(" ERROR1");
              }
            }
          } on Exception catch (_) {
            print('PAGE=DEVICE,Wrong Type Value.');
          }

          abc = String.fromCharCodes(data);
          if (firstOpen) {
            print("FIRST");
            EasyLoading.show(status: 'Syncing...');
            firstOpen = false;
          }
          // print("dataDevicePage=$s");
          print("checkM=$checkM");
          if ((checkM == true) &&
              (checkL == false) &&
              (checkL1 == false) &&
              (checkL2 == false) &&
              (checkL3 == false) &&
              (checkL4 == false) &&
              (checkT == false)) {
            //step2
            // subscription.cancel();
            // subscriptionDEVICEPAGE.cancel();
            _receiveDataDEVICEPAGE(args);

            _sendData("5", globals.args);

            print("SEND 5 FROM DEVICE PAGE");
          } else if ((checkM == true) &&
              (checkL == true) &&
              (checkL1 == false) &&
              (checkL2 == false) &&
              (checkL3 == false) &&
              (checkL4 == false) &&
              (checkT == false)) {
            //step3
            // subscription.cancel();
            // subscriptionDEVICEPAGE.cancel();
            _receiveDataDEVICEPAGE(args);
            _sendData("-", args);
          } else if ((checkM == true) &&
              (checkL == true) &&
              (checkL1 == true) &&
              (checkL2 == false) &&
              (checkL3 == false) &&
              (checkL4 == false) &&
              (checkT == false)) {
            //step4
            // subscription.cancel();
            // subscriptionDEVICEPAGE.cancel();
            _receiveDataDEVICEPAGE(args);
            _sendData("+", args);
          } else if ((checkM == true) &&
              (checkL == true) &&
              (checkL1 == true) &&
              (checkL2 == true) &&
              (checkL3 == false) &&
              (checkL4 == false) &&
              (checkT == false)) {
            //step5
            // subscription.cancel();
            // subscriptionDEVICEPAGE.cancel();
            // _receiveDataDEVICEPAGE(args);
            _sendData("[", args);
          } else if ((checkM == true) &&
              (checkL == true) &&
              (checkL1 == true) &&
              (checkL2 == true) &&
              (checkL3 == true) &&
              (checkL4 == false) &&
              (checkT == false)) {
            //step6
            // subscription.cancel();
            // subscriptionDEVICEPAGE.cancel();
            _receiveDataDEVICEPAGE(args);
            _sendData("]", args);
          } else if ((checkM == true) &&
              (checkL == true) &&
              (checkL1 == true) &&
              (checkL2 == true) &&
              (checkL3 == true) &&
              (checkL4 == true) &&
              (checkT == false)) {
            //step7
            // subscription.cancel();
            // subscriptionDEVICEPAGE.cancel();
            _receiveDataDEVICEPAGE(args);
            _sendData("i", args);
          } else if ((checkM == true) &&
              (checkL == true) &&
              (checkL1 == true) &&
              (checkL2 == true) &&
              (checkL3 == true) &&
              (checkL4 == true) &&
              (checkT == true)) {
            //step8
            // subscription.cancel();
            // subscriptionDEVICEPAGE.cancel();
            checkM = false;
            checkL = false;
            checkL1 = false;
            checkL2 = false;
            checkL3 = false;
            checkL4 = false;
            checkT = false;
            allVisible = true;
            // refreshScreen();
            // Navigator.pop(context);
print("SUBcancel BEFORE PUSH");
            subscriptionDEVICEPAGE.cancel();

            Future.delayed(const Duration(milliseconds: 200), () {
              Navigator.push(
                context,
                PageRouteBuilder(
                  pageBuilder: (_, __, ___) => RotaionPage(),
                  transitionDuration: Duration(seconds: 0),
                ),
              ).then((value) {
                // subscriptionDEVICEPAGE.cancel();
                mustPop =true;
                // Navigator.pop(context);


                // firstOpen = true;

                // allVisible = true;
                //  checkM = true;
                //  checkL = true;
                //  checkL1 = true;
                //  checkL2 = true;
                //  checkL3 = true;
                //  checkL4 = true;
                //  checkT = true;

                refreshScreen();
              });
            });

          }
          subscriptionDEVICEPAGE.cancel();
        }

      }, onError: (dynamic error) {
        print("ONERROR");
      });


      print("iosTESTBUILD4");
    }
  }

  @override
  Widget build(BuildContext context) {
    // QualifiedCharacteristic args = ModalRoute.of(context).settings.arguments;
    globals.args = ModalRoute
        .of(context)
        .settings
        .arguments;
    // EasyLoading.instance
    //   ..displayDuration = const Duration(milliseconds: 2000)
    //   ..indicatorType = EasyLoadingIndicatorType.dualRing
    //   ..loadingStyle = EasyLoadingStyle.dark
    //   ..maskType = EasyLoadingMaskType.black
    //   ..indicatorSize = 45.0
    //   ..radius = 10.0
    // // ..progressColor = Colors.yellow
    // //   ..backgroundColor = Colors.green
    // // ..indicatorColor = Colors.yellow
    // // ..textColor = Colors.yellow
    // // ..maskColor = Colors.blue.withOpacity(0.5)
    //   ..userInteractions = false
    //   ..dismissOnTap = false;
    // EasyLoading.show(status: 'Syncing...');
    if (allVisible) {
      print("esyloadClose=$allVisible");
      EasyLoading.dismiss();

      // EasyLoading.show(status: 'Syncing...');

      // refreshScreen();
    } else {
      print("esyloadOpen=$allVisible");
      // EasyLoading.dismiss();

      // scanningVisible = true;
      // refreshScreen();
    }

    if (firstOpen) {
      try {
        print("firstOPENrecievedata");
        _receiveDataDEVICEPAGE(globals.args);
      } on Exception catch (_) {
        print("SUB ERROR");
      }
      // _sendData("9", globals.args);

      Future.delayed(const Duration(milliseconds: 200), () {
        _sendData("9", globals.args);
      });

      Future.delayed(const Duration(milliseconds: 400), () {
        _sendData("4", globals.args);
      });
      // Future.delayed(const Duration(milliseconds: 600), () {
      //   _sendData("5", globals.args);
      // });


      //

      // print("motorStatus=$motorStatus");
    } else {
      print("notFIRST");
      print("globals.motorStatus=${globals.motorStatus}");
      print("globals.motorDirection=${globals.motorDirection}");
      print("globals.motorSpeed=${globals.motorSpeed}");
      //motor
      textDirection = globals.motorDirection;
      // print(":error=${globals.motorSpeed.trim()}");
      textSpeed = (double.parse(globals.motorSpeed.trim()) - globals.motorMin)
          .toString();
      var ts = textSpeed.split('.');
      textSpeed = ts[0];

      // textSpeed = globals.motorSpeed;

      if (globals.motorStatus == "off") {
        textDirection = "-";
        textSpeed = "-";
        globals.motorSpeed = "1000";
      }
//light
      print("globals.lightStatus=${globals.lightStatus}");
      print("globals.lightMode=${globals.lightMode}");
      if (globals.lightStatus == "on") {
        colorVi = true;
        textLightMode = globals.lightMode;
      } else {
        colorVi = false;
        textLightMode = "-";
      }

      (globals.lightMode == "Off") ? globals.lightMode = "-" : null;
      // if (globals.lightMode == "4 Colors Breathing") {
      //   globals.SM = "m";
      //   cardVisible1 = false;
      //   cardVisible2 = true;
      // } else {
      //   globals.SM = "s";
      //   cardVisible1 = true;
      //   cardVisible2 = false;
      // }

      var rgb = globals.lightColor.split(',');
      globals.lightColorHex = convert.rgb
          .hex(int.parse(rgb[0]), int.parse(rgb[1]), int.parse(rgb[2]));
      globals.lightColorHex = "0xff${globals.lightColorHex}";
      // print(globals.lightColorHex);

      var rgb1 = globals.lightColor1.split(',');
      globals.lightColorHex1 = convert.rgb
          .hex(int.parse(rgb1[0]), int.parse(rgb1[1]), int.parse(rgb1[2]));
      globals.lightColorHex1 = "0xff${globals.lightColorHex1}";
      // print(globals.lightColorHex1);

      var rgb2 = globals.lightColor2.split(',');
      globals.lightColorHex2 = convert.rgb
          .hex(int.parse(rgb2[0]), int.parse(rgb2[1]), int.parse(rgb2[2]));
      globals.lightColorHex2 = "0xff${globals.lightColorHex2}";
      // print(globals.lightColorHex2);

      var rgb3 = globals.lightColor3.split(',');
      globals.lightColorHex3 = convert.rgb
          .hex(int.parse(rgb3[0]), int.parse(rgb3[1]), int.parse(rgb3[2]));
      globals.lightColorHex3 = "0xff${globals.lightColorHex3}";
      // print(globals.lightColorHex3);

      var rgb4 = globals.lightColor4.split(',');
      globals.lightColorHex4 = convert.rgb
          .hex(int.parse(rgb4[0]), int.parse(rgb4[1]), int.parse(rgb4[2]));
      globals.lightColorHex4 = "0xff${globals.lightColorHex4}";
      // print(globals.lightColorHex4);

      //time
// print(globals.startTime);
// print(globals.endTime);
// print(globals.isCheckedDay);
      if (!globals.statusTime) {
        print("QQ");
        timeOnOff = "off";
        textDay = "-";
        textTime = "-";
      } else {
        print("WW");
        timeOnOff = "on";

        textDay = "";
        if (globals.isCheckedDay.toString() ==
            "[true, true, true, true, true, true, true]") {
          textDay = "Everyday";
        } else {
          for (var i = 0; i <= 6; i++) {
            if (globals.isCheckedDay[i]) {
              textDay = textDay + globals.daysShort[i];

              if (i != 6) {
                textDay = textDay + ",";
              }
            }
          }
        }
        textTime = "${globals.startTime} - ${globals.endTime}";
      }

      // refreshScreen();
    }
    // if (motorStatus == "on") {

    // }

    void _onItemTapped(int index) {
      // Navigator.pop(context);
      print(index);
      if (index == 0) {
        Navigator.push(
          context,
          PageRouteBuilder(
            pageBuilder: (_, __, ___) => RotaionPage(),
            transitionDuration: Duration(seconds: 0),
          ),
        );
      } else if (index == 1) {
        Navigator.push(
          context,
          PageRouteBuilder(
            pageBuilder: (_, __, ___) => LightingPage(),
            transitionDuration: Duration(seconds: 0),
          ),
        );
      } else if (index == 2) {
        Navigator.push(
          context,
          PageRouteBuilder(
            pageBuilder: (_, __, ___) => TimePage(),
            transitionDuration: Duration(seconds: 0),
          ),
        );
      }
    }

    return

      WillPopScope(onWillPop: ()  {
        subscriptionDEVICEPAGE.cancel();
        print("willpopSubCAN");
      }, child: Scaffold(
        // appBar: AppBar(
        //   backgroundColor: Color(0xff444444),
        //   // title: Text(abc),
        // ),
        body: Container(
          child: Visibility(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // Text(args.toString()),
                // RaisedButton(
                //   onPressed: () => _sendData("9", args),
                //   child: Icon(
                //     Icons.play_arrow,
                //     color: Colors.blue,
                //   ),
                // ),
                // RaisedButton(
                //   onPressed: () => _sendData("8", args),
                //   child: Icon(
                //     Icons.stop_rounded,
                //     color: Colors.blue,
                //   ),
                // ),
                // RaisedButton(
                //   onPressed: () => _receiveDataDEVICEPAGE(args),
                //   child: Icon(
                //     Icons.add,
                //     color: Colors.blue,
                //   ),
                // ),
                Column(
                  children: [
                    Container(
                      padding: EdgeInsets.fromLTRB(10, 10, 10, 10),
                      child: Column(
                        children: [
                          GestureDetector(
                            onTap: () {

                              Navigator.push(
                                context,
                                PageRouteBuilder(
                                  pageBuilder: (_, __, ___) => RotaionPage(),
                                  transitionDuration: Duration(seconds: 0),
                                ),
                              ).then((value) {
                                // firstOpen = true;
subscriptionDEVICEPAGE.cancel();
                                allVisible = true;
                                refreshScreen();
                              });
                            },
                            child: Column(
                              children: [
                                Card(
                                  color: Colors.white,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(1.0),
                                  ),
                                  elevation: 2,
                                  child: Row(
                                    children: [
                                      Container(
                                        padding:
                                        EdgeInsets.fromLTRB(20, 20, 20, 20),
                                        // child: Image.asset("img/boxIcon.png",
                                        //     width: MediaQuery.of(context).size.width / 9),
                                        child: RawMaterialButton(
                                          onPressed: () {
                                            // Navigator.pushNamed(
                                            //         context, "/rotation_page",
                                            //         arguments: args)
                                            //     .then((value) {
                                            //   // firstOpen = true;
                                            //
                                            //   allVisible = true;
                                            //   refreshScreen();
                                            // });

                                            //

                                            // Navigator.push(
                                            //     context,
                                            //     MaterialPageRoute(
                                            //       builder: (context) => RotaionPage(text: 'Hello',),
                                            //     ));

                                            Navigator.push(
                                              context,
                                              PageRouteBuilder(
                                                pageBuilder: (_, __, ___) =>
                                                    RotaionPage(),
                                                transitionDuration:
                                                Duration(seconds: 0),
                                              ),
                                            ).then((value) {
                                              // firstOpen = true;
                                              subscriptionDEVICEPAGE.cancel();
                                              allVisible = true;
                                              refreshScreen();
                                            });
                                          },
                                          elevation: 2.0,
                                          fillColor: Colors.white,
                                          child: Icon(
                                            Icons.sync,
                                            // size: 35.0,
                                          ),
                                          padding: EdgeInsets.all(20.0),
                                          shape: CircleBorder(),
                                        ),
                                      ),
                                      Container(
                                        padding:
                                        EdgeInsets.fromLTRB(0, 0, 20, 15),
                                        child: Column(
                                          mainAxisAlignment:
                                          MainAxisAlignment.start,
                                          crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                          children: [
                                            Container(
                                              padding: EdgeInsets.fromLTRB(
                                                  0, 10, 0, 0),
                                              child: Column(
                                                mainAxisAlignment:
                                                MainAxisAlignment.start,
                                                crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                                children: [
                                                  Text("Rotation",
                                                      style: TextStyle(
                                                        color: Colors.black,
                                                        fontSize: 16,
                                                      )),
                                                  Row(
                                                    children: [
                                                      Text("Status : "),
                                                      Text(globals.motorStatus,
                                                          style: TextStyle(
                                                            color: Colors.black,
                                                          )),
                                                    ],
                                                  ),
                                                  Text(
                                                      "Direction : $textDirection"),
                                                  Text("Speed : $textSpeed"),
                                                ],
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                          GestureDetector(
                            onTap: () {
                              Navigator.push(
                                context,
                                PageRouteBuilder(
                                  pageBuilder: (_, __, ___) => LightingPage(),
                                  transitionDuration: Duration(seconds: 0),
                                ),
                              ).then((value) {
                                // firstOpen = true;
                                // allVisible = false;
                                subscriptionDEVICEPAGE.cancel();
                                refreshScreen();
                              });
                            },
                            child: Column(
                              children: [
                                Visibility(
                                  child: Card(
                                    color: Colors.white,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(1.0),
                                    ),
                                    elevation: 2,
                                    child: Row(
                                      children: [
                                        Container(
                                          padding:
                                          EdgeInsets.fromLTRB(20, 20, 20, 20),
                                          // child: Image.asset("img/boxIcon.png",
                                          //     width: MediaQuery.of(context).size.width / 9),
                                          child: RawMaterialButton(
                                            onPressed: () {
                                              Navigator.push(
                                                context,
                                                PageRouteBuilder(
                                                  pageBuilder: (_, __, ___) =>
                                                      LightingPage(),
                                                  transitionDuration:
                                                  Duration(seconds: 0),
                                                ),
                                              ).then((value) {
                                                // firstOpen = true;
                                                // allVisible = false;
                                                subscriptionDEVICEPAGE.cancel();
                                                refreshScreen();
                                              });
                                            },
                                            elevation: 2.0,
                                            fillColor: Colors.white,
                                            child: Icon(
                                              Icons.lightbulb_outline,
                                              // size: 35.0,
                                            ),
                                            padding: EdgeInsets.all(20.0),
                                            shape: CircleBorder(),
                                          ),
                                        ),
                                        Container(
                                          padding:
                                          EdgeInsets.fromLTRB(0, 0, 20, 15),
                                          child: Column(
                                            mainAxisAlignment:
                                            MainAxisAlignment.start,
                                            crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                            children: [
                                              Container(
                                                padding: EdgeInsets.fromLTRB(
                                                    0, 10, 0, 0),
                                                child: Column(
                                                  mainAxisAlignment:
                                                  MainAxisAlignment.start,
                                                  crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                                  children: [
                                                    Text("Lighting",
                                                        style: TextStyle(
                                                          color: Colors.black,
                                                          fontSize: 16,
                                                        )),
                                                    Row(
                                                      children: [
                                                        Text("Status : "),
                                                        Text(
                                                            globals.lightStatus,
                                                            style: TextStyle(
                                                              color: Colors
                                                                  .black,
                                                            )),
                                                      ],
                                                    ),
                                                    Text(
                                                        "Mode : $textLightMode"),
                                                    Visibility(
                                                      child: Row(
                                                        children: [
                                                          Text("Color : "),
                                                          Container(
                                                            width: 20,
                                                            height: 20,
                                                            // child: Icon(Icons.circle, size: 20,),
                                                            decoration: BoxDecoration(
                                                                shape: BoxShape
                                                                    .circle,
                                                                color: Color(int
                                                                    .parse(
                                                                    globals
                                                                        .lightColorHex))),
                                                          ),
                                                          Text(
                                                              " (RGB = ${globals
                                                                  .lightColor}) "),
                                                        ],
                                                      ),
                                                      visible: colorVi,
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  visible: cardVisible1,
                                ),
                                Visibility(
                                  child: Card(
                                    color: Colors.white,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(1.0),
                                    ),
                                    elevation: 2,
                                    child: Row(
                                      children: [
                                        Container(
                                          padding:
                                          EdgeInsets.fromLTRB(20, 20, 20, 20),
                                          // child: Image.asset("img/boxIcon.png",
                                          //     width: MediaQuery.of(context).size.width / 9),
                                          child: RawMaterialButton(
                                            onPressed: () {
                                              Navigator.pushNamed(
                                                  context, "/lighting_page",
                                                  arguments: globals.args)
                                                  .then((value) {
                                                // firstOpen = true;
                                                // allVisible = false;
                                                subscriptionDEVICEPAGE.cancel();
                                                refreshScreen();
                                              });
                                            },
                                            elevation: 2.0,
                                            fillColor: Colors.white,
                                            child: Icon(
                                              Icons.lightbulb_outline,
                                              // size: 35.0,
                                            ),
                                            padding: EdgeInsets.all(20.0),
                                            shape: CircleBorder(),
                                          ),
                                        ),
                                        Container(
                                          padding:
                                          EdgeInsets.fromLTRB(0, 0, 20, 15),
                                          child: Column(
                                            mainAxisAlignment:
                                            MainAxisAlignment.start,
                                            crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                            children: [
                                              Container(
                                                padding: EdgeInsets.fromLTRB(
                                                    0, 10, 0, 0),
                                                child: Column(
                                                  mainAxisAlignment:
                                                  MainAxisAlignment.start,
                                                  crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                                  children: [
                                                    Text("Lighting",
                                                        style: TextStyle(
                                                          color: Colors.black,
                                                          fontSize: 16,
                                                        )),
                                                    Row(
                                                      children: [
                                                        Text("Status : "),
                                                        Text(
                                                            globals.lightStatus,
                                                            style: TextStyle(
                                                              color: Colors
                                                                  .black,
                                                            )),
                                                      ],
                                                    ),
                                                    Text(
                                                        "Mode : ${globals
                                                            .lightMode}"),
                                                    Row(
                                                      children: [
                                                        Text("Color1 : "),
                                                        Container(
                                                          width: 20,
                                                          height: 20,
                                                          // child: Icon(Icons.circle, size: 20,),
                                                          decoration: BoxDecoration(
                                                              shape:
                                                              BoxShape.circle,
                                                              color: Color(int
                                                                  .parse(globals
                                                                  .lightColorHex1))),
                                                        ),
                                                        Text(
                                                            " (RGB = ${globals
                                                                .lightColor1}) "),
                                                      ],
                                                    ),
                                                    Row(
                                                      children: [
                                                        Text("Color2 : "),
                                                        Container(
                                                          width: 20,
                                                          height: 20,
                                                          // child: Icon(Icons.circle, size: 20,),
                                                          decoration: BoxDecoration(
                                                              shape:
                                                              BoxShape.circle,
                                                              color: Color(int
                                                                  .parse(globals
                                                                  .lightColorHex2))),
                                                        ),
                                                        Text(
                                                            " (RGB = ${globals
                                                                .lightColor2}) "),
                                                      ],
                                                    ),
                                                    Row(
                                                      children: [
                                                        Text("Color3 : "),
                                                        Container(
                                                          width: 20,
                                                          height: 20,
                                                          // child: Icon(Icons.circle, size: 20,),
                                                          decoration: BoxDecoration(
                                                              shape:
                                                              BoxShape.circle,
                                                              color: Color(int
                                                                  .parse(globals
                                                                  .lightColorHex3))),
                                                        ),
                                                        Text(
                                                            " (RGB = ${globals
                                                                .lightColor3}) "),
                                                      ],
                                                    ),
                                                    Row(
                                                      children: [
                                                        Text("Color4 : "),
                                                        Container(
                                                          width: 20,
                                                          height: 20,
                                                          // child: Icon(Icons.circle, size: 20,),
                                                          decoration: BoxDecoration(
                                                              shape:
                                                              BoxShape.circle,
                                                              color: Color(int
                                                                  .parse(globals
                                                                  .lightColorHex4))),
                                                        ),
                                                        Text(
                                                            " (RGB = ${globals
                                                                .lightColor4}) "),
                                                      ],
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  visible: cardVisible2,
                                ),
                                GestureDetector(
                                    onTap: () {
                                      Navigator.push(
                                        context,
                                        PageRouteBuilder(
                                          pageBuilder: (_, __, ___) =>
                                              TimePage(),
                                          transitionDuration:
                                          Duration(seconds: 0),
                                        ),
                                      ).then((value) {
                                        // firstOpen = true;
                                        // allVisible = false;
                                        subscriptionDEVICEPAGE.cancel();
                                        refreshScreen();
                                      });
                                    },
                                    child: Column(children: [
                                      Card(
                                        color: Colors.white,
                                        shape: RoundedRectangleBorder(
                                          borderRadius:
                                          BorderRadius.circular(1.0),
                                        ),
                                        elevation: 2,
                                        child: Row(
                                          children: [
                                            Container(
                                              padding: EdgeInsets.fromLTRB(
                                                  20, 20, 20, 20),
                                              // child: Image.asset("img/boxIcon.png",
                                              //     width: MediaQuery.of(context).size.width / 9),
                                              child: RawMaterialButton(
                                                onPressed: () {
                                                  Navigator.push(
                                                    context,
                                                    PageRouteBuilder(
                                                      pageBuilder: (_, __,
                                                          ___) =>
                                                          TimePage(),
                                                      transitionDuration:
                                                      Duration(seconds: 0),
                                                    ),
                                                  ).then((value) {
                                                    // firstOpen = true;
                                                    // allVisible = false;
                                                    subscriptionDEVICEPAGE.cancel();
                                                    refreshScreen();
                                                  });
                                                },
                                                elevation: 2.0,
                                                fillColor: Colors.white,
                                                child: Icon(
                                                  Icons.access_time_outlined,
                                                  // size: 35.0,
                                                ),
                                                padding: EdgeInsets.all(20.0),
                                                shape: CircleBorder(),
                                              ),
                                            ),
                                            Container(
                                              padding: EdgeInsets.fromLTRB(
                                                  0, 0, 20, 15),
                                              child: Column(
                                                mainAxisAlignment:
                                                MainAxisAlignment.start,
                                                crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                                children: [
                                                  Container(
                                                    padding: EdgeInsets
                                                        .fromLTRB(
                                                        0, 10, 0, 0),
                                                    child: Column(
                                                      mainAxisAlignment:
                                                      MainAxisAlignment.start,
                                                      crossAxisAlignment:
                                                      CrossAxisAlignment
                                                          .start,
                                                      children: [
                                                        Text("Play Time",
                                                            style: TextStyle(
                                                              color: Colors
                                                                  .black,
                                                              fontSize: 16,
                                                            )),
                                                        Row(
                                                          children: [
                                                            Text("Status : "),
                                                            Text(timeOnOff,
                                                                style: TextStyle(
                                                                  color: Colors
                                                                      .black,
                                                                )),
                                                          ],
                                                        ),
                                                        Text("Days : $textDay"),
                                                        Text(
                                                            "Time : $textTime"),
                                                      ],
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ])),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    // Row(
                    //   mainAxisAlignment: MainAxisAlignment.center,
                    //   children: [
                    //     Column(
                    //       children: [
                    //         RawMaterialButton(
                    //           onPressed: () {
                    //             Navigator.pushNamed(context, "/rotation_page",
                    //                 arguments: "argsSend");
                    //           },
                    //           elevation: 2.0,
                    //           fillColor: Colors.white,
                    //           child: Icon(
                    //             Icons.sync,
                    //             // size: 35.0,
                    //           ),
                    //           padding: EdgeInsets.all(20.0),
                    //           shape: CircleBorder(),
                    //         ),
                    //         Container(
                    //             padding: EdgeInsets.fromLTRB(10, 5, 10, 10),
                    //             child: Text("Rotation")),
                    //       ],
                    //     ),
                    //     Column(
                    //       children: [
                    //         RawMaterialButton(
                    //           onPressed: () {},
                    //           elevation: 2.0,
                    //           fillColor: Colors.white,
                    //           child: Icon(
                    //             Icons.lightbulb_outline,
                    //             // size: 35.0,
                    //           ),
                    //           padding: EdgeInsets.all(20.0),
                    //           shape: CircleBorder(),
                    //         ),
                    //         Container(
                    //             padding: EdgeInsets.fromLTRB(10, 5, 10, 10),
                    //             child: Text("Light")),
                    //       ],
                    //     ),
                    //     Column(
                    //       children: [
                    //         RawMaterialButton(
                    //           onPressed: () {},
                    //           elevation: 2.0,
                    //           fillColor: Colors.white,
                    //           child: Icon(
                    //             Icons.access_time,
                    //             // size: 35.0,
                    //           ),
                    //           padding: EdgeInsets.all(20.0),
                    //           shape: CircleBorder(),
                    //         ),
                    //         Container(
                    //             padding: EdgeInsets.fromLTRB(10, 5, 10, 10),
                    //             child: Text("Time")),
                    //       ],
                    //     ),
                    //   ],
                    // ),
                  ],
                )
              ],
            ),
            visible: allVisible,
          ),
        ),

        bottomNavigationBar: BottomNavigationBar(
          currentIndex: 0, // this will be set when a new tab is tapped
          items: [
            BottomNavigationBarItem(
              icon: new Icon(Icons.sync),
              title: new Text('Rotation'),
            ),
            BottomNavigationBarItem(
              icon: new Icon(Icons.lightbulb_outline),
              title: new Text('Lighting'),
            ),
            BottomNavigationBarItem(
                icon: Icon(Icons.access_time_outlined),
                title: Text('On/Off Time'))
          ],

          // selectedItemColor: Colors.amber[800],
          onTap: _onItemTapped,
        ),
      ),);
  }
}

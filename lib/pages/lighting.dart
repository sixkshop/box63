import 'dart:async';

import 'package:Sixk_Control/pages/rotation.dart';
import 'package:Sixk_Control/pages/time.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'package:color_convert/color_convert.dart';
import 'package:flutter_reactive_ble/flutter_reactive_ble.dart';
import 'package:scrollable_positioned_list/scrollable_positioned_list.dart';
import 'globals.dart' as globals;

Uuid _UART_UUID = Uuid.parse("0000ffe0-0000-1000-8000-00805f9b34fb");
Uuid _UART_RX = Uuid.parse("0000ffe1-0000-1000-8000-00805f9b34fb");
Uuid _UART_TX = Uuid.parse("0000ffe1-0000-1000-8000-00805f9b34fb");
bool sVisble = false;
bool mVisble = false;
bool radioVisble = false;
int _value = globals.lightSpeedValue;
// QualifiedCharacteristic args;

enum SingingCharacter { lafayette, jefferson }

class LightingPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _LightingPageState();
  }
}

class _LightingPageState extends State<LightingPage> {
  SingingCharacter _character = SingingCharacter.lafayette;

  // bool checkTapUpDown = true;
  bool firstOpen = false;
  final flutterReactiveBle = FlutterReactiveBle();
  Stream<List<int>> _receivedDataStream;
  QualifiedCharacteristic _txCharacteristic;
  QualifiedCharacteristic _rxCharacteristic;

  ItemScrollController scrollController = ItemScrollController();

  // bool lightTheme = true;
  // Color currentColor = Colors.white;
  // Color currentColor1 = Colors.white;
  // Color currentColor2 = Colors.white;
  // Color currentColor3 = Colors.white;
  // Color currentColor4 = Colors.white;
  // String r = "";
  // String g = "";
  // String b = "";
  // String r1 = "";
  // String g1 = "";
  // String b1 = "";
  // String r2 = "";
  // String g2 = "";
  // String b2 = "";
  // String r3 = "";
  // String g3 = "";
  // String b3 = "";
  // String r4 = "";
  // String g4 = "";
  // String b4 = "";

  // int tempLighMode = 0;
  // String tempLighColor = "";
  // String tempSpeed = "";
  // int tempLighMode1 = 0;
  // String tempLighColor1 = "";
  // String tempSpeed1 = "";
  // int tempLighMode2 = 0;
  // String tempLighColor2 = "";
  // String tempSpeed2 = "";
  // int tempLighMode3 = 0;
  // String tempLighColor3 = "";
  // String tempSpeed3 = "";
  // int tempLighMode4 = 0;
  // String tempLighColor4 = "";
  // String tempSpeed4 = "";

  List<Color> currentColors = [Colors.limeAccent, Colors.green];

  // bool _status = true;
  // String tempStatus = "on";
  // bool _status1 = true;
  // String tempStatus1 = "on";

  StreamSubscription subscription;

  bool checkL = false;
  bool checkL1 = false;
  bool checkL2 = false;
  bool checkL3 = false;
  bool checkL4 = false;
  bool vi = false;

  void refreshScreen() {
    setState(() {});
  }

  void _sendData(command, args) async {
    await flutterReactiveBle.writeCharacteristicWithResponse(args,
        value: command.toString().codeUnits);
    print(command);
  }

  void _receiveData(args) async {
    _txCharacteristic = QualifiedCharacteristic(
        serviceId: _UART_UUID,
        characteristicId: _UART_TX,
        deviceId: args.deviceId);
    _receivedDataStream =
        flutterReactiveBle.subscribeToCharacteristic(_txCharacteristic);
    subscription = _receivedDataStream.listen((data) {
      // onNewReceivedData(data);
      // print(data.toString());
      var q = String.fromCharCodes(data).toString();
      // print("rec=$q");
      // var qq = data.toString();
      var parts0 = q.split('@');
      // print(parts0[0]);
      print('PAGE=LIGHT / $data');
      var xx = data.toString();
      if ((xx != "[10]") &&
          (xx != "[13, 10]") &&
          (xx != "[48, 48, 13, 10]") &&
          (xx != "[52, 48, 48, 13, 10]")) {
        // fix bug รับค่าเปล่าจากไหนไม่รู้
        // subscription.cancel();
        try {
          if (parts0[0] == "l") {
            // print("in1");
            checkL = true;
            var parts = parts0[1].split('/');
            globals.tempLighMode = int.parse(parts[0].trim());
            // print("tempLighMode=$tempLighMode");
            globals.tempLighColor = parts[1].trim();
            // print("tempLighColor=$tempLighColor");
            globals.tempSpeed = parts[2].trim();
            if (globals.tempLighMode == 0) {
              globals.statusLight = false;
              globals.tempStatus = "off";
            }

            var parts2 = globals.tempLighColor.split(',');
            globals.r = parts2[0];
            globals.g = parts2[1];
            globals.b = parts2[2];

            var toRGB = convert.rgb.hex(int.parse(globals.r),
                int.parse(globals.g), int.parse(globals.b));
            String getColor = "0xff$toRGB";
            globals.currentColor = Color(int.parse(getColor));
          } else if (parts0[0] == "l1") {
            // print("in2");
            checkL1 = true;
            var parts = parts0[1].split('/');
            globals.tempLighMode = int.parse(parts[0].trim());
            globals.tempLighColor1 = parts[1].trim();
            // print("tempLighColor1=$tempLighColor1");
            globals.tempSpeed = parts[2].trim();
            if (globals.tempLighMode == 0) {
              globals.statusLight = false;
              globals.tempStatus = "off";
            }

            var parts2 = globals.tempLighColor1.split(',');
            globals.r1 = parts2[0];
            globals.g1 = parts2[1];
            globals.b1 = parts2[2];
            // print("rgb1=$r1,$g1,$b1");
            var toRGB = convert.rgb.hex(int.parse(globals.r1),
                int.parse(globals.g1), int.parse(globals.b1));
            String getColor = "0xff$toRGB";
            globals.currentColor1 = Color(int.parse(getColor));
          } else if (parts0[0] == "l2") {
            // print("in3");
            checkL2 = true;
            var parts = parts0[1].split('/');
            globals.tempLighMode = int.parse(parts[0].trim());
            globals.tempLighColor2 = parts[1].trim();
            // print("tempLighColor2=$tempLighColor2");
            globals.tempSpeed = parts[2].trim();
            if (globals.tempLighMode == 0) {
              globals.statusLight = false;
              globals.tempStatus = "off";
            }

            var parts2 = globals.tempLighColor2.split(',');
            globals.r2 = parts2[0];
            globals.g2 = parts2[1];
            globals.b2 = parts2[2];
            // print("rgb1=$r2,$g2,$b2");
            var toRGB = convert.rgb.hex(int.parse(globals.r2),
                int.parse(globals.g2), int.parse(globals.b2));
            String getColor = "0xff$toRGB";
            globals.currentColor2 = Color(int.parse(getColor));
          } else if (parts0[0] == "l3") {
            // print("in4");
            checkL3 = true;
            var parts = parts0[1].split('/');
            globals.tempLighMode = int.parse(parts[0].trim());
            globals.tempLighColor3 = parts[1].trim();
            // print("tempLighColor3=$tempLighColor3");
            globals.tempSpeed = parts[2].trim();
            if (globals.tempLighMode == 0) {
              globals.statusLight = false;
              globals.tempStatus = "off";
            }

            var parts2 = globals.tempLighColor3.split(',');
            globals.r3 = parts2[0];
            globals.g3 = parts2[1];
            globals.b3 = parts2[2];
            // print("rgb1=$r3,$g3,$b3");
            var toRGB = convert.rgb.hex(int.parse(globals.r3),
                int.parse(globals.g3), int.parse(globals.b3));
            String getColor = "0xff$toRGB";
            globals.currentColor3 = Color(int.parse(getColor));
          } else if (parts0[0] == "l4") {
            // print("in5");
            checkL4 = true;
            var parts = parts0[1].split('/');
            globals.tempLighMode = int.parse(parts[0].trim());
            globals.tempLighColor4 = parts[1].trim();
            // print("tempLighColor4=$tempLighColor4");
            globals.tempSpeed = parts[2].trim();
            if (globals.tempLighMode == 0) {
              globals.statusLight = false;
              globals.tempStatus = "off";
            }

            var parts2 = globals.tempLighColor4.split(',');
            globals.r4 = parts2[0];
            globals.g4 = parts2[1];
            globals.b4 = parts2[2];
            // print("rgb1=$r4,$g4,$b4");
            var toRGB = convert.rgb.hex(int.parse(globals.r4),
                int.parse(globals.g4), int.parse(globals.b4));
            String getColor = "0xff$toRGB";
            globals.currentColor4 = Color(int.parse(getColor));
          }
        } on Exception catch (_) {
          print('PAGE=LIGHT,Wrong Type Value.');
        }

        if (firstOpen) {
          firstOpen = false;
        }
        if ((checkL == true) &&
            (checkL1 == false) &&
            (checkL2 == false) &&
            (checkL3 == false) &&
            (checkL4 == false)) {
          subscription.cancel();
          _sendData("-", args);
          _receiveData(args);
        } else if ((checkL == true) &&
            (checkL1 == true) &&
            (checkL2 == false) &&
            (checkL3 == false) &&
            (checkL4 == false)) {
          subscription.cancel();
          _sendData("+", args);
          _receiveData(args);
        } else if ((checkL == true) &&
            (checkL1 == true) &&
            (checkL2 == true) &&
            (checkL3 == false) &&
            (checkL4 == false)) {
          subscription.cancel();
          _sendData("[", args);
          _receiveData(args);
        } else if ((checkL == true) &&
            (checkL1 == true) &&
            (checkL2 == true) &&
            (checkL3 == true) &&
            (checkL4 == false)) {
          subscription.cancel();
          _sendData("]", args);
          _receiveData(args);
        } else if ((checkL == true) &&
            (checkL1 == true) &&
            (checkL2 == true) &&
            (checkL3 == true) &&
            (checkL4 == true)) {
          subscription.cancel();
          checkL = false;
          checkL1 = false;
          checkL2 = false;
          checkL3 = false;
          checkL4 = false;
          refreshScreen();
        }
      }
    });
  }

  void changeColor(Color color) {
    // print("checkTapUpDown=$checkTapUpDown");
    setState(() {
      var string1 = color.toString();
      var string2 = string1.substring(10, 16);
      var string3 = convert.hex.rgb(string2);
      globals.currentColor = color;
      globals.r = string3[0].toString();
      globals.g = string3[1].toString();
      globals.b = string3[2].toString();
      globals.tempLighColor = "2${globals.r},${globals.g},${globals.b},";
      if (globals.isDada) {
        _sendData(globals.tempLighColor, globals.args);
        _sendData("2z", globals.args);
      }

      globals.lightColor = "${globals.r},${globals.g},${globals.b}";
    });
    // checkTapUpDown = false;
  }

  void changeColor1(Color color) {
    setState(() {
      var string1 = color.toString();
      var string2 = string1.substring(10, 16);
      var string3 = convert.hex.rgb(string2);
      globals.currentColor1 = color;
      globals.r1 = string3[0].toString();
      globals.g1 = string3[1].toString();
      globals.b1 = string3[2].toString();
      globals.tempLighColor1 =
          "2266,266,266,${globals.r1},${globals.g1},${globals.b1},${globals.r2},${globals.g2},${globals.b2},${globals.r3},${globals.g3},${globals.b3},${globals.r4},${globals.g4},${globals.b4},";

      if (globals.isDada) {
        _sendData(globals.tempLighColor1, globals.args);
        _sendData("2z", globals.args);
      }

      globals.lightColor1 = "${globals.r1},${globals.g1},${globals.b1}";
    });
  }

  void changeColor2(Color color) {
    setState(() {
      var string1 = color.toString();
      var string2 = string1.substring(10, 16);
      var string3 = convert.hex.rgb(string2);
      globals.currentColor2 = color;
      globals.r2 = string3[0].toString();
      globals.g2 = string3[1].toString();
      globals.b2 = string3[2].toString();
      globals.tempLighColor2 =
          "2266,266,266,${globals.r1},${globals.g1},${globals.b1},${globals.r2},${globals.g2},${globals.b2},${globals.r3},${globals.g3},${globals.b3},${globals.r4},${globals.g4},${globals.b4},";
      if (globals.isDada) {
        _sendData(globals.tempLighColor2, globals.args);
        _sendData("2z", globals.args);
      }
      globals.lightColor2 = "${globals.r2},${globals.g2},${globals.b2}";
      // _sendData("2z", args);
    });
  }

  void changeColor3(Color color) {
    setState(() {
      var string1 = color.toString();
      var string2 = string1.substring(10, 16);
      var string3 = convert.hex.rgb(string2);
      globals.currentColor3 = color;
      globals.r3 = string3[0].toString();
      globals.g3 = string3[1].toString();
      globals.b3 = string3[2].toString();
      globals.tempLighColor3 =
          "2266,266,266,${globals.r1},${globals.g1},${globals.b1},${globals.r2},${globals.g2},${globals.b2},${globals.r3},${globals.g3},${globals.b3},${globals.r4},${globals.g4},${globals.b4},";
      if (globals.isDada) {
        _sendData(globals.tempLighColor3, globals.args);
        _sendData("2z", globals.args);
      }
      globals.lightColor3 = "${globals.r3},${globals.g3},${globals.b3}";
      // _sendData("2z", args);
    });
  }

  void changeColor4(Color color) {
    setState(() {
      var string1 = color.toString();
      var string2 = string1.substring(10, 16);
      var string3 = convert.hex.rgb(string2);
      globals.currentColor4 = color;
      globals.r4 = string3[0].toString();
      globals.g4 = string3[1].toString();
      globals.b4 = string3[2].toString();
      globals.tempLighColor4 =
          "2266,266,266,${globals.r1},${globals.g1},${globals.b1},${globals.r2},${globals.g2},${globals.b2},${globals.r3},${globals.g3},${globals.b3},${globals.r4},${globals.g4},${globals.b4},";
      if (globals.isDada) {
        _sendData(globals.tempLighColor4, globals.args);
        _sendData("2z", globals.args);
      }
      globals.lightColor4 = "${globals.r4},${globals.g4},${globals.b4}";
      // _sendData("2z", args);
    });
  }

  void changeColors(Color colors) => setState(() {
        globals.currentColor = colors;
      });

  @override
  Widget build(BuildContext context) {
    // args = ModalRoute.of(context).settings.arguments;
    print("_charater=$_character");
    if (firstOpen) {
      _receiveData(globals.args);
      _sendData("5", globals.args);
    } else {
      print("notFIRST-light");
      globals.tempStatus = globals.lightStatus;
//color0
      var parts2 = globals.lightColor.split(',');
      globals.r = parts2[0];
      globals.g = parts2[1];
      globals.b = parts2[2];
      var toRGB = convert.rgb.hex(
          int.parse(globals.r), int.parse(globals.g), int.parse(globals.b));
      String getColor = "0xff$toRGB";
      globals.currentColor = Color(int.parse(getColor));

      //color1
      parts2 = globals.lightColor1.split(',');
      globals.r1 = parts2[0];
      globals.g1 = parts2[1];
      globals.b1 = parts2[2];
      toRGB = convert.rgb.hex(
          int.parse(globals.r1), int.parse(globals.g1), int.parse(globals.b1));
      getColor = "0xff$toRGB";
      globals.currentColor1 = Color(int.parse(getColor));

      //color2
      parts2 = globals.lightColor2.split(',');
      globals.r2 = parts2[0];
      globals.g2 = parts2[1];
      globals.b2 = parts2[2];
      toRGB = convert.rgb.hex(
          int.parse(globals.r2), int.parse(globals.g2), int.parse(globals.b2));
      getColor = "0xff$toRGB";
      globals.currentColor2 = Color(int.parse(getColor));

      //color3
      parts2 = globals.lightColor3.split(',');
      globals.r3 = parts2[0];
      globals.g3 = parts2[1];
      globals.b3 = parts2[2];
      toRGB = convert.rgb.hex(
          int.parse(globals.r3), int.parse(globals.g3), int.parse(globals.b3));
      getColor = "0xff$toRGB";
      globals.currentColor3 = Color(int.parse(getColor));

      // color4
      parts2 = globals.lightColor4.split(',');
      globals.r4 = parts2[0];
      globals.g4 = parts2[1];
      globals.b4 = parts2[2];
      toRGB = convert.rgb.hex(
          int.parse(globals.r4), int.parse(globals.g4), int.parse(globals.b4));
      getColor = "0xff$toRGB";
      globals.currentColor4 = Color(int.parse(getColor));

      // print(globals.SM);
    }
    print("HEEE0=${globals.SM}");
    if (globals.SM == "s") {
      print("HEEE1");
      sVisble = true;
      mVisble = false;
    } else if (globals.SM == "m") {
      print("HEEE2");
      sVisble = false;
      mVisble = true;
    } else if (globals.SM == "n") {
      print("HEEE3");
      sVisble = false;
      mVisble = false;
    }

    print(radioVisble);
    int count = 1;
    Widget setupAlertDialoadContainer() {
      return Container(
        height: 1000.0, // Change as per your requirement
        width: 1000.0, // Change as per your requirement
        child: ScrollablePositionedList.builder(
          // shrinkWrap: true,
          itemScrollController: scrollController,

          itemCount: globals.modeSelect.length,
          itemBuilder: (BuildContext context, int index) {
            String tempsMode = globals.modeNameList[index];
            String sMode = '$count - ' '${globals.modeNameList[index]}';
            bool tempSelected = false;
            if (globals.lightChoose == index) {
              tempSelected = true;
              // globals.listIndex = index;
              // globals.lightModeNum = index;
            }

            if ((index == 0) ||
                (index == 2) ||
                (index == 4) ||
                (index == 5) ||
                (index == 6) || //random color
                (index == 7) ||
                (index == 8) ||
                (index == 10) ||
                (index == 11) ||
                (index == 13) ||
                (index == 14) ||
                (index == 15) || //random color
                (index == 16) ||
                (index == 17) ||
                (index == 19) ||
                (index == 20) ||
                (index == 22) ||
                (index == 23) ||
                (index == 24) || //random color
                (index == 25) ||
                (index == 27) || //random color
                (index == 32) ||
                (index == 34) ||
                (index == 35) ||
                (index == 37) ||
                (index == 38) ||
                (index == 40)) {
              vi = false;
            } else {
              vi = true;
              count++;
            }

            return Scrollbar(
              child: Column(
                children: [
                  Visibility(
                    child: ListTile(
                      title: Text("$sMode"),
                      // title: Text(index.toString()),
                      onTap: () {
                        globals.lightChoose = index;
                        globals.tempLighMode = globals.modeSelectNum[index];
                        (globals.tempLighMode == 0)
                            ? globals.statusLight = false
                            : null;
                        (globals.tempLighMode == 0)
                            ? globals.tempStatus = "off"
                            : null;

                        globals.lightMode =
                            globals.modeNameList[globals.tempLighMode];

                        // print(tempLighMode.toString());
                        _sendData(globals.modeSelect[index], globals.args);
                        refreshScreen();
                        Future.delayed(const Duration(milliseconds: 200), () {

                          _sendData("2z", globals.args);
                        });

                        globals.SM = globals.sm[index];
                        globals.radioBool = globals.radio[index];
                        // if (globals.radio[index]) {
                        //   radioVisble = true;
                        // } else {
                        //   radioVisble = false;
                        // }
                        _value = 0;

                        Navigator.of(context).pop();
                      },
                      selected: tempSelected,
                      enabled: vi,
                    ),
                    visible: vi,
                  ),

                  // Divider(),
                ],
              ),
            );
          },
        ),
      );
    }

    void _onItemTapped(int index) {
      print(index);
      Navigator.pop(context);
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

    return WillPopScope(
        onWillPop: () {
          Navigator.pop(context);
          Navigator.pop(context);
        },
        child: Scaffold(
          appBar: PreferredSize(
            preferredSize: Size.fromHeight(100.0), // here the desired height
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                AppBar(
                    automaticallyImplyLeading: true,
                    centerTitle: true,
                    // backgroundColor: Color(0xff444444),
                    title: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.lightbulb_outline),
                        Text("Light"),
                      ],
                    )),
              ],
            ),
          ),
          body: SingleChildScrollView(
            child: Column(children: [
              SwitchListTile(
                title: Text("Light Status"),
                subtitle: Text(globals.tempStatus),
                value: globals.statusLight,
                onChanged: (bool value) {
                  setState(() {
                    globals.statusLight = value;
                    if (globals.statusLight) {
                      // globals.radioBool = globals.radio[index];
                      globals.tempStatus = "on";
                      globals.lightStatus = "on";
                      print("555555");
                      globals.statusLight = true;
                      (globals.lightModeNum == 0)
                          ? globals.lightModeNum = 1
                          : null;
                      (globals.tempLighMode == 0)
                          ? globals.tempLighMode = globals.lightModeNum
                          : null;
                      _sendData(globals.modeSelect[globals.tempLighMode],
                          globals.args);
                      print("tempLighMode=${globals.tempLighMode}");
                      globals.lightMode =
                          globals.modeNameList[globals.lightModeNum];
                      globals.SM = globals.sm[globals.lightModeNum];
                      Future.delayed(const Duration(milliseconds: 200), () {

                        _sendData("2z", globals.args);
                      });
                      // refreshScreen();
                    } else {
                      globals.radioBool = false;
                      globals.lightChoose = 1;
                      globals.tempStatus = "off";
                      globals.lightStatus = "off";
                      globals.tempLighMode = 0;
                      print("DADA=${globals.tempLighMode}");
                      globals.lightModeNum = globals.tempLighMode;
                      globals.statusLight = false;
                      _sendData("2l", globals.args);

                      Future.delayed(const Duration(milliseconds: 200), () {

                        _sendData("2z", globals.args);
                      });

                    }
                  });
                },
                secondary: const Icon(Icons.power_settings_new),
              ),
              Divider(),
              ListTile(
                title: Text("Mode"),
                subtitle: Text(globals.lightMode),
                leading: Icon(
                  Icons.list_alt_outlined,
                ),
                onTap: () async {
                  await showDialog(
                      context: context,
                      builder: (BuildContext context) {
                        return AlertDialog(
                          title: Text('Select Mode'),
                          content: setupAlertDialoadContainer(),
                        );
                      }).then((val) {
                    count = 1;
                  });
                  // Future.delayed(const Duration(milliseconds: 2000), () {
                  //
                  //   scrollController.jumpTo(
                  //       index: globals.listIndex*2, );
                  // });
                },
                enabled: globals.statusLight,
              ),
              Divider(),
              Visibility(
                // LIGHT SPEED
                child: Column(
                  children: [
                    ListTile(
                      title: Text("Light Speed"),
                      subtitle: Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.start,
                                children: [
                                  Radio(

                                    value: -1,
                                    groupValue: _value,

                                    // activeColor: Color(0xFF6200EE),
                                    onChanged: (int value) {
                                      setState(() {
                                        _value = value;
                                        print("_value=$_value");
                                        int tLightChoose =
                                            globals.lightChoose - 1;
                                        _sendData(
                                            "${globals.modeSelect[tLightChoose]}",
                                            globals.args);
                                        Future.delayed(
                                            const Duration(milliseconds: 200),
                                            () {
                                          _sendData("2z", globals.args);
                                        });
                                      });
                                    },
                                  ),
                                  Text("Slow"),
                                ],
                              ),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.start,
                                children: [
                                  Radio(
                                    value: 0,
                                    groupValue: _value,
                                    // activeColor: Color(0xFF6200EE),
                                    onChanged: (int value) {
                                      setState(() {
                                        _value = value;
                                        print("_value=$_value");
                                        int tLightChoose = globals.lightChoose;
                                        _sendData(
                                            "${globals.modeSelect[tLightChoose]}",
                                            globals.args);
                                        Future.delayed(
                                            const Duration(milliseconds: 200),
                                            () {
                                          _sendData("2z", globals.args);
                                        });
                                      });
                                    },
                                  ),
                                  Text("Medium"),
                                ],
                              ),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.start,
                                children: [
                                  Radio(
                                    value: 1,
                                    groupValue: _value,
                                    // activeColor: Color(0xFF6200EE),
                                    onChanged: (int value) {
                                      setState(() {
                                        _value = value;
                                        print("_value=$_value");
                                        int tLightChoose =
                                            globals.lightChoose + 1;
                                        _sendData(
                                            "${globals.modeSelect[tLightChoose]}",
                                            globals.args);
                                        Future.delayed(
                                            const Duration(milliseconds: 200),
                                            () {
                                          _sendData("2z", globals.args);
                                        });
                                      });
                                    },
                                  ),
                                  Text("Fast"),
                                ],
                              ),
                            ],
                          ),
                        ],
                      ),
                      leading: Icon(
                        Icons.tune_outlined,
                      ),
                      enabled: globals.statusLight,
                    ),
                    Divider(),
                  ],
                ),
                visible: globals.radioBool,
              ),
              Visibility(
                child: Column(
                  children: [
                    ListTile(
                      title: Text("Light Color"),
                      subtitle: Column(
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Expanded(
                                child: Text(
                                  "R",
                                  textAlign: TextAlign.start,
                                ),
                              ),
                              Expanded(
                                child: Text(
                                  "G",
                                  textAlign: TextAlign.start,
                                ),
                              ),
                              Expanded(
                                child: Text(
                                  "B",
                                  textAlign: TextAlign.start,
                                ),
                              ),
                            ],
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Expanded(
                                child: Text(
                                  globals.r,
                                  textAlign: TextAlign.start,
                                ),
                              ),
                              Expanded(
                                child: Text(
                                  globals.g,
                                  textAlign: TextAlign.start,
                                ),
                              ),
                              Expanded(
                                child: Text(
                                  globals.b,
                                  textAlign: TextAlign.start,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                      onTap: () {
                        // _sendData("3l", args);
                        setState(() {
                          showDialog(
                            context: context,
                            builder: (BuildContext context) {
                              return WillPopScope(
                                onWillPop: () {},
                                child: AlertDialog(
                                  titlePadding: const EdgeInsets.all(0.0),
                                  contentPadding: const EdgeInsets.all(0.0),
                                  content: SingleChildScrollView(
                                    child: Column(
                                      children: [
                                        GestureDetector(
                                          // behavior: HitTestBehavior.opaque,
                                          // onHorizontalDragEnd: (_){checkTapUpDown = true; print("xPANUPDATE");} ,
                                          // onPanDown: (_){checkTapUpDown = true; print("xPANDOWN");} ,

                                          child: ColorPicker(
                                            pickerColor: globals.currentColor,
                                            onColorChanged: changeColor,
                                            colorPickerWidth: 400.0,
                                            pickerAreaHeightPercent: 1,
                                            enableAlpha: false,
                                            displayThumbColor: true,
                                            showLabel: true,
                                            paletteType: PaletteType.hsv,
                                            pickerAreaBorderRadius:
                                                const BorderRadius.only(
                                              topLeft:
                                                  const Radius.circular(2.0),
                                              topRight:
                                                  const Radius.circular(2.0),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  actions: <Widget>[
                                    FlatButton(
                                      child: const Text('Close'),
                                      onPressed: () {
                                        // _sendData("3p", args);
                                        // _sendData("3=$tempSpeed,", args);
                                        _sendData("2z", globals.args);
                                        // setState(() => currentColor = pickerColor);
                                        Navigator.of(context).pop();
                                        refreshScreen();
                                      },
                                    ),
                                  ],
                                ),
                              );
                            },
                          );
                        });
                      },
                      leading: Container(
                        width: 20,
                        height: 20,
                        // child: Icon(Icons.circle, size: 20,),
                        decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: globals.currentColor),
                      ),
                      enabled: globals.statusLight,
                    ),
                    Divider(),
                  ],
                ),
                visible: sVisble,
              ),
              Visibility(
                child: Column(
                  children: [
                    ListTile(
                      title: Text("Light Color 1"),
                      subtitle: Column(
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Expanded(
                                child: Text(
                                  "R",
                                  textAlign: TextAlign.start,
                                ),
                              ),
                              Expanded(
                                child: Text(
                                  "G",
                                  textAlign: TextAlign.start,
                                ),
                              ),
                              Expanded(
                                child: Text(
                                  "B",
                                  textAlign: TextAlign.start,
                                ),
                              ),
                            ],
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Expanded(
                                child: Text(
                                  globals.r1,
                                  textAlign: TextAlign.start,
                                ),
                              ),
                              Expanded(
                                child: Text(
                                  globals.g1,
                                  textAlign: TextAlign.start,
                                ),
                              ),
                              Expanded(
                                child: Text(
                                  globals.b1,
                                  textAlign: TextAlign.start,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                      onTap: () {
                        // _sendData("3l", args);
                        setState(() {
                          showDialog(
                            context: context,
                            builder: (BuildContext context) {
                              return WillPopScope(
                                onWillPop: () {},
                                child: AlertDialog(
                                  titlePadding: const EdgeInsets.all(0.0),
                                  contentPadding: const EdgeInsets.all(0.0),
                                  content: SingleChildScrollView(
                                    child: Column(
                                      children: [
                                        ColorPicker(
                                          pickerColor: globals.currentColor1,
                                          onColorChanged: changeColor1,
                                          colorPickerWidth: 400.0,
                                          pickerAreaHeightPercent: 1,
                                          enableAlpha: false,
                                          displayThumbColor: true,
                                          showLabel: true,
                                          paletteType: PaletteType.hsv,
                                          pickerAreaBorderRadius:
                                              const BorderRadius.only(
                                            topLeft: const Radius.circular(2.0),
                                            topRight:
                                                const Radius.circular(2.0),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  actions: <Widget>[
                                    FlatButton(
                                      child: const Text('Close'),
                                      onPressed: () {
                                        // _sendData("3p", args);
                                        // _sendData("3=$tempSpeed,", args);
                                        _sendData("2z", globals.args);
                                        // setState(() => currentColor = pickerColor);
                                        Navigator.of(context).pop();
                                        refreshScreen();
                                      },
                                    ),
                                  ],
                                ),
                              );
                            },
                          );
                        });
                      },
                      leading: Container(
                        width: 20,
                        height: 20,
                        // child: Icon(Icons.circle, size: 20,),
                        decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: globals.currentColor1),
                      ),
                      enabled: globals.statusLight,
                    ),
                    Divider(),
                    ListTile(
                      title: Text("Light Color 2"),
                      subtitle: Column(
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Expanded(
                                child: Text(
                                  "R",
                                  textAlign: TextAlign.start,
                                ),
                              ),
                              Expanded(
                                child: Text(
                                  "G",
                                  textAlign: TextAlign.start,
                                ),
                              ),
                              Expanded(
                                child: Text(
                                  "B",
                                  textAlign: TextAlign.start,
                                ),
                              ),
                            ],
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Expanded(
                                child: Text(
                                  globals.r2,
                                  textAlign: TextAlign.start,
                                ),
                              ),
                              Expanded(
                                child: Text(
                                  globals.g2,
                                  textAlign: TextAlign.start,
                                ),
                              ),
                              Expanded(
                                child: Text(
                                  globals.b2,
                                  textAlign: TextAlign.start,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                      onTap: () {
                        // _sendData("3l", args);
                        setState(() {
                          showDialog(
                            context: context,
                            builder: (BuildContext context) {
                              return WillPopScope(
                                onWillPop: () {},
                                child: AlertDialog(
                                  titlePadding: const EdgeInsets.all(0.0),
                                  contentPadding: const EdgeInsets.all(0.0),
                                  content: SingleChildScrollView(
                                    child: Column(
                                      children: [
                                        ColorPicker(
                                          pickerColor: globals.currentColor2,
                                          onColorChanged: changeColor2,
                                          colorPickerWidth: 400.0,
                                          pickerAreaHeightPercent: 1,
                                          enableAlpha: false,
                                          displayThumbColor: true,
                                          showLabel: true,
                                          paletteType: PaletteType.hsv,
                                          pickerAreaBorderRadius:
                                              const BorderRadius.only(
                                            topLeft: const Radius.circular(2.0),
                                            topRight:
                                                const Radius.circular(2.0),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  actions: <Widget>[
                                    FlatButton(
                                      child: const Text('Close'),
                                      onPressed: () {
                                        // _sendData("3p", args);
                                        // _sendData("3=$tempSpeed,", args);
                                        _sendData("2z", globals.args);
                                        // setState(() => currentColor = pickerColor);
                                        Navigator.of(context).pop();
                                        refreshScreen();
                                      },
                                    ),
                                  ],
                                ),
                              );
                            },
                          );
                        });
                      },
                      leading: Container(
                        width: 20,
                        height: 20,
                        // child: Icon(Icons.circle, size: 20,),
                        decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: globals.currentColor2),
                      ),
                      enabled: globals.statusLight,
                    ),
                    Divider(),
                    ListTile(
                      title: Text("Light Color 3"),
                      subtitle: Column(
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Expanded(
                                child: Text(
                                  "R",
                                  textAlign: TextAlign.start,
                                ),
                              ),
                              Expanded(
                                child: Text(
                                  "G",
                                  textAlign: TextAlign.start,
                                ),
                              ),
                              Expanded(
                                child: Text(
                                  "B",
                                  textAlign: TextAlign.start,
                                ),
                              ),
                            ],
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Expanded(
                                child: Text(
                                  globals.r3,
                                  textAlign: TextAlign.start,
                                ),
                              ),
                              Expanded(
                                child: Text(
                                  globals.g3,
                                  textAlign: TextAlign.start,
                                ),
                              ),
                              Expanded(
                                child: Text(
                                  globals.b3,
                                  textAlign: TextAlign.start,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                      onTap: () {
                        // _sendData("3l", args);
                        setState(() {
                          showDialog(
                            context: context,
                            builder: (BuildContext context) {
                              return WillPopScope(
                                onWillPop: () {},
                                child: AlertDialog(
                                  titlePadding: const EdgeInsets.all(0.0),
                                  contentPadding: const EdgeInsets.all(0.0),
                                  content: SingleChildScrollView(
                                    child: Column(
                                      children: [
                                        ColorPicker(
                                          pickerColor: globals.currentColor3,
                                          onColorChanged: changeColor3,
                                          colorPickerWidth: 400.0,
                                          pickerAreaHeightPercent: 1,
                                          enableAlpha: false,
                                          displayThumbColor: true,
                                          showLabel: true,
                                          paletteType: PaletteType.hsv,
                                          pickerAreaBorderRadius:
                                              const BorderRadius.only(
                                            topLeft: const Radius.circular(2.0),
                                            topRight:
                                                const Radius.circular(2.0),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  actions: <Widget>[
                                    FlatButton(
                                      child: const Text('Close'),
                                      onPressed: () {
                                        // _sendData("3p", args);
                                        // _sendData("3=$tempSpeed,", args);
                                        // _sendData("9", args);
                                        _sendData("2z", globals.args);
                                        // setState(() => currentColor = pickerColor);
                                        Navigator.of(context).pop();
                                        refreshScreen();
                                      },
                                    ),
                                  ],
                                ),
                              );
                            },
                          );
                        });
                      },
                      leading: Container(
                        width: 20,
                        height: 20,
                        // child: Icon(Icons.circle, size: 20,),
                        decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: globals.currentColor3),
                      ),
                      enabled: globals.statusLight,
                    ),
                    Divider(),
                    ListTile(
                      title: Text("Light Color 4"),
                      subtitle: Column(
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Expanded(
                                child: Text(
                                  "R",
                                  textAlign: TextAlign.start,
                                ),
                              ),
                              Expanded(
                                child: Text(
                                  "G",
                                  textAlign: TextAlign.start,
                                ),
                              ),
                              Expanded(
                                child: Text(
                                  "B",
                                  textAlign: TextAlign.start,
                                ),
                              ),
                            ],
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Expanded(
                                child: Text(
                                  globals.r4,
                                  textAlign: TextAlign.start,
                                ),
                              ),
                              Expanded(
                                child: Text(
                                  globals.g4,
                                  textAlign: TextAlign.start,
                                ),
                              ),
                              Expanded(
                                child: Text(
                                  globals.b4,
                                  textAlign: TextAlign.start,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                      onTap: () {
                        // _sendData("3l", args);
                        setState(() {
                          showDialog(
                            context: context,
                            builder: (BuildContext context) {
                              return WillPopScope(
                                onWillPop: () {},
                                child: AlertDialog(
                                  titlePadding: const EdgeInsets.all(0.0),
                                  contentPadding: const EdgeInsets.all(0.0),
                                  content: SingleChildScrollView(
                                    child: Column(
                                      children: [
                                        ColorPicker(
                                          pickerColor: globals.currentColor4,
                                          onColorChanged: changeColor4,
                                          colorPickerWidth: 400.0,
                                          pickerAreaHeightPercent: 1,
                                          enableAlpha: false,
                                          displayThumbColor: true,
                                          showLabel: true,
                                          paletteType: PaletteType.hsv,
                                          pickerAreaBorderRadius:
                                              const BorderRadius.only(
                                            topLeft: const Radius.circular(2.0),
                                            topRight:
                                                const Radius.circular(2.0),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  actions: <Widget>[
                                    FlatButton(
                                      child: const Text('Close'),
                                      onPressed: () {
                                        // _sendData("0", args);
                                        // _sendData("3p", args);
                                        // _sendData("3=$tempSpeed,", args);
                                        _sendData("2z", globals.args);
                                        // setState(() => currentColor = pickerColor);
                                        Navigator.of(context).pop();
                                        refreshScreen();
                                      },
                                    ),
                                  ],
                                ),
                              );
                            },
                          );
                        });
                      },
                      leading: Container(
                        width: 20,
                        height: 20,
                        // child: Icon(Icons.circle, size: 20,),
                        decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: globals.currentColor4),
                      ),
                      enabled: globals.statusLight,
                    ),
                    Divider(),
                  ],
                ),
                visible: mVisble,
              ),
            ]),

          ),
          bottomNavigationBar: BottomNavigationBar(
            currentIndex: 1, // this will be set when a new tab is tapped
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
        ));
  }
}

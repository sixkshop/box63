import 'dart:async';

import 'package:Sixk_Control/pages/time.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_reactive_ble/flutter_reactive_ble.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:Sixk_Control/pages/globals.dart' as globals;

import 'lighting.dart';

Uuid _UART_UUID = Uuid.parse("0000ffe0-0000-1000-8000-00805f9b34fb");
Uuid _UART_RX = Uuid.parse("0000ffe1-0000-1000-8000-00805f9b34fb");
Uuid _UART_TX = Uuid.parse("0000ffe1-0000-1000-8000-00805f9b34fb");

class RotaionPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _RatationPageState();
  }
}

class _RatationPageState extends State<RotaionPage> {
  double tempSpeed = null;
  bool firstOpen = false;
  bool waitSSFinish = false;
  final flutterReactiveBle = FlutterReactiveBle();
  Stream<List<int>> _receivedDataStream;
  QualifiedCharacteristic _txCharacteristic;
  QualifiedCharacteristic _rxCharacteristic;

  bool _status = false;

  String tempStatus = "";

  // bool _rotation = false;
  // String tempRotation = "";
  // IconData tempRotationIcon = Icons.rotate_right;

  double _currentSliderValue = double.parse('${globals.motorSpeed}');

  // String motorStatus = "";
  // String motorDirection = "";
  // String motorSpeed = "";

  StreamSubscription subscription;

  get i1 => null;

  void _sendData(command, args) async {
    await flutterReactiveBle.writeCharacteristicWithResponse(args,
        value: command.toString().codeUnits);
    print(command);
  }

  void refreshScreen() {
    setState(() {});
  }

  void _receiveData(args) async {
    print("ROTATION RECIEVE");
    _txCharacteristic = QualifiedCharacteristic(
        serviceId: Uuid.parse("FFE0"),
        characteristicId: Uuid.parse("FFE1"),
        deviceId: args.deviceId);
    _receivedDataStream =
        flutterReactiveBle.subscribeToCharacteristic(_txCharacteristic);
    subscription = _receivedDataStream.listen((data) {
      // onNewReceivedData(data);
      // print(data.toString());
      var s = String.fromCharCodes(data).toString();
      var ss = data.toString();
      print("CHECK=$ss");
      if ((ss.indexOf("115, 115, 70, 105, 110, 105, 115, 104") == 1) || (ss.indexOf("115, 24, 15, 22, 110, 105, 115, 104, 13, 10") == 1)){// แก้บีคปิด recievedata หน้า  device page ไม่ได้ ทำให้รับข้อมูลซ้อนกัน
        //ssFinish
        // print("s1=ssFinish");
        waitSSFinish = false;
        refreshScreen();
      } else {
        // print("s2=$s");
        try {
          var parts0 = s.split('@');
          var parts = parts0[1].split(',');
          tempStatus = parts[0].trim();

          if (tempStatus == "on") {
            _status = true;
            globals.rotation = true;
            globals.motorStatus = "on";
          } else {
            _status = false;
            globals.rotation = false;
            globals.motorStatus = "off";
          }
          globals.motorDirection = parts[1].trim();
          if (globals.motorDirection == "cc") {
            globals.tempRotation = "Clockwise";
          } else {
            globals.tempRotation = "Anticlockwise";
          }
          globals.motorSpeed = parts[2].trim();
          var globalsMotorSpeed = globals.motorSpeed;
          _currentSliderValue = double.parse('$globalsMotorSpeed');

          if (_currentSliderValue < globals.motorMin) {
            _currentSliderValue = globals.motorMin;
          }
        } on Exception catch (_) {
          print('Wrong Type Value.');
        }
      }

      // abc = String.fromCharCodes(data);
      // if(waitSSFinish){
      // print("asdasd");
      //   waitSSFinish = false;
      //   refreshScreen();
      // }

      if (firstOpen) {
        // firstOpen = false;

        refreshScreen();
      }

      print("dataRotatiobPage=$s");
      subscription.cancel();
    });
  }

  @override
  Widget build(BuildContext context) {
    // QualifiedCharacteristic args = ModalRoute.of(context).settings.arguments;

    if (_currentSliderValue < globals.motorMin) {
      _currentSliderValue = 40;
    }

    // print("_currentSliderValue=$_currentSliderValue");

    // print(globals.motorDirection);
    if (globals.motorStatus == "on") {
      _status = true;
      tempStatus = "on";
      // (globals.motorDirection=="-")? globals.motorDirection = "Clockwise":null;
      globals.tempRotation = globals.motorDirection;
      globals.rotation = true;
    } else {
      _status = false;
      tempStatus = "off";
      // (globals.motorDirection=="-")? globals.motorDirection = "Clockwise":null;
      globals.tempRotation = globals.motorDirection;
      globals.rotation = false;
    }
    // var globalsMotorSpeed = globals.motorSpeed;
    // _currentSliderValue = double.parse('$globalsMotorSpeed');
    // _currentSliderValue = double.parse('${globals.motorSpeed}');

    EasyLoading.instance
      ..displayDuration = const Duration(milliseconds: 2000)
      ..indicatorType = EasyLoadingIndicatorType.dualRing
      ..loadingStyle = EasyLoadingStyle.dark
      ..maskType = EasyLoadingMaskType.black
      ..indicatorSize = 45.0
      ..radius = 10.0
    // ..progressColor = Colors.yellow
    // ..backgroundColor = Colors.green
    // ..indicatorColor = Colors.yellow
    // ..textColor = Colors.yellow
    // ..maskColor = Colors.blue.withOpacity(0.5)
      ..userInteractions = false
      ..dismissOnTap = false;

    // EasyLoading.show(status: 'loading...');
    // EasyLoading.showSuccess('Great Success!');
    // EasyLoading.dismiss();
    // EasyLoading.removeCallback(statusCallback);

    // EasyLoading.removeAllCallbacks();
    // EasyLoading.showProgress(22, status: 'downloading...');
    //
    // EasyLoading.showSuccess('Great Success!');
    //
    // EasyLoading.showError('Failed with Error');
    //
    // EasyLoading.showInfo('Useful Information.');
    //
    // EasyLoading.showToast('Toast');

    // EasyLoading.dismiss();

    // if (firstOpen) {
    //   _sendData("4", args);
    //   _receiveData(args);
    // }

    // print("waitSSFinish=$waitSSFinish");
    if (waitSSFinish) {
      EasyLoading.show(status: 'Direction Setting...');
      // return Scaffold(
      //     body: SafeArea(
      //   child: Column(
      //     children: [
      //       Text("wait goback."),
      //     ],
      //   ),
      // ));
    } else {
      EasyLoading.dismiss();
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
      onWillPop: () async {
        print("onwillpop");

        if (!waitSSFinish) {
          print("onwillpop2");
          Navigator.pop(context);
          print("onwillpop4");
          Navigator.pop(context);

          print("onwillpop5");
          return true;
        } else {
          print("onwillpop6");
          return false;
        }

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
                      Icon(Icons.sync),
                      Text("Rotation"),
                    ],
                  )),
            ],
          ),
        ),
        body: Column(
          children: [
            SwitchListTile(
              title: Text("Rotation Status"),
              subtitle: Text(tempStatus),
              value: _status,
              onChanged: (bool value) {
                setState(() {
                  _status = value;
                  if (_status) {
                    if (globals.motorSpeed == "0") {
                      //ต้องแยกสองบรรทัดใส่ 93=1000,3d แล้ว bug
                      globals.motorSpeed = "50";
                      print("XXX1");
                      var globalsMotorSpeed = globals.motorSpeed;
                      var tempSend = "93=$globalsMotorSpeed,";

                      _currentSliderValue = double.parse('$globalsMotorSpeed');
                      if (_currentSliderValue < globals.motorMin) {
                        _currentSliderValue = globals.motorMin;
                      }
                      tempSpeed = _currentSliderValue;
                      _sendData(tempSend, globals.args);

                      Future.delayed(const Duration(milliseconds: 200), () {
                        _sendData("3z", globals.args);
                      });
                      // print("HERE1");

                    } else {
                      if (tempSpeed == null) {
                        print("HERE2");
                        var globalsMotorSpeed = globals.motorSpeed;
                        _sendData("93=$globalsMotorSpeed,", globals.args);
                        Future.delayed(const Duration(milliseconds: 200), () {
                          _sendData("3z", globals.args);
                        });
                      } else {
                        print("YYY1");
                        int i1 = tempSpeed.toInt();
                        _sendData("93=$i1,", globals.args);
                        // _sendData("3z", args);
                        Future.delayed(const Duration(milliseconds: 200), () {
                          _sendData("3z", globals.args);
                        });
                        // print("HERE3");
                      }
                    }

                    // print("motorspd=$motorSpeed");
                    if (globals.motorSpeed == "0") {
                      //ต้องแยกสองบรรทัดใส่ 93=1000,3d แล้ว bug

                      // _sendData("3=1000,", args);
                      _sendData("3c", globals.args);
                    }

                    // _sendData("3z", args);
                    tempStatus = "On";
                    globals.rotation = true;
                    globals.motorStatus = "on";
                  } else {
                    print("OFFFFFFFFFFFFFF");
                    _receiveData(globals.args);
                    Future.delayed(const Duration(milliseconds: 1000), () {
                      _sendData("7", globals.args);
                    });
                    // _sendData("3z", args);
                    tempStatus = "Off";
                    globals.rotation = false;
                    globals.motorStatus = "off";
                    waitSSFinish = true;

                    // _receiveData(args);
                  }
                  refreshScreen();
                });
                // (globals.motorDirection=="cc")? globals.motorDirection="Clockwise":globals.motorDirection="Anticlockwise";
              },
              secondary: const Icon(Icons.power_settings_new),
            ),
            Divider(),
            ListTile(
              title: Text("Direction"),
              subtitle: Text(globals.motorDirection),
              onTap: () {
                setState(() {
                  if (globals.tempRotation == "Anticlockwise") {
                    _sendData("3q", globals.args);
                    // _sendData("3z", args);
                    Future.delayed(const Duration(milliseconds: 200), () {
                      _sendData("3z", globals.args);
                    });
                    globals.tempRotation = "Clockwise";
                    globals.tempRotationIcon = Icons.rotate_right;
                    globals.motorDirection = "Clockwise";
                  } else {
                    _sendData("3w", globals.args);
                    // _sendData("3z", args);
                    Future.delayed(const Duration(milliseconds: 200), () {
                      _sendData("3z", globals.args);
                    });
                    globals.tempRotation = "Anticlockwise";
                    globals.tempRotationIcon = Icons.rotate_left;
                    globals.motorDirection = "Anticlockwise";
                  }
                });
              },
              leading: Icon(
                globals.tempRotationIcon,
              ),
              enabled: globals.rotation,
            ),
            Divider(),
            ListTile(
              title: Text("Speed"),
              subtitle: Row(
                children: [
                  Text((_currentSliderValue - globals.motorMin)
                      .round()
                      .toString()),
                  Expanded(
                    child: SliderTheme(
                        data: SliderThemeData(
                          // valueIndicatorColor: Colors.tealAccent,
                          thumbColor: Colors.tealAccent,
                          activeTrackColor: Colors.tealAccent,
                        ),
                        child: Slider(
                          value: _currentSliderValue,
                          min:  globals.motorMin,//20
                          max: globals.motorMax,//120
                          divisions: 100,
                          label: (_currentSliderValue - globals.motorMin)
                              .round()
                              .toString(),
                          onChanged: !globals.rotation
                              ? null
                              : (double value) {
                            setState(() {
                              _currentSliderValue = value;
                              tempSpeed = _currentSliderValue;
                            });
                          },
                          onChangeEnd: (value) {
                            String str1 = "3=";
                            String str2 =
                            _currentSliderValue.round().toString();
                            String str3 = ",";
                            String str4 = "${str1}${str2}${str3}";
                            _sendData(str4, globals.args);
                            // _sendData("3z", args);
                            Future.delayed(const Duration(milliseconds: 200),
                                    () {
                                  _sendData("3z", globals.args);
                                });
                            tempSpeed = _currentSliderValue;
                            globals.motorSpeed = tempSpeed.toString();

                            // (globals.motorDirection=="cc")? globals.motorDirection="Clockwise":globals.motorDirection="Anticlockwise";
                            // print(globals.motorDirection);
                          },
                        )),
                  ),
                ],
              ),
              leading: Icon(
                Icons.speed,
              ),
              enabled: globals.rotation,
            ),
            Divider(),
            // RaisedButton(
            //   onPressed: () {Navigator.of(context).pop();},
            //   child: Icon(
            //     Icons.play_arrow,
            //
            //   ),
            // ),
          ],
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
      ),
    );
  }
}

import 'dart:async';

import 'package:Sixk_Control/pages/rotation.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_reactive_ble/flutter_reactive_ble.dart';
import 'package:flutter_time_picker_spinner/flutter_time_picker_spinner.dart';
import 'package:smart_select/smart_select.dart';
import 'globals.dart' as globals;
import 'lighting.dart';

Uuid _UART_UUID = Uuid.parse("0000ffe0-0000-1000-8000-00805f9b34fb");
Uuid _UART_RX = Uuid.parse("0000ffe1-0000-1000-8000-00805f9b34fb");
Uuid _UART_TX = Uuid.parse("0000ffe1-0000-1000-8000-00805f9b34fb");
List<int> value;

// QualifiedCharacteristic args;

// List days = ["Monday","Tuesday","Wednesday","Thursday","Friday","Saturday","Sunday"];
class TimePage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    // globals.isCheckedDay = List<bool>.filled(globals.days.length, false);

    return _TimePageState();
  }
}

class _TimePageState extends State<TimePage> {
  bool firstOpen = false;
  bool firstSettime = true;
  final flutterReactiveBle = FlutterReactiveBle();
  Stream<List<int>> _receivedDataStream;
  QualifiedCharacteristic _txCharacteristic;
  StreamSubscription subscription;

  // String startTime = "00:00";
  // String endTime = "00:00";
  // List startTimeHrMi ;
  // List endTimeHrMi ;
  //
  // bool statusTime = false;
  // String tempStatus = "";
  @override
  Widget build(BuildContext context) {
    // args = ModalRoute.of(context).settings.arguments;
    void refreshScreen() {
      setState(() {});
    }

    void _sendData(command, args) async {
      await flutterReactiveBle.writeCharacteristicWithResponse(args,
          value: command
              .toString()
              .codeUnits);
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
        var parts0 = q.split('/');
        // print(parts0[0]);
        print('PAGE=TIME');
        try {
          globals.startTime = parts0[0].trim();
          globals.endTime = parts0[1].trim();

          for (var i = 0; i <= 6; i++) {
            int myInt = int.parse(parts0[2].trim().substring(i, i + 1));
            myInt == 0
                ? globals.isCheckedDay[i] = false
                : globals.isCheckedDay[i] = true;
          }
        } on Exception catch (_) {
          print('PAGE=LIGHT,Wrong Type Value.');
        }

        if (firstOpen) {
          var now = new DateTime.now();
          var nowHR = now.toString().substring(11, 13);
          var nowMI = now.toString().substring(14, 16);
          var nowSE = now.toString().substring(17, 19);
          var nowWeekday = now.weekday;
print("now.toString()");
          _sendData("u$nowHR$nowMI$nowSE$nowWeekday,", args);

          print(now);
          print(nowWeekday);
          firstOpen = false;

          refreshScreen();
          print(globals.startTime);
          print(globals.endTime);
        }

        if ((globals.startTime == "00:00") && (globals.endTime == "00:00")) {
          //off
          print("in1");
          print("startTime=${globals.startTime}");
          print("endTime=${globals.endTime}");
          globals.statusTime = false;
        } else {
          //on
          print("in2");
          print("startTime=${globals.startTime}");
          print("endTime=${globals.endTime}");
          globals.statusTime = true;
        }

        subscription.cancel();
      });
    }

    String daysAll = "";
    String timeAll = "";
    if (globals.isCheckedDay[0]) {
      daysAll = "$daysAll MON,";
    }
    if (globals.isCheckedDay[1]) {
      daysAll = "$daysAll TUE,";
    }
    if (globals.isCheckedDay[2]) {
      daysAll = "$daysAll WED,";
    }
    if (globals.isCheckedDay[3]) {
      daysAll = "$daysAll THU,";
    }
    if (globals.isCheckedDay[4]) {
      daysAll = "$daysAll FRI,";
    }
    if (globals.isCheckedDay[5]) {
      daysAll = "$daysAll SAT,";
    }
    if (globals.isCheckedDay[6]) {
      daysAll = "$daysAll SUN";
    }
    timeAll = "${globals.startTime} - ${globals.endTime}";
    globals.startTimeHrMi = globals.startTime.split(":");
    globals.endTimeHrMi = globals.endTime.split(":");
    if (globals.statusTime == false) {
      daysAll = "";
      timeAll = "";
    }
    if (firstSettime) {
      var now = new DateTime.now();
      var nowHR = now.toString().substring(11, 13);
      var nowMI = now.toString().substring(14, 16);
      var nowSE = now.toString().substring(17, 19);
      var nowWeekday = now.weekday;
      print("now.toString()");

      _sendData("u$nowHR$nowMI$nowSE$nowWeekday,", globals.args);
      firstSettime = false;
    }


    if (firstOpen) {
      _receiveData(globals.args);
      _sendData("i", globals.args);
      // _sendData("2266,266,266,80,0,255,0,0,255,0,255,0,255,0,0,", args);
    } else {
      print("notFIRST-time");
      print("globals.statusTime=${globals.statusTime}");
      (globals.statusTime)
          ? globals.tempStatusTime = "on"
          : globals.tempStatusTime = "off";
      //
      // String daysAll = "";
      // String timeAll = "";
      // print(globals.isCheckedDay);
      // if (globals.isCheckedDay[0]) {
      //   daysAll = "$daysAll MON,";
      // }
      // if (globals.isCheckedDay[1]) {
      //   daysAll = "$daysAll TUE,";
      // }
      // if (globals.isCheckedDay[2]) {
      //   daysAll = "$daysAll WED,";
      // }
      // if (globals.isCheckedDay[3]) {
      //   daysAll = "$daysAll THU,";
      // }
      // if (globals.isCheckedDay[4]) {
      //   daysAll = "$daysAll FRI,";
      // }
      // if (globals.isCheckedDay[5]) {
      //   daysAll = "$daysAll SAT,";
      // }
      // if (globals.isCheckedDay[6]) {
      //   daysAll = "$daysAll SUN";
      // }
      // if((globals.startTime == "00:00") && (globals.endTime == "00:00")){ //off
      //   print("in1");
      //   print("startTime=${globals.startTime}");
      //   print("endTime=${globals.endTime}");
      //   globals.statusTime=false;
      // }else{ //on
      //   print("in2");
      //   print("startTime=${globals.startTime}");
      //   print("endTime=${globals.endTime}");
      //   globals.statusTime=true;
      // }

    }

    void _onItemTapped(int index) {
      Navigator.pop(context);
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
                      Icon(Icons.access_time_outlined),
                      Text("Time"),
                    ],
                  )),
            ],
          ),
        ),
        body: Column(
          children: [
            SwitchListTile(
              title: Text("Auto Play Status"),
              subtitle: Text(globals.tempStatusTime),
              value: globals.statusTime,
              onChanged: (bool value) {
                setState(() {
                  globals.statusTime = value;
                  if (globals.statusTime) {
                    globals.tempStatusTime = "on";
                    globals.startTime = "18:00";
                    globals.endTime = "23:00";

                    List<String> s = globals.startTime.split(':');
                    List<String> e = globals.endTime.split(':');
                    String s1 = s.join("");
                    String e1 = e.join("");
                    String d = "";
                    for (var i = 0; i <= 6; i++) {
                      // globals.isCheckedDay[i] == true ? d = d+"1" : d = d+"0";
                      globals.isCheckedDay[i] = true;
                      d = d + "1";
                      d.trim();
                    }
                    _sendData("o$s1$e1$d,", globals.args);
                    // _sendData("2z", args);
                  } else {
                    globals.tempStatusTime = "off";
                    _sendData("o000000000000000,", globals.args);
                    // _sendData("2z", args);
                  }
                });
              },
              secondary: const Icon(Icons.power_settings_new),
            ),
            Divider(),
            ListTile(
              title: Text("Days"),
              subtitle: Text(daysAll),
              leading: Icon(
                Icons.calendar_today_outlined,
              ),
              onTap: () {
                showDialog(
                    context: context,
                    builder: (BuildContext context) {
                      // return AlertDialog(
                      //   title: Text('Select Mode'),
                      //   content: setupAlertDialoadContainer(),
                      // );

                      return WillPopScope(
                        onWillPop: () {},
                        child: StatefulBuilder(
                          builder: (context, setState) {
                            return AlertDialog(
                              title: Text('Select Mode'),
                              content: Container(
                                height: 500.0,
                                // Change as per your requirement
                                width: 1000.0,
                                // Change as per your requirement
                                child: ListView.builder(
                                  itemCount: globals.days.length,
                                  itemBuilder: (context, index) {
                                    return CheckboxListTile(
                                      title: Text(globals.days[index]),
                                      value: globals.isCheckedDay[index],
                                      onChanged: (val) {
                                        setState(
                                              () {
                                            globals.isCheckedDay[index] = val;
                                            print(globals.isCheckedDay);
                                          },
                                        );
                                      },
                                    );
                                  },
                                ),
                              ),
                              actions: <Widget>[
                                FlatButton(
                                    child: Text('Close'),
                                    onPressed: () =>
                                        setState(() {
                                          List<String> s =
                                          globals.startTime.split(':');
                                          List<String> e =
                                          globals.endTime.split(':');
                                          String s1 = s.join("");
                                          String e1 = e.join("");
                                          String d = "";
                                          for (var i = 0; i <= 6; i++) {
                                            globals.isCheckedDay[i] == true
                                                ? d = d + "1"
                                                : d = d + "0";
                                            d.trim();
                                          }
                                          _sendData("o$s1$e1$d,", globals.args);
                                          Navigator.of(context).pop();
                                          refreshScreen();
                                        }))
                              ],
                            );
                          },
                        ),
                      );
                    });
              },
              enabled: globals.statusTime,
            ),
            Divider(),
            ListTile(
              title: Text("Time"),
              subtitle: Text(timeAll),
              leading: Icon(
                Icons.timer_outlined,
              ),
              onTap: () {
                showDialog(
                    context: context,
                    builder: (BuildContext context) {
                      // return AlertDialog(
                      //   title: Text('Select Mode'),
                      //   content: setupAlertDialoadContainer(),
                      // );
                      return StatefulBuilder(
                        builder: (context, setState) {
                          return WillPopScope(
                            onWillPop: () {},
                            child: AlertDialog(
                              // title: Text('Start Time'),
                              content: Container(
                                height: 400.0,
                                // Change as per your requirement
                                width: 1000.0,
                                // Change as per your requirement
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Container(
                                        padding:
                                        EdgeInsets.fromLTRB(20, 20, 20, 5),
                                        child: Row(
                                          children: [
                                            Text("Start TIme"),
                                          ],
                                        )),
                                    TimePickerSpinner(
                                      is24HourMode: true,
                                      normalTextStyle: TextStyle(
                                          fontSize: 24, color: Colors.grey),
                                      highlightedTextStyle: TextStyle(
                                          fontSize: 24, color: Colors.white),
                                      spacing: 50,
                                      itemHeight: 50,
                                      isForce2Digits: true,
                                      time: DateTime(
                                          0,
                                          0,
                                          0,
                                          int.parse(globals.startTimeHrMi[0]),
                                          int.parse(globals.startTimeHrMi[1]),
                                          00),
                                      onTimeChange: (time) {
                                        setState(() {
                                          var s = time.toString();
                                          List<String> k = s.split(' ');
                                          List<String> j = k[1].split(':');
                                          var h = j[0];
                                          var h1 = j[1];
                                          globals.startTime = "$h:$h1";
                                          // print(startTime);
                                        });
                                      },
                                    ),
                                    Container(
                                        padding:
                                        EdgeInsets.fromLTRB(20, 20, 20, 5),
                                        child: Row(
                                          children: [
                                            Text("End TIme"),
                                          ],
                                        )),
                                    TimePickerSpinner(
                                      is24HourMode: true,
                                      normalTextStyle: TextStyle(
                                          fontSize: 24, color: Colors.grey),
                                      highlightedTextStyle: TextStyle(
                                          fontSize: 24, color: Colors.white),
                                      spacing: 50,
                                      itemHeight: 50,
                                      isForce2Digits: true,
                                      time: DateTime(
                                          0,
                                          0,
                                          0,
                                          int.parse(globals.endTimeHrMi[0]),
                                          int.parse(globals.endTimeHrMi[1]),
                                          00),
                                      onTimeChange: (time) {
                                        setState(() {
                                          var s = time.toString();
                                          List<String> k = s.split(' ');
                                          List<String> j = k[1].split(':');
                                          var h = j[0];
                                          var h1 = j[1];
                                          globals.endTime = "$h:$h1";
                                          // print(endTime);
                                        });
                                      },
                                    ),
                                  ],
                                ),
                              ),
                              actions: <Widget>[
                                FlatButton(
                                    child: Text('Close'),
                                    onPressed: () =>
                                        setState(() {
                                          List<String> s =
                                          globals.startTime.split(':');
                                          List<String> e =
                                          globals.endTime.split(':');
                                          String s1 = s.join("");
                                          String e1 = e.join("");
                                          String d = "";
                                          for (var i = 0; i <= 6; i++) {
                                            globals.isCheckedDay[i] == true
                                                ? d = d + "1"
                                                : d = d + "0";
                                            d.trim();
                                          }
                                          _sendData("o$s1$e1$d,", globals.args);
                                          Navigator.of(context).pop();
                                          refreshScreen();
                                        }))
                              ],
                            ),
                          );
                        },
                      );
                    });
              },
              enabled: globals.statusTime,
            ),
            Divider(),
          ],
        ),
        bottomNavigationBar: BottomNavigationBar(
          currentIndex: 2, // this will be set when a new tab is tapped
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

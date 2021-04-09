import 'package:app_settings/app_settings.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'dart:async';
import 'package:flutter_reactive_ble/flutter_reactive_ble.dart';
import 'package:Sixk_Control/pages/globals.dart' as globals;
// import 'package:location_permissions/location_permissions.dart';
// import 'package:system_setting/system_setting.dart';
import 'dart:io' show Platform;
import 'package:permission_handler/permission_handler.dart';

Uuid _UART_UUID = Uuid.parse("0000ffe0-0000-1000-8000-00805f9b34fb");
Uuid _UART_RX = Uuid.parse("0000ffe1-0000-1000-8000-00805f9b34fb");
Uuid _UART_TX = Uuid.parse("0000ffe1-0000-1000-8000-00805f9b34fb");

class HomePage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _HomePageState();
  }
}

class _HomePageState extends State<HomePage> {
  bool bleStatus = true;
  bool locationStatus = true;
  bool locationPerStatus = false;
  bool scanningVisible = true;
  bool onceTimeSend = true;
  bool waitSSFinish = false;
  final flutterReactiveBle = FlutterReactiveBle();
  List<DiscoveredDevice> _foundBleUARTDevices = [];
  StreamSubscription<DiscoveredDevice> _scanStream;
  Stream<ConnectionStateUpdate> _currentConnectionStream;
  StreamSubscription<ConnectionStateUpdate> _connection;
  QualifiedCharacteristic _txCharacteristic;
  QualifiedCharacteristic _rxCharacteristic;
  Stream<List<int>> _receivedDataStream;
  TextEditingController _dataToSendText;
  bool _scanning = false;
  bool _connected = false;
  String _logTexts = "";
  List<String> _receivedData = [];
  int _numberOfMessagesReceived = 0;
  var cardArray = [];
  var argsSend;
  StreamSubscription subscription;

  void initState() {
    super.initState();
    _dataToSendText = TextEditingController();
    // _disconnect();
    // _startScan();
    // _checkBluetoothLocation();
    Future.delayed(const Duration(milliseconds: 2000), () {
      // delay แก้ bug alert bluetooth โผล่ตอนแรก
      checkBluetooth();
      firstCheckLocation();
    });

    print("initStateinitStateinitStateinitState");
  }

  void refreshScreen() {
    setState(() {});
  }

  void _sendData(command) async {
    print("_sendData=$command");
    await flutterReactiveBle.writeCharacteristicWithResponse(_rxCharacteristic,
        value: command.codeUnits);
    // value: _dataToSendText.text.codeUnits);
  }

  void onNewReceivedData(List<int> data) {
    // print(data);
    _numberOfMessagesReceived += 1;
    _receivedData
        .add("$_numberOfMessagesReceived: ${String.fromCharCodes(data)}");
    if (_receivedData.length > 5) {
      _receivedData.removeAt(0);
    }
    refreshScreen();
  }

  void checkBluetooth() async {
    print("checkBLUETOOTH");
    flutterReactiveBle.statusStream.listen((status) {
      if ((status.toString().trim() == "BleStatus.poweredOff") ||
          (status.toString().trim() == "BleStatus.unknown")) {
        bleStatus = false;
        print("BLUETOOTH CHECK FALSE");
        // SystemSetting.goto(SettingTarget.BLUETOOTH);
      } else {
        bleStatus = true;
        _startScan();
      }
      // refreshScreen();
      print("checkBLUETOOTH=${status.toString().trim()}");
    });

    // _checkLocation();
  }

  void firstCheckLocation() async {
    if (await Permission.location.request().isGranted) {
      // Either the permission was already granted before or the user just granted it.
      print("W1");
    } else {
      print("W2");
      // _checkBluetoothLocation();
    }

    if (await Permission.locationWhenInUse.serviceStatus.isEnabled) {
      // Use location.
      print("Q1");
      locationStatus = true;
    } else {
      print("Q2");
      locationStatus = false;
      // SystemSetting.goto(SettingTarget.LOCATION);
      //   _checkBluetoothLocation();
    }

    refreshScreen();
  }

  void _checkLocation() async {
    if (await Permission.location.request().isGranted) {
      // Either the permission was already granted before or the user just granted it.
      print("W1");
    } else {
      print("W2");
      // _checkBluetoothLocation();
    }

    if (await Permission.locationWhenInUse.serviceStatus.isEnabled) {
      // Use location.
      print("Q1");
      locationStatus = true;
      refreshScreen();
    } else {
      print("Q2");
      locationStatus = false;
      // SystemSetting.goto(SettingTarget.LOCATION); //xxxxx

      _checkLocation();
      //   _checkBluetoothLocation();
    }
  }

  void _startScan() async {
    print("START SCAN");
    bool goForIt = false;
    // PermissionStatus permission;

    // if (Platform.isAndroid) {
    //   print("location permission");
    //   permission = await LocationPermissions().requestPermissions();
    //   if (permission == PermissionStatus.granted) goForIt = true;
    // } else if (Platform.isIOS) {
    //   goForIt = true;
    // }
    goForIt = true;

    // var statusLocation = await Permission.location.request().isGranted;
    // var statusBluetooth = await Permission.

    // print("status=$status");
    // openAppSettings();

    // SystemSetting.goto(SettingTarget.BLUETOOTH);
    // SystemSetting.goto(SettingTarget.LOCATION);

    if (goForIt) {
      //TODO replace True with permission == PermissionStatus.granted is for IOS test
      _foundBleUARTDevices = [];
      cardArray = [];
      _scanning = true;
      refreshScreen();
      _scanStream = flutterReactiveBle
          .scanForDevices(withServices: [_UART_UUID]).listen((device) {
        if (_foundBleUARTDevices.every((element) => element.id != device.id)) {
          _foundBleUARTDevices.add(device);
          cardArray.add(device.name);
          print("FOUNDED device id=$device");
          refreshScreen();
        }
      }, onError: (Object error) {
        _logTexts = "${_logTexts}ERROR while scanning:$error \n";
        refreshScreen();
      });
      print("SCANNING");
    } else {
      // await showNoPermissionDialog();
    }
  }

  void onConnectDevice(index) async {
    await _scanStream.cancel();
    _scanning = false;

    _currentConnectionStream = flutterReactiveBle.connectToAdvertisingDevice(
      id: _foundBleUARTDevices[index].id,
      prescanDuration: Duration(seconds: 1),
      withServices: [_UART_UUID, _UART_RX, _UART_TX],
    );
    print("_currentConnectionStream=$_currentConnectionStream");
    _logTexts = "";
    // refreshScreen();
    _connection = _currentConnectionStream.listen((event) {
      var id = event.deviceId.toString();
      switch (event.connectionState) {
        case DeviceConnectionState.connecting:
          {
            print("case1");
            _logTexts = "${_logTexts}Connecting to $id\n";
            break;
          }
        case DeviceConnectionState.connected:
          {
            print("case2");
            _connected = true;
            _logTexts = "${_logTexts}Connected to $id\n";

            _numberOfMessagesReceived = 0;
            _receivedData = [];
            _txCharacteristic = QualifiedCharacteristic(
                serviceId: Uuid.parse("FFE0"),
                characteristicId: Uuid.parse("FFE1"),
                deviceId: event.deviceId);
            // _receivedDataStream =
            //     flutterReactiveBle.subscribeToCharacteristic(_txCharacteristic);
            // _receivedDataStream.listen((data) {
            //   // onNewReceivedData(data);
            //   print("INRE = ${String.fromCharCodes(data)}");
            // }, onError: (dynamic error) {
            //   print("INRE ERROR = $error");
            //   _logTexts = "${_logTexts}Error:$error$id\n";
            // });
            _rxCharacteristic = QualifiedCharacteristic(
                serviceId: Uuid.parse("FFE0"),
                characteristicId: Uuid.parse("FFE1"),
                deviceId: event.deviceId);

            // argsSend = [cardArray[index],_rxCharacteristic];
            argsSend = _rxCharacteristic;
            print(argsSend);
            // _stopScan();

            Navigator.pushNamed(context, "/device_setting_page",
                    arguments: argsSend)
                .then((value) {
              cardArray =[];
              EasyLoading.dismiss();
              onceTimeSend = true;

              print("Re ${globals.motorStatus}");
              if(globals.motorStatus=="off"){
                _sendData("6");



                Future.delayed(const Duration(milliseconds: 500), () {
                  waitSSFinish = false;
                  _disconnect();
                  _startScan();
                });

              }else{
                waitSSFinish = true;
                _receiveData(globals.args);
                Future.delayed(const Duration(milliseconds: 200), () {
                  _sendData("8");
                });
              }

              refreshScreen();







            });
            break;
          }
        case DeviceConnectionState.disconnecting:
          {
            print("case3");
            _connected = false;
            _logTexts = "${_logTexts}Disconnecting from $id\n";
            break;
          }
        case DeviceConnectionState.disconnected:
          {
            print("case4");
            _logTexts = "${_logTexts}Disconnected from $id\n";
            break;
          }
      }
      // refreshScreen();
    });
  }

  void _disconnect() async {
    await _connection.cancel();
    _connected = false;
    refreshScreen();
    print("DISCONTECT");
    // _startScan();
  }

  void _stopScan() async {
    await _scanStream.cancel();
    _scanning = false;
    // refreshScreen();
    print("STOP-SCAN");
  }

  void _receiveData(args) async {
    print("iosTEST-1");
    _txCharacteristic = QualifiedCharacteristic(
        serviceId: Uuid.parse("FFE0"),
        characteristicId: Uuid.parse("FFE1"),
        deviceId: args.deviceId);
    _receivedDataStream =
        flutterReactiveBle.subscribeToCharacteristic(_txCharacteristic);

    subscription = _receivedDataStream.listen((data) {
      // onNewReceivedData(data);
      // print(String.fromCharCodes(data));
      // print(waitSSFinish);
      var s = String.fromCharCodes(data);
      // if(s=="ssFinish"){
      print("PAGE=HOME");
      print("data=$data");
      print("data=$s");
      // var parts = s.split(',');
      // if(parts[2].trim()==)


      // if ((data.toString() ==
      //         "[109, 64, 111, 102, 102, 44, 97, 99, 44, 48, 13, 10]") ||
      //     (data.toString() ==
      //         "[109, 64, 111, 102, 102, 44, 99, 99, 44, 48, 13, 10]")) {
      //   //off
      //   print("OFF1");
      //   if (onceTimeSend) {
      //     print("OFF2");
      //     _sendData("6");
      //     onceTimeSend = false;
      //     waitSSFinish = false;
      //     Future.delayed(const Duration(milliseconds: 500), () {
      //       _disconnect();
      //     });
      //
      //     subscription.cancel();
      //   }
      // } else {
      //   print("OFF3");
      //   if (onceTimeSend) {
      //     print("OFF4");
      //     _sendData("8");
      //     onceTimeSend = false;
      //   }
      // }




      // if (data.toString() ==
      //     "[115, 115, 70, 105, 110, 105, 115, 104, 13, 10]") {

        if ((data.toString().indexOf("115, 115, 70, 105, 110, 105, 115, 104") == 1) || (data.toString().indexOf("115, 24, 15, 22, 110, 105, 115, 104, 13, 10") == 1)){// แก้บีคปิด recievedata หน้า  device page ไม่ได้ ทำให้รับข้อมูลซ้อนกัน
        //ssFinish
        waitSSFinish = false;
        print('$s' + '$waitSSFinish');
        _disconnect();
        subscription.cancel();
        refreshScreen();
        _startScan();
      }
      // _startScan();
      // refreshScreen();

      // }
    });
  }

  @override
  Widget build(BuildContext context) {
    // _receiveData(argsSend);
    EasyLoading.instance
      ..displayDuration = const Duration(milliseconds: 2000)
      ..indicatorType = EasyLoadingIndicatorType.dualRing
      ..loadingStyle = EasyLoadingStyle.dark
      ..maskType = EasyLoadingMaskType.black
      ..indicatorSize = 45.0
      ..radius = 10.0
      // ..progressColor = Colors.yellow
      ..backgroundColor = Colors.green
      // ..indicatorColor = Colors.yellow
      // ..textColor = Colors.yellow
      // ..maskColor = Colors.blue.withOpacity(0.5)
      ..userInteractions = false
      ..dismissOnTap = false;
    if (waitSSFinish) {
      EasyLoading.show(status: 'Setting Point...');
      scanningVisible = false;
      refreshScreen();
    } else {
      EasyLoading.dismiss();
      scanningVisible = true;
      refreshScreen();
    }

    // if (!bleStatus) {
    //   print("NO");
    // } else {
    //   print("YES");
    // }
    if (!bleStatus) {
      return AlertDialog(
        title: Text('Please turn on bluetooth and location.'),
        content: TextButton.icon(
            label: Text(
              'Setting',
              style: TextStyle(fontSize: 16),
            ),
            icon: Icon(Icons.bluetooth),
            onPressed: () {
              // SystemSetting.goto(SettingTarget.BLUETOOTH);//xxxxx
              // AppSettings.openLocationSettings();
              AppSettings.openBluetoothSettings();
            }),
      );
    } else if (!locationStatus) {
      _checkLocation();
      return AlertDialog(
        title: Text('Please turn on location.'),
        content: TextButton.icon(
            label: Text(
              'Setting',
              style: TextStyle(fontSize: 16),
            ),
            icon: Icon(Icons.location_pin),
            onPressed: () {
              AppSettings.openLocationSettings();
            }),
      );
    } else {
      return Scaffold(
          // backgroundColor: Color(0xFFF1F1F1),
          // appBar: AppBar(
          //   title: Text("title text"),
          // ),
          body: SafeArea(
        child: Column(
          children: [
            Container(
              padding: EdgeInsets.fromLTRB(20, 15, 20, 10),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Select your device.",
                    style: TextStyle(
                      // color: Colors.black,
                      fontSize: 20,
                    ),
                  ),
                  // Text(
                  //   waitSSFinish.toString(),
                  //   style: TextStyle(
                  //     color: Colors.black,
                  //     fontSize: 20,
                  //   ),
                  // ),
                  // RaisedButton(
                  //   onPressed: !_scanning && !_connected ? _startScan : () {},
                  //   child: Icon(
                  //     Icons.play_arrow,
                  //     color: !_scanning && !_connected
                  //         ? Colors.blue
                  //         : Colors.grey,
                  //   ),
                  // ),
                  // RaisedButton(
                  //     onPressed: _disconnect,
                  //     child: Icon(
                  //       Icons.stop,
                  //       color: _scanning ? Colors.blue : Colors.grey,
                  //     )),
                ],
              ),
            ),
            Flexible(
              child: Container(
                padding: EdgeInsets.fromLTRB(20, 0, 20, 10),
                child: ListView.builder(
                    itemCount: cardArray.length,
                    // gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    //     crossAxisCount: 1,
                    //     childAspectRatio: 6 / 2,
                    //     crossAxisSpacing: 5,
                    //     mainAxisSpacing: 5),
                    itemBuilder: (ctx, index) {
                      return GestureDetector(
                        onTap: () {
                          EasyLoading.show(status: 'Connecting...');
                          _stopScan();
                          onConnectDevice(index);

                          // arguments: _logTexts);
                        },
                        child: Card(
                          color: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(2.0),
                          ),
                          elevation: 2,
                          child: Container(
                            padding: EdgeInsets.fromLTRB(15, 15, 15, 15),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.start,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Container(
                                  padding: EdgeInsets.fromLTRB(0, 0, 0, 0),
                                  child: Image.asset(
                                    "img/boxIcon.png",
                                    width:
                                        MediaQuery.of(context).size.width / 6,
                                  ),
                                ),
                                Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Container(
                                        padding:
                                            EdgeInsets.fromLTRB(10, 8, 0, 0),
                                        child: Text(
                                          cardArray[index],
                                          style: TextStyle(
                                            color: Colors.black,
                                            fontSize: 14,
                                          ),
                                        )),
                                    Container(
                                        padding:
                                            EdgeInsets.fromLTRB(10, 1, 0, 0),
                                        child: Text(
                                          "Ready",
                                          style: TextStyle(
                                            color: Colors.green,
                                            fontSize: 12,
                                          ),
                                        )),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    }),
              ),
            ),
            Container(
                padding: EdgeInsets.fromLTRB(0, 0, 0, 10),
                child: Column(
                  children: [
                    Visibility(
                      child: Column(
                        children: [
                          CircularProgressIndicator(),
                          Container(
                              padding: EdgeInsets.all(10),
                              child: Text("Searching device...",
                                  style: TextStyle(
                                    color: Colors.grey,
                                  ))),
                          Text("version:1.0.0",
                              style: TextStyle(
                                color: Colors.grey,
                                fontSize: 10,
                              )),
                        ],
                      ),
                      visible: scanningVisible,
                    ),
                  ],
                )),
          ],
        ),
      ));
    }
  }
}

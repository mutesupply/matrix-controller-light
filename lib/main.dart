import 'package:flutter/material.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'package:sleek_circular_slider/sleek_circular_slider.dart';
import 'package:syncfusion_flutter_gauges/gauges.dart';


import 'dart:async';

import 'package:flutter_blue_plus/flutter_blue_plus.dart';
void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
return MaterialApp(
  debugShowCheckedModeBanner: false,
  theme: ThemeData(
    brightness: Brightness.dark,
    scaffoldBackgroundColor: const Color(0xFF07101A),
    primaryColor: Colors.cyanAccent,
    sliderTheme: const SliderThemeData(
      activeTrackColor: Colors.cyanAccent,
      thumbColor: Colors.cyanAccent,
    ),
  ),
  home: SplashScreen(),
);
  }
}

// ================= SPLASH SCREEN =================
class SplashScreen extends StatefulWidget {
  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {


  late AnimationController glowController;
  

  double opacity = 0;

  @override
  void initState() {
    super.initState();


    glowController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);



    Future.delayed(const Duration(milliseconds: 500), () {
      if (!mounted) return;
      setState(() => opacity = 1);

    });

    Future.delayed(const Duration(seconds: 5), () {
      if (!mounted) return;
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const HomePage()),
      );
    });
  }

@override
void dispose() {
  glowController.dispose();
  super.dispose();
}

  @override
  Widget build(BuildContext context) {
    return Scaffold(


      backgroundColor: Colors.black,
      body: Center(
        child: AnimatedOpacity(
          duration: const Duration(seconds: 2),
          opacity: opacity,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [

              // 🔥 LOGO ANIMATED
// 🔥 LOGO ANIMATED (NO ROTATE)
AnimatedBuilder(
  animation: glowController,
  builder: (_, __) {
    return Transform.scale(
      scale: 0.9 + (glowController.value * 0.1),
      child: Container(
        decoration: BoxDecoration(
          boxShadow: [
            BoxShadow(
              color: Colors.cyanAccent.withOpacity(
                  0.5 + glowController.value * 0.5),
              blurRadius: 60,
              spreadRadius: 15,
            )
          ],
        ),
        child: Image.asset(
          'assets/logo.png',
          width: 180,
        ),
      ),
    );
  },
),

              const SizedBox(height: 30),

              const Text(
                "MUTE SUPPLY",
                style: TextStyle(
                  color: Colors.cyanAccent,
                  fontSize: 26,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 3,
                ),
              ),

              const SizedBox(height: 10),

              const Text(
                "MATRIX CONTROLLER",
                style: TextStyle(
                  color: Colors.white70,
                  fontSize: 14,
                  letterSpacing: 2,
                ),
              ),

              const SizedBox(height: 30),

              // 🔄 LOADING FUTURISTIC
              SizedBox(
                width: 120,
                child: LinearProgressIndicator(
                  minHeight: 4,
                  color: Colors.cyanAccent,
                  backgroundColor: Colors.white12,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}
bool isUploading = false;
class _HomePageState extends State<HomePage> {
late stt.SpeechToText speech;
bool isListening = false;
String lastWords = "";
BluetoothDevice? device;
BluetoothCharacteristic? txCharacteristic;
bool isConnected = false;
bool isConnecting = false;
StreamSubscription<BluetoothConnectionState>? connectionSub;
List<BluetoothDevice> devicesList = [];
BluetoothDevice? selectedDevice;

Widget glowButton(String text, VoidCallback onTap, {bool loading = false}) {
  return GestureDetector(
    onTap: loading ? null : onTap,
    child: AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      height: 50,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(15),
        gradient: LinearGradient(
          colors: loading
              ? [
                  Colors.grey,
                  Colors.black45,
                ]
              : [
                  Colors.cyanAccent,
                  Colors.blueAccent,
                ],
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.cyanAccent.withOpacity(0.6),
            blurRadius: 20,
          )
        ],
      ),
      child: Center(
        child: loading
            ? const SizedBox(
                height: 18,
                width: 18,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: Colors.black,
                ),
              )
            : Text(
                text,
                style: const TextStyle(
                  color: Colors.black,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1,
                ),
              ),
      ),
    ),
  );
}

Widget controlButton(String text, Color color, VoidCallback onTap) {
  return GestureDetector(
    onTap: onTap,
    child: AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      height: 60,
      width: 130,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        gradient: LinearGradient(
          colors: [
            color.withOpacity(0.8),
            color,
          ],
        ),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.8),
            blurRadius: 25,
          )
        ],
      ),
      child: Center(
        child: Text(
          text,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            letterSpacing: 1,
            color: Colors.white,
          ),
        ),
      ),
    ),
  );
}

Future<void> connectToBT() async {
  if (isConnected) {
    print("Sudah connect");
    return;
  }


  if (selectedDevice == null) {
    print("Belum pilih device");
    return;
  }

  if (isConnecting) {
    print("Sedang connect...");
    return;
  }

  isConnecting = true;
  txCharacteristic = null; // 🔥 RESET WAJIB
  device = selectedDevice;
await FlutterBluePlus.stopScan(); // 🔥 WAJIB UNTUK iOS
await Future.delayed(const Duration(milliseconds: 300));


  try {
await Future.delayed(const Duration(milliseconds: 500)); // 🔥 penting

try {
  await device!.connect(
    timeout: const Duration(seconds: 10),
    autoConnect: false, // 🔥 PENTING UNTUK iOS
  );
} catch (e) {
  print("Retry connect...");
  await Future.delayed(const Duration(seconds: 1));
  await device!.connect(
    timeout: const Duration(seconds: 10),
    autoConnect: false,
  );
}
await Future.delayed(const Duration(milliseconds: 500)); // 🔥 WAJIB
    // 🔥 FIX LISTENER
    connectionSub?.cancel();   // 🔥 tambahkan ini
connectionSub = device!.connectionState.listen((state) {

  setState(() {
    isConnected = state == BluetoothConnectionState.connected;
  });

  print("STATE: $state");

});

await Future.delayed(const Duration(milliseconds: 500)); // 🔥 TAMBAHKAN INI
    List<BluetoothService> services =
        await device!.discoverServices();

for (var service in services) {

if (service.uuid.toString().toLowerCase() ==
    "12345678-1234-1234-1234-1234567890ab") {

    for (var c in service.characteristics) {

      if (c.properties.write || c.properties.writeWithoutResponse) {
        txCharacteristic = c;
await Future.delayed(const Duration(milliseconds: 200)); // 🔥 tambahan stabil
        print("✅ ESP CHARACTERISTIC DITEMUKAN");
        break; // 🔥 WAJIB STOP DI SINI
      }

    }
break; // 🔥 TAMBAHKAN INI (PENTING BANGET)
  }

}
if (txCharacteristic == null) {
  print("❌ CHARACTERISTIC TIDAK DITEMUKAN");
  return;
}
await Future.delayed(const Duration(milliseconds: 300)); // 🔥 FINAL DELAY
print("Connected BLE!");
await FlutterBluePlus.stopScan();
} catch (e) {
  print("Gagal connect: $e");
} finally {
  isConnecting = false;   // 🔥 WAJIB
  setState(() {});        // 🔥 UPDATE UI
}

 
}

void sendBT(String data) async {
  if (txCharacteristic == null) {
    print("❌ BELUM ADA CHARACTERISTIC");
    return;
  }

  print("📤 KIRIM: $data");

  await txCharacteristic!.write(
    data.codeUnits,
    withoutResponse: true, // 🔥 WAJIB
  );
}

  Widget menuCard(String title, IconData icon, VoidCallback onTap) {
  return InkWell(
    borderRadius: BorderRadius.circular(20),
    onTap: onTap,
    child: Container(
      height: 120,
      margin: const EdgeInsets.all(8),
      decoration: BoxDecoration(
  borderRadius: BorderRadius.circular(20),
  gradient: LinearGradient(
    colors: title == "WELCOME" && welcome > 0
        ? [
            Colors.cyanAccent,
            Colors.blueAccent,
          ]
        : [
            Colors.cyan.withOpacity(0.3),
            Colors.blue.withOpacity(0.2),
          ],
  ),
  boxShadow: [
    BoxShadow(
color: title == "WELCOME" && welcome > 0
    ? Colors.cyanAccent.withOpacity(glow)
          : Colors.cyanAccent.withOpacity(0.3),
      blurRadius: title == "WELCOME" && welcome > 0 ? 30 : 15,
    )
  ],
),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 40, color: Colors.white),
          const SizedBox(height: 10),
          Text(title),
        ],
      ),
    ),
  );
}
  double glow = 0.5;

StreamSubscription? scanSub;

Future<void> scanDevices() async {
  setState(() {
    devicesList.clear();
  });

  await FlutterBluePlus.stopScan();
  await Future.delayed(const Duration(milliseconds: 300));

  await FlutterBluePlus.turnOn();
  await Future.delayed(const Duration(seconds: 1)); // 🔥 penting

  await FlutterBluePlus.startScan(
    timeout: const Duration(seconds: 10),
    continuousUpdates: true,
    androidUsesFineLocation: true,
  );

  scanSub?.cancel();

  scanSub = FlutterBluePlus.scanResults.listen((results) {
    for (ScanResult r in results) {

      if (!devicesList.any((d) => d.id == r.device.id)) {
        setState(() {
          devicesList.add(r.device);
        });
      }

      print("SCAN: ${r.device.platformName} | ${r.device.id}");
    }
  });
}

late Timer glowTimer;
@override
void dispose() {
  connectionSub?.cancel(); // 🔥 penting
  scanSub?.cancel(); // 🔥 tambahkan ini
  glowTimer.cancel();
  device?.disconnect(); // 🔥 tambahkan ini
  super.dispose();
}
@override
void initState() {
  super.initState();
  speech = stt.SpeechToText();
scanDevices(); // 🔥 VERSI BARU
  glowTimer = Timer.periodic(const Duration(milliseconds: 80), (_) {
    setState(() {
      glow += 0.05;
      if (glow > 1) glow = 0.3;
    });
  });
}
void startListening() async {
  bool available = await speech.initialize();

  if (available) {
    setState(() => isListening = true);

    speech.listen(
      localeId: "id_ID",
      listenFor: const Duration(seconds: 5), // 🔥 tambahkan ini
      onResult: (result) {
        setState(() {
          lastWords = result.recognizedWords.toLowerCase();
        });

        processVoiceCommand(lastWords);
      },
    );
  }
}
void stopListening() async {
  await speech.stop();
  setState(() => isListening = false);
}
void processVoiceCommand(String command) {
  command = command.toLowerCase();

  if (command.contains("start") || command.contains("nyalakan")) {
    sendBT("START");
    return;
  }

  if (command.contains("stop") || command.contains("matikan")) {
    sendBT("STOP");
    return;
  }

  if (command.contains("animasi") || command.contains("mainkan")) {
    RegExp reg = RegExp(r'\d+');
    var match = reg.firstMatch(command);

    if (match != null) {
      int number = int.parse(match.group(0)!);

      if (number >= 1 && number <= 30) {
        sendBT("M$number");
      }
    }
  }
}



Widget panel(String title, IconData icon, Widget child) {
  return Container(
    margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
    decoration: BoxDecoration(
      borderRadius: BorderRadius.circular(20),
      gradient: LinearGradient(
        colors: [
          Colors.cyan.withOpacity(0.15),
          Colors.blue.withOpacity(0.05),
        ],
      ),
      boxShadow: [
        BoxShadow(
          color: Colors.cyanAccent.withOpacity(0.25),
          blurRadius: 15,
          spreadRadius: 1,
        )
      ],
    ),
    child: ExpansionTile(
      leading: Icon(icon, color: Colors.cyanAccent),
      title: Text(
        title,
        style: const TextStyle(
          fontWeight: FontWeight.bold,
          letterSpacing: 1,
        ),
      ),
      iconColor: Colors.cyanAccent,
      collapsedIconColor: Colors.white54,
      children: [
        Padding(
          padding: const EdgeInsets.all(12),
          child: child,
        ),
      ],
    ),
  );
}
int ledCount = 12;
Map<String, bool> lampState = {
  "fog": false,
  "dekat": false,
  "jauh": false,
};
  double speed = 120;
  int modeJauh = 0;
  int welcome = 0;
int activeButton = -1;


  List<int> fog = [];

List<int> dekat = [];
List<int> jauh = [];
String btName = "";


String selectedAnimasi = "Animasi 1";

// otomatis buat M1 sampai M30
List<String> animasiList =
    List.generate(30, (index) => "Animasi ${index + 1}");


Widget buildLampBox(String type, List<int> data, Function setModalState) {
  return Column(
    children: [

      Wrap(
        spacing: 10,
        runSpacing: 10,
        children: List.generate(ledCount, (i) {
          int n = i + 1;

          return GestureDetector(
  onTap: () {
    setModalState(() {
      if (data.contains(n)) {
        data.remove(n);
      } else {
        data.add(n);
      }
    });
  },
  child: AnimatedContainer(
    duration: const Duration(milliseconds: 150),
    padding: const EdgeInsets.all(10),
    decoration: BoxDecoration(
      borderRadius: BorderRadius.circular(12),

      // 🔥 WARNA LED
      color: data.contains(n)
          ? Colors.cyanAccent
          : Colors.white10,

      // 🔥 EFEK GLOW
      boxShadow: data.contains(n)
          ? [
              BoxShadow(
                color: Colors.cyanAccent.withOpacity(0.9),
                blurRadius: 15,
                spreadRadius: 2,
              )
            ]
          : [],
    ),

    child: Text(
      "$n",
      style: TextStyle(
        color: data.contains(n)
            ? Colors.black
            : Colors.white,
        fontWeight: FontWeight.bold,
      ),
    ),
  ),
);
        }),
      ),

      const SizedBox(height: 10),

      ElevatedButton(
        onPressed: () {
          sendBT("$type:${data.join(",")}");
        },
        child: const Text("SAVE"),
      )
    ],
  );
}
  @override
  Widget build(BuildContext context) {
return Scaffold(
  floatingActionButton: FloatingActionButton(
  backgroundColor: isListening ? Colors.red : Colors.blue,
  onPressed: () {
    if (isListening) {
      stopListening();
    } else {
      startListening();
    }
  },
  child: Icon(isListening ? Icons.mic : Icons.mic_none),
),
  body: Container(
decoration: BoxDecoration(
  gradient: const LinearGradient(
    colors: [
      Color(0xFF02040A),
      Color(0xFF07101A),
      Color(0xFF0A1F2E),
    ],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  ),
  boxShadow: [
    BoxShadow(
      color: Colors.cyanAccent.withOpacity(glow),
      blurRadius: 60,
      spreadRadius: 10,
    )
  ],
),

    child: SafeArea(
        child: SingleChildScrollView(



          child: Column(
            children: [

              DropdownButton<int>(
  value: ledCount,
  dropdownColor: Colors.black,
  isExpanded: true,
  items: [8, 10, 12, 14, 16].map((e) {
    return DropdownMenuItem(
      value: e,
      child: Text("$e LED"),
    );
  }).toList(),
onChanged: (v) {
  setState(() {
    ledCount = v!;

    // 🔥 RESET DATA BIAR AMAN
    fog.clear();
    dekat.clear();
    jauh.clear();
  });
},
),
    // ===== INPUT IP =====

Padding(
  padding: const EdgeInsets.all(12),
  child: Column(
    children: [

Container(
  padding: const EdgeInsets.symmetric(horizontal: 12),
  decoration: BoxDecoration(
    borderRadius: BorderRadius.circular(20),
    gradient: LinearGradient(
      colors: [
        Colors.cyan.withOpacity(0.2),
        Colors.blue.withOpacity(0.1),
      ],
    ),
    boxShadow: [
      BoxShadow(
        color: Colors.cyanAccent.withOpacity(0.3),
        blurRadius: 15,
      )
    ],
  ),
  child: DropdownButton<BluetoothDevice>(
    hint: const Text(
      "Pilih Bluetooth",
      style: TextStyle(color: Colors.white70),
    ),
    value: devicesList.contains(selectedDevice)
        ? selectedDevice
        : null,
    isExpanded: true,
    dropdownColor: Colors.black,
    underline: const SizedBox(),

    icon: const Icon(Icons.bluetooth, color: Colors.cyanAccent),

    items: devicesList.map((device) {
      return DropdownMenuItem(
        value: device,
child: Text(
  device.platformName.isNotEmpty
      ? device.platformName
      : "ESP (${device.id})", // 🔥 TAMBAH KOMA DI SINI
  style: const TextStyle(color: Colors.white),
),
      );
    }).toList(),

onChanged: (device) async {
  setState(() {
    selectedDevice = device;
    isConnecting = true;
  });

  await Future.delayed(const Duration(milliseconds: 200));
  await connectToBT();
},
  ),
),

      const SizedBox(height: 10),

glowButton("SCAN BT", scanDevices),

const SizedBox(height: 10),

glowButton(
  isConnected
      ? "CONNECTED"
      : (isConnecting ? "CONNECTING..." : "CONNECT"),
  connectToBT,
  loading: isConnecting,
),
const SizedBox(height: 10),


    ],
  ),
),


    // ===== HEADER =====
Container(
  margin: const EdgeInsets.all(12),
  padding: const EdgeInsets.all(16),
  decoration: BoxDecoration(
    borderRadius: BorderRadius.circular(20),
    gradient: LinearGradient(
      colors: [
        Colors.cyan.withOpacity(0.2),
        Colors.blue.withOpacity(0.1),
      ],
    ),
    boxShadow: [
      BoxShadow(
        color: Colors.cyanAccent.withOpacity(0.3),
        blurRadius: 20,
      )
    ],
  ),
  child: Column(
    children: [

          const Text(
            "MATRIX CONTROL",
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
            ),
          ),

          const SizedBox(height: 4),

          const Text(
            "MUTE SUPPLY",
            style: TextStyle(color: Colors.grey),
          ),

          const SizedBox(height: 6),

          // ===== STATUS ONLINE =====
Text(
  isConnected ? "ONLINE" : "OFFLINE",
  style: TextStyle(
    color: isConnected ? Colors.green : Colors.red,
    fontWeight: FontWeight.bold,
  ),
),

const SizedBox(height: 6),

Text(
  isConnected ? "BT CONNECTED" : "BT DISCONNECTED",
  style: TextStyle(
    color: isConnected ? Colors.green : Colors.red,
    fontWeight: FontWeight.bold,
  ),
),

        ],
      ),
    ),

Column(
  crossAxisAlignment: CrossAxisAlignment.start,
  children: [

    const Padding(
      padding: EdgeInsets.only(left: 16),
      child: Text(
        "PILIH ANIMASI",
        style: TextStyle(
          color: Colors.white70,
          fontSize: 12,
          letterSpacing: 1,
        ),
      ),
    ),

    // 🔥 INI YANG TADI SALAH → HARUS PAKAI CONTAINER
    Container(
      margin: const EdgeInsets.all(12),
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        gradient: LinearGradient(
          colors: [
            Colors.cyan.withOpacity(0.15),
            Colors.blue.withOpacity(0.05),
          ],
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.cyanAccent.withOpacity(0.3),
            blurRadius: 15,
          )
        ],
      ),
      child: Row(
        children: [

          const Icon(Icons.auto_awesome, color: Colors.cyanAccent),

          const SizedBox(width: 10),

          Expanded(
            child: DropdownButton<String>(
              value: selectedAnimasi,
              isExpanded: true,
              dropdownColor: Colors.black,
              underline: const SizedBox(),

              items: animasiList.map((String value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Text(
                    value,
                    style: const TextStyle(color: Colors.white),
                  ),
                );
              }).toList(),

              onChanged: (value) {
                setState(() {
                  selectedAnimasi = value!;
                });

                int nomor = int.parse(value!.split(" ")[1]);
                sendBT("M$nomor");
              },
            ),
          ),
        ],
      ),
    ),
  ],
),


              // ===== CONTROL =====
Row(
  mainAxisAlignment: MainAxisAlignment.center,
  children: [

controlButton(
  "START",
  Colors.green,
  () => sendBT("START"), // ✅ BENAR
),
    const SizedBox(width: 12),

    controlButton(
      "STOP",
      Colors.red,
      () => sendBT("STOP"),
    ),

  ],
),
const SizedBox(height: 10),

Column(
  children: [
    const Text("SPEED", style: TextStyle(fontSize: 14)),

    const SizedBox(height: 10),

    SizedBox(
      height: 220,
      child: SfRadialGauge(
        axes: [
          RadialAxis(
            minimum: 0,
            maximum: 300,
            showLabels: true,
            showTicks: true,
            axisLineStyle: AxisLineStyle(
              thickness: 0.15,
              thicknessUnit: GaugeSizeUnit.factor,
            ),

            pointers: [
              NeedlePointer(
                value: speed,
                needleColor: Colors.redAccent,
                knobStyle: KnobStyle(
                  color: Colors.white,
                ),
              ),
            ],

            ranges: [
              GaugeRange(
                startValue: 0,
                endValue: 100,
                color: Colors.green,
              ),
              GaugeRange(
                startValue: 100,
                endValue: 200,
                color: Colors.orange,
              ),
              GaugeRange(
                startValue: 200,
                endValue: 300,
                color: Colors.red,
              ),
            ],

            annotations: [
              GaugeAnnotation(
                widget: Text(
                  "${speed.toInt()}",
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.cyanAccent,
                  ),
                ),
                angle: 90,
                positionFactor: 0.6,
              )
            ],
          )
        ],
      ),
    ),

    Slider(
      value: speed,
      min: 0,
      max: 300,
onChanged: (v) {
  setState(() => speed = v);

  int realSpeed = 300 - v.toInt(); // 🔥 dibalik

  sendBT("SPD$realSpeed");
},
    ),
  ],
),
const SizedBox(height: 12),
Column(
  crossAxisAlignment: CrossAxisAlignment.start,
  children: [

    const Padding(
      padding: EdgeInsets.only(left: 16),
      child: Text(
        "MODE JAUH",
        style: TextStyle(
          color: Colors.white70,
          fontSize: 12,
          letterSpacing: 1,
        ),
      ),
    ),

    Container(
      margin: const EdgeInsets.all(12),
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        gradient: LinearGradient(
          colors: [
            Colors.cyan.withOpacity(0.15),
            Colors.blue.withOpacity(0.05),
          ],
        ),
      ),
      child: DropdownButton<int>(
        value: modeJauh,
        isExpanded: true,
        dropdownColor: Colors.black,
        underline: const SizedBox(),

        items: const [
          DropdownMenuItem(value: 0, child: Text("NORMAL")),
          DropdownMenuItem(value: 1, child: Text("MEDIUM")),
          DropdownMenuItem(value: 2, child: Text("BRUTAL")),
        ],

        onChanged: (v) {
          setState(() => modeJauh = v!);

          // 🔥 kirim ke ESP
          sendBT("MJ$modeJauh");
        },
      ),
    ),
  ],
),
              const SizedBox(height: 10),

              // ===== CARD =====

const SizedBox(height: 20),

GridView.count(
  crossAxisCount: 2,
  shrinkWrap: true,
  physics: const NeverScrollableScrollPhysics(),
children: [

  // ===== FOGLAMP =====
  menuCard("FOGLAMP", Icons.lightbulb, () {
    showModalBottomSheet(
      context: context,
      builder: (_) => StatefulBuilder(
        builder: (context, setModalState) {
          return buildLampBox("fog", fog, setModalState);
        },
      ),
    );
  }),

  // ===== DEKAT =====
  menuCard("DEKAT", Icons.highlight, () {
    showModalBottomSheet(
      context: context,
      builder: (_) => StatefulBuilder(
        builder: (context, setModalState) {
          return buildLampBox("dekat", dekat, setModalState);
        },
      ),
    );
  }),

  // ===== JAUH =====
  menuCard("JAUH", Icons.flash_on, () {
    showModalBottomSheet(
      context: context,
      builder: (_) => StatefulBuilder(
        builder: (context, setModalState) {
          return buildLampBox("jauh", jauh, setModalState);
        },
      ),
    );
  }),

  // ===== WELCOME =====
  menuCard("WELCOME", Icons.auto_awesome, () {
    showModalBottomSheet(
      context: context,
      builder: (_) => Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const SizedBox(height: 10),
          const Text("PILIH WELCOME",
              style: TextStyle(color: Colors.white)),

          Padding(
            padding: const EdgeInsets.all(12),
            child: DropdownButton<int>(
              value: welcome,
              isExpanded: true,
              dropdownColor: Colors.black,
              items: List.generate(31, (i) {
                return DropdownMenuItem(
                  value: i,
                  child: Text(
                    i == 0 ? "OFF" : "M$i",
                    style: const TextStyle(color: Colors.white),
                  ),
                );
              }),
              onChanged: (v) {
                setState(() => welcome = v!);
              },
            ),
          ),

          ElevatedButton(
            onPressed: () {
              sendBT("W$welcome");
              setState(() {});
            },
            child: const Text("SAVE"),
          ),

          const SizedBox(height: 20),
        ],
      ),
    );
  }),

],
),

const SizedBox(height: 20),


panel("BLUETOOTH SETTINGS", Icons.bluetooth, Column(
  children: [

    TextField(
      style: const TextStyle(color: Colors.white),
      decoration: const InputDecoration(
        labelText: "DEVICE NAME",
        labelStyle: TextStyle(color: Colors.white),
      ),
      onChanged: (v) => btName = v,
    ),

    const SizedBox(height: 10),

    ElevatedButton(
      onPressed: () {
        sendBT("BTNAME:$btName");
      },
      child: const Text("SAVE NAME"),
    )
  ],
),
),
              const SizedBox(height: 30),
            ],
          ),
        ), // Column
      ),   // SingleChildScrollView
    ),     // SafeArea
  );
}
}